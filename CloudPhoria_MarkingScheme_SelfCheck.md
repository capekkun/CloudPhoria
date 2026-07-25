# CloudPhoria — Marking Scheme Self-Check

> Drafting aid only — not referenced by the project, safe to delete anytime, does not affect the build. This checks your project against the marking criteria in your screenshot (Report: Introduction, Storyboard & Requirement Specification, Design & Modelling, Implementation & Discussion, Conclusion/Formatting — and Website: Web Page Layout, User Authentication & Authorization, Dynamic Content, Insert/Update/Delete Records, Form Validation/Navigation/Usability). Each item is checked against your actual code/docs, not assumed.

**Legend:** ✅ Satisfied (code/docs exist and work) — ⚠️ Partially satisfied (exists but has a gap) — ❌ Not yet satisfied (needs work before submission)

---

## REPORT criteria

### Introduction — targeting "Comprehensive and engaging introduction, well-articulated goals and objectives"

✅ **Satisfied**, if you use what's already drafted for you.

`CloudPhoria_AssignmentReport.md` Section 2 has a full Introduction/Project Plan draft: objectives, scope (in-scope vs explicitly out-of-scope features with reasoning), and a project schedule table. This is genuinely comprehensive — it covers 6 distinct objectives and a clear in-scope/out-of-scope boundary (e.g. why Consultation booking was removed).

**What you still need to do:** copy this into your actual Word document and rewrite it in your own voice/tense — right now it reads as drafting notes, not finished prose. A marker giving 9-10 wants to see confident, polished writing, not a checklist.

---

### Storyboard and Requirement Specification — targeting "Comprehensive storyboard with clear user flow; requirements are precise, detailed, and well-documented"

⚠️ **Partially satisfied.**

What exists and is strong:
- `CloudPhoria_UseCases_Student.md` — a full, code-verified Use Case Specification table for every Student use case (Login, Register, Enroll, Complete SubTopic, Take Exam, Join Classroom, Submit Assignment, Join Challenge, Battle Boss Fight, View Achievements, Upgrade, Profile, File a Report, Notifications, Logout) with Actors/Precondition/Main Flow/Alternative Flows for each — this is exactly what "requirements are precise, detailed, and well-documented" is asking for.
- A UML Use Case Diagram (PlantUML) with correctly-justified `<<include>>`/`<<extend>>` relationships.
- `CloudPhoria_Flowchart_Student.md` — 7 flowcharts covering the full Student user flow (auth, learning pathway, exam, classroom, challenges, boss fight, account) plus one simplified overview flowchart.
- `CloudPhoria_UseCase_Audit.md` and `CloudPhoria_UseCase_Student_Audit.md` — a genuine audit trail showing you (and Kiro) caught and fixed 13+7 real logic errors in the use case model by checking it against actual code, which is a strong signal of rigor if you reference this process in your report.

**Gap:** you only have the Student module's use cases/flowcharts done to this depth. Your assignment likely needs Instructor and Admin use cases too (the earlier cross-role audit `CloudPhoria_UseCase_Audit.md` has draft versions, but they weren't put through the same focused correction pass as the Student ones were). If your brief requires storyboards/use cases for all three roles, this is currently incomplete for Instructor/Admin.

**Action:** ask for the same corrected treatment (audit + tables + diagram) for Instructor and Admin, then assemble all three into one Requirement Specification section.

---

### Design & Modelling — targeting "Fully developed, accurate, and efficient design with detailed modeling"

✅ **Satisfied**, with one accuracy correction needed.

- `CloudPhoria_ERD_UsedTables.md` has a full, **verified-against-the-live-database** ERD: 46 of 57 real tables are actually used in code, with a Mermaid ERD diagram covering only the used tables, grouped by feature area, plus real row counts pulled directly from SQL Server.
- `CloudPhoria_DataSchema.md` has the full 52-57 table schema documentation (columns, types, FKs, constraints) — this is thorough.

**Correction needed before you submit:** `CloudPhoria_DataSchema.md` still says "52 tables" in its Table Summary, but the live database actually has 57 (5 tables — `ChallengeQuestions`, `ChallengeQuestionOptions`, `ClassroomMessages`, `FunRoomQuestions`, `FunRoomQuestionOptions` — exist in the database and are missing from that doc). If a marker cross-checks your ERD against your actual SQL Server database (which they might, given the marking scheme explicitly covers database work), a mismatch here would cost marks for "accurate" modelling. Fix this before submission — I can update `CloudPhoria_DataSchema.md`'s table count and list if you want.

- Wireframes/navigational structure: `CloudPhoria_AssignmentReport.md` Section 4.2/4.3 has a text-based layout description and a full site map by role, but **no actual visual wireframe images** — you still need to either screenshot real pages or sketch box-diagrams and insert them as images. This is called out already in that file as a to-do.

---

### Implementation & Discussion — targeting "Fully implemented system with thorough and critical discussion"

✅ **Satisfied for the Student module**, gap for Instructor/Admin.

`CloudPhoria_Student_Implementation.md` gives you a complete, code-verified Implementation write-up for the Module Exam feature: 4 real SQL snippets (eligibility checks, transactional writes, duplicate-XP prevention), form validation (client + server-side), and CSS examples — each with an explanation prompt so you write it critically rather than just pasting code.

**Gap:** this only covers one feature (Module Exam) in the Student module. "Fully implemented system... thorough... discussion" at the 9-10 band likely expects coverage of multiple features across all three roles (e.g. Instructor's classroom/assignment grading, Admin's content management with the instructor-assignment cascade). Right now you have deep coverage of one feature and shallower coverage everywhere else.

**Action:** if you want the same treatment for 2-3 more features (e.g. Admin's "Assign Instructor to Module" cascade — genuinely interesting to discuss since it updates 5 tables in one transaction — or Instructor's assignment grading), ask and I'll produce the same style of document.

---

### Conclusion, Document Styles & Formatting — targeting "High-quality formatting and well-structured, insightful conclusion"

❌ **Not yet satisfied — this doesn't exist yet.**

None of the drafted documents include a Conclusion section. This is entirely up to you to write since it should reflect your own reflection on the project (challenges faced, what you learned, what you'd improve) — genuinely your own voice matters most here and a marker will likely notice if this reads as generated. I'd recommend writing this section yourself rather than asking for a draft. If you want a structure/outline to work from (not the content), ask and I'll give you a skeleton with prompts.

Formatting (headings, consistent styles, ToC) is on you in Word — the section structure in `CloudPhoria_AssignmentReport.md` Section 1 gives you a Table of Contents starting point.

---

## WEBSITE criteria

### Web Page Layout & Appearance — targeting "Outstanding layout with excellent design and usability considerations"

✅ **Satisfied.**

Verified directly: consistent design system across the whole site (`Content/Site.css` variables for colour/spacing/radius), a shared `Site.Master` with role-based navigation, responsive breakpoints (`@media(max-width:768px)` etc.), real uploaded imagery (module backgrounds, dashboard icons, boss fight art, certification images — all confirmed wired up correctly to their database-driven pages), and consistent component patterns (cards, badges, empty-states, progress bars) reused everywhere rather than one-off styling per page.

One thing worth being ready to explain in a viva: the site previously had heavier emoji-as-icon usage which was cleaned up to plain text/SVG icons for a more professional look — if asked, this shows deliberate design iteration.

---

### User Authentication & Authorization — targeting "Robust authentication and authorization with high-level security"

✅ **Satisfied**, with one caveat you should be ready to explain.

Verified: session-based auth (`Session["UserID"]`/`Session["Role"]`) checked on every protected page, `Session.Clear()`/`Session.Abandon()` on logout, banned/inactive account checks at login, instructor licence-approval gating, ownership checks before update/delete (e.g. `WHERE ClassroomID=@CID AND InstructorID=@IID` — an instructor can only touch their own classroom), and all SQL is parameterised (no injection risk).

**Caveat to be upfront about if asked:** `LogIn.aspx.cs` has a documented fallback that accepts plaintext password comparison for seed/demo accounts alongside the real SHA-256 hash check, with a `// TODO: Remove before production deployment` comment already in the code. This is honest, deliberate, and commented — a marker who finds it and asks about it should hear "yes, this is a known limitation for the demo dataset, production accounts would only use the hashed path" rather than being caught off guard. Don't hide this; explaining it well shows security awareness rather than costing marks.

---

### Dynamic Content — targeting "Advanced, highly interactive dynamic content implementation"

✅ **Satisfied.**

Verified interactive, database-driven features beyond basic CRUD: live server-authoritative countdown timers (exams, challenges, boss fights) that can't be tampered with client-side, a drag-and-drop battle UI for Boss Fights, real-time-feeling classroom chat (polling-based), dynamic subscription-based content gating (Free vs Pro), and server-side shuffled question/option ordering per attempt. This is a strong section — the boss fight battle system and the server-side-timer pattern used consistently across three different features (exams/challenges/boss fights) are good things to specifically call out to a marker as "advanced."

---

### Insert, Update & Delete Records — targeting "Optimized, secure, and well-integrated database operations"

✅ **Satisfied.**

Verified: consistent `using` blocks for connection/command disposal, parameterised commands throughout (zero string-concatenated SQL found anywhere in the codebase across this entire session's investigation), multi-table transactional updates where correctness requires it (exam finish, the Admin "Assign Instructor" cascade touching 5 tables, boss fight battle turns), ownership checks before mutating operations, and `IF NOT EXISTS`/duplicate-guard patterns preventing double-inserts (enrollment, XP awarding, subtopic progress).

One thing to mention if your report wants "optimized" specifically: indexes are documented in `CloudPhoria_DataSchema.md` on the columns that matter for these operations (`StudentID`, `ModuleID`, foreign keys used in JOINs), which supports the "optimized" claim rather than just "correct."

---

### Form Validation, Navigation & Usability — targeting "Seamless usability, robust validation, and intuitive navigation"

✅ **Satisfied.**

Verified: ASP.NET validator controls (`RequiredFieldValidator`, `CompareValidator`, `RegularExpressionValidator`) on Register/Login/Classroom-join forms, paired with independent server-side re-validation on every submit handler (never trusts `Page.IsValid` alone for security-sensitive checks like exam eligibility or ownership). Navigation is role-aware (Student/Instructor/Admin/Guest each see a different, appropriate nav menu) and consistent across every page via the shared Master Page.

---

## Overall summary

| Section | Status |
|---|---|
| Introduction | ✅ drafted, needs your own-voice rewrite |
| Storyboard & Requirement Spec | ⚠️ Student done well, Instructor/Admin need the same treatment |
| Design & Modelling | ✅ mostly done, one table-count fix needed in DataSchema doc, wireframe images still needed |
| Implementation & Discussion | ✅ one feature done in depth, more features would strengthen it |
| Conclusion & Formatting | ❌ not started — write this yourself |
| Web Page Layout | ✅ |
| Authentication & Authorization | ✅ (be ready to explain the demo-password fallback) |
| Dynamic Content | ✅ |
| Insert/Update/Delete | ✅ |
| Form Validation/Navigation | ✅ |

**Highest-priority fixes before submission, in order:**
1. Write the Conclusion section yourself (nothing exists yet).
2. Fix the "52 tables" vs actual 57-table mismatch in `CloudPhoria_DataSchema.md`.
3. Decide whether you need Instructor/Admin use cases at the same depth as Student — if yes, ask for it.
4. Get real wireframe/screenshot images into the report (text descriptions alone won't satisfy "storyboard").
5. Rewrite drafted sections (Introduction, Implementation) in your own voice rather than submitting them as-is.

Want me to start on any of these fixes now — the DataSchema table-count correction is quick and I can do it immediately if you'd like.
