# CloudPhoria — Implementation Section (Student Module)

> Drafting aid only — safe to delete, doesn't affect the build. Snippets are real, copied from the project. Rewrite in your own voice before submitting.

Brief: *"Provide a detailed explanation of the source code of the major web application features. This includes CSS for web page styling, form validation, and SQL queries for database connectivity."*

This document is organised around exactly those three elements, demonstrated across three major Student features: **Module Exam**, **Boss Fight battle**, and the **Achievement system (Badges & Certifications)**.

---

## 1. SQL Queries for Database Connectivity

All access uses **ADO.NET with `Microsoft.Data.SqlClient`**; every query is a parameterised `SqlCommand` — no string concatenation is used to build SQL anywhere in the project.

### 1.1 Module Exam — eligibility, tamper-resistant timer, transactional finish

Eligibility is re-checked server-side on every load, so a student can't reach a locked exam by guessing the URL:
```csharp
using (SqlCommand cmd = new SqlCommand(
    "SELECT COUNT(*) FROM ExamAttempts WHERE StudentID=@SID AND ModuleID=@MID AND IsPassed=1", conn))
{ alreadyPassed = Convert.ToInt32(cmd.ExecuteScalar()) > 0; }
```

The countdown is server-authoritative — `StartedAt` is written by `GETDATE()` on the database, and remaining time is recomputed from that stored value on every postback, so editing the browser timer has no effect:
```csharp
if (GetRemainingSeconds() <= 0) { FinishExam(true); return; } // re-checked after every answer too
```

Answer correctness is decided by a database lookup at submission time — the correct option is never sent to or stored in the browser:
```csharp
"SELECT IsCorrect FROM ExamQuestionOptions WHERE OptionID=@OID AND ExamQuestionID=@QID"
```

Finishing the exam runs inside a transaction, so the score, XP, and badge either all succeed or all roll back together:
```csharp
using (SqlTransaction tx = conn.BeginTransaction())
{
    // UPDATE ExamAttempts SET ScorePercent=@Score, IsPassed=@Passed, XPAwarded=@XP ...
    if (isPassed && priorPasses == 0) { /* INSERT XPTransactions; UPDATE Students.TotalXP */ }
    if (isPassed) { /* INSERT UserBadges ... WHERE NOT EXISTS (already has it) */ }
    tx.Commit();
}
```
Without the transaction, a crash between the score update and the XP insert could leave a passed exam with no matching reward — an inconsistency that would be very hard to notice or repair later.

### 1.2 Boss Fight — server-tracked combat state

HP is calculated and persisted server-side on every turn; the drag-and-drop UI only ever reflects it, never calculates it:
```csharp
bossHP   = Math.Max(0, bossHP   - dmgToBoss);
playerHP = Math.Max(0, playerHP - dmgToPlayer);
// UPDATE BattleSessions SET BossCurrentHP=@BHP, PlayerCurrentHP=@PHP WHERE SessionID=@SID
```
`Math.Max(0, ...)` stops HP going negative, which would otherwise break the health bar's width calculation. Saving before the page re-renders means refreshing mid-battle can never desync the displayed HP from the database's real HP. Ending the battle reuses the exact same transaction pattern as the exam (update outcome, then reward ledger, commit together) — a deliberate reuse of a proven pattern rather than writing bespoke logic twice.

### 1.3 Achievement system — a real bug, found and fixed (the deepest SQL in this project)

`Badges`, `UserBadges`, `Certifications`, and `UserCertifications` were fully designed and seeded (28 badges, one per module), and `Achievements.aspx`/`PathwayDetail.aspx` already had working display and "already earned?" read logic. But no code anywhere in the application ever executed an `INSERT INTO UserBadges` or `UserCertifications` — the write path simply didn't exist. A student could pass every exam in a pathway and their Achievements page would permanently show zero. This is exactly the kind of gap that's easy to miss during development, because every *other* part of the feature looks finished: schema correct, UI correct, read queries correct. Only the write path was missing, invisible until you actually play through the app as a student and notice the count never moves.

The fix — badge award, guarded against duplicates by the `UNIQUE(StudentID, BadgeID)` constraint:
```csharp
INSERT INTO UserBadges (StudentID, BadgeID, AwardedAt)
SELECT @SID, b.BadgeID, GETDATE() FROM Badges b
WHERE b.ModuleID = @MID
  AND NOT EXISTS (SELECT 1 FROM UserBadges ub WHERE ub.StudentID=@SID AND ub.BadgeID=b.BadgeID)
```

Certification is more interesting technically because it's a *cross-module* condition — only true once every module in the pathway has been passed, not just the one just finished:
```sql
INSERT INTO UserCertifications (StudentID, CertificationID, IssuedAt)
SELECT @SID, c.CertificationID, GETDATE() FROM Certifications c
INNER JOIN Modules m ON m.PathwayID = c.PathwayID
WHERE m.ModuleID = @MID
  AND NOT EXISTS (SELECT 1 FROM UserCertifications uc WHERE uc.StudentID=@SID AND uc.CertificationID=c.CertificationID)
  AND NOT EXISTS (                                  -- any unpassed published module blocks the award
      SELECT 1 FROM Modules m2 WHERE m2.PathwayID=c.PathwayID AND m2.IsPublished=1
        AND NOT EXISTS (SELECT 1 FROM ExamAttempts ea2 WHERE ea2.StudentID=@SID AND ea2.ModuleID=m2.ModuleID AND ea2.IsPassed=1)
  )
```
The double `NOT EXISTS` expresses "all modules must be passed" in SQL, which has no direct `FOR ALL` operator — it reads as "award unless there exists a module not yet passed." This runs after *every* exam pass rather than only on the last module, since the trigger has no way to know in advance which module will turn out to be the student's last one; checking unconditionally and letting the guards no-op until the condition is genuinely true is simpler than detecting "is this the final module" as a special case.

Because this bug existed while the app was already in use, students who'd already passed every module in a pathway before the fix had no certification recorded, requiring a one-off backfill query — deliberately near-identical to the live-award query above — to retroactively award what they'd already earned. Worth naming as a trade-off: the same eligibility logic now exists in two places; a cleaner long-term design would extract it into one shared stored procedure rather than duplicating the SQL.

---

## 2. Form Validation

Two layers throughout the project: ASP.NET validator controls for immediate client-side feedback, and independent server-side re-verification before anything touches the database, since client-side checks can always be bypassed.

**Client-side (Register.aspx / LogIn.aspx):**
```html
<asp:RequiredFieldValidator ControlToValidate="txtPassword" ErrorMessage="Password is required." />
<asp:CompareValidator ControlToValidate="txtConfirm" ControlToCompare="txtPassword" ErrorMessage="Passwords do not match." />
<asp:RegularExpressionValidator ControlToValidate="txtEmail" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" />
```

**Server-side session/role guard**, repeated at the top of every protected Student page — this is the check client-side validators cannot provide, since they can't stop someone typing a URL directly into the address bar:
```csharp
if (Session["UserID"] == null || Session["Role"]?.ToString() != "Student")
{ Response.Redirect("~/LogIn.aspx", true); return; }
```

**Business-rule validation specific to the Exam feature:** the exam's own answer-submission handler re-validates that the submitted `OptionID` genuinely belongs to the current question (shown in §1.1) before scoring it — a check that has nothing to do with ASP.NET validator controls, but is exactly the kind of server-side re-verification this criterion is looking for beyond simple required-field checks.

**Password hashing, kept consistent between registration and login:** passwords are never stored in plaintext. `Register.aspx.cs` hashes with SHA-256 before the `INSERT`, and `LogIn.aspx.cs` calls the exact same shared method to verify — one implementation, used in both places, rather than two copies that could drift out of sync:
```csharp
public static string ComputeSHA256(string plainText)
{
    using (SHA256 sha = SHA256.Create())
    {
        byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(plainText));
        // ... converted to a hex string, stored in PasswordHash
    }
}
```
```csharp
cmd.Parameters.Add("@Pass", SqlDbType.NVarChar, 256).Value = Utils.ComputeSHA256(password);
```

**Format validation on registration, both layers:** the original build only checked that Full Name, Email, and Password were *not empty* — a value like `"aaaaaa"` passed as a valid name, and any 6-character string passed as a password. Deliberately testing with junk input surfaced this, so both layers were tightened:
```html
<asp:RegularExpressionValidator ControlToValidate="txtFullName"
    ValidationExpression="^[A-Za-z]+([ '\-][A-Za-z]+)+$"
    ErrorMessage="Enter your full name (letters and spaces, at least 2 words)." />
<asp:RegularExpressionValidator ControlToValidate="txtPassword"
    ValidationExpression="^(?=.*[A-Za-z])(?=.*\d).{6,}$"
    ErrorMessage="Password must be at least 6 characters and include a letter and a number." />
```
```csharp
// Register.aspx.cs — re-checked server-side, since client validators can be bypassed
if (!Regex.IsMatch(fullName, @"^[A-Za-z]+([ '\-][A-Za-z]+)+$")) { ShowError("..."); return; }
if (!Regex.IsMatch(password, @"^(?=.*[A-Za-z])(?=.*\d).{6,}$")) { ShowError("..."); return; }
```

**A second gap, found and closed the same way:** `Admin/Courses.aspx.cs` parsed numeric fields (XP reward, exam pass-mark %) with `int.TryParse(...)` defaulting to `0` on failure, so an out-of-range value like `-500` or `9999%` was silently saved instead of rejected. Fixed with `RangeValidator` controls on each field (`MinimumValue="0" MaximumValue="100"` for pass mark, similar bounds for XP and exam duration).

Both gaps were found the same way — deliberately testing invalid input (empty forms, junk strings, negative numbers, duplicate emails) rather than only the happy path. That is the practical difference between "my form has validators" and "my validation holds up under testing."

---

## 3. CSS for Web Page Styling

CloudPhoria is built on **Bootstrap 5** as a base grid/utility framework, layered with a custom design system in `Content/Site.css` and page-specific `<style>` blocks.

**Module Exam — live countdown timer:**
```css
.battle-timer { font-size:22px; font-weight:800; color:#F59E0B; font-variant-numeric:tabular-nums; }
```
```javascript
if (remaining <= 5) display.style.color = '#EF4444'; // turns red under 5 seconds remaining
```
`font-variant-numeric: tabular-nums` keeps every digit the same fixed width, so the countdown doesn't visually jitter as the numbers change each second. The colour switch from amber to red is a deliberate urgency cue, not just decoration.

**Boss Fight — server-driven HP bars:**
```css
.boss-hp-bar-wrap { background:rgba(255,255,255,0.08); border-radius:4px; height:6px; margin:10px 0; }
.boss-hp-bar      { height:100%; border-radius:4px; background-color:#EF4444; transition:width 0.3s; }
```
```csharp
bossHPBar.Style["width"] = ((bossHP * 100) / Math.Max(1, bossMax)) + "%";
```
The width percentage is computed entirely server-side and written straight into the `style` attribute — there is no client-side JavaScript recalculating HP, which means the displayed bar can never disagree with the database's `BossCurrentHP` value. `Math.Max(1, bossMax)` in the denominator is a small defensive touch avoiding a divide-by-zero if a boss were ever configured with 0 max HP. The `transition:width 0.3s` gives the HP change a smooth animated feel without any JavaScript animation code.

---

## 4. Optimisation note (supports "database operations" being optimized, not just correct)

The queries above are backed by explicit indexes documented in `CloudPhoria_DataSchema.md`: `ExamAttempts.StudentID`, `ExamAttempts.ModuleID`, `XPTransactions.StudentID`, `Modules.PathwayID`. These are exactly the columns used in the `WHERE`/`JOIN` clauses of every query shown above — without them, each lookup would become a full table scan as the tables grow with more students and attempts.

---

## 5. Mapping to the brief

| Brief requirement | Satisfied by |
|---|---|
| Detailed explanation of source code of major features | §1–3 across three features: Module Exam, Boss Fight, Achievement system |
| CSS for web page styling | §3 — countdown timer and server-driven HP bar, both explained (not just shown) |
| Form validation | §2 — client validators, server guards, business-rule re-validation, and two real gaps found by testing invalid input and then fixed |
| SQL queries for database connectivity | §1 — parameterised queries, two multi-table transactions, one cross-module eligibility query, plus a real bug found/fixed/backfilled |

**Presenting this well:** for every snippet, say what it does in plain English first, show the code, then explain *why* it's written that way — in your own words, not this template's. §1.3 (the achievement bug) is the single highest-impact part of this document: a marker reading "here is a bug I found in my own system, why it happened, and how I fixed and backfilled it" is seeing genuine understanding of the source code, which is precisely what "detailed explanation" is asking for — not just that the code exists, but that you know why it works the way it does.
