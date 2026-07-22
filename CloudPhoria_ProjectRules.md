# CloudPhoria Project Rules

> **Project:** CloudPhoria  
> **Module:** CT050-3-2-WAPP  
> **Purpose:** This document is the main development rulebook for the CloudPhoria ASP.NET Web Forms project.

## 0. CURRENT STATE SNAPSHOT (Read This First)

This document grew over many development sessions and contains historical notes describing earlier versions of the project (30-page budget, single-tab Admin dashboard, restricted guest access, etc.) that are explicitly marked as superseded where they still exist. If you are a Kiro instance picking up this project for the first time, read this section first — it tells you what is actually true right now, verified directly against the code on disk, not just what the numbered rule sections say.

**Page count: 38 total** (`.aspx` pages, verified by directory listing).
- Root/Shared: 3 — `Default.aspx` (guest landing page), `LogIn.aspx`, `Register.aspx`
- `Admin/`: 9 — `Dashboard.aspx`, `Users.aspx`, `InstructorApprovals.aspx`, `Courses.aspx`, `Challenges.aspx`, `Reports.aspx`, `AuditLogs.aspx`, `Notifications.aspx`, `Profile.aspx`
- `Instructor/`: 10 — `Dashboard.aspx`, `Modules.aspx`, `SubTopics.aspx`, `Questions.aspx`, `Classrooms.aspx`, `Materials.aspx`, `Assignments.aspx`, `Challenges.aspx`, `Notifications.aspx`, `Profile.aspx`
- `Student/`: 16 — `Dashboard.aspx`, `Pathways.aspx`, `PathwayDetail.aspx`, `ModuleDetail.aspx`, `SubTopicView.aspx`, `MyLearning.aspx`, `Exams.aspx`, `Challenges.aspx`, `BossFights.aspx`, `Classrooms.aspx`, `ClassroomDetail.aspx`, `AssignmentDetail.aspx`, `Achievements.aspx`, `Notifications.aspx`, `Profile.aspx`, `Upgrade.aspx`
- Budget is 40 (raised from an original 30 to balance workload: Admin=1 person, Instructor=1 person, Student=2 people). Project currently sits 2 under budget because Consultations (2 pages) was built, then permanently removed again — see Section 44.

**Features permanently REMOVED — do not rebuild without explicit new instruction:**
- Fun Rooms (`FunRooms`, `FunRoomQuestions`, `FunRoomQuestionOptions` — tables exist, unused, no pages)
- Practice Quizzes / practice-taking UI (`PracticeQuestionOptions`, `PracticeAttempts`, `PracticeAnswers` — orphaned; note `PracticeQuestions` itself is NOT fully orphaned, see below)
- Discussions/Forum (`DiscussionThreads`, `DiscussionReplies` — orphaned)
- Consultations (`ConsultationSlots`, `ConsultationBookings` — orphaned; built, deleted, rebuilt, deleted again — see Section 44 for the full history)
- Guest/Learn page, About.aspx, Contact.aspx

**Challenges quiz/leaderboard mechanic — FIXED, now fully functional.** Previously `ChallengeQuestions`/`ChallengeQuestionOptions` existed with seed data but no code used them, and "Join Challenge" went nowhere. Both sides are now built: Instructor/Admin can add MCQ questions to a challenge (`Challenges.aspx?manageQuestions=X`), and students can actually take a challenge (`Student/Challenges.aspx?challengeID=X` — intro screen, timed quiz, server-side scoring, XP award, top-10 leaderboard). See Section 39 "Challenges" subsection for full detail.

**Guest access (current, correct model — Section 40 is authoritative, Section 39's "Guest Access" bullet list is a stale historical note):** Guests (no session) get a nav bar and can browse `Pathways.aspx`, `PathwayDetail.aspx`, `ModuleDetail.aspx`, `SubTopicView.aspx`, `BossFights.aspx`, `Challenges.aspx`, `Upgrade.aspx` read-only — they cannot enrol, answer questions, join battles, or earn XP. Detection pattern used consistently: `bool isGuest = (Session["UserID"] == null || Session["Role"] == null || Session["Role"].ToString() != "Student");` at the top of `Page_Load`.

**Admin scope — intentionally simpler than the original assignment brief** (explicit user decision): Admin manages Users (full CRUD), Instructor Approvals, Courses (assign + publish), Global Challenges, Reports (moderation), Audit Logs. Admin does **NOT** manage subscription pricing (fixed in `Student/Upgrade.aspx` code), does NOT review Fun Rooms (deleted feature), and has NO gamification/XP-formula settings page.

**Content authority — Admin-only Modules/SubTopics/Questions (Changed).** Instructors no longer create/edit/publish/delete Modules, SubTopics, or Questions — only Admin can, via `Admin/Courses.aspx` (top-level module creation + `?moduleID=`/`?subTopicID=` drill-down for subtopics/questions). Instructors only see this content read-only on their own pages, once an Admin assigns a module to them via the existing "Assign Instructor" cascade. See Section 12b for full detail. Instructors keep full control of Classrooms, classroom Materials/Assignments/Challenges, and `LearningMaterials` uploads (Section 21/29) — this change only affects the module/subtopic/question content tree.

**Recently fixed gaps (see Section 39 subsections for detail):**
- Report submission — `Student/Profile.aspx` and `Instructor/Profile.aspx` now have a working "Report an Issue" form that inserts into `Reports` (previously `Admin/Reports.aspx` could only read/update, nothing ever created a report).
- Classroom material upload — `Instructor/Classrooms.aspx` now has upload/list/delete for `ClassroomMaterials` (previously `Student/ClassroomDetail.aspx`'s Files tab could only display materials, nothing ever wrote them).
- Module reassignment cascade — `Admin/Courses.aspx`'s "Assign Instructor" dropdown now cascades ownership to `SubTopics`, `Questions`, `LearningMaterials`, `PracticeQuestions`, `ExamQuestions` in one transaction, instead of only updating `Modules.CreatedByInstructorID` as a cosmetic label.

**When in doubt about whether something is currently true, trust the code over this document, and trust the highest-numbered section discussing a topic over an earlier one** — sections are appended chronologically as the project evolved, and later sections correct earlier ones rather than editing them in place (to preserve the history of *why* decisions were made). This document is intentionally long and cumulative — use Ctrl+F / grep for the feature name you care about rather than reading top to bottom.

## 1. Rule Priority and Source of Truth

Before modifying the project, always read:

1.  `CloudPhoria_ProjectRules.md`
2.  `CloudPhoria_DatabaseSchema.md`
3.  The actual SQL creation and seed scripts
4.  The existing project files affected by the requested change
5.  The latest task instructions from the user

Use the following priority when instructions conflict:

1.  The latest explicit instruction from the user
2.  The actual SQL database schema
3.  `CloudPhoria_DatabaseSchema.md`
4.  `CloudPhoria_ProjectRules.md`
5.  Existing project implementation

The actual database schema is the final source of truth for:

- Table names
- Column names
- Primary keys
- Foreign keys
- Data types
- Nullability
- Check constraints
- Unique constraints
- Supported status values

Do not guess database structures.

Do not invent tables, columns, relationships, roles, status values, or stored procedures unless the user explicitly requests a database change.

## 2. Project Overview

CloudPhoria is a gamified cloud-computing learning platform.

The platform allows students to:

- Explore cloud-computing learning pathways
- Complete modules and subtopics
- Answer interactive lesson questions
- Take unlimited practice quizzes
- Take timed module examinations
- Track module and subtopic progress
- Earn XP, badges, and certifications
- Join instructor-led classrooms
- Complete classroom assignments
- Participate in challenges
- Join community discussions
- Create and explore community Fun Rooms
- Participate in official Boss Fight quiz rooms

CloudPhoria may take general inspiration from structured learning platforms such as TryHackMe, particularly in:

- Guided learning paths
- Progress-based module navigation
- Interactive learning rooms
- Immediate question feedback
- Gamification
- XP and achievement systems
- Clear learning progression

However, CloudPhoria must remain an original cloud-computing platform.

Do not copy:

- TryHackMe branding
- TryHackMe page layouts exactly
- TryHackMe wording
- TryHackMe icons
- TryHackMe illustrations
- TryHackMe assets
- TryHackMe source code

## 3. Technology Stack

CloudPhoria uses:

- ASP.NET Web Forms
- C#
- SQL Server
- ADO.NET
- HTML
- CSS
- JavaScript
- Bootstrap, only where already included or explicitly approved
- Bootstrap Icons, only where already included or explicitly approved

Do not convert the project to:

- ASP.NET MVC
- ASP.NET Core
- Razor Pages
- Blazor
- React
- Angular
- Vue
- Node.js
- Entity Framework
- Any different framework

Do not introduce:

- Repository Pattern
- Dependency Injection
- Microservices
- Complex service layers
- Unnecessary design patterns
- Advanced architecture unsuitable for a Year 2 university Web Forms assignment

Keep the implementation understandable, practical, and explainable during a viva.

## 4. Existing Project Rule

Always modify the existing CloudPhoria project.

Do not:

- Create a new solution
- Create a new project
- Rebuild the application in another framework
- Duplicate existing pages unnecessarily
- Create replacement folders without checking the current structure
- Delete working functionality without explicit permission
- Rename existing project files casually
- change namespaces without checking all affected files

Before creating a new file, check whether the required function can reasonably be added to an existing:

- `.aspx` page
- `.aspx.cs` code-behind file
- Master Page
- CSS file
- JavaScript file
- User Control

New files may only be created when:

- The requested feature genuinely requires one
- No appropriate existing file is available
- The new file follows the current project structure
- The user has not prohibited new files

When the user explicitly says not to create new files, do not create any.

## 5. Main Folder Structure

Use the existing project folder structure.

Expected role folders are:

    Student/
    Instructor/
    Admin/
    Guest/

Shared project files may remain in appropriate existing locations such as:

    App_Code/
    Content/
    Scripts/
    Images/
    uploads/
    Database/

Do not create a `Parent/` folder.

CloudPhoria has only these account roles:

    Student
    Instructor
    Admin

There is no Parent role in the current schema.

## 6. Master Page Rules

CloudPhoria uses:

    Site.Master
    Site.Master.cs

Use `Site.Master` as the shared application layout.

Do not create additional Master Pages unless explicitly requested.

All normal application pages should use `Site.Master` unless there is a clear existing exception, such as:

- A standalone login page
- A special error page
- A print-only page
- Another page explicitly approved by the user

The Master Page should be responsible for shared layout elements such as:

- Sidebar
- Top header
- Logo
- Main navigation
- User profile area
- Notification access
- Main content container
- Mobile sidebar behaviour
- Shared footer, where required
- Shared scripts
- Shared accessibility structure

Do not duplicate the full sidebar or top header inside individual content pages.

Role-specific navigation should be controlled from the Master Page or its code-behind using the authenticated role.

## 7. Database Name and SQL Script Rules

The official database name is:

    CloudPhoria

SQL scripts must use:

    USE CloudPhoria;
    GO

Do not use `CloudPhoriaDB` unless the whole database is officially renamed.

The database scripts must run in this order:

1.  Table creation
2.  Constant or lookup seed data
3.  Dummy or sample data

Do not run seed data before the required tables are created.

Do not silently change the schema to make website code easier.

The website must follow the database, not invent a different database structure.

## 8. Database Naming Conventions

CloudPhoria database objects use PascalCase.

Correct examples:

    Users
    StudentID
    InstructorID
    ModuleID
    SubTopicID
    CreatedAt
    IsPublished
    LicenseStatus

Incorrect examples:

    users
    studentId
    instructor_id
    moduleID
    subtopicid
    created_at

Use the exact names from the schema in:

- SQL queries
- `SqlDataReader` access
- `DataTable` access
- Parameters
- Data binding expressions
- Documentation
- Comments referring to database objects

C# local variables may use normal C# camelCase:

    int studentID;
    string moduleName;
    bool isPublished;

However, SQL columns must retain their real PascalCase names:

    SELECT StudentID, ModuleName, IsPublished

Do not rename database columns in SQL aliases merely to copy conventions from another project unless an alias is genuinely needed for display or aggregation.

## 9. ID and Primary Key Rules

Most CloudPhoria tables use:

    INT IDENTITY(1,1)

Do not generate IDs such as:

    U001
    ST001
    MOD001
    ROOM001

unless the actual schema explicitly uses that format.

Use integer IDs.

CloudPhoria uses a shared-primary-key pattern for role tables:

    Students.StudentID = Users.UserID
    Instructors.InstructorID = Users.UserID
    Admins.AdminID = Users.UserID

When creating a new account:

1.  Insert the account into `Users`
2.  Retrieve the newly created `UserID`
3.  Insert the same ID into the appropriate role table

Use an appropriate method such as:

    SCOPE_IDENTITY()

Do not generate a separate identity value for:

- `Students.StudentID`
- `Instructors.InstructorID`
- `Admins.AdminID`

Do not create an independent Student, Instructor, or Admin record without a matching `Users` record.

## 10. User Roles and Access Control

Supported roles are:

    Student
    Instructor
    Admin

Every protected page must verify:

- A valid user session exists
- The current user has the required role
- The user account is active
- The user account is not banned

Do not depend only on hiding sidebar links.

Access control must also be checked in page code-behind.

Examples:

- A Student must not access Instructor pages by manually typing the URL.
- An Instructor must not access Admin pages by manually typing the URL.
- A guest must not access protected role pages.
- A banned or inactive user must not continue using protected pages.

When access is invalid:

- Redirect to the appropriate login or access-denied page
- Do not expose protected data
- Do not allow the requested action to continue

## 11. Authentication Rules

Authentication uses the `Users` table.

Relevant fields include:

    UserID
    FullName
    Email
    PasswordHash
    Role
    IsActive
    IsBanned

Login must verify:

- The email exists
- The submitted password matches the stored password securely
- `IsActive = 1`
- `IsBanned = 0`
- `Role` is valid

Never store new passwords as plaintext.

Never compare plaintext passwords in production logic.

Use an appropriate secure password hashing approach consistent with the existing project.

The sample database may contain demonstration passwords. That does not mean new account logic should continue storing plaintext passwords.

After successful login, the session should contain at least:

    UserID
    Role

Useful additional session values may include:

    FullName
    StudentID
    InstructorID
    AdminID

Only store additional values when they are actually required.

Do not rely on a display name as the account identifier.

Use `UserID` as the authenticated identity.

## 12. Instructor Approval Rules

Instructor access depends on:

    Instructors.LicenseStatus

Supported values are:

    Pending
    Approved
    Rejected

Only an approved instructor should receive full instructor functionality.

An instructor with `Pending` or `Rejected` status must not be allowed to:

- Publish modules
- Publish subtopics
- Create official learning questions
- Upload official learning materials
- Create or manage normal instructor content
- Access functions reserved for approved instructors

The exact restricted experience should follow the existing project requirement.

Do not invent new license status values.

## 12b. Content Authority — Admin-Only Module/SubTopic/Question Creation (Changed)

**This is a significant authority change from earlier in the project — read carefully before touching Modules, SubTopics, or Questions.**

Previously, Instructors created their own Modules/SubTopics/Questions directly (via `Instructor/Modules.aspx`, `SubTopics.aspx`, `Questions.aspx`), and `CreatedByInstructorID` was set to whoever created the row. The user explicitly changed this: **only Admin may create, edit, publish, or delete Modules, SubTopics, and Questions.** Instructors no longer have create/edit/publish/delete rights over this content tree — they only view whatever has been assigned to them.

**New flow:**
1. Admin creates a Module via `Admin/Courses.aspx` (top-level "Create a New Module" form) — `CreatedByInstructorID` starts as `NULL` (unassigned).
2. Admin drills into that module (`Courses.aspx?moduleID=X`) to create SubTopics — also `CreatedByInstructorID=NULL` initially.
3. Admin drills into a subtopic (`Courses.aspx?subTopicID=X`) to create Questions (MCQ/Regex/StringMatch, same option-entry pattern as the old Instructor page) — also unassigned initially.
4. Admin uses the existing "Assign Instructor" dropdown (Section 43's cascade) to assign the module to an Approved instructor. This cascades `CreatedByInstructorID`/`InstructorID` across `Modules`, `SubTopics`, `Questions`, `LearningMaterials`, `PracticeQuestions`, `ExamQuestions` in one transaction — exactly the mechanism already built for this purpose (Section 43).
5. Only after assignment does the instructor see that content on their (now read-only) `Instructor/Modules.aspx`/`SubTopics.aspx`/`Questions.aspx` pages.

**What Instructor pages became read-only:**
- `Instructor/Modules.aspx` — list only. No "New Module" button, no publish/unpublish, no delete. Links through to `SubTopics.aspx?moduleID=`.
- `Instructor/SubTopics.aspx` — list only, filtered to subtopics whose parent module is assigned to the current instructor (`INNER JOIN Modules m ... WHERE m.CreatedByInstructorID=@ID`, no longer filtered by the subtopic's own `CreatedByInstructorID` since Admin — not the instructor — sets that value). No create/publish/delete. Links through to `Questions.aspx?subTopicID=`.
- `Instructor/Questions.aspx` — list only, same join-through-module filtering pattern. No create/delete.

**What did NOT change (still Instructor-owned, per the user's own wording "and so on" was interpreted as the module/topic/question content tree specifically, not the whole Instructor role):**
- `Instructor/Materials.aspx` — instructors can still upload `LearningMaterials` files to subtopics assigned to them. Ownership check still works because the Assign cascade (step 4 above) sets `SubTopics.CreatedByInstructorID`, which `Materials.aspx`'s ownership check reads.
- `Instructor/Classrooms.aspx`, `Assignments.aspx`, `Challenges.aspx` — classroom-level features (chat, classroom materials, classroom assignments, instructor-created challenges) are unrelated to the Modules/SubTopics/Questions content tree and remain fully instructor-owned, unchanged.

**No schema changes.** `Modules.CreatedByInstructorID`, `SubTopics.CreatedByInstructorID`, `Questions.CreatedByInstructorID` were already nullable/instructor-assignable columns — this change is purely about which role's UI is allowed to write to them, enforced in application code (page-level checks + which pages even expose create/edit/delete controls), not a database constraint.

**Page count impact: none.** No new pages were created. `Admin/Courses.aspx` was extended with the module-creation form plus two query-string drill-down views (`?moduleID=` for subtopics, `?subTopicID=` for questions) — same page, same pattern already used everywhere else in this project (Exams, Challenges, BossFights, Classrooms). The three Instructor pages kept their existing `.aspx` files, just with reduced markup/code (list only). Still 38 pages total.

## 13. Main Learning Structure

The official learning hierarchy is:

    Pathway
      -> Module
          -> SubTopic
              -> LearningMaterials
              -> Questions
                  -> AnswerOptions

Module-level activities include:

    Module
      -> PracticeQuestions
          -> PracticeQuestionOptions

    Module
      -> ExamQuestions
          -> ExamQuestionOptions

    Module
      -> Badge

Do not confuse:

- Inline subtopic questions
- Module practice questions
- Module exam questions
- Assignment questions
- Boss Fight questions

Each has separate tables and a different purpose.

## 14. Learning Path and Progress Rules

Students progress through:

- Pathways
- Modules
- Subtopics

Modules may have:

    PrerequisiteModuleID

A module with an incomplete prerequisite should remain locked when prerequisite enforcement is required.

Only published content should normally be visible to students:

    Modules.IsPublished = 1
    SubTopics.IsPublished = 1

Student progress uses:

    SubTopicProgress
    ModuleProgress

Supported progress status values are:

    NotStarted
    InProgress
    Completed

Do not invent values such as:

    Started
    Done
    Finished
    Locked

A locked state may be calculated for interface display, but it is not a stored progress status unless the database is officially changed.

Progress records must remain unique per student and learning item.

Before inserting a progress record, check whether one already exists or use logic that respects the database unique constraint.

## 15. Interactive Subtopic Questions

Subtopic learning questions use:

    Questions
    AnswerOptions

Supported question types are:

    MCQ
    Regex
    StringMatch

Question handling must depend on `QuestionType`.

For `MCQ`:

- Display options from `AnswerOptions`
- Validate that the selected option belongs to the current question
- Determine correctness using authorised database data

For `Regex`:

- Validate the submitted answer against the stored expected regular expression
- Handle invalid patterns safely
- Do not execute arbitrary code

For `StringMatch`:

- Compare according to the intended matching rules
- Apply trimming or case handling consistently
- Do not silently change the stored expected answer

Do not treat all question types as MCQ.

Do not expose the correct answer in HTML, JavaScript, query strings, hidden fields, or client-side source before submission.

## 16. Practice Quiz Rules

Practice quizzes use:

    PracticeQuestions
    PracticeQuestionOptions
    PracticeAttempts
    PracticeAnswers

Practice is intended for repeated learning.

Practice attempts:

- May be attempted multiple times
- Are not module final examinations
- May support logged-in students
- May support guests through `GuestSessionID`

For logged-in students:

    PracticeAttempts.StudentID

is used.

For guests:

    StudentID = NULL
    GuestSessionID = valid anonymous session identifier

Do not create a fake Student record for a guest.

Do not award normal student XP to a guest unless the database and user requirement explicitly support it.

## 17. Module Exam Rules

**Fixed — the exam-taking flow was previously a stub.** `Student/Exams.aspx.cs` used to have a literal `// TODO: Full exam logic to be re-integrated here` comment where the `?moduleID=X` handling should have been — clicking "Start Exam" just reloaded the same listing page and did nothing. This is now implemented, following the exact same pattern used for Challenges (Section 39) and Boss Fights (Section 41): intro screen (locked/already-passed/no-questions checks) → `btnStartExam_Click` inserts an `ExamAttempts` row and locks in the ordered question list into ViewState → one question at a time with shuffled options and a live countdown → `btnSubmitExamAnswer_Click` validates the answer server-side and inserts into `ExamAnswers` → on the last question (or on timeout), `FinishExam()` computes `ScorePercent`, compares against `Modules.ExamPassMarkPercent`, and awards XP via `XPTransactions`/`Students.TotalXP` in one transaction if passed for the first time. No new page was created — same `.aspx` file, same page count.

Module exams use:

    ExamQuestions
    ExamQuestionOptions
    ExamAttempts
    ExamAnswers

Exam behaviour must use module settings such as:

    Modules.ExamDurationMinutes
    Modules.ExamPassMarkPercent
    Modules.XPReward

Do not hard-code the same duration or pass mark for all modules when the database already stores these values.

Exam rules should include:

- Server-side start time
- Server-side submission time
- Server-side score calculation
- Server-side pass calculation
- Prevention of invalid option submissions
- Handling of expired attempts
- Prevention of duplicate XP awards
- Recording each answer in `ExamAnswers`

The browser timer is a visual aid.

The server-side time is the authority.

Do not trust only JavaScript to enforce examination duration.

Do not send correct-answer information to the browser before submission.

**How the implementation satisfies these rules:** `ExamAttempts.StartedAt` is set server-side (`GETDATE()`) when the attempt is created, not from any client-supplied time. `GetRemainingSeconds()` recomputes `(Modules.ExamDurationMinutes * 60) - DateTime.Now.Subtract(StartedAt).TotalSeconds` on every question load AND every answer submission — the JS countdown (`startExamTimer()`) is purely cosmetic; even if a student's browser clock is wrong, paused, or the JS never runs, the server independently ends the exam once `GetRemainingSeconds() <= 0`. Options are validated with `WHERE OptionID=@OID AND ExamQuestionID=@QID` so a submitted option must actually belong to the current question (prevents cross-question option injection). Correct-answer flags (`IsCorrect`) are never rendered to the option list HTML — only `OptionID`/`OptionText`. Duplicate XP is prevented by checking for a prior passing `ExamAttempts` row (excluding the current one) before awarding — passing the same exam twice only pays XP once.

`XPTransactions` is the XP ledger and the primary record of XP-earning events.

Supported `SourceType` values are:

    SubTopic
    ModuleExam
    Challenge
    FunRoom
    Bonus
    BossFight

Do not invent new source types unless the database constraint is changed.

`SourceID` is a polymorphic reference.

Its meaning depends on `SourceType`.

The database does not enforce a direct foreign key for `SourceID`, so application logic must validate it carefully.

When awarding XP:

1.  Confirm the activity is eligible
2.  Confirm the student has not already received the same one-time reward
3.  Insert an `XPTransactions` row
4.  Update `Students.TotalXP`
5.  Perform related progress or achievement updates
6.  Use one database transaction when these operations belong to one action

`Students.TotalXP` should remain consistent with the XP transaction ledger.

Do not award XP only by changing `Students.TotalXP`.

Do not award the same one-time XP repeatedly because a page is refreshed or a button is clicked twice.

## 19. Badge and Certification Rules

Badges use:

    Badges
    UserBadges

A student cannot earn the same badge more than once.

Before inserting into `UserBadges`, respect the unique relationship:

    StudentID + BadgeID

Certifications use:

    Certifications
    UserCertifications

A student cannot receive the same certification more than once.

Certification eligibility must be calculated from the required pathway or module completion rules.

Do not award a certification merely because a user opens a result page.

Awarding must be tied to verified completion conditions.

## 20. Subscription and Content Access Rules

Subscriptions use:

    SubscriptionPlans
    UserSubscriptions

Access restrictions must be based on active subscription data.

The Free plan may be limited to Foundation content through:

    SubscriptionPlans.CanAccessFoundationOnly
    Pathways.IsFoundation

When checking access:

- Confirm an active subscription exists
- Consider `StartDate`
- Consider `EndDate`
- Consider `IsActive`
- Apply Foundation-only restrictions when required

Do not secure paid content only by hiding it visually.

Server-side code must prevent unauthorised access to restricted modules.

## 21. Classroom Rules

Instructor-led classrooms use:

    Classrooms
    ClassroomEnrollments
    ClassroomMaterials
    ClassroomAssignments
    AssignmentQuestions
    AssignmentQuestionOptions
    AssignmentSubmissions
    Feedback

Only the owning instructor or authorised Admin should manage a classroom.

Every classroom-management query must verify ownership using:

    Classrooms.InstructorID

Do not trust a `ClassroomID` from the query string without checking ownership.

Students may enrol using a valid:

    Classrooms.InviteCode

The same student must not be enrolled twice in one classroom.

Assignment questions may be:

    Objective
    Subjective

Objective questions use `AssignmentQuestionOptions`.

Subjective questions use text-based answers.

Do not treat classroom assignments as module exams.

Do not insert more than one submission for the same student and assignment question unless the schema is officially changed to support resubmission history.

**Classroom material uploads (Added):** Instructors upload files for a specific classroom directly from `Instructor/Classrooms.aspx` (visible once a classroom is selected via `?id=`), not from `Instructor/Materials.aspx` — that page is for subtopic-level `LearningMaterials`, a separate table/feature. Classroom material upload writes to `ClassroomMaterials` with `FilePath` under `/uploads/classroom/{ClassroomID}/`, matching the storage convention already documented in Section 29. `Student/ClassroomDetail.aspx`'s Files & Attachments tab reads from the same `ClassroomMaterials` table, so anything an instructor uploads here shows up there immediately — no separate publish step. Same upload validation as `Instructor/Materials.aspx`: extension allowlist (PDF/DOCX/DOC/PPTX/PPT/TXT/PNG/JPG/JPEG), 10 MB max, safe stored filename, ownership check against `Classrooms.InstructorID` before saving.

## 22. Community Fun Room Rules

Community-created rooms use:

    FunRooms

Any supported user role may create a community Fun Room when allowed by the application.

Supported status values are:

    Pending
    Approved
    Rejected

Newly submitted community content should normally begin as:

    Pending

Only approved content should normally be visible publicly.

Admin review uses:

    ReviewedByAdminID

Do not confuse `FunRooms` with `BossFightRooms`.

They are separate features.

## 23. Boss Fight Rules

Official Boss Fight content uses:

    BossFightRooms
    Bosses
    BossFightQuestions
    BossFightQuestionOptions
    BattleSessions
    BattleSessionAnswers

Boss Fight rooms are Admin-created official content.

Each Boss Fight room has one boss.

Supported difficulty levels are:

    Easy
    Medium
    Hard
    Legendary

Only published Boss Fight rooms should be available to students:

    BossFightRooms.IsPublished = 1

A battle must create and maintain a `BattleSessions` record.

Supported battle statuses are:

    InProgress
    Won
    Lost
    Abandoned

Every answer turn should be recorded in:

    BattleSessionAnswers

The server must calculate:

- Whether the answer is correct
- Damage dealt to the boss
- Damage taken by the player
- Enrage bonus damage
- Remaining player HP
- Remaining boss HP
- Battle status
- Final XP eligibility

Do not trust client-side HP values, damage values, answer correctness, or XP values.

The browser may animate the battle, but the server remains authoritative.

Award Boss Fight XP only after a verified win.

Do not allow refreshing the result page to award XP again.

## 24. Challenges

Challenges use:

    Challenges
    ChallengeParticipation

A challenge may be created by an Instructor or Admin depending on the feature rules.

Application logic must ensure the creator fields are valid.

Where required, exactly one creator should be set:

    CreatedByInstructorID
    CreatedByAdminID

Students should have only one participation record per challenge unless the schema is officially changed.

Challenge availability must respect:

    StartDate
    EndDate

Do not rely only on the visible button state.

Validate dates server-side.

## 25. Discussions and Forum Rules

Discussion features use:

    DiscussionThreads
    DiscussionReplies

A thread may be linked to:

- A module
- A subtopic
- General discussion

When editing or deleting user-created content:

- Verify the current user created the content, or
- Verify the current user is an authorised Admin

Do not allow users to edit or delete another user’s thread or reply by changing a URL ID.

Display user-generated content safely.

Encode plain text before displaying it unless the field is intentionally designed and sanitised to store HTML.

## 26. Consultation Rules (Feature Removed — Do Not Rebuild)

Consultations (Student + Instructor booking) is **permanently removed** from this project. It was deleted during the 30-page squeeze, briefly rebuilt as 2 dedicated pages when the budget was raised to 40, then the user explicitly said "i dont want consultation anymore" — so it was deleted again and should stay deleted.

No `.aspx` pages, code-behind, nav links, or `csproj` entries for Consultations exist anymore. The `ConsultationSlots` and `ConsultationBookings` tables remain in the database schema for completeness only — they are not read or written by any current page. Do not create Consultation pages, nav links, or code unless the user explicitly asks again.

## 27. Reports, Moderation, and Audit Rules

Reports use:

    Reports

Supported report statuses are:

    Open
    Reviewed
    ActionTaken
    Dismissed

Fields such as:

    ReportedContentType
    ReportedContentID

are polymorphic references.

They are not normal database foreign keys.

Validate `ReportedContentType` against a known allowlist before using it to select a table or content type.

Audit logs use:

    AuditLogs

Fields such as:

    TargetTable
    TargetID

are also polymorphic references.

Never insert a table name supplied directly by a user into dynamic SQL.

Important actions that may require audit logging include:

- Instructor approval or rejection
- User ban or unban
- Content approval or rejection
- Administrative content changes
- Report resolution
- Security-sensitive actions

**Report submission (Added):** Students and Instructors submit reports from a "Report an Issue" form on their own `Profile.aspx` (`Student/Profile.aspx` and `Instructor/Profile.aspx`) — there is no separate dedicated Report page for submission, to avoid adding another page under the budget. The form inserts into `Reports` with `Status='Open'`, `ReportedByUserID` = current session user, and `ReportedContentType` chosen from a fixed dropdown (`User`/`Classroom`/`Challenge`/`Other`). `ReportedUserID` and `ReportedContentID` are left `NULL` on this simple submission form — the reporter just describes the issue in free text (`Reason`), and an Admin follows up manually via `Admin/Reports.aspx`. This is intentionally simple, matching the descoped/simplified admin scope decided earlier in the project (see Section 39 user corrections).

Follow the existing audit implementation when available.

## 28. Notification Rules

Notifications use:

    Notifications

A notification belongs to one user through:

    Notifications.UserID

Only the intended user should be able to view or update their notification.

When marking a notification as read, verify both:

    NotificationID
    UserID

Do not allow a user to mark another user’s notification as read by changing an ID.

The unread notification count should be retrieved from the database and should not be a hard-coded visual number.

## 29. File and Image Storage Rules

Do not store uploaded file binaries in SQL Server.

Store relative web paths in database path columns.

Use these locations:

    /uploads/badges/
    /uploads/bosses/
    /uploads/materials/
    /uploads/classroom/{ClassroomID}/

Examples:

    /uploads/badges/cloud-starter.png
    /uploads/bosses/firewall-beast.png
    /uploads/materials/cloud-overview.pdf
    /uploads/classroom/1/week1-slides.pdf

Do not store local machine paths such as:

    C:\Users\Name\Downloads\file.pdf

Use:

- `FileName` for the original human-readable filename
- `FilePath` for the stored web path
- `IconPath` for badge or boss images

When handling uploads:

- Validate file extension
- Validate MIME type when practical
- Limit file size
- Generate a safe stored filename
- Prevent path traversal
- Do not use raw user input as a physical path
- Do not overwrite an unrelated existing file
- Restrict executable file types
- Verify ownership before replacing or deleting files

## 30. SQL and ADO.NET Rules

Use ADO.NET consistently with the existing project.

Use:

- `SqlConnection`
- `SqlCommand`
- `SqlDataReader`
- `SqlDataAdapter`
- `DataTable`
- `ExecuteScalar`
- `ExecuteNonQuery`

Choose the simplest appropriate method.

Examples:

- Use `ExecuteScalar` for one value
- Use `ExecuteNonQuery` for insert, update, or delete
- Use `SqlDataReader` for forward-only reading
- Use `DataTable` when data binding or disconnected tabular data is useful

Always use parameterised SQL.

Correct:

    string sql = @"SELECT UserID, FullName
                   FROM Users
                   WHERE Email = @Email";

    using (SqlCommand command = new SqlCommand(sql, connection))
    {
        command.Parameters.Add("@Email", SqlDbType.NVarChar, 100).Value = email;
    }

Incorrect:

    string sql = "SELECT * FROM Users WHERE Email = '" + email + "'";

Do not concatenate:

- User input
- Query-string values
- Session values
- Form values
- IDs
- Status values

into SQL strings.

Use explicit column lists.

Avoid:

    SELECT *

unless there is a specific justified reason.

When several dependent updates represent one action, use:

    SqlTransaction

Examples include:

- Account and role creation
- XP ledger and TotalXP update
- Exam completion and XP award
- Boss Fight completion and XP award
- Deleting an item with related child records

## 31. Database Connection Rules

Use the existing CloudPhoria connection string.

Do not hard-code:

- Server names
- Database usernames
- Database passwords
- Local machine connection details

inside individual code-behind files.

Retrieve the connection string through the project configuration.

Example:

    ConfigurationManager.ConnectionStrings["CloudPhoriaConnectionString"].ConnectionString

Use the actual existing connection-string name.

Do not invent another connection string if one already exists.

Always close and dispose database resources.

Prefer `using` blocks.

## 32. Web Forms Lifecycle Rules

Understand and respect the Web Forms lifecycle.

Use:

    if (!IsPostBack)
    {
        // Initial page loading
    }

for data that should load only during the first request.

Do not place all page logic inside `Page_Load`.

Use clearly named methods for separate responsibilities, such as:

    CheckAccess()
    LoadUserProfile()
    LoadModules()
    LoadNotifications()
    BindClassrooms()
    ShowMessage()

Keep methods separate when they perform meaningfully different tasks.

Do not create excessive one-line methods that make the code harder to follow.

Do not rebind controls on every postback when doing so would:

- Reset selected values
- Clear entered data
- Interrupt editing
- Reset pagination
- Duplicate processing

Handle events through normal Web Forms event handlers.

Do not manually call button event handlers from unrelated methods as a shortcut.

## 33. Server Control Rules

Use ASP.NET server controls when server-side interaction is required.

Examples include:

- `asp:Literal`
- `asp:Label`
- `asp:TextBox`
- `asp:Button`
- `asp:LinkButton`
- `asp:Panel`
- `asp:Repeater`
- `asp:GridView`
- `asp:DropDownList`
- `asp:FileUpload`
- Validation controls

Every server control referenced in code-behind must:

- Exist in the matching `.aspx` or `.master` file
- Have the correct `ID`
- Include `runat="server"`
- Be available in the designer file when required

Do not reference a control that does not exist.

Do not casually edit designer files by hand unless necessary and understood.

When a control error occurs, first check:

- Exact control ID
- `runat="server"`
- Naming container
- Correct ContentPlaceHolder
- Designer declaration
- Build state

## 34. Query String and Session Validation

Treat query-string and session values as untrusted input.

Never directly use:

    Request.QueryString["id"]

without validation.

Use `int.TryParse` for integer IDs.

Example:

    int moduleID;

    if (!int.TryParse(Request.QueryString["moduleID"], out moduleID))
    {
        Response.Redirect("~/Student/Modules.aspx");
        return;
    }

After parsing, verify:

- The record exists
- The user is allowed to access it
- The record belongs to the expected parent
- The record has the required status

Do not assume that a valid integer ID means valid access.

Check session values safely before conversion.

Do not allow null session values to cause unhandled exceptions.

## 35. Security Rules

Every feature must consider:

- Authentication
- Authorisation
- SQL injection
- Cross-site scripting
- CSRF exposure
- File upload security
- Query-string tampering
- Duplicate submission
- Direct-object-reference attacks
- Data ownership
- Error information leakage

Use:

    HttpUtility.HtmlEncode()

or safe ASP.NET encoding for plain user-generated text.

Do not encode intentionally approved HTML content blindly if it must render as lesson content. Instead, ensure such HTML is created only by trusted users and sanitised appropriately.

Never display:

- SQL statements
- Connection strings
- Stack traces
- Physical file paths
- Internal exception details

to normal users.

Log detailed errors securely where an existing logging mechanism is available.

Show users a clear general error message.

Do not use an empty `catch` block.

Do not write:

    catch (Exception)
    {
    }

Handle the error meaningfully or allow it to be logged appropriately.

## 36. Ownership and Authorisation Rules

Any update or delete operation involving user-owned data must check ownership.

Examples:

- Classroom belongs to current Instructor
- Material belongs to current Instructor’s classroom
- Assignment belongs to current Instructor’s classroom
- Discussion thread belongs to current user
- Discussion reply belongs to current user
- Fun Room belongs to current creator
- Notification belongs to current user
- Battle session belongs to current Student
- Exam attempt belongs to current Student

Do not authorise an action using only a visible button.

The server-side SQL query should include ownership criteria where possible.

Example:

    DELETE FROM DiscussionThreads
    WHERE ThreadID = @ThreadID
    AND CreatedByUserID = @UserID

Admin override behaviour must be explicit.

## 37. UI Design Direction

CloudPhoria uses a clean, modern, professional cloud-learning design.

The interface should feel:

- Structured
- Motivating
- Technical
- Modern
- Friendly
- Gamified without appearing childish
- Suitable for university students and beginning professionals

The normal learning interface should not use an aggressive hacker or cyberpunk appearance.

Boss Fight pages may be more dramatic but must still belong to the same CloudPhoria visual system.

## 38. Locked Colour System

Use the following core palette consistently.

### Primary colours

    Cloud Blue:       #0EA5E9
    Deep Cloud Blue:  #0284C7
    Indigo:           #6366F1
    Deep Indigo:      #4F46E5

### Main layout colours

    Sidebar Navy:     #0F172A
    Sidebar Surface:  #172033
    Page Background:  #F4F7FB
    Card Background:  #FFFFFF
    Main Text:        #172033
    Muted Text:       #64748B
    Border:           #E2E8F0

### Status and gamification colours

    Success:          #22C55E
    Warning:          #F59E0B
    Danger:           #EF4444
    Info:             #0EA5E9
    XP Highlight:     #F59E0B
    Locked:           #94A3B8

### Boss Fight colours

    Boss Dark:        #111827
    Boss Red:         #DC2626
    Boss Orange:      #F97316
    Boss Purple:      #7C3AED

Do not introduce random colours on every page.

New colours should be derived from the existing design system and used only when necessary.

## 39. CSS Variables

Where appropriate, define reusable variables in the main CloudPhoria stylesheet.

Recommended structure:

    :root {
        --cp-primary: #0EA5E9;
        --cp-primary-dark: #0284C7;
        --cp-indigo: #6366F1;
        --cp-indigo-dark: #4F46E5;

        --cp-sidebar: #0F172A;
        --cp-sidebar-surface: #172033;
        --cp-page-bg: #F4F7FB;
        --cp-surface: #FFFFFF;

        --cp-text: #172033;
        --cp-text-muted: #64748B;
        --cp-border: #E2E8F0;

        --cp-success: #22C55E;
        --cp-warning: #F59E0B;
        --cp-danger: #EF4444;
        --cp-info: #0EA5E9;

        --cp-radius-sm: 8px;
        --cp-radius-md: 12px;
        --cp-radius-lg: 18px;

        --cp-shadow-sm: 0 2px 8px rgba(15, 23, 42, 0.06);
        --cp-shadow-md: 0 10px 30px rgba(15, 23, 42, 0.10);
    }

Use the existing variable names if the project already has an established equivalent.

Do not duplicate multiple competing variable systems.

## 40. CSS Naming Rules

Use a CloudPhoria-specific prefix for shared custom CSS classes.

Recommended prefix:

    cp-

Examples:

    cp-layout
    cp-sidebar
    cp-topbar
    cp-page-header
    cp-card
    cp-stat-card
    cp-btn
    cp-badge
    cp-progress
    cp-empty-state
    cp-module-card
    cp-room-card
    cp-boss-hp

Do not use ScienceBuddy-specific prefixes such as:

    sb-
    st-

inside CloudPhoria unless those classes are temporary legacy code being deliberately migrated.

Do not use vague shared class names such as:

    box
    item
    thing
    blue
    left
    right

Prefer names based on purpose.

Do not create a separate copy of the same CSS for every page.

Use shared classes with small page-specific extensions.

## 41. Layout Rules

The authenticated CloudPhoria layout should normally contain:

    Fixed or persistent left sidebar
    Top header
    Main page workspace
    Responsive mobile sidebar

The sidebar should:

- Use the dark navy palette
- Display the CloudPhoria brand clearly
- Group navigation by purpose
- Highlight the active page
- Show icons consistently
- Collapse appropriately on smaller screens
- Avoid excessive decorative elements

The top header should support:

- Mobile menu button
- Current page title
- Notification access
- User name or avatar
- User menu
- Relevant page actions where required

The main workspace should:

- Use a light background
- Have clear content width and spacing
- Use reusable cards
- Maintain consistent page headers
- Avoid excessive empty space
- Remain readable on common laptop screens

## 42. Spacing and Card Rules

Use a consistent spacing scale.

Recommended values:

    4px
    8px
    12px
    16px
    20px
    24px
    32px
    40px
    48px

Use moderate rounded corners.

Recommended:

    8px to 18px

Cards should generally use:

- White or appropriate surface background
- Light border
- Soft shadow
- Clear internal spacing
- Strong title hierarchy

Avoid:

- Huge empty cards with very little information
- Excessive shadows
- Excessively rounded bubble-style UI
- Too many gradients
- Random card heights
- Text touching card edges
- Icons misaligned from labels
- Checkmarks separated far from their related text

## 43. Typography Rules

Use the existing project font if one is already established.

Otherwise, prefer a clean modern sans-serif font.

Maintain clear hierarchy:

- Page title
- Page description
- Section title
- Card title
- Body text
- Supporting or muted text

Do not make all text the same size and weight.

Avoid:

- Extremely small body text
- Excessive uppercase text
- Large paragraphs centred inside cards
- Decorative fonts for normal content
- Emoji used as the primary icon system

Use real icons where practical.

Emoji may be used sparingly for informal achievements or celebratory messages, but should not replace the overall icon system.

## 44. Buttons and Form Controls

Buttons should use consistent reusable styles.

Typical button types include:

    Primary
    Secondary
    Outline
    Success
    Danger
    Text or Link
    Icon button

Primary actions should be visually clear.

Do not place several equally strong primary buttons in one small area.

Danger actions must:

- Look distinct
- Be used only for destructive actions
- Request confirmation where appropriate

Forms must include:

- Visible labels
- Clear required-field indication
- Helpful validation messages
- Consistent input sizes
- Appropriate input types
- Server-side validation

Do not rely only on placeholders as labels.

Do not rely only on client-side validation.

## 45. Page-State Rules

Every data-driven page should consider:

- Loading state where applicable
- Empty state
- Error state
- Success state
- Restricted state
- Locked state
- No-search-results state
- Disabled action state

Do not leave an empty blank container when no records exist.

An empty state should explain:

- What is missing
- Why the area is empty
- What the user can do next, where relevant

Messages must match the actual situation.

Do not display fake success messages.

## 46. Responsive Design Rules

All main pages must be usable on:

- Desktop
- Laptop
- Tablet
- Mobile

Responsive behaviour should include:

- Mobile sidebar drawer
- Sidebar overlay
- Flexible grids
- Stacked cards where needed
- Responsive tables or card-based alternatives
- Buttons that remain usable without overflowing
- Forms that fit small screens
- Page headers that wrap properly

Do not create desktop-only interfaces with fixed widths that break on smaller screens.

Avoid horizontal scrolling except where genuinely necessary, such as a complex data table.

## 47. Accessibility Rules

Use semantic HTML where practical:

    header
    nav
    main
    section
    article
    footer
    button
    label

Requirements include:

- Meaningful page titles
- Alternative text for informative images
- Labels for form inputs
- Keyboard-accessible controls
- Visible focus states
- Sufficient colour contrast
- Buttons for actions
- Links for navigation
- ARIA labels for icon-only controls
- Appropriate heading order

Do not use clickable `<div>` elements where a button or link is more appropriate.

Do not communicate status using colour alone.

## 48. JavaScript Rules

Use JavaScript only for appropriate client-side behaviour such as:

- Sidebar toggling
- Dropdown menus
- Modal interaction
- Visual timers
- Tabs
- Non-security UI enhancement
- Boss Fight animation
- Confirmation prompts
- Progressive interface behaviour

Do not place authoritative business logic only in JavaScript.

The server must validate:

- Access
- Role
- Ownership
- Correct answers
- Exam timing
- Scores
- XP
- Progress
- HP and damage
- Subscription access
- Record status

Do not expose sensitive values in JavaScript.

Avoid large inline scripts duplicated across many `.aspx` files.

Place reusable JavaScript in existing shared script files.

Make sure JavaScript selectors match the actual rendered control IDs.

## 49. Code Readability Rules

Code must remain suitable for a Year 2 Computer Science student.

Use:

- Clear method names
- Clear variable names
- Normal `if` and `else` blocks
- Braces for control structures
- Straightforward ADO.NET
- Short useful comments
- Logical separation of responsibilities

Avoid:

- Excessively clever one-line code
- Deeply nested ternary expressions
- Unnecessary null-propagation chains when they reduce readability
- Huge methods that perform unrelated tasks
- Overly abstract helper systems
- Generic methods that hide simple logic
- Unnecessary interfaces
- Unnecessary inheritance
- Unexplained reflection
- Dynamic SQL
- Advanced architecture introduced only to look professional

Prefer code that the student can explain clearly during a viva.

Comments should explain:

- Why a non-obvious step exists
- What a security or business rule protects
- Why a transaction is required
- Why an ownership check is necessary

Do not comment every obvious line.

## 50. Error Handling Rules

Use `try` and `catch` where an operation has a realistic recoverable failure, especially:

- Database work
- File operations
- External integration
- Parsing of uncertain data

Do not wrap every small method in a generic `try-catch`.

Do not ignore exceptions.

User-facing messages should be clear and safe.

Example:

    We could not load the module at the moment. Please try again.

Do not expose:

    System.Data.SqlClient.SqlException
    Object reference not set
    Invalid column name
    Connection string details
    Stack traces

to normal users.

## 51. Date and Time Rules

Use database-supported date types appropriately.

Use:

    DATETIME2
    DATE
    TIME

according to the actual schema.

Use parameterised date values.

Do not build SQL date strings manually.

Display dates in a clear, consistent user-facing format.

Use server-side date validation for:

- Challenge periods
- Assignment due dates
- Subscription periods
- Exam attempts

Do not rely only on the user’s device clock.

## 52. Content Language

CloudPhoria content is English-only under the current schema.

Do not copy bilingual logic from ScienceBuddy.

Do not create:

- English and Malay duplicate columns
- Language toggle logic
- `T("English", "Malay")` helper methods
- EN/BM literal pairs

unless the CloudPhoria database and requirements are officially changed to support multiple languages.

Use clear English suitable for cloud-computing learners.

## 53. Placeholder and Demo Data Rules

Do not use hard-coded placeholder values when real database data is available.

Avoid hard-coded examples such as:

    1,250 XP
    12 modules completed
    John Doe
    75% progress
    3 unread notifications

unless clearly marked as temporary design mockup data.

Functional pages should retrieve data from the database.

If data does not exist:

- Show an honest empty state
- Do not invent achievements or progress
- Do not display misleading statistics

## 54. Existing Functionality Protection

Before changing a file:

1.  Read the whole relevant section
2.  Identify existing server controls
3.  Identify existing event handlers
4.  Identify current database calls
5.  Identify dependent pages or scripts
6.  Preserve working logic not included in the request

Do not remove functionality simply because it is not part of the current task.

Do not rename a server control without updating:

- Code-behind
- Designer file
- JavaScript
- CSS
- Data-binding references
- Validation controls

Do not perform broad project-wide replacements without checking their effect.

## 55. Build and Verification Rules

After making code changes, verify:

- The project builds successfully
- No server control is missing
- No method or variable is undefined
- No duplicate control ID exists
- The Master Page ContentPlaceHolder IDs match
- SQL table and column names are correct
- Parameter names match the SQL command
- Session keys are checked safely
- Role protection works
- Query-string tampering is handled
- Empty states display properly
- Mobile layout does not overflow
- Existing pages are not broken

Do not claim a feature is complete without checking the affected files for consistency.

When actual execution is unavailable, clearly state what was verified statically and what still requires runtime testing.

## 56. Change-Scope Rules

Only modify files required for the requested task.

Do not:

- Redesign unrelated pages
- Rewrite unrelated working code
- Rename the whole CSS system
- Change the database without permission
- Add new features outside the request
- Perform broad refactoring during a small fix
- Replace existing authentication casually
- Add unnecessary packages
- Add unrelated sample data

When a wider change is genuinely required, explain why before performing it.

## 57. Kiro Working Behaviour

When Kiro receives a task, it must:

1.  Read this Project Rules document
2.  Read the Database Schema Guide
3.  Inspect all files directly involved
4.  Identify the existing implementation
5.  State which files need changes
6.  Preserve the existing architecture
7.  Implement only the requested scope
8.  Check for related compile errors
9.  Report what changed
10. Report what was not changed
11. Mention any required manual testing

Kiro must not immediately generate large amounts of code before inspecting the project.

Kiro must not assume a file is missing without searching for it.

Kiro must not claim a database column exists without checking the schema.

Kiro must not silently create replacement pages when an existing page already provides the same purpose.

## 58. Required Completion Report

After completing a development task, Kiro should provide:

### Files changed

List every file modified.

### Changes made

Explain the practical changes in clear language.

### Database objects used

List the relevant:

- Tables
- Columns
- Relationships
- Status values

### Security checks

State which access, ownership, validation, and parameterisation checks were applied.

### Existing functionality preserved

Mention important features intentionally left unchanged.

### Testing required

List specific steps the student should test.

### Remaining limitations

State honestly what was not implemented or could not be verified.

Do not provide a vague response such as:

    Done. Everything has been updated.

## 59. Prohibited Actions

Unless explicitly requested, do not:

- Create a new solution
- Create a new project
- Change framework
- Add a Parent role
- Create another Master Page
- Add fake tables or columns
- Rename database fields
- Change integer IDs to string IDs
- Use ScienceBuddy database structures
- Add bilingual ScienceBuddy logic
- Store plaintext passwords
- Concatenate input into SQL
- Trust query-string IDs
- Trust client-side scores
- Trust client-side XP
- Trust client-side Boss Fight HP
- Expose correct answers before submission
- Store local physical file paths
- Store uploaded binaries in SQL Server
- Duplicate XP rewards
- Duplicate badge awards
- Duplicate certification awards
- Hide unauthorised actions only through CSS
- Delete working features outside the requested scope
- Create unnecessary files
- Introduce advanced architecture without approval
- Copy another platform’s branding or source code
- Use placeholders where real data should be retrieved
- Claim runtime success without testing

## 60. Final Development Principle

When uncertain:

- Inspect the existing project
- Inspect the database schema
- Choose the simplest correct Web Forms solution
- Preserve working logic
- Keep the implementation understandable
- Ask only when a decision cannot reasonably be derived from the project

Do not invent a new architecture.

Do not solve a small issue by rebuilding the entire feature.

CloudPhoria should remain:

- Consistent
- Secure
- Database-aligned
- Responsive
- Understandable
- Original
- Suitable for a university Web Application Development assignment


## 39. Additional Features (Added During Development)

### Page Count Summary (38 pages total)

The page budget was raised from 30 to 40 by the lecturer specifically so Admin (1 person) and Instructor (1 person) each get a fairer page count relative to Student (2 people). The project currently sits at 38 (2 under budget) — Consultations was briefly restored then removed again per the user's final decision, so the total is 40 minus the 2 Consultations pages.

**Shared (3 pages):** Default.aspx (landing), LogIn.aspx, Register.aspx

**Admin (9 pages):** Dashboard (overview stats only), Users (full CRUD), InstructorApprovals, Courses (assign instructor + publish/unpublish), Challenges (global admin challenges), Reports (moderation), AuditLogs (searchable log viewer), Notifications, Profile

**Instructor (10 pages):** Dashboard, Modules, SubTopics, Questions, Classrooms, Materials, Assignments, Challenges, Notifications, Profile

**Student (16 pages):** Dashboard, Pathways, PathwayDetail, ModuleDetail, SubTopicView, MyLearning, Exams, Challenges, BossFights, Classrooms, ClassroomDetail, AssignmentDetail, Achievements, Notifications, Profile, Upgrade

The single-page tabbed Admin dashboard (6 tabs on one `.aspx`) described in earlier revisions of this document has been **replaced** by 9 dedicated Admin pages — see Section 43 below for the current breakdown. Consultations is permanently removed — see Section 26 and Section 44.

### Guest Access (STALE NOTE, SUPERSEDED — see Section 40 for the current, correct behaviour)
This bullet list describes an EARLIER, more restrictive guest model ("guests can ONLY see Default.aspx, no navigation bar, cannot click into anything") that was true for a short period but is **no longer accurate**. It is kept here only so the history is visible. The current behaviour, confirmed against `Site.Master.cs` and every guest-aware page's code-behind, is:
- Guests DO have a navigation bar (`pnlGuestNav` in `Site.Master`, shown by `CheckAuthentication()` when there's no session).
- Guests CAN click into `Student/Pathways.aspx`, `PathwayDetail.aspx`, `ModuleDetail.aspx`, `SubTopicView.aspx`, `BossFights.aspx`, `Challenges.aspx`, and `Upgrade.aspx` in read-only mode — they just can't enrol, answer questions, or earn XP.
- `Site.Master.cs` `CheckAuthentication()` does NOT redirect guests to login — it shows the guest nav/actions panels and returns early.
- The `Guest/` folder being empty is still true (no pages live there; guest support is handled via `isGuest` flags inside the Student pages themselves, not a separate folder).
- The `GuestModuleAccess` table is still unused — that part of this note remains accurate.
- See Section 40 ("Guest Read-Only Access") for the complete, current, accurate description of exactly which pages support guests and how the detection pattern works. If this note and Section 40 ever seem to disagree again, trust Section 40 and check the actual code — this note is deliberately left as a historical marker of "this used to be true, then it changed."

### Registration (Register.aspx)
- Students: fill name, email, password, optional TP number → instant account creation + auto-login + Free subscription assigned
- Instructors: fill name, email, password, qualification, teaching permit description → account created with `LicenseStatus = 'Pending'` → admin notified → must wait for approval before accessing instructor features
- Duplicate email check prevents multiple accounts

### Merged Pages
- `Exams.aspx` handles both exam listing AND exam taking (via `?moduleID=` query parameter)
- `Challenges.aspx` handles both challenge listing AND live challenge (via `?challengeID=` parameter)
- `BossFights.aspx` handles both boss listing AND battle (via `?roomID=` parameter)

### Deleted Features (to reduce page count from original ~44 down to 30)
- Fun Rooms (FunRooms, FunRoomDetail, FunRoomCreate) — REMOVED, permanently. Do not rebuild even with the 40-page budget; the user explicitly said "forget about the fun rooms."
- Practice Quizzes (Practice, PracticeQuiz) — REMOVED, still removed under the 40-page budget
- Discussions/Forum (Discussions, DiscussionThread, DiscussionCreate) — REMOVED, still removed under the 40-page budget
- Guest/Learn page — REMOVED
- About.aspx, Contact.aspx — REMOVED

### Consultations — Permanently Removed
See Section 26 and Section 44 for the full history and current status. Short version: deleted, rebuilt, deleted again — stays deleted.

### Classroom Chat
- Uses `ClassroomMessages` table for Teams-style messaging
- Both enrolled students and the classroom instructor can send messages
- Messages displayed with sender avatar initials, name, timestamp
- Instructor messages highlighted with special badge
- Page: `Student/ClassroomDetail.aspx` (Teams-style layout with sidebar tabs)

### Challenges (Fixed — the "enter and take a challenge" flow was built)
This feature previously had a real gap: instructors/admins could create challenges, but there was no way for a student to actually take one, and no way to add quiz questions to a challenge at all. Both sides are now implemented.

**Creating challenge questions (Instructor/Admin):**
- `Instructor/Challenges.aspx?manageQuestions=X` and `Admin/Challenges.aspx?manageQuestions=X` — new "Questions" link per challenge row opens a question-management view on the same page (query-string switched, same pattern as everywhere else in this project).
- Add a question: text, points, time limit (seconds), and 2+ answer options with one marked correct via radio buttons — same MCQ-creation pattern as `Instructor/Questions.aspx`. Inserts into `ChallengeQuestions` + `ChallengeQuestionOptions`.
- List + delete existing questions per challenge. Instructor side checks ownership (`Challenges.CreatedByInstructorID`); Admin side checks `IsGlobalAdminChallenge=1`.
- A challenge with 0 questions shows "No questions yet" instead of "Join Challenge" on the student list — students cannot enter an empty challenge.

**Taking a challenge (Student):**
- `Student/Challenges.aspx?challengeID=X` — clicking "Join Challenge" now leads to an intro screen (title, description, question count, XP reward, one-attempt warning) with a "Start Challenge" button.
- Starting locks in the ordered list of `ChallengeQuestionID`s into ViewState, then walks through them one at a time: question text, shuffled options (`ORDER BY NEWID()`), a per-question countdown timer (JS-driven display, same visual pattern as the Boss Fight battle timer), and a Submit button. Timeout auto-submits `0` (counts as wrong), same convention as `BossFights.aspx`.
- Correctness is checked **server-side** by looking up `ChallengeQuestionOptions.IsCorrect` for the submitted `OptionID` — the client never receives which option is correct beforehand, consistent with Section 15/17's "do not expose correct answers before submission" rule.
- Score accumulates in ViewState across questions. On the last question, `EndChallenge()` INSERTs one row into `ChallengeParticipation` (guarded against double-submission by checking for an existing row first, since `(ChallengeID, StudentID)` has a UNIQUE constraint) and, in the same transaction, awards `XPTransactions` (`SourceType='Challenge'`) + updates `Students.TotalXP` — exactly the same transactional pattern used for Boss Fight XP awards.
- Final screen shows the student's score + XP earned, followed by a **top-10 leaderboard** (`ORDER BY Score DESC, CompletedAt ASC`, tie-break by whoever finished first).
- `Student/Challenges.aspx?leaderboard=X` — a standalone leaderboard view (no need to take the challenge again) is linked from both the active-challenge list and the past-participation table.

**What's still intentionally simple / not built:** no live/synchronous multiplayer aspect (each student takes the quiz independently whenever they click Join, not at the same literal moment as other students — "live" here just means "time-boxed by `StartDate`/`EndDate`", consistent with how the feature was originally named). No question shuffling across challenge attempts (there's only one attempt per student per challenge anyway, enforced by the UNIQUE constraint). No partial-credit or negative scoring — a question is either fully correct (`Points` added) or not (`0` added).

### Subscription / Upgrade
- Simplified to 2 plans: Free ($0) and Pro ($9.99/month)
- "Go Pro" link visible in navigation bar for free-tier students
- Upgrade page: `Student/Upgrade.aspx` with payment modal
- On upgrade: deactivates old subscription, inserts new Pro subscription

### Pathway Enrollment
- No auto-enrollment when visiting modules
- Students must click "Enroll in Pathway" on `PathwayDetail.aspx`
- Enrollment creates `ModuleProgress` rows for ALL modules in the pathway
- Non-Foundation pathways blocked for Free users (shows "Upgrade to Pro to Enroll")
- Foundation pathway freely enrollable by all students

### Module Exams
- Exams locked until all subtopics completed (checked server-side)
- Handled within `Student/Exams.aspx` (merged page)
- One question at a time with countdown timer
- Score calculated server-side; XP awarded on pass

### Assignments
- Instructor creates assignments with questions via `Instructor/Assignments.aspx`
- Supports Objective (MCQ) and Subjective (free-text) questions
- Students view and answer via `Student/AssignmentDetail.aspx`
- One submission per student per question (UNIQUE constraint)
- Instructor can view submissions and give feedback/grades

### Subtopic Learning Content
- All subtopics have detailed HTML lesson content in `ContentBody`
- Content displays before questions on `SubTopicView.aspx`
- Clear visual separator between lesson and assessment questions
- "Mark as Complete" button appears after questions

### Navigation
- Top navigation bar with role-specific links
- "Go Pro" link (golden) in student nav for free-tier users
- Logout button always visible next to avatar (red styling)
- Dropdown menus for Learn and Compete sections
- Logout redirects to `Default.aspx` (landing page)


## 40. Guest Read-Only Access (Added)

Guests (not logged in) can now browse a subset of student pages in **read-only mode**:

**Guest-accessible pages:**
- `Student/Pathways.aspx` — browse all pathways (shows "Guest" notice instead of Free plan notice)
- `Student/PathwayDetail.aspx` — view pathway info, modules, exam info (Enroll button replaced with "Register / Upgrade to Enroll")
- `Student/ModuleDetail.aspx` — view module + subtopics list (no enrollment check for guests)
- `Student/SubTopicView.aspx` — read full lesson content, but questions are replaced with a "Register for Free" prompt (`pnlGuestPrompt`)
- `Student/BossFights.aspx` — browse boss fight rooms (Enter Battle replaced with "Register to Battle")
- `Student/Challenges.aspx` — browse challenges (Join replaced with "Register to Join")
- `Student/Upgrade.aspx` — view pricing (buttons redirect to Register instead of processing payment)

**How guest detection works in code-behind:**
```csharp
bool isGuest = (Session["UserID"] == null || Session["Role"] == null ||
    Session["Role"].ToString() != "Student");
```
Use `studentID = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0;` and guard any student-specific SQL (subscription checks, enrollment checks, progress writes) with `if (!isGuest) { ... }`.

**Guest navigation:**
- `Site.Master.cs` `CheckAuthentication()` no longer redirects to login when there's no session — instead it sets `pnlGuestNav.Visible = true` and `pnlGuestActions.Visible = true`, then returns early (skips `LoadCurrentUser`, `ConfigureNavigation`, `LoadNotificationCount`, `LoadXP`).
- Guest nav bar shows: Browse Pathways, Boss Fights, Challenges, Pricing + "Log In" / "Join for Free" buttons.
- `Default.aspx` (landing page) does NOT use `Site.Master` — it has its own nav with the same links plus a "Browse Pathways" preview section (pathway + module list, read-only, populated by `Default.aspx.cs LoadGuestPathways()`).

**Pages that still require login (no guest access):** Dashboard, Exams, Classrooms, ClassroomDetail, AssignmentDetail, Achievements, Notifications, Profile, MyLearning — these still use the original redirect-to-login pattern.

**Tier comparison:**
| | Guest | Free Plan | Pro Plan |
|---|---|---|---|
| Browse pathways/modules/lessons | ✓ read-only | ✓ | ✓ |
| Answer questions / earn XP | ✗ | ✓ (Foundation only) | ✓ (all) |
| Enroll in pathways | ✗ | ✓ (Foundation) | ✓ (all) |
| Take exams / boss fights / challenges | ✗ | ✓ (Foundation) | ✓ |
| Classrooms / Assignments | ✗ (requires login) | ✓ | ✓ |

## 41. Drag-and-Drop Boss Fights (Added)

The boss battle mechanic was rebuilt as **drag-and-drop** instead of click-to-answer, and merged directly into `Student/BossFights.aspx` (no separate `BossFightBattle.aspx` page — keeps page count at 30).

**No schema changes** — reuses the existing `BossFightRooms`, `Bosses`, `BossFightQuestions`, `BossFightQuestionOptions`, `BattleSessions`, `BattleSessionAnswers` tables exactly as documented in Section 23.

**How it works:**
- `BossFights.aspx?roomID=X` (only for logged-in students) shows the battle arena inline instead of the room list.
- 4 answer options render as `.drag-opt` draggable `<div>` elements; one `.drop-zone` div is the target.
- Student drags (or taps, for touch/accessibility fallback) an option into the drop zone → JS sets a hidden field and auto-clicks a hidden `asp:Button` to postback.
- Server (`btnSubmitAnswer_Click`) validates the selected `OptionID` against `BossFightQuestionOptions.IsCorrect` — correctness, damage, and HP are ALL calculated server-side per the existing rule in Section 23 ("Do not trust client-side HP values...").
- Countdown timer per question (`BossFightQuestions.TimeLimitSeconds`) auto-submits option `0` (counts as wrong) on timeout.
- Battle continues until `BossCurrentHP <= 0` (win) or `PlayerCurrentHP <= 0` (loss); `EndBattle()` awards XP via `XPTransactions` + `Students.TotalXP` update in one transaction, same as before.

**New boss fight rooms added via `Database/add_more_bossfights.sql`:**
1. The Load Balancer Leviathan (Easy) — networking/load balancing
2. The Ransomware Wraith (Medium) — security basics
3. The Kubernetes Kraken (Hard) — container orchestration
4. The Data Breach Devourer (Legendary) — advanced security, has `EnrageThresholdPct`

Run this script AFTER the original 5 setup scripts and after `bossfight_difficulty_questions.sql`.

**Known bug, FIXED — duplicate boss fight rooms.** `Database/add_more_bossfights.sql` originally had no duplicate check before its `INSERT INTO BossFightRooms` statements. If a teammate ran the script more than once against an already-seeded database (e.g. re-running "all setup scripts" without tracking what had already been applied), each run silently created 4 more copies of the same 4 rooms (plus duplicate Bosses, BossFightQuestions, and BossFightQuestionOptions for each). This is exactly why "boss fight still duplicate" showed up for a teammate — the script itself was never idempotent.

Both parts of this are now fixed:
- `Database/add_more_bossfights.sql` now wraps each room's insert in `IF NOT EXISTS (SELECT 1 FROM BossFightRooms WHERE Title = '...') BEGIN ... END` — it is now safe to run multiple times; re-running it on an already-seeded database is now a no-op instead of creating more duplicates.
- `Database/fix_duplicate_bossfights.sql` (new) — a one-time cleanup script for any database that already has duplicates from before this fix. It identifies duplicate `BossFightRooms.Title` groups, keeps the lowest `RoomID` per title, and cascades the delete through `BattleSessionAnswers` → `BattleSessions` → `BossFightQuestionOptions` → `BossFightQuestions` → `Bosses` → `BossFightRooms` in FK-safe order. Safe to re-run (a no-op once duplicates are gone). Have your friend run this once against their database to clean up the existing duplicates.

## 42. Updated Page List (Student — 16 pages, verify against actual folder)

`Dashboard, Pathways, PathwayDetail, ModuleDetail, SubTopicView, MyLearning, Exams, Challenges, BossFights, Classrooms, ClassroomDetail, AssignmentDetail, Achievements, Notifications, Profile, Upgrade`

Note: `Exams.aspx` (exam taking), `Challenges.aspx` (live challenge), and `BossFights.aspx` (drag-and-drop battle) are each **merged pages** — the listing view and the interactive/detail view live in the same `.aspx`/`.aspx.cs`, switched via query string (`?moduleID=`, `?challengeID=`, `?roomID=`) or ViewState panel visibility. Do not recreate `ExamStart.aspx`, `ExamTake.aspx`, `ChallengeDetail.aspx`, or `BossFightBattle.aspx` — they were intentionally deleted and merged, and stay merged even under the 40-page budget (merging where sensible is still preferred; the extra budget went to fairness across roles, not to un-merging pages).

`Student/Discussions.aspx`, `Student/Practice.aspx`, `Instructor/ExamQuestions.aspx`, and `Instructor/PracticeQuestions.aspx` were stale orphaned files left on disk after the Task 6 deletion pass (never referenced in `CloudPhoria.csproj`, `Site.Master` nav, or any other page). They have been deleted for good — do not recreate them.


## 43. Admin Dashboard — 9 Dedicated Pages (Replaces old single-tab-page design)

Earlier revisions of this project (30-page budget) implemented Admin as a **single tabbed `Admin/Dashboard.aspx`** with 6 tabs. Once the lecturer raised the budget to 40 pages specifically to balance workload (Admin = 1 person, Instructor = 1 person, Student = 2 people), Admin was split into **9 dedicated pages**, each with its own `.aspx`/`.aspx.cs`/`.aspx.designer.cs`. **No FunRoom review, no subscription plan editing, and no gamification/XP-formula settings** — those remain explicitly descoped per the user's decision. Pricing stays fixed as coded in `Student/Upgrade.aspx` ($0 Free / $9.99 Pro).

### Admin/Dashboard.aspx — Overview
Read-only stats only now: total students, total instructors, pending approvals count, published module count, and the last 10 rows from `AuditLogs`. (Previously this page also hosted the other 5 tabs — that content has moved to its own dedicated pages below.)

### Admin/Users.aspx — Users (full CRUD)
- **Create**: modal form — pick Role (Student/Instructor/Admin), enter name/email/temp password. Creates the `Users` row plus the matching `Students`/`Instructors`/`Admins` role row in one transaction (shared-PK pattern per Section 9). New instructors created this way are auto-`Approved` (an admin creating an instructor account directly implies approval).
- **Ban / Unban**: toggles `Users.IsBanned`.
- **Deactivate / Activate**: toggles `Users.IsActive`.
- **Delete**: hard-deletes the `Users` row. Will fail with a friendly error if the user has related records (FKs) — this is expected and intentional; the admin should reassign/clean up content first rather than force-deleting through app code.
- Every action is written to `AuditLogs` via a shared `LogAction()` helper.

### Admin/InstructorApprovals.aspx — Instructor Approvals
This is the fix for "why did all my instructor's modules/subtopics/questions/challenges disappear" — those pages hard-redirect back to `Instructor/Dashboard.aspx` whenever `Session["LicenseStatus"] != "Approved"` (by design, Section 12). This page is the missing piece that lets an Admin actually change that status:
- Lists all `Instructors` where `LicenseStatus = 'Pending'` with Approve/Reject buttons.
- Approve/Reject updates `Instructors.LicenseStatus`, `ApprovedBy` (= current AdminID), `ApprovedAt`, sends the instructor a `Notifications` row, and logs to `AuditLogs` (`APPROVE_INSTRUCTOR` / `REJECT_INSTRUCTOR`).
- Below that, a read-only table of every instructor and their current status for reference.
- **Important:** the instructor's `Session["LicenseStatus"]` is set once at login time (see `LogIn.aspx.cs`). If an Admin approves an instructor while they're still logged in, that instructor must log out and back in for their session to pick up the new `Approved` status and regain access to Modules/SubTopics/Questions/Classrooms/Materials/Assignments/Challenges.

### Admin/Courses.aspx — Manage & Assign Courses (Now includes full Module/SubTopic/Question CRUD, see Section 12b)
- Read-only grid of all `Pathways` with module counts.
- "Create a New Module" form — Admin is now the only role that can create modules (name, description, difficulty, XP, exam duration/pass mark). New modules start unassigned (`CreatedByInstructorID=NULL`).
- Table of all `Modules` across every pathway with:
  - "Subtopics" link → drills into `Courses.aspx?moduleID=X`, a view with a "Add a Subtopic" form (name, content body, order, XP) and a list of existing subtopics with Publish/Unpublish/Delete, plus a "Questions" link per subtopic drilling one level deeper.
  - "Questions" link (from the subtopic drill-down) → `Courses.aspx?subTopicID=X`, a view with an "Add a Question" form (text, type MCQ/Regex/StringMatch, XP, order, correct answer, and up to 4 MCQ options with a checkbox for the correct one) and a list of existing questions with Delete.
  - A per-row dropdown (populated from `Instructors WHERE LicenseStatus='Approved'`) to reassign a module — this is the "choose the reliable instructor to manage" course-assignment requirement. **Assigning is a full ownership transfer, not just a label** — see the cascade behaviour below.
  - Publish/Unpublish toggle (`Modules.IsPublished`) — this is the admin-level content moderation/staging control, reusing the existing publish flag instead of a separate review queue.
  - Delete — removes the module outright (fails with a friendly error if subtopics/content still reference it, same FK-safety pattern as Section 36).

**Assign = cascade to all child content (Fixed — was previously a shallow, misleading update).** The schema does not have one "owner" column per module; `SubTopics`, `Questions`, `LearningMaterials`, and `PracticeQuestions`/`ExamQuestions` each carry their own independent instructor-ownership column, and every `Instructor/*.aspx` page filters strictly by its own column rather than by the parent module's owner. Earlier, "Assign" only updated `Modules.CreatedByInstructorID`, which meant the new instructor got the label but not actual edit access to the subtopics/questions/materials inside — the original instructor silently kept full edit rights. That was confusing and not what "assign a module to an instructor" should mean.

Assigning a module to an instructor (value > 0) now updates, in one transaction:
- `Modules.CreatedByInstructorID`
- `SubTopics.CreatedByInstructorID` (all rows where `ModuleID` matches)
- `Questions.CreatedByInstructorID` (joined through `SubTopics.ModuleID`)
- `LearningMaterials.InstructorID` (joined through `SubTopics.ModuleID`)
- `PracticeQuestions.CreatedByInstructorID` (where `ModuleID` matches)
- `ExamQuestions.CreatedByInstructorID` (where `ModuleID` matches)

After this, the new instructor sees and can edit everything in that module across `Instructor/SubTopics.aspx`, `Questions.aspx`, and `Materials.aspx` — the previous instructor loses access, since those pages' ownership checks now match the new instructor.

**Unassigning ("-- Unassigned --", value 0) does NOT cascade.** `Modules.CreatedByInstructorID` is nullable, but `Questions`, `LearningMaterials`, `PracticeQuestions`, and `ExamQuestions` all have `CreatedByInstructorID`/`InstructorID` as `NOT NULL` — there's no valid "unowned" state for those rows. Unassigning only clears the module-level label; the existing subtopics/questions/materials keep whatever instructor currently owns them. This is intentional, not a bug — do not attempt to force those columns to `NULL`.

### Admin/Challenges.aspx — Global Challenges
- Create form: title, description, XP reward, start/end date → inserts into `Challenges` with `CreatedByAdminID = current admin` and `IsGlobalAdminChallenge = 1` (per Section 24, exactly one creator field is set).
- List of existing global challenges with participant counts and Delete.
- These appear alongside instructor-created challenges on `Student/Challenges.aspx` (that page does not filter by creator — no student-facing change needed).

### Admin/Reports.aspx — Review & Moderate Content
- Lists `Reports` rows filtered/sorted by status (`Open`, `Reviewed`, `ActionTaken`, `Dismissed`).
- Admin can change a report's status and add resolution notes; status transitions are logged to `AuditLogs`.
- `ReportedContentType`/`ReportedContentID` are polymorphic (Section 27) — validate `ReportedContentType` against a known allowlist before using it to look up content, never build dynamic SQL from it.

### Admin/AuditLogs.aspx — Searchable Activity Log
- Full searchable/filterable view of `AuditLogs` (by action type, target table, date range, admin).
- Replaces the old Overview tab's "last 10 rows" preview with the complete, filterable log.

### Admin/Notifications.aspx and Admin/Profile.aspx
Standard notification inbox and profile/account settings pages, consistent with the equivalent Student/Instructor pages.

### What Admin still CANNOT do (explicitly out of scope per user decision)
- Cannot edit `SubscriptionPlans` pricing/features — fixed in code on `Student/Upgrade.aspx`.
- Cannot review/approve FunRooms — feature was already deleted from this project.
- Cannot configure XP formulas, badge algorithms, or leaderboard structures — no gamification settings page exists or is planned.
- Still cannot manage `BossFightRooms`/`Bosses` or `ConsultationSlots`/`ConsultationBookings` through a dedicated Admin UI — those remain Student/Instructor-facing only.

### Setup note
Run `Database/admin_setup.sql` once to confirm you have at least one `Admins` row and to see the current `LicenseStatus` of every seeded instructor. It is read-only by default (the bulk-approve UPDATE is commented out) — approve instructors through `Admin/InstructorApprovals.aspx` instead.


## 44. Consultations Feature — Full History (Permanently Removed)

Consultations (Student + Instructor) went through a full cycle:
1. Built originally (Task 4) as `Instructor/Consultations.aspx` + `Student/Consultations.aspx`, using `ConsultationSlots`/`ConsultationBookings`.
2. Deleted during the 30-page squeeze (Task 6) to hit the lecturer's original page limit.
3. Rebuilt as 2 dedicated pages when the budget was raised to 40 (Task 7), to help balance Instructor's page count.
4. **Permanently removed again** — the user explicitly said "i dont want consultation anymore." Both pages, their `.aspx.cs`/`.aspx.designer.cs` files, `csproj` entries, and `Site.Master` nav links (Instructor and Student panels) were deleted.

**Current state:** no Consultation pages exist. Do not rebuild `Instructor/Consultations.aspx`, `Student/Consultations.aspx`, or their nav links unless the user explicitly asks again. The `ConsultationSlots`/`ConsultationBookings` tables remain in the schema (never dropped) but are unused — same status as `FunRooms` and `PracticeQuestions`.

**Current page count impact:** removing these 2 pages brings the total from 40 down to **38** (Instructor 10, Student 16). See Section 39 for the full current breakdown.


## 45. Demo/Test Data Scripts (Added)

`Database/demo_instructor_approval.sql` — creates one demo instructor account (`jane.demo@cloudphoria.test` / `Demo@123`) with `LicenseStatus = 'Pending'`, specifically so the `Admin/InstructorApprovals.aspx` Approve/Reject flow can be demoed without needing a real registration. Idempotent — safe to re-run, it resets the demo account back to `Pending` instead of erroring on duplicate email. Not part of the main setup sequence (Section 13 of DataSchema); run it on demand whenever you want to demo the approval flow.


## 46. Report an Issue — Student/Instructor Submission Path (Added)

Previously there was no way for a Student or Instructor to actually create a `Reports` row — `Admin/Reports.aspx` only read/updated existing reports, with no submission form anywhere. This is now fixed:

- **`Student/Profile.aspx`** and **`Instructor/Profile.aspx`** each got a new "Report an Issue" card at the bottom of the page (below the existing account/stats cards).
- Form fields: a `ReportedContentType` dropdown (`User` / `Classroom` / `Challenge` / `Other`) and a required free-text `Reason` textarea.
- Submitting inserts into `Reports` with `Status = 'Open'` and `ReportedByUserID` = the current session user. `ReportedUserID` and `ReportedContentID` are left `NULL` — this is a simple "describe the issue" form, not a structured "report this specific row" button. If a more granular report-this-item flow is wanted later, it can be added per-feature (e.g. a report link inside `ClassroomDetail.aspx` chat), but that was not requested.
- No new page was created — added to the existing Profile pages to avoid growing the page count.
- Reports submitted this way immediately appear in `Admin/Reports.aspx` under the `Open` filter, using the exact same table both pages already shared.


## 47. Instructor Classroom Material Upload (Added)

Previously `ClassroomMaterials` was a fully defined table with a working reader (`Student/ClassroomDetail.aspx` Files & Attachments tab), but **no writer existed anywhere** — instructors had no way to actually upload a file into a specific classroom. `Instructor/Materials.aspx` only handles `LearningMaterials` (subtopic-level lesson attachments), a different table entirely. This is now fixed:

- **`Instructor/Classrooms.aspx`** — when an instructor clicks "View Students" on a classroom (`?id=` in the query string), a new "Classroom Materials" section now appears below the enrolled-students table, alongside an "Upload Material" button opening a modal.
- Upload validation matches `Instructor/Materials.aspx` exactly: extension allowlist (PDF, DOCX, DOC, PPTX, PPT, TXT, PNG, JPG, JPEG), 10 MB max, safe stored filename (timestamp + sanitised original name), ownership check (`Classrooms.InstructorID` must match session user) before saving.
- Files are physically saved to `/uploads/classroom/{ClassroomID}/`, matching the path convention already documented in Section 29 and in the DataSchema doc's naming-convention table — this was previously just a documented convention with no code actually using it.
- Materials list on this page also supports Delete (removes DB row + physical file, ownership-checked).
- No schema changes, no new page — reuses the existing `ClassroomMaterials` table and adds the missing CRUD to the existing `Instructor/Classrooms.aspx` page.
- Students immediately see uploaded materials in `Student/ClassroomDetail.aspx`'s Files & Attachments tab — no separate publish step, since both pages read/write the same table.

## 45. Git Reset and Merge Conflict Resolution (Historical — Admin Pages)

At one point the local repo was hard-reset to `origin/master` (`git fetch` + `git reset --hard origin/master` + `git clean -fd`) at the user's explicit request ("i want to the newest and latest"), discarding an unpushed local commit that contained earlier Admin-page work from this same session. The resulting `origin/master` commit itself had a bad merge landed directly on it by a teammate — 24 files under `Admin/` (`AuditLogs`, `Challenges`, `Dashboard`, `InstructorApprovals`, `Notifications`, `Profile`, `Reports`, `Users`, each `.aspx`/`.cs`/`.designer.cs`) contained literal unresolved `<<<<<<< HEAD` / `=======` / `>>>>>>>` conflict markers, and the build failed with ~147 errors.

**Resolution applied:** every conflict was resolved in favour of the side matching this session's established conventions (`ConnStr`/`AdminID` properties, `ShowSuccess`/`ShowError` helpers, `?manageQuestions=`/`?moduleID=`/`?subTopicID=` query-string drill-down pattern) rather than the teammate's independently-built HEAD side, because the Student-side Challenges quiz flow (Section 24/39) and the Admin content-ownership model (Section 12) structurally depend on that version, and because the HEAD side's `Dashboard.aspx.cs` still referenced the permanently-deleted FunRooms feature (`LoadPendingFunRooms`/`litPendingFunRooms`), directly violating Section 22's "do not rebuild FunRooms" rule.

Three extra Admin pages that existed only on the teammate's HEAD side were deleted entirely (`.aspx`/`.cs`/`.designer.cs` each): `Admin/BossFights.aspx` (admin room creation — not part of any tested/documented flow), `Admin/FunRoomReviews.aspx` (**violates the deleted-FunRooms policy directly**), `Admin/LearningContent.aspx` (duplicated module/content moderation already covered by `Admin/Courses.aspx`, Section 12b).

`CloudPhoria.csproj` was cleaned up to match: the `<Compile Include>` ItemGroup had picked up duplicate entries (Users, InstructorApprovals, Challenges, Reports each listed twice) and dangling references to the three deleted pages' code-behind files — all removed, leaving exactly 18 Compile entries for the 9 Admin pages (2 files each).

One residual compile error surfaced after the conflict resolution: `Admin/InstructorApprovals.aspx.cs`'s `rptPendingInstructors_ItemCommand` handler used `RepeaterCommandEventArgs` without the `using System.Web.UI.WebControls;` directive (the merged-in HEAD-side handler needed it, the file's using block hadn't been updated). Added the missing `using` statement; build is now 0 errors.

**Current verified state:** Admin folder = exactly 9 pages (Dashboard, Users, InstructorApprovals, Courses, Challenges, Reports, AuditLogs, Notifications, Profile), matching Section 0's page count. `Student/Challenges.aspx.cs` and `Student/Exams.aspx.cs` were confirmed intact on `origin/master` (Section 17/24 fixes present, no stub `TODO` left). `Student/Upgrade.aspx` was checked and has no stale "Fun Rooms"/"Practice quizzes" text — that specific complaint was already resolved upstream. No `<<<<<<<` markers remain anywhere in the repo (verified via repo-wide search) and `Site.Master`'s `======` occurrences are decorative comment-block banners, not conflict markers.

If a future teammate's branch reintroduces a conflicting version of any Admin page, resolve in favour of the pattern documented in this section and re-run this same verification (grep for conflict markers repo-wide, rebuild, check Admin page count, check FunRooms is not reintroduced) before pushing.
