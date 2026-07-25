# CloudPhoria — Implementation Section (Student Module)

> Drafting aid only — not referenced by the project, safe to delete anytime, does not affect the build. This covers the "Implementation" requirement from your assignment brief: CSS for styling, form validation, and SQL queries for database connectivity, for the **Student-side Module Exam feature** (the same feature you just demoed). Every snippet below is copied directly from the real files in this project — `Student/Exams.aspx`, `Student/Exams.aspx.cs`, `LogIn.aspx`, `Register.aspx`, and `Content/Site.css`/`Site.Master` — nothing here is invented. Copy the parts you want into your Word report and adjust the surrounding prose to your own voice.

---

## 1. Feature chosen: Module Exam (Student/Exams.aspx)

This feature was chosen for the Implementation write-up because it demonstrates all three required elements clearly in one place: form validation (session/role guards, server-side answer validation), CSS (a live countdown timer, progress states), and non-trivial SQL (multi-step transactional writes, duplicate-prevention checks, parameterised queries throughout).

**What it does:** a logged-in student takes a timed final exam for a module once they've completed all of that module's subtopics. Questions are shown one at a time with shuffled options and a server-authoritative countdown. On completion, the score is calculated, compared against the module's pass mark, and XP is awarded exactly once on a student's first pass.

---

## 2. SQL Queries for Database Connectivity

All database access in this project uses **ADO.NET with `Microsoft.Data.SqlClient`**, and every query is a **parameterised `SqlCommand`** — no string concatenation is ever used to build SQL, which prevents SQL injection. Below are four real snippets from `Student/Exams.aspx.cs` showing the range of query types used.

### 2.1 Checking eligibility before allowing an exam attempt

Before showing the "Start Exam" button, the page runs three separate checks — is it already passed, are all subtopics done, and are there any questions — using parameterised `COUNT(*)` queries and `ExecuteScalar()`:

```csharp
// Already passed?
bool alreadyPassed;
using (SqlCommand cmd = new SqlCommand(
    "SELECT COUNT(*) FROM ExamAttempts WHERE StudentID=@SID AND ModuleID=@MID AND IsPassed=1", conn))
{
    cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
    cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
    alreadyPassed = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
}

// Locked (subtopics not all completed)?
int subtopicCount, completedCount;
using (SqlCommand cmd = new SqlCommand(
    "SELECT COUNT(*) FROM SubTopics WHERE ModuleID=@MID AND IsPublished=1", conn))
{
    cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
    subtopicCount = Convert.ToInt32(cmd.ExecuteScalar());
}
using (SqlCommand cmd = new SqlCommand(
    @"SELECT COUNT(*) FROM SubTopicProgress stp
      INNER JOIN SubTopics st ON st.SubTopicID = stp.SubTopicID
      WHERE st.ModuleID=@MID AND stp.StudentID=@SID AND stp.Status='Completed'", conn))
{
    cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
    cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
    completedCount = Convert.ToInt32(cmd.ExecuteScalar());
}
```

**Why this matters:** the exam is only unlocked when `completedCount == subtopicCount` — this is enforced entirely server-side, so a student cannot bypass the requirement by navigating directly to the exam URL.

### 2.2 Starting an attempt and capturing a server-side timestamp

When "Start Exam" is clicked, a new `ExamAttempts` row is inserted, and the server reads back its own generated ID and start time using `OUTPUT INSERTED`:

```csharp
using (SqlCommand cmd = new SqlCommand(
    @"INSERT INTO ExamAttempts (StudentID, ModuleID, StartedAt, IsPassed, XPAwarded)
      OUTPUT INSERTED.ExamAttemptID, INSERTED.StartedAt
      VALUES (@SID, @MID, GETDATE(), 0, 0)", conn))
{
    cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
    cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
    using (SqlDataReader rdr = cmd.ExecuteReader())
    {
        rdr.Read();
        attemptID = Convert.ToInt32(rdr["ExamAttemptID"]);
        startedAt = Convert.ToDateTime(rdr["StartedAt"]);
    }
}
```

**Why this matters:** `StartedAt` comes from the database server (`GETDATE()`), not from the browser's clock. The remaining time for the countdown is recalculated on every postback from this stored timestamp, so a student cannot cheat the timer by editing client-side JavaScript.

### 2.3 Validating an answer against the correct option, server-side

When a student submits an answer, the app checks correctness by querying the database — the correct answer is never sent to the browser at any point during the exam:

```csharp
if (selectedOptionID > 0)
{
    // The option must actually belong to the current question —
    // prevents a tampered request from scoring against a different question.
    using (SqlCommand cmd = new SqlCommand(
        "SELECT IsCorrect FROM ExamQuestionOptions WHERE OptionID=@OID AND ExamQuestionID=@QID", conn))
    {
        cmd.Parameters.Add("@OID", SqlDbType.Int).Value = selectedOptionID;
        cmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
        object r = cmd.ExecuteScalar();
        isCorrect = (r != null && Convert.ToBoolean(r));
    }
}

using (SqlCommand cmd = new SqlCommand(
    @"INSERT INTO ExamAnswers (ExamAttemptID, ExamQuestionID, SelectedOptionID, IsCorrect)
      VALUES (@AID, @QID, @OID, @Correct)", conn))
{
    cmd.Parameters.Add("@AID", SqlDbType.Int).Value = attemptID;
    cmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
    cmd.Parameters.Add("@OID", SqlDbType.Int).Value = selectedOptionID > 0 ? (object)selectedOptionID : DBNull.Value;
    cmd.Parameters.Add("@Correct", SqlDbType.Bit).Value = isCorrect;
    cmd.ExecuteNonQuery();
}
```

### 2.4 Finishing the exam: a transaction with a duplicate-XP guard

On the last question (or on timeout), the final score is written and XP is awarded — all inside a single `SqlTransaction`, so either everything succeeds together or nothing is saved:

```csharp
using (SqlTransaction tx = conn.BeginTransaction())
{
    using (SqlCommand cmd = new SqlCommand(
        @"UPDATE ExamAttempts SET SubmittedAt=GETDATE(), ScorePercent=@Score,
                                   IsPassed=@Passed, XPAwarded=@XP
          WHERE ExamAttemptID=@AID", conn, tx))
    {
        cmd.Parameters.Add("@Score", SqlDbType.Decimal).Value = scorePercent;
        cmd.Parameters.Add("@Passed", SqlDbType.Bit).Value = isPassed;
        cmd.Parameters.Add("@XP", SqlDbType.Int).Value = xpAwarded;
        cmd.Parameters.Add("@AID", SqlDbType.Int).Value = attemptID;
        cmd.ExecuteNonQuery();
    }

    if (isPassed && xpAwarded > 0)
    {
        // Only award XP if this is the student's FIRST pass of this module —
        // prevents earning XP repeatedly by retaking an already-passed exam.
        int priorPasses;
        using (SqlCommand cmd = new SqlCommand(
            @"SELECT COUNT(*) FROM ExamAttempts
              WHERE StudentID=@SID AND ModuleID=@MID AND IsPassed=1 AND ExamAttemptID<>@AID", conn, tx))
        {
            cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
            cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
            cmd.Parameters.Add("@AID", SqlDbType.Int).Value = attemptID;
            priorPasses = Convert.ToInt32(cmd.ExecuteScalar());
        }

        if (priorPasses == 0)
        {
            using (SqlCommand cmd = new SqlCommand(
                @"INSERT INTO XPTransactions (StudentID, SourceType, SourceID, XPAmount, CreatedAt)
                  VALUES (@SID, 'ModuleExam', @MID, @XP, GETDATE())", conn, tx))
            {
                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                cmd.Parameters.Add("@XP", SqlDbType.Int).Value = xpAwarded;
                cmd.ExecuteNonQuery();
            }

            using (SqlCommand cmd = new SqlCommand(
                "UPDATE Students SET TotalXP = TotalXP + @XP WHERE StudentID=@SID", conn, tx))
            {
                cmd.Parameters.Add("@XP", SqlDbType.Int).Value = xpAwarded;
                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                cmd.ExecuteNonQuery();
            }
        }
    }

    tx.Commit();
}
```

**Explain in your own words for the report:** "A transaction guarantees the score update, the XP ledger entry, and the student's running total all succeed or fail together — if any step throws an exception, the whole update rolls back, so the database never ends up with a passed exam but no matching XP record, or vice versa."

---

## 3. Form Validation

CloudPhoria uses **two layers of validation** consistently: ASP.NET validator controls for immediate client-side feedback, and server-side checks that re-verify everything before touching the database (since client-side validation can always be bypassed).

### 3.1 Client-side: ASP.NET validator controls (from Register.aspx)

```html
<asp:TextBox ID="txtEmail" runat="server" CssClass="cp-reg-input" TextMode="Email"
    placeholder="you@example.com" MaxLength="100" />
<asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
    CssClass="cp-reg-error" ErrorMessage="Email is required." Display="Dynamic" />

<asp:TextBox ID="txtPassword" runat="server" CssClass="cp-reg-input" TextMode="Password"
    placeholder="Min 6 characters" MaxLength="256" />
<asp:RequiredFieldValidator ID="rfvPass" runat="server" ControlToValidate="txtPassword"
    CssClass="cp-reg-error" ErrorMessage="Password is required." Display="Dynamic" />

<asp:TextBox ID="txtConfirm" runat="server" CssClass="cp-reg-input" TextMode="Password"
    placeholder="Repeat password" MaxLength="256" />
<asp:CompareValidator ID="cvPass" runat="server" ControlToValidate="txtConfirm"
    ControlToCompare="txtPassword" CssClass="cp-reg-error"
    ErrorMessage="Passwords do not match." Display="Dynamic" />
```

From `LogIn.aspx`, a `RegularExpressionValidator` checks the email format before the form can even submit:

```html
<asp:RegularExpressionValidator
    ID="revEmail"
    runat="server"
    ControlToValidate="txtEmail"
    CssClass="cp-field-error"
    ErrorMessage="Please enter a valid email address."
    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
    Display="Dynamic"
    EnableClientScript="true" />
```

### 3.2 Server-side: re-checking everything before it touches the database

Every protected Student page starts with the same session/role guard — this runs on the server regardless of what the client sent, so a manipulated request can't skip authentication:

```csharp
protected void Page_Load(object sender, EventArgs e)
{
    if (Session["UserID"] == null || Session["Role"] == null ||
        Session["Role"].ToString() != "Student")
    {
        Response.Redirect("~/LogIn.aspx", true);
        return;
    }
    ...
}
```

And in `LogIn.aspx.cs`, even though client-side validators already checked the fields, the server independently re-validates before ever touching the database:

```csharp
protected void btnLogin_Click(object sender, EventArgs e)
{
    // Web Forms validators run before the event handler.
    // If client validation was bypassed, stop here.
    if (!Page.IsValid) { return; }

    string email    = txtEmail.Text.Trim().ToLowerInvariant();
    string password = txtPassword.Text; // Do NOT trim passwords.

    if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
    {
        ShowError("Please enter your email and password.");
        return;
    }

    AuthenticateUser(email, password);
}
```

**Explain in your own words for the report:** "Client-side validators improve user experience by giving instant feedback, but they run in the browser and can be disabled or bypassed. The server repeats the same checks — and adds checks the client can't do at all, like whether the account is banned or whether an exam is actually unlocked — before any data is written."

---

## 4. CSS for Web Page Styling

CloudPhoria is built on **Bootstrap 5** as a base grid/utility framework, layered with a custom design system defined in `Content/Site.css` and page-specific `<style>` blocks. Below are two real examples relevant to the exam feature and the shared login form.

### 4.1 Live countdown timer colour change (Student/Exams.aspx)

```css
.battle-timer { font-size:22px; font-weight:800; color:#F59E0B; font-variant-numeric:tabular-nums; }
```
```javascript
if (remaining <= 5) display.style.color = '#EF4444';   // turns red under 5 seconds
```

**Explain in your own words:** "`font-variant-numeric: tabular-nums` keeps each digit the same width, so the countdown doesn't visually jitter as the numbers change every second. The colour switches from amber to red in the last 5 seconds as an urgency cue."

### 4.2 Login form styling (LogIn.aspx)

```css
.cp-login-box {
    background: #FFFFFF;
    border-radius: 18px;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.35);
    width: 100%;
    max-width: 420px;
    overflow: hidden;
}

.cp-login-input {
    display: block;
    width: 100%;
    padding: 10px 14px;
    font-size: 14px;
    background: #F4F7FB;
    border: 1.5px solid #E2E8F0;
    border-radius: 9px;
    transition: border-color 0.15s, box-shadow 0.15s;
}
.cp-login-input:focus {
    outline: none;
    border-color: #0EA5E9;
    box-shadow: 0 0 0 3px rgba(14,165,233,0.12);
    background: #FFFFFF;
}
.cp-login-input.input-error {
    border-color: #EF4444;
}
```

**Explain in your own words:** "The `:focus` state adds a soft blue glow (`box-shadow`) around the active input for accessibility and visual feedback, matching the site's primary brand colour. The `.input-error` class swaps the border to red when server-side validation fails, giving a consistent visual language for valid vs invalid fields across the whole site."

---

## 5. Summary Table (optional — use if your brief wants a quick overview)

| Requirement | Where it's shown |
|---|---|
| SQL for database connectivity | Section 2 — 4 real parameterised query examples from `Exams.aspx.cs`, including a multi-step transaction |
| Form validation | Section 3 — client-side validator controls (`RequiredFieldValidator`, `CompareValidator`, `RegularExpressionValidator`) + server-side session/role guards and re-validation |
| CSS for styling | Section 4 — countdown timer styling and login form input states |

---

## 6. A note on presenting this well (not just copy-pasting)

Markers usually want to see that you **understand** the code, not just that it exists. For each snippet you use in your report:
1. State what it does in plain English first.
2. Then show the code.
3. Then explain *why* it's written that way (the "Explain in your own words" lines above are a starting point — rephrase them so they sound like you, not like a template).

Avoid just pasting a wall of code with no commentary — a short paragraph before/after each snippet is what turns "I found this in my project" into "I understand what my project does."
