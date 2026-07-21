# CloudPhoria Database Schema Guide

> **Group 14 | CT050-3-2-WAPP**
> **Important rule:** Use the exact table names and column names shown here. Do not rename columns in website code unless the SQL database schema is officially changed.

---

## 0. CURRENT STATE SNAPSHOT (Read This First)

This document is long and cumulative — sections were appended as the project evolved rather than rewritten in place, so later sections correct or supersede earlier ones. If you are a Kiro instance new to this project, read this snapshot first instead of reading top to bottom; it is verified directly against the actual `.cs` files on disk, not just against what earlier sections claim.

**Tables genuinely orphaned (created, possibly seeded, but zero `.cs` file anywhere reads or writes them):**
- `FunRooms`, `FunRoomQuestions`, `FunRoomQuestionOptions` — feature permanently deleted, do not rebuild
- `PracticeQuestionOptions`, `PracticeAttempts`, `PracticeAnswers` — no page lets anyone take a practice quiz
- `DiscussionThreads`, `DiscussionReplies` — forum feature deleted
- `ConsultationSlots`, `ConsultationBookings` — built, deleted, rebuilt, deleted again (final state: deleted, see Section 15)
- `GuestModuleAccess` — guest browsing uses in-code `isGuest` flags instead, this table was never wired up

**`ChallengeQuestions`/`ChallengeQuestionOptions` are NO LONGER orphaned** — a full quiz-taking + question-management UI was built (see "Challenges — Fixed" in Section 10 below), so they're intentionally NOT in the orphaned list above.

**Table that LOOKS orphaned but isn't:** `PracticeQuestions` (no page uses it for its original practice-quiz purpose, but `Admin/Courses.aspx.cs`'s module-reassignment cascade still runs `UPDATE PracticeQuestions SET CreatedByInstructorID=...` against it — see Section 15b). Don't assume every "Practice*" table is dead code.

**Current page count: 38** (Admin 9 / Instructor 10 / Student 16 / Shared 3). Full breakdown and history in `CloudPhoria_ProjectRules.md` Section 0 and Section 39.

**IMPORTANT — the 5 "original" root-level scripts referenced throughout this document (`create_tables.sql`, `seed_constants.sql`, `seed_dummy_data.sql`, `cloudphoria_additional_content.sql`, `cloudphoria_exams_and_bossfights.sql`) DO NOT EXIST anywhere in this repository or in git history.** Confirmed by both a file search and `git log --all --diff-filter=D` (searching for deleted files too) — zero matches. Every actual `.sql` file in this project lives in the `Database/` folder (16 files, listed in Section 13's run order table below). This means one of two things: either a teammate has these 5 files locally and never committed/shared them, or they were planned/described in documentation but never actually created. **Do not assume these 5 scripts exist or can be run — verify with the user or your teammates before treating Section 2's or Section 13's run order as executable as written.** If you need to set up a fresh database and these files are genuinely missing, you likely need to either ask the user for them or reconstruct the base schema from what's referenced across all the `Database/*.sql` scripts and this document's table definitions (Sections A–J below).

**If a rule/table description in a numbered section below seems to contradict this snapshot or contradicts `CloudPhoria_ProjectRules.md`, trust the code on disk.** Use `grep`/search for the actual table name across `.cs` files before assuming a documented feature works as described — this document has been wrong before (see the Challenges correction) and was fixed only after someone actually checked.

---

## 1. Database Name

```sql
CloudPhoria
```

> ⚠️ **Naming inconsistency in the current script — UNVERIFIABLE, see Section 0.** This note claims `create_tables.sql` runs `USE CloudPhoria;` while `seed_constants.sql`/`seed_dummy_data.sql` run `USE CloudPhoriaDB;`. **None of these three files exist in this repository or in git history** (verified — see Section 0's snapshot). This warning cannot currently be verified against real files. It's kept here as a historical note in case those files exist locally on a teammate's machine and get added later — if so, check this inconsistency before running them. Every `.sql` file that DOES exist in `Database/` consistently uses `USE CloudPhoria; GO` (confirmed by reading all 16 files), so if/when the missing scripts resurface, standardise them on `CloudPhoria` to match.

Always run scripts using:

```sql
USE CloudPhoria;
GO
```

---

## 2. SQL Script Run Order

The database is built up from five scripts, run in this order, each as a single batch:

| Order | Section | Purpose |
|---:|---|---|
| 1 | `create_tables.sql` | Creates the `CloudPhoria` database objects — 52 tables, PKs, FKs, unique constraints, check constraints, and indexes. Includes the core schema plus the Boss Fight Fun Rooms extension. |
| 2 | `seed_constants.sql` | Inserts seeded/constant data: subscription plans, pathways, certifications. |
| 3 | `seed_dummy_data.sql` | Inserts sample users, students, instructors, admins, and all activity data (modules, subtopics, quizzes, exams, progress, XP, badges, classrooms, forums, boss fights, etc.). |
| 4 | `cloudphoria_additional_content.sql` | Fills out `Modules`/`SubTopics`/`LearningMaterials`/`Questions`/`AnswerOptions` so every one of the 7 `Pathways` has 4–8 modules and every module has 3+ subtopics. |
| 5 | `cloudphoria_exams_and_bossfights.sql` | Tops up `PracticeQuestions` and `ExamQuestions` to 10 per module, and adds `Bosses` + `BossFightQuestions`/`BossFightQuestionOptions` for `BossFightRooms` 5–12. |

None of these five scripts create or alter tables — steps 2–5 are all `INSERT`s into the 52 tables created in step 1. Do not run any insert step before table creation, and don't run steps 4–5 against a fresh/empty database — they reference existing `ModuleID`/`RoomID` values, so they need steps 1–3 done first. If SQL Server says `Invalid object name`, it normally means table creation did not run successfully, the query ran against the wrong database, or the `USE` statement mismatch described in Section 1 above sent the insert statements to a different database than the tables were created in.

---

## 3. Global Naming and Coding Rules

- SQL Server schema is `dbo` (default, not explicitly qualified anywhere in the script).
- ID columns are `INT IDENTITY(1,1)` surrogate keys (auto-incrementing integers), **not** string IDs. Reference by integer, e.g. `StudentID = 5`.
- Three tables (`Students`, `Instructors`, `Admins`) use a **shared-PK / role-table pattern**: their primary key is *also* a foreign key back to `Users.UserID`. A user row is created once in `Users`, then a matching row is inserted into exactly one of `Students`, `Instructors`, or `Admins` using the same ID. Do not generate a new ID for the role table.
- `BIT` values are stored as `1` or `0` in SQL Server.
- Use ISO date format in SQL inserts and updates: `YYYY-MM-DD` or `YYYY-MM-DD HH:MM:SS`.
- Content is **English-only** — there is no `EN`/`BM` bilingual column pattern in this schema (unlike some other coursework schemas your groupmates may have seen).
- Current check constraints allow these values:
  - `Users.Role`: `Student`, `Instructor`, `Admin`
  - `Instructors.LicenseStatus`: `Pending`, `Approved`, `Rejected`
  - `Modules.DifficultyLevel`: `Easy`, `Medium`, `Hard`
  - `AssignmentQuestions.QuestionType`: `Objective`, `Subjective`
  - `Questions.QuestionType`: `MCQ`, `Regex`, `StringMatch`
  - `SubTopicProgress.Status` / `ModuleProgress.Status`: `NotStarted`, `InProgress`, `Completed`
  - `XPTransactions.SourceType`: `SubTopic`, `ModuleExam`, `Challenge`, `FunRoom`, `Bonus`, `BossFight`
  - `FunRooms.Status`: `Pending`, `Approved`, `Rejected`
  - `ConsultationBookings.Status`: `Pending`, `Confirmed`, `Cancelled`
  - `Reports.Status`: `Open`, `Reviewed`, `ActionTaken`, `Dismissed`
  - `BossFightRooms.DifficultyLevel`: `Easy`, `Medium`, `Hard`, `Legendary`
  - `BattleSessions.Status`: `InProgress`, `Won`, `Lost`, `Abandoned`

---

## 4. File Path Rules

All stored file/image paths in the sample data follow this convention:

| Table | Column | Convention Used In Sample Data | Example |
|---|---|---|---|
| `ClassroomMaterials` | `FilePath` | `/uploads/classroom/{ClassroomID}/filename.ext` | `/uploads/classroom/1/week1-slides.pdf` |
| `LearningMaterials` | `FilePath` | `/uploads/materials/filename.ext` | `/uploads/materials/cloud-overview.pdf` |
| `Badges` | `IconPath` | `/uploads/badges/filename.png` | `/uploads/badges/cloud-starter.png` |
| `Bosses` | `IconPath` | `/uploads/bosses/filename.png` | `/uploads/bosses/firewall-beast.png` |

### Path Handling Rules for Website Code

- Store relative/web-root paths only — never local machine paths like `C:\Users\...`.
- For web display, combine the database value with the project's static file base URL.
- `LearningMaterials.FileName` stores the human-readable original filename separately from `FilePath` (the stored/served path) — display `FileName` to users, use `FilePath` to serve the file.
- Treat `NULL` as "no attachment/no icon" wherever these columns are nullable.

---

## 5. Table Summary

52 tables, grouped by feature area.

| # | Table | Purpose |
|---:|---|---|
| 1 | `Users` | Login credentials, role, active/banned status. |
| 2 | `Students` | Student-specific profile: TP number, total XP. |
| 3 | `Instructors` | Instructor-specific profile: qualification, license approval status. |
| 4 | `Admins` | Admin-specific marker row (no extra columns). |
| 5 | `SubscriptionPlans` | Seeded lookup: Free / Pro / Student plans. |
| 6 | `UserSubscriptions` | Which plan each student currently holds. |
| 7 | `Classrooms` | Instructor-owned classroom with an invite code. |
| 8 | `ClassroomEnrollments` | Students enrolled into a classroom. |
| 9 | `ClassroomMaterials` | Files instructors upload for a classroom. |
| 10 | `ClassroomAssignments` | Assignments set by an instructor in a classroom. |
| 11 | `AssignmentQuestions` | Questions inside a classroom assignment (Objective/Subjective). |
| 12 | `AssignmentQuestionOptions` | MCQ-style options for Objective assignment questions. |
| 13 | `AssignmentSubmissions` | Student answers to assignment questions. |
| 14 | `Pathways` | Top-level learning tracks (e.g. Cloud Fundamentals, DevOps Engineer). |
| 15 | `Modules` | Units of learning inside a pathway; supports prerequisites and a visual roadmap position. |
| 16 | `SubTopics` | Lesson content inside a module. |
| 17 | `LearningMaterials` | Instructor-uploaded files attached to a subtopic. |
| 18 | `Questions` | Inline "TryHackMe-style" subtopic questions (MCQ/Regex/StringMatch). |
| 19 | `AnswerOptions` | Options for MCQ subtopic questions. |
| 20 | `PracticeQuestions` | Module-level practice/mock questions (unlimited attempts). |
| 21 | `PracticeQuestionOptions` | Options for practice questions. |
| 22 | `PracticeAttempts` | A practice session, by student or guest session. |
| 23 | `PracticeAnswers` | Answers given during a practice attempt. |
| 24 | `ExamQuestions` | Module final-exam questions. |
| 25 | `ExamQuestionOptions` | Options for exam questions. |
| 26 | `ExamAttempts` | A timed exam attempt with score/pass result. |
| 27 | `ExamAnswers` | Answers given during an exam attempt. |
| 28 | `SubTopicProgress` | Per-student completion status of a subtopic. |
| 29 | `ModuleProgress` | Per-student completion status of a module. |
| 30 | `Badges` | Badge earned on completing a specific module. |
| 31 | `UserBadges` | Badges a student has actually earned. |
| 32 | `Certifications` | One certification per non-foundation pathway. |
| 33 | `UserCertifications` | Certifications issued to a student. |
| 34 | `XPTransactions` | XP ledger — every XP-earning event, across all sources. |
| 35 | `GuestModuleAccess` | Tracks anonymous/guest access to modules (no login). |
| 36 | `Challenges` | Time-boxed challenges, instructor- or admin-created. |
| 37 | `ChallengeParticipation` | Student scores in a challenge. |
| 38 | `FunRooms` | Community-authored content rooms with an approval workflow. |
| 39 | `DiscussionThreads` | Forum threads, optionally tied to a subtopic or module. |
| 40 | `DiscussionReplies` | Replies inside a discussion thread. |
| 41 | `ConsultationSlots` | Instructor-defined bookable time slots. |
| 42 | `ConsultationBookings` | Student bookings against a slot. |
| 43 | `Feedback` | Instructor feedback/grade on a student's assignment submission. |
| 44 | `Reports` | User-submitted reports on other users/content, for moderation. |
| 45 | `AuditLogs` | System/admin action audit trail. |
| 46 | `Notifications` | In-app notifications sent to a user. |
| 47 | `BossFightRooms` | Admin-only gamified battle stage (distinct from `FunRooms`). |
| 48 | `Bosses` | The single boss tied to a Boss Fight room. |
| 49 | `BossFightQuestions` | Combat questions used to damage the boss. |
| 50 | `BossFightQuestionOptions` | Options for boss fight questions. |
| 51 | `BattleSessions` | One student's playthrough of a Boss Fight room. |
| 52 | `BattleSessionAnswers` | Turn-by-turn answer log within a battle session. |

---

## 6. Seeded / Mostly Static Tables

Inserted through `seed_constants.sql` — treat as reference/lookup data:

| Table | Notes |
|---|---|
| `SubscriptionPlans` | 3 plans: Free (Foundation-only), Pro, Student. |
| `Pathways` | 7 pathways: 1 Foundation (`IsFoundation = 1`) + 6 specialisations. |
| `Certifications` | 6 certifications, one per non-foundation pathway. |

`Modules`, `SubTopics`, `LearningMaterials`, `Questions`/`AnswerOptions`, `PracticeQuestions`, `ExamQuestions`, `Badges`, `BossFightRooms`, and `Bosses`/`BossFightQuestions` are instructor/admin-authored content, seeded via `seed_dummy_data.sql` and topped up via `cloudphoria_additional_content.sql` and `cloudphoria_exams_and_bossfights.sql` — in production these grow as instructors/admins publish new content, so treat them as **managed content**, not fixed constants.

Current state after all 5 scripts:

| Table | Rows | Notes |
|---|---:|---|
| `Modules` | 53 | Spans all 7 `Pathways`, 4–8 modules each. |
| `SubTopics` | 3+ per module | Every module has at least 3. |
| `PracticeQuestions` / `ExamQuestions` | 10 per module | |
| `BossFightRooms` | 12 | |
| `Bosses` | 12 | Every room now has exactly one boss (1:1). |

**Note:** `seed_dummy_data.sql` has been re-run more than once without an idempotency guard, which is why `Modules`/`BossFightRooms` counts include duplicate copies, and why rooms 5–12 were briefly missing a `Boss` row (fixed by `cloudphoria_exams_and_bossfights.sql`). This is a data/process issue, not a schema issue — no table or constraint needs to change for it — and it isn't being fixed as part of this update.

---

## 7. Account, Access, and Status Rules

### User Login Rules

- Login uses `dbo.Users`.
- Email/password must match (`PasswordHash` — sample data stores plaintext `'password123'` for demo purposes only; **real deployment must store a proper password hash**, e.g. bcrypt).
- Only `IsActive = 1` users can log in.
- `IsBanned = 1` users cannot log in, regardless of `IsActive`.

### User Roles

Allowed by check constraint on `Users.Role`:

- `Student`
- `Instructor`
- `Admin`

Each role has a matching row in `Students`, `Instructors`, or `Admins` sharing the same ID as `Users.UserID`.

### Instructor License Status

Use these values (`Instructors.LicenseStatus`) in application logic:

| Status | Meaning |
|---|---|
| `Pending` | Instructor has restricted access while waiting for admin approval. |
| `Approved` | Instructor can create classrooms, modules, subtopics, materials, questions, etc. |
| `Rejected` | Instructor is restricted and may need to resubmit qualifications. |

`Instructors.ApprovedBy` / `ApprovedAt` record which admin approved the instructor and when.

### Content Review / Publish Status

- Teacher-created `Modules` and `SubTopics` use `IsPublished` (BIT) rather than a text status — `1` = visible to students, `0` = draft/hidden.
- `FunRooms.Status` uses a text workflow: `Pending` → `Approved`/`Rejected`, reviewed by `ReviewedByAdminID`.
- `BossFightRooms.IsPublished` (BIT) — Admin-authored, no review workflow needed since Admin is the sole author.

---

## 8. Main Learning Structure

The main content hierarchy is:

```text
Pathway
  -> Module (supports PrerequisiteModuleID for sequencing)
      -> SubTopic
          -> LearningMaterials
          -> Questions -> AnswerOptions
      -> PracticeQuestions -> PracticeQuestionOptions
      -> ExamQuestions -> ExamQuestionOptions
      -> Badges
```

Student progress links into this structure through:

```text
Student
  -> SubTopicProgress
  -> ModuleProgress
  -> PracticeAttempts -> PracticeAnswers
  -> ExamAttempts -> ExamAnswers
  -> UserBadges
  -> UserCertifications
  -> XPTransactions
  -> GuestModuleAccess (anonymous/no-login variant, keyed by GuestSessionID instead of StudentID)
```

Classroom (instructor-led cohort) features link through:

```text
Instructor
  -> Classroom
      -> ClassroomEnrollments (Students)
      -> ClassroomMaterials
      -> ClassroomAssignments
          -> AssignmentQuestions -> AssignmentQuestionOptions
          -> AssignmentSubmissions
              -> Feedback
```

Gamification (Boss Fight Fun Rooms — admin-only, separate from community `FunRooms`) links through:

```text
Admin
  -> BossFightRoom
      -> Boss (1:1)
      -> BossFightQuestions -> BossFightQuestionOptions

Student
  -> BattleSession
      -> BattleSessionAnswers
```

Community & communication features use:

```text
Forum:
  DiscussionThreads (optionally on a SubTopic or Module)
    -> DiscussionReplies

FunRooms  (community content, Pending/Approved/Rejected review by Admin)

Challenges -> ChallengeParticipation

ConsultationSlots (Instructor) -> ConsultationBookings (Student)
```

Moderation & system tables (`Reports`, `AuditLogs`, `Notifications`) reference `Users` directly and can point at content in any of the tables above via loosely-typed `ReportedContentType` / `TargetTable` string columns (not enforced FKs — see Section 10 note).

---

## 9. Main Foreign Key Relationships

| Child Table | FK Column | Parent Table | Parent Column | Constraint Name |
|---|---|---|---|---|
| `Students` | `StudentID` | `Users` | `UserID` | `FK_Students_Users` |
| `Instructors` | `InstructorID` | `Users` | `UserID` | `FK_Instructors_Users` |
| `Instructors` | `ApprovedBy` | `Users` | `UserID` | `FK_Instructors_Approved` |
| `Admins` | `AdminID` | `Users` | `UserID` | `FK_Admins_Users` |
| `UserSubscriptions` | `StudentID` | `Students` | `StudentID` | `FK_UserSubs_Students` |
| `UserSubscriptions` | `PlanID` | `SubscriptionPlans` | `PlanID` | `FK_UserSubs_Plans` |
| `Classrooms` | `InstructorID` | `Instructors` | `InstructorID` | `FK_Classrooms_Instructors` |
| `ClassroomEnrollments` | `ClassroomID` | `Classrooms` | `ClassroomID` | `FK_Enroll_Classrooms` |
| `ClassroomEnrollments` | `StudentID` | `Students` | `StudentID` | `FK_Enroll_Students` |
| `ClassroomMaterials` | `ClassroomID` | `Classrooms` | `ClassroomID` | `FK_CMaterials_Classrooms` |
| `ClassroomMaterials` | `InstructorID` | `Instructors` | `InstructorID` | `FK_CMaterials_Instructors` |
| `ClassroomAssignments` | `ClassroomID` | `Classrooms` | `ClassroomID` | `FK_Assignments_Classrooms` |
| `ClassroomAssignments` | `InstructorID` | `Instructors` | `InstructorID` | `FK_Assignments_Instructors` |
| `AssignmentQuestions` | `AssignmentID` | `ClassroomAssignments` | `AssignmentID` | `FK_AQ_Assignments` |
| `AssignmentQuestionOptions` | `AssignmentQuestionID` | `AssignmentQuestions` | `AssignmentQuestionID` | `FK_AQOptions_Questions` |
| `AssignmentSubmissions` | `AssignmentID` | `ClassroomAssignments` | `AssignmentID` | `FK_Submissions_Assignments` |
| `AssignmentSubmissions` | `AssignmentQuestionID` | `AssignmentQuestions` | `AssignmentQuestionID` | `FK_Submissions_Questions` |
| `AssignmentSubmissions` | `StudentID` | `Students` | `StudentID` | `FK_Submissions_Students` |
| `Modules` | `PathwayID` | `Pathways` | `PathwayID` | `FK_Modules_Pathways` |
| `Modules` | `PrerequisiteModuleID` | `Modules` | `ModuleID` | `FK_Modules_Prerequisite` (self-referencing) |
| `Modules` | `CreatedByInstructorID` | `Instructors` | `InstructorID` | `FK_Modules_Instructors` |
| `SubTopics` | `ModuleID` | `Modules` | `ModuleID` | `FK_SubTopics_Modules` |
| `SubTopics` | `CreatedByInstructorID` | `Instructors` | `InstructorID` | `FK_SubTopics_Instructors` |
| `LearningMaterials` | `SubTopicID` | `SubTopics` | `SubTopicID` | `FK_Materials_SubTopics` |
| `LearningMaterials` | `InstructorID` | `Instructors` | `InstructorID` | `FK_Materials_Instructors` |
| `Questions` | `SubTopicID` | `SubTopics` | `SubTopicID` | `FK_Questions_SubTopics` |
| `Questions` | `CreatedByInstructorID` | `Instructors` | `InstructorID` | `FK_Questions_Instructors` |
| `AnswerOptions` | `QuestionID` | `Questions` | `QuestionID` | `FK_Options_Questions` |
| `PracticeQuestions` | `ModuleID` | `Modules` | `ModuleID` | `FK_PQ_Modules` |
| `PracticeQuestions` | `CreatedByInstructorID` | `Instructors` | `InstructorID` | `FK_PQ_Instructors` |
| `PracticeQuestionOptions` | `PracticeQuestionID` | `PracticeQuestions` | `PracticeQuestionID` | `FK_PQOptions_Questions` |
| `PracticeAttempts` | `ModuleID` | `Modules` | `ModuleID` | `FK_PA_Modules` |
| `PracticeAttempts` | `StudentID` | `Students` | `StudentID` | `FK_PA_Students` (nullable — guest support) |
| `PracticeAnswers` | `AttemptID` | `PracticeAttempts` | `AttemptID` | `FK_PAnswers_Attempts` |
| `PracticeAnswers` | `PracticeQuestionID` | `PracticeQuestions` | `PracticeQuestionID` | `FK_PAnswers_Questions` |
| `PracticeAnswers` | `SelectedOptionID` | `PracticeQuestionOptions` | `OptionID` | `FK_PAnswers_Options` |
| `ExamQuestions` | `ModuleID` | `Modules` | `ModuleID` | `FK_EQ_Modules` |
| `ExamQuestions` | `CreatedByInstructorID` | `Instructors` | `InstructorID` | `FK_EQ_Instructors` |
| `ExamQuestionOptions` | `ExamQuestionID` | `ExamQuestions` | `ExamQuestionID` | `FK_EQOptions_Questions` |
| `ExamAttempts` | `StudentID` | `Students` | `StudentID` | `FK_ExamAttempts_Students` |
| `ExamAttempts` | `ModuleID` | `Modules` | `ModuleID` | `FK_ExamAttempts_Modules` |
| `ExamAnswers` | `ExamAttemptID` | `ExamAttempts` | `ExamAttemptID` | `FK_EA_Attempts` |
| `ExamAnswers` | `ExamQuestionID` | `ExamQuestions` | `ExamQuestionID` | `FK_EA_Questions` |
| `ExamAnswers` | `SelectedOptionID` | `ExamQuestionOptions` | `OptionID` | `FK_EA_Options` |
| `SubTopicProgress` | `StudentID` | `Students` | `StudentID` | `FK_STProg_Students` |
| `SubTopicProgress` | `SubTopicID` | `SubTopics` | `SubTopicID` | `FK_STProg_SubTopics` |
| `ModuleProgress` | `StudentID` | `Students` | `StudentID` | `FK_ModProg_Students` |
| `ModuleProgress` | `ModuleID` | `Modules` | `ModuleID` | `FK_ModProg_Modules` |
| `Badges` | `ModuleID` | `Modules` | `ModuleID` | `FK_Badges_Modules` |
| `UserBadges` | `StudentID` | `Students` | `StudentID` | `FK_UserBadges_Students` |
| `UserBadges` | `BadgeID` | `Badges` | `BadgeID` | `FK_UserBadges_Badges` |
| `Certifications` | `PathwayID` | `Pathways` | `PathwayID` | `FK_Certs_Pathways` |
| `UserCertifications` | `StudentID` | `Students` | `StudentID` | `FK_UserCerts_Students` |
| `UserCertifications` | `CertificationID` | `Certifications` | `CertificationID` | `FK_UserCerts_Certs` |
| `XPTransactions` | `StudentID` | `Students` | `StudentID` | `FK_XPTransactions_Students` |
| `GuestModuleAccess` | `ModuleID` | `Modules` | `ModuleID` | `FK_GuestAccess_Modules` |
| `Challenges` | `CreatedByInstructorID` | `Instructors` | `InstructorID` | `FK_Challenges_Instructors` |
| `Challenges` | `CreatedByAdminID` | `Admins` | `AdminID` | `FK_Challenges_Admins` |
| `ChallengeParticipation` | `ChallengeID` | `Challenges` | `ChallengeID` | `FK_Participation_Challenges` |
| `ChallengeParticipation` | `StudentID` | `Students` | `StudentID` | `FK_Participation_Students` |
| `FunRooms` | `CreatedByUserID` | `Users` | `UserID` | `FK_FunRooms_Users` |
| `FunRooms` | `ReviewedByAdminID` | `Admins` | `AdminID` | `FK_FunRooms_Admins` |
| `DiscussionThreads` | `SubTopicID` | `SubTopics` | `SubTopicID` | `FK_Threads_SubTopics` (nullable) |
| `DiscussionThreads` | `ModuleID` | `Modules` | `ModuleID` | `FK_Threads_Modules` (nullable) |
| `DiscussionThreads` | `CreatedByUserID` | `Users` | `UserID` | `FK_Threads_Users` |
| `DiscussionReplies` | `ThreadID` | `DiscussionThreads` | `ThreadID` | `FK_Replies_Threads` |
| `DiscussionReplies` | `CreatedByUserID` | `Users` | `UserID` | `FK_Replies_Users` |
| `ConsultationSlots` | `InstructorID` | `Instructors` | `InstructorID` | `FK_Slots_Instructors` |
| `ConsultationBookings` | `SlotID` | `ConsultationSlots` | `SlotID` | `FK_Bookings_Slots` |
| `ConsultationBookings` | `StudentID` | `Students` | `StudentID` | `FK_Bookings_Students` |
| `Feedback` | `StudentID` | `Students` | `StudentID` | `FK_Feedback_Students` |
| `Feedback` | `InstructorID` | `Instructors` | `InstructorID` | `FK_Feedback_Instructors` |
| `Feedback` | `ClassroomID` | `Classrooms` | `ClassroomID` | `FK_Feedback_Classrooms` |
| `Feedback` | `SubmissionID` | `AssignmentSubmissions` | `SubmissionID` | `FK_Feedback_Submissions` |
| `Reports` | `ReportedByUserID` | `Users` | `UserID` | `FK_Reports_ReportedBy` |
| `Reports` | `ReportedUserID` | `Users` | `UserID` | `FK_Reports_ReportedUser` (nullable) |
| `Reports` | `ReviewedByAdminID` | `Admins` | `AdminID` | `FK_Reports_Admins` (nullable) |
| `AuditLogs` | `PerformedByUserID` | `Users` | `UserID` | `FK_AuditLogs_Users` |
| `Notifications` | `UserID` | `Users` | `UserID` | `FK_Notifications_Users` |
| `BossFightRooms` | `CreatedByAdminID` | `Admins` | `AdminID` | `FK_BossFightRooms_Admins` |
| `Bosses` | `RoomID` | `BossFightRooms` | `RoomID` | `FK_Bosses_Rooms` (1:1, `RoomID` is `UNIQUE`) |
| `BossFightQuestions` | `RoomID` | `BossFightRooms` | `RoomID` | `FK_BFQ_Rooms` |
| `BossFightQuestionOptions` | `BossFightQuestionID` | `BossFightQuestions` | `BossFightQuestionID` | `FK_BFQOptions_Questions` |
| `BattleSessions` | `RoomID` | `BossFightRooms` | `RoomID` | `FK_BattleSessions_Rooms` |
| `BattleSessions` | `StudentID` | `Students` | `StudentID` | `FK_BattleSessions_Students` |
| `BattleSessionAnswers` | `SessionID` | `BattleSessions` | `SessionID` | `FK_BSA_Sessions` |
| `BattleSessionAnswers` | `BossFightQuestionID` | `BossFightQuestions` | `BossFightQuestionID` | `FK_BSA_Questions` |
| `BattleSessionAnswers` | `SelectedOptionID` | `BossFightQuestionOptions` | `OptionID` | `FK_BSA_Options` (nullable — `NULL` = timed out) |

> **Not a real FK:** `Reports.ReportedContentType` / `ReportedContentID` and `AuditLogs.TargetTable` / `TargetID` are **loosely-typed polymorphic references** (a string table name + an integer ID), not enforced foreign keys. Application code must validate `ReportedContentType`/`TargetTable` against a known set of table names (e.g. `'FunRoom'`, `'DiscussionReply'`, `'Instructors'`, `'Users'`) and must not assume the database will catch a typo or a dangling reference here.

---

## 10. Check Constraints

| Table | Column | Rule |
|---|---|---|
| `Users` | `Role` | `IN ('Student','Instructor','Admin')` |
| `Instructors` | `LicenseStatus` | `DEFAULT 'Pending'`, `IN ('Pending','Approved','Rejected')` |
| `Modules` | `DifficultyLevel` | `IN ('Easy','Medium','Hard')` |
| `AssignmentQuestions` | `QuestionType` | `IN ('Objective','Subjective')` |
| `Questions` | `QuestionType` | `IN ('MCQ','Regex','StringMatch')` |
| `SubTopicProgress` | `Status` | `DEFAULT 'NotStarted'`, `IN ('NotStarted','InProgress','Completed')` |
| `ModuleProgress` | `Status` | `DEFAULT 'NotStarted'`, `IN ('NotStarted','InProgress','Completed')` |
| `XPTransactions` | `SourceType` | `IN ('SubTopic','ModuleExam','Challenge','FunRoom','Bonus','BossFight')` |
| `FunRooms` | `Status` | `DEFAULT 'Pending'`, `IN ('Pending','Approved','Rejected')` |
| `ConsultationBookings` | `Status` | `DEFAULT 'Pending'`, `IN ('Pending','Confirmed','Cancelled')` |
| `Reports` | `Status` | `DEFAULT 'Open'`, `IN ('Open','Reviewed','ActionTaken','Dismissed')` |
| `BossFightRooms` | `DifficultyLevel` | `IN ('Easy','Medium','Hard','Legendary')` |
| `Bosses` | `MaxHP` | `> 0` |
| `Bosses` | `AttackStrength` | `>= 0`, `DEFAULT 10` |
| `Bosses` | `EnrageThresholdPct` | `BETWEEN 0 AND 100` (nullable — `NULL` = boss has no enrage phase) |
| `BossFightQuestions` | `DamageValue` | `> 0`, `DEFAULT 10` |
| `BossFightQuestions` | `TimeLimitSeconds` | `> 0`, `DEFAULT 20` |
| `BattleSessions` | `Status` | `DEFAULT 'InProgress'`, `IN ('InProgress','Won','Lost','Abandoned')` |

**Unique constraints** worth knowing (beyond primary keys):
`Users.Email`, `Students.TPNumber`, `Classrooms.InviteCode`, `Bosses.RoomID` (enforces 1:1 with `BossFightRooms`), and these composite uniques: `ClassroomEnrollments(ClassroomID, StudentID)`, `AssignmentSubmissions(AssignmentQuestionID, StudentID)`, `SubTopicProgress(StudentID, SubTopicID)`, `ModuleProgress(StudentID, ModuleID)`, `UserBadges(StudentID, BadgeID)`, `UserCertifications(StudentID, CertificationID)`, `GuestModuleAccess(GuestSessionID, ModuleID)`, `ChallengeParticipation(ChallengeID, StudentID)`.

**Indexes** created explicitly (beyond PK/UNIQUE auto-indexes): `Users.Email`, `Users.Role`, `UserSubscriptions.StudentID`, `Classrooms.InviteCode`, `ClassroomAssignments.ClassroomID`, `Modules.PathwayID`, `SubTopics.ModuleID`, `Questions.SubTopicID`, `PracticeAttempts.StudentID`, `PracticeAttempts.ModuleID`, `ExamAttempts.StudentID`, `ExamAttempts.ModuleID`, `XPTransactions.StudentID`, `GuestModuleAccess.GuestSessionID`, `AuditLogs.PerformedByUserID`, `AuditLogs.CreatedAt`, `Notifications.UserID`, `BossFightRooms.DifficultyLevel`, `BossFightRooms.IsPublished`, `BossFightQuestions.RoomID`, `BattleSessions.StudentID`, `BattleSessions.RoomID`, `BattleSessions.Status`, `BattleSessionAnswers.SessionID`.

---

# Table Details

## Section A — Users & Access

### 1. `Users`
Base account for every person in the system.

| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `UserID` | `INT IDENTITY(1,1)` | No | PK | Auto-increment. |
| `FullName` | `NVARCHAR(100)` | No | - | |
| `Email` | `NVARCHAR(100)` | No | UNIQUE | Login identifier. |
| `PasswordHash` | `NVARCHAR(256)` | No | - | Store a real hash (bcrypt/etc.) in production — sample data uses plaintext. |
| `Role` | `NVARCHAR(20)` | No | CHECK | `Student` / `Instructor` / `Admin`. |
| `IsActive` | `BIT` | No | DEFAULT 1 | |
| `IsBanned` | `BIT` | No | DEFAULT 0 | |
| `CreatedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |

### 2. `Students`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `StudentID` | `INT` | No | PK, FK → `Users.UserID` | Shared PK pattern — same value as the user's `UserID`. |
| `TPNumber` | `NVARCHAR(20)` | No | UNIQUE | Student ID number (APU-style TP number). |
| `TotalXP` | `INT` | No | DEFAULT 0 | Running total; should reconcile with `SUM(XPTransactions.XPAmount)` for that student. |

### 3. `Instructors`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `InstructorID` | `INT` | No | PK, FK → `Users.UserID` | Shared PK pattern. |
| `Qualification` | `NVARCHAR(100)` | Yes | - | |
| `LicenseStatus` | `NVARCHAR(20)` | No | DEFAULT 'Pending', CHECK | `Pending` / `Approved` / `Rejected`. |
| `ApprovedBy` | `INT` | Yes | FK → `Users.UserID` | The admin who approved/rejected. |
| `ApprovedAt` | `DATETIME2` | Yes | - | |

### 4. `Admins`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `AdminID` | `INT` | No | PK, FK → `Users.UserID` | Shared PK pattern. No other columns. |

---

## Section B — Subscriptions

### 5. `SubscriptionPlans`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `PlanID` | `INT IDENTITY(1,1)` | No | PK | |
| `PlanName` | `NVARCHAR(50)` | No | - | Free / Pro / Student. |
| `Price` | `DECIMAL(10,2)` | No | DEFAULT 0 | |
| `CanAccessFoundationOnly` | `BIT` | No | DEFAULT 0 | `1` on the Free plan restricts access to the Foundation pathway. |
| `Description` | `NVARCHAR(MAX)` | Yes | - | |

### 6. `UserSubscriptions`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `UserSubscriptionID` | `INT IDENTITY(1,1)` | No | PK | |
| `StudentID` | `INT` | No | FK → `Students.StudentID` | |
| `PlanID` | `INT` | No | FK → `SubscriptionPlans.PlanID` | |
| `StartDate` | `DATETIME2` | No | DEFAULT GETDATE() | |
| `EndDate` | `DATETIME2` | Yes | - | `NULL` = no fixed end (e.g. Free plan). |
| `IsActive` | `BIT` | No | DEFAULT 1 | |

---

## Section C — Classroom (Instructor-led Cohorts)

### 7. `Classrooms`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `ClassroomID` | `INT IDENTITY(1,1)` | No | PK | |
| `InstructorID` | `INT` | No | FK → `Instructors.InstructorID` | |
| `ClassroomName` | `NVARCHAR(100)` | No | - | |
| `InviteCode` | `NVARCHAR(20)` | No | UNIQUE | Students self-enrol using this code. |
| `CreatedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |

### 8. `ClassroomEnrollments`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `EnrollmentID` | `INT IDENTITY(1,1)` | No | PK | |
| `ClassroomID` | `INT` | No | FK → `Classrooms.ClassroomID` | |
| `StudentID` | `INT` | No | FK → `Students.StudentID` | |
| `EnrolledAt` | `DATETIME2` | No | DEFAULT GETDATE() | |
| — | — | — | UNIQUE `(ClassroomID, StudentID)` | A student can only enrol once per classroom. |

### 9. `ClassroomMaterials`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `ClassroomMaterialID` | `INT IDENTITY(1,1)` | No | PK | |
| `ClassroomID` | `INT` | No | FK → `Classrooms.ClassroomID` | |
| `InstructorID` | `INT` | No | FK → `Instructors.InstructorID` | |
| `FileName` | `NVARCHAR(255)` | No | - | Original display filename. |
| `FilePath` | `NVARCHAR(500)` | No | - | Stored/served path. |
| `Description` | `NVARCHAR(500)` | Yes | - | |
| `UploadedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |

### 10. `ClassroomAssignments`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `AssignmentID` | `INT IDENTITY(1,1)` | No | PK | |
| `ClassroomID` | `INT` | No | FK → `Classrooms.ClassroomID` | |
| `InstructorID` | `INT` | No | FK → `Instructors.InstructorID` | |
| `Title` | `NVARCHAR(150)` | No | - | |
| `Description` | `NVARCHAR(MAX)` | Yes | - | |
| `DueDate` | `DATETIME2` | Yes | - | |
| `CreatedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |

### 11. `AssignmentQuestions`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `AssignmentQuestionID` | `INT IDENTITY(1,1)` | No | PK | |
| `AssignmentID` | `INT` | No | FK → `ClassroomAssignments.AssignmentID` | |
| `QuestionText` | `NVARCHAR(MAX)` | No | - | |
| `QuestionType` | `NVARCHAR(20)` | No | CHECK | `Objective` (has MCQ options) or `Subjective` (free text). |
| `OrderIndex` | `INT` | No | DEFAULT 0 | |

### 12. `AssignmentQuestionOptions`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `OptionID` | `INT IDENTITY(1,1)` | No | PK | |
| `AssignmentQuestionID` | `INT` | No | FK → `AssignmentQuestions.AssignmentQuestionID` | Only populated for `Objective` questions. |
| `OptionText` | `NVARCHAR(MAX)` | No | - | |
| `IsCorrect` | `BIT` | No | DEFAULT 0 | |

### 13. `AssignmentSubmissions`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `SubmissionID` | `INT IDENTITY(1,1)` | No | PK | |
| `AssignmentID` | `INT` | No | FK → `ClassroomAssignments.AssignmentID` | |
| `AssignmentQuestionID` | `INT` | No | FK → `AssignmentQuestions.AssignmentQuestionID` | |
| `StudentID` | `INT` | No | FK → `Students.StudentID` | |
| `AnswerText` | `NVARCHAR(MAX)` | Yes | - | Freeform text for both Objective (option label) and Subjective answers in the sample data. |
| `SubmittedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |
| — | — | — | UNIQUE `(AssignmentQuestionID, StudentID)` | One submission per student per question. |

---

## Section D — Learning Content (Pathways → Modules → SubTopics)

### 14. `Pathways`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `PathwayID` | `INT IDENTITY(1,1)` | No | PK | |
| `PathwayName` | `NVARCHAR(100)` | No | - | |
| `Description` | `NVARCHAR(MAX)` | Yes | - | |
| `IsFoundation` | `BIT` | No | DEFAULT 0 | `1` for the single "Cloud Fundamentals" foundation pathway; drives the `SubscriptionPlans.CanAccessFoundationOnly` gate. |

### 15. `Modules`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `ModuleID` | `INT IDENTITY(1,1)` | No | PK | |
| `PathwayID` | `INT` | No | FK → `Pathways.PathwayID` | |
| `ModuleName` | `NVARCHAR(150)` | No | - | |
| `Description` | `NVARCHAR(MAX)` | Yes | - | |
| `DifficultyLevel` | `NVARCHAR(10)` | No | CHECK | `Easy` / `Medium` / `Hard`. |
| `PrerequisiteModuleID` | `INT` | Yes | FK → `Modules.ModuleID` (self) | `NULL` = no prerequisite (entry point). |
| `XPReward` | `INT` | No | DEFAULT 0 | XP for passing the module exam. |
| `ExamDurationMinutes` | `INT` | No | DEFAULT 60 | |
| `ExamPassMarkPercent` | `INT` | No | DEFAULT 70 | |
| `IsFoundationOnly` | `BIT` | No | DEFAULT 0 | |
| `RoadmapPositionX` / `RoadmapPositionY` | `INT` | Yes | - | Coordinates for a visual skill-tree/roadmap UI. |
| `CreatedByInstructorID` | `INT` | Yes | FK → `Instructors.InstructorID` | |
| `IsPublished` | `BIT` | No | DEFAULT 0 | Draft vs. visible to students. |
| `CreatedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |

### 16. `SubTopics`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `SubTopicID` | `INT IDENTITY(1,1)` | No | PK | |
| `ModuleID` | `INT` | No | FK → `Modules.ModuleID` | |
| `SubTopicName` | `NVARCHAR(150)` | No | - | |
| `ContentBody` | `NVARCHAR(MAX)` | Yes | - | Lesson text/HTML. |
| `OrderIndex` | `INT` | No | DEFAULT 0 | |
| `XPReward` | `INT` | No | DEFAULT 0 | |
| `CreatedByInstructorID` | `INT` | Yes | FK → `Instructors.InstructorID` | |
| `IsPublished` | `BIT` | No | DEFAULT 0 | |
| `CreatedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |

### 17. `LearningMaterials`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `MaterialID` | `INT IDENTITY(1,1)` | No | PK | |
| `SubTopicID` | `INT` | No | FK → `SubTopics.SubTopicID` | |
| `InstructorID` | `INT` | No | FK → `Instructors.InstructorID` | |
| `FileName` | `NVARCHAR(255)` | No | - | |
| `FilePath` | `NVARCHAR(500)` | No | - | |
| `UploadedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |

---

## Section E — Questions, Practice, and Exams

### 18. `Questions` (inline subtopic questions)
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `QuestionID` | `INT IDENTITY(1,1)` | No | PK | |
| `SubTopicID` | `INT` | No | FK → `SubTopics.SubTopicID` | |
| `QuestionText` | `NVARCHAR(MAX)` | No | - | |
| `QuestionType` | `NVARCHAR(20)` | No | CHECK | `MCQ` / `Regex` / `StringMatch`. |
| `CorrectAnswer` | `NVARCHAR(MAX)` | No | - | For `MCQ`, the correct option is also flagged in `AnswerOptions.IsCorrect`; for `Regex`/`StringMatch`, this column holds the pattern/expected string directly. |
| `OrderIndex` | `INT` | No | DEFAULT 0 | |
| `XPReward` | `INT` | No | DEFAULT 0 | |
| `CreatedByInstructorID` | `INT` | No | FK → `Instructors.InstructorID` | |

### 19. `AnswerOptions`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `OptionID` | `INT IDENTITY(1,1)` | No | PK | |
| `QuestionID` | `INT` | No | FK → `Questions.QuestionID` | Only used when `QuestionType = 'MCQ'`. |
| `OptionText` | `NVARCHAR(MAX)` | No | - | |
| `IsCorrect` | `BIT` | No | DEFAULT 0 | |

### 20. `PracticeQuestions` (module-level mock, unlimited attempts, no timer)
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `PracticeQuestionID` | `INT IDENTITY(1,1)` | No | PK | |
| `ModuleID` | `INT` | No | FK → `Modules.ModuleID` | |
| `QuestionText` | `NVARCHAR(MAX)` | No | - | |
| `OrderIndex` | `INT` | No | DEFAULT 0 | |
| `CreatedByInstructorID` | `INT` | No | FK → `Instructors.InstructorID` | |

### 21. `PracticeQuestionOptions`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `OptionID` | `INT IDENTITY(1,1)` | No | PK | |
| `PracticeQuestionID` | `INT` | No | FK → `PracticeQuestions.PracticeQuestionID` | |
| `OptionText` | `NVARCHAR(MAX)` | No | - | |
| `IsCorrect` | `BIT` | No | DEFAULT 0 | |

### 22. `PracticeAttempts`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `AttemptID` | `INT IDENTITY(1,1)` | No | PK | |
| `ModuleID` | `INT` | No | FK → `Modules.ModuleID` | |
| `StudentID` | `INT` | Yes | FK → `Students.StudentID` | `NULL` when a guest is practising. |
| `GuestSessionID` | `NVARCHAR(100)` | Yes | - | Set instead of `StudentID` for anonymous guests. |
| `AttemptedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |

### 23. `PracticeAnswers`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `PracticeAnswerID` | `INT IDENTITY(1,1)` | No | PK | |
| `AttemptID` | `INT` | No | FK → `PracticeAttempts.AttemptID` | |
| `PracticeQuestionID` | `INT` | No | FK → `PracticeQuestions.PracticeQuestionID` | |
| `SelectedOptionID` | `INT` | No | FK → `PracticeQuestionOptions.OptionID` | |
| `IsCorrect` | `BIT` | No | DEFAULT 0 | |

### 24. `ExamQuestions` (module final exam, timed — see "Exam-taking flow fixed" note below)
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `ExamQuestionID` | `INT IDENTITY(1,1)` | No | PK | |
| `ModuleID` | `INT` | No | FK → `Modules.ModuleID` | |
| `QuestionText` | `NVARCHAR(MAX)` | No | - | |
| `OrderIndex` | `INT` | No | DEFAULT 0 | |
| `CreatedByInstructorID` | `INT` | No | FK → `Instructors.InstructorID` | |

### 25. `ExamQuestionOptions`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `OptionID` | `INT IDENTITY(1,1)` | No | PK | |
| `ExamQuestionID` | `INT` | No | FK → `ExamQuestions.ExamQuestionID` | |
| `OptionText` | `NVARCHAR(MAX)` | No | - | |
| `IsCorrect` | `BIT` | No | DEFAULT 0 | |

### 26. `ExamAttempts`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `ExamAttemptID` | `INT IDENTITY(1,1)` | No | PK | |
| `StudentID` | `INT` | No | FK → `Students.StudentID` | |
| `ModuleID` | `INT` | No | FK → `Modules.ModuleID` | |
| `StartedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |
| `SubmittedAt` | `DATETIME2` | Yes | - | `NULL` while still in progress. |
| `ScorePercent` | `DECIMAL(5,2)` | Yes | - | |
| `IsPassed` | `BIT` | No | DEFAULT 0 | Compare against `Modules.ExamPassMarkPercent`. |
| `XPAwarded` | `INT` | No | DEFAULT 0 | |

### 27. `ExamAnswers`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `ExamAnswerID` | `INT IDENTITY(1,1)` | No | PK | |
| `ExamAttemptID` | `INT` | No | FK → `ExamAttempts.ExamAttemptID` | |
| `ExamQuestionID` | `INT` | No | FK → `ExamQuestions.ExamQuestionID` | |
| `SelectedOptionID` | `INT` | No | FK → `ExamQuestionOptions.OptionID` | |
| `IsCorrect` | `BIT` | No | DEFAULT 0 | |

**Exam-taking flow fixed (previously a stub).** `Student/Exams.aspx.cs` used to have `// TODO: Full exam logic to be re-integrated here` in place of the `?moduleID=X` handler — the exam list rendered correctly and `ExamAttempts`/`ExamAnswers` were fully defined, but nothing ever inserted into either table because "Start Exam" just reloaded the listing page. This is now implemented (same pattern as the Challenges fix): intro screen with locked/already-passed/no-questions checks → `ExamAttempts` row created on start with server-side `StartedAt` → one question at a time from `ExamQuestions`/`ExamQuestionOptions` with shuffled options and a live countdown (server-side authoritative, recomputed from `StartedAt` + `Modules.ExamDurationMinutes` on every request, not trusted from the client) → each answer inserted into `ExamAnswers` → on completion, `ExamAttempts.ScorePercent`/`IsPassed`/`XPAwarded` are updated and XP is awarded via `XPTransactions`(`SourceType='ModuleExam'`)/`Students.TotalXP` only on a student's first pass of that module. No schema changes, no new page — same `.aspx` file as before.

---

## Section F — Progress Tracking

### 28. `SubTopicProgress`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `ProgressID` | `INT IDENTITY(1,1)` | No | PK | |
| `StudentID` | `INT` | No | FK → `Students.StudentID` | |
| `SubTopicID` | `INT` | No | FK → `SubTopics.SubTopicID` | |
| `Status` | `NVARCHAR(20)` | No | DEFAULT 'NotStarted', CHECK | `NotStarted` / `InProgress` / `Completed`. |
| `XPEarned` | `INT` | No | DEFAULT 0 | |
| `CompletedAt` | `DATETIME2` | Yes | - | |
| — | — | — | UNIQUE `(StudentID, SubTopicID)` | One progress row per student per subtopic. |

### 29. `ModuleProgress`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `ProgressID` | `INT IDENTITY(1,1)` | No | PK | |
| `StudentID` | `INT` | No | FK → `Students.StudentID` | |
| `ModuleID` | `INT` | No | FK → `Modules.ModuleID` | |
| `Status` | `NVARCHAR(20)` | No | DEFAULT 'NotStarted', CHECK | `NotStarted` / `InProgress` / `Completed`. |
| `XPEarned` | `INT` | No | DEFAULT 0 | |
| `CompletedAt` | `DATETIME2` | Yes | - | |
| — | — | — | UNIQUE `(StudentID, ModuleID)` | |

---

## Section G — Gamification

### 30. `Badges`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `BadgeID` | `INT IDENTITY(1,1)` | No | PK | |
| `ModuleID` | `INT` | No | FK → `Modules.ModuleID` | One badge is tied to completing this specific module. |
| `BadgeName` | `NVARCHAR(100)` | No | - | |
| `Description` | `NVARCHAR(255)` | Yes | - | |
| `IconPath` | `NVARCHAR(255)` | Yes | - | `/uploads/badges/...` |

### 31. `UserBadges`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `UserBadgeID` | `INT IDENTITY(1,1)` | No | PK | |
| `StudentID` | `INT` | No | FK → `Students.StudentID` | |
| `BadgeID` | `INT` | No | FK → `Badges.BadgeID` | |
| `AwardedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |
| — | — | — | UNIQUE `(StudentID, BadgeID)` | Can't earn the same badge twice. |

### 32. `Certifications`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `CertificationID` | `INT IDENTITY(1,1)` | No | PK | |
| `PathwayID` | `INT` | No | FK → `Pathways.PathwayID` | |
| `CertificateName` | `NVARCHAR(150)` | No | - | |

### 33. `UserCertifications`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `UserCertificationID` | `INT IDENTITY(1,1)` | No | PK | |
| `StudentID` | `INT` | No | FK → `Students.StudentID` | |
| `CertificationID` | `INT` | No | FK → `Certifications.CertificationID` | |
| `IssuedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |
| — | — | — | UNIQUE `(StudentID, CertificationID)` | |

### 34. `XPTransactions`
The single source of truth XP ledger — everything that awards XP writes a row here.

| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `TransactionID` | `INT IDENTITY(1,1)` | No | PK | |
| `StudentID` | `INT` | No | FK → `Students.StudentID` | |
| `SourceType` | `NVARCHAR(30)` | No | CHECK | `SubTopic` / `ModuleExam` / `Challenge` / `FunRoom` / `Bonus` / `BossFight`. |
| `SourceID` | `INT` | Yes | - | ID within the source table named by `SourceType` (e.g. `SubTopicID`, `ModuleID`, `ChallengeID`, `RoomID` for BossFight). **Not an enforced FK** — it's polymorphic, resolved in application code based on `SourceType`. |
| `XPAmount` | `INT` | No | - | |
| `CreatedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |

### 35. `GuestModuleAccess`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `GuestAccessID` | `INT IDENTITY(1,1)` | No | PK | |
| `GuestSessionID` | `NVARCHAR(100)` | No | - | Anonymous session identifier (e.g. a cookie/session token). |
| `ModuleID` | `INT` | No | FK → `Modules.ModuleID` | |
| `AccessedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |
| — | — | — | UNIQUE `(GuestSessionID, ModuleID)` | |

### 36. `Challenges`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `ChallengeID` | `INT IDENTITY(1,1)` | No | PK | |
| `Title` | `NVARCHAR(150)` | No | - | |
| `Description` | `NVARCHAR(MAX)` | Yes | - | |
| `CreatedByInstructorID` | `INT` | Yes | FK → `Instructors.InstructorID` | Exactly one of this or `CreatedByAdminID` should be set (enforce in app logic — not a DB constraint). |
| `CreatedByAdminID` | `INT` | Yes | FK → `Admins.AdminID` | |
| `XPReward` | `INT` | No | DEFAULT 0 | |
| `StartDate` | `DATETIME2` | No | - | |
| `EndDate` | `DATETIME2` | No | - | |
| `IsGlobalAdminChallenge` | `BIT` | No | DEFAULT 0 | |

### 37. `ChallengeParticipation`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `ParticipationID` | `INT IDENTITY(1,1)` | No | PK | |
| `ChallengeID` | `INT` | No | FK → `Challenges.ChallengeID` | |
| `StudentID` | `INT` | No | FK → `Students.StudentID` | |
| `Score` | `INT` | No | DEFAULT 0 | |
| `CompletedAt` | `DATETIME2` | Yes | - | |
| — | — | — | UNIQUE `(ChallengeID, StudentID)` | |

### 38. `FunRooms` (community content, review workflow)
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `FunRoomID` | `INT IDENTITY(1,1)` | No | PK | |
| `CreatedByUserID` | `INT` | No | FK → `Users.UserID` | Any role can author a Fun Room. |
| `RoomTitle` | `NVARCHAR(150)` | No | - | |
| `ContentBody` | `NVARCHAR(MAX)` | Yes | - | |
| `Status` | `NVARCHAR(20)` | No | DEFAULT 'Pending', CHECK | `Pending` / `Approved` / `Rejected`. |
| `ReviewedByAdminID` | `INT` | Yes | FK → `Admins.AdminID` | |
| `CreatedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |

> **Do not confuse with `BossFightRooms`** (Section H) — `FunRooms` is community-authored content with a review workflow; `BossFightRooms` is Admin-only official content with no review step. They are intentionally separate tables.

---

## Section H — Boss Fight Fun Rooms (Admin-authored gamified battles)

### 39. `BossFightRooms`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `RoomID` | `INT IDENTITY(1,1)` | No | PK | |
| `Title` | `NVARCHAR(150)` | No | - | |
| `ThemeDescription` | `NVARCHAR(MAX)` | Yes | - | |
| `DifficultyLevel` | `NVARCHAR(20)` | No | CHECK | `Easy` / `Medium` / `Hard` / `Legendary`. |
| `XPReward` | `INT` | No | DEFAULT 0 | Set explicitly by Admin per room (suggested scaling: Easy ~50-100, Medium ~100-200, Hard ~200-350, Legendary ~350-500+ — guidance only, not DB-enforced). |
| `PlayerMaxHP` | `INT` | No | DEFAULT 100 | |
| `IsPublished` | `BIT` | No | DEFAULT 0 | |
| `CreatedByAdminID` | `INT` | No | FK → `Admins.AdminID` | Admin-only — no instructor/student creator. |
| `CreatedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |
| `UpdatedAt` | `DATETIME2` | Yes | - | |

### 40. `Bosses`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `BossID` | `INT IDENTITY(1,1)` | No | PK | |
| `RoomID` | `INT` | No | FK → `BossFightRooms.RoomID`, UNIQUE | 1:1 with the room. |
| `BossName` | `NVARCHAR(100)` | No | - | |
| `MaxHP` | `INT` | No | CHECK > 0 | |
| `AttackStrength` | `INT` | No | DEFAULT 10, CHECK >= 0 | |
| `EnrageThresholdPct` | `INT` | Yes | CHECK 0-100 | `NULL` = boss never enrages. |
| `EnrageAttackBonus` | `INT` | No | DEFAULT 0 | Extra attack once HP drops below the enrage threshold. |
| `IconPath` | `NVARCHAR(255)` | Yes | - | |

### 41. `BossFightQuestions`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `BossFightQuestionID` | `INT IDENTITY(1,1)` | No | PK | |
| `RoomID` | `INT` | No | FK → `BossFightRooms.RoomID` | |
| `QuestionText` | `NVARCHAR(MAX)` | No | - | |
| `DamageValue` | `INT` | No | DEFAULT 10, CHECK > 0 | Damage dealt to the boss on a correct answer. |
| `TimeLimitSeconds` | `INT` | No | DEFAULT 20, CHECK > 0 | |
| `OrderIndex` | `INT` | No | DEFAULT 0 | |

### 42. `BossFightQuestionOptions`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `OptionID` | `INT IDENTITY(1,1)` | No | PK | |
| `BossFightQuestionID` | `INT` | No | FK → `BossFightQuestions.BossFightQuestionID` | |
| `OptionText` | `NVARCHAR(MAX)` | No | - | |
| `IsCorrect` | `BIT` | No | DEFAULT 0 | |

### 43. `BattleSessions`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `SessionID` | `INT IDENTITY(1,1)` | No | PK | |
| `RoomID` | `INT` | No | FK → `BossFightRooms.RoomID` | |
| `StudentID` | `INT` | No | FK → `Students.StudentID` | |
| `PlayerMaxHP` | `INT` | No | - | Snapshot of HP at session start. |
| `PlayerCurrentHP` | `INT` | No | - | Live/ending HP. |
| `BossMaxHP` | `INT` | No | - | Snapshot of boss HP at session start. |
| `BossCurrentHP` | `INT` | No | - | Live/ending HP. |
| `Status` | `NVARCHAR(20)` | No | DEFAULT 'InProgress', CHECK | `InProgress` / `Won` / `Lost` / `Abandoned`. |
| `XPAwarded` | `INT` | No | DEFAULT 0 | Only non-zero on `Won`. |
| `StartedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |
| `EndedAt` | `DATETIME2` | Yes | - | |

### 44. `BattleSessionAnswers`
Turn-by-turn combat log.

| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `AnswerLogID` | `INT IDENTITY(1,1)` | No | PK | |
| `SessionID` | `INT` | No | FK → `BattleSessions.SessionID` | |
| `BossFightQuestionID` | `INT` | No | FK → `BossFightQuestions.BossFightQuestionID` | Question pool can be reused within a session for extra "hits." |
| `SelectedOptionID` | `INT` | Yes | FK → `BossFightQuestionOptions.OptionID` | `NULL` = player timed out with no answer selected. |
| `IsCorrect` | `BIT` | No | DEFAULT 0 | |
| `DamageDealtToBoss` | `INT` | No | DEFAULT 0 | |
| `DamageTakenByPlayer` | `INT` | No | DEFAULT 0 | Includes enrage-phase bonus damage when applicable. |
| `TimeTakenSeconds` | `INT` | Yes | - | |
| `AnsweredAt` | `DATETIME2` | No | DEFAULT GETDATE() | |

---

## Section I — Community, Consultation & Feedback

### 45. `DiscussionThreads`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `ThreadID` | `INT IDENTITY(1,1)` | No | PK | |
| `SubTopicID` | `INT` | Yes | FK → `SubTopics.SubTopicID` | |
| `ModuleID` | `INT` | Yes | FK → `Modules.ModuleID` | A thread is typically tied to one *or* the other, or neither (general discussion) — both nullable, not mutually exclusive at the DB level. |
| `CreatedByUserID` | `INT` | No | FK → `Users.UserID` | |
| `Title` | `NVARCHAR(200)` | No | - | |
| `Body` | `NVARCHAR(MAX)` | No | - | |
| `CreatedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |

### 46. `DiscussionReplies`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `ReplyID` | `INT IDENTITY(1,1)` | No | PK | |
| `ThreadID` | `INT` | No | FK → `DiscussionThreads.ThreadID` | |
| `CreatedByUserID` | `INT` | No | FK → `Users.UserID` | |
| `Body` | `NVARCHAR(MAX)` | No | - | |
| `CreatedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |

### 47. `ConsultationSlots`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `SlotID` | `INT IDENTITY(1,1)` | No | PK | |
| `InstructorID` | `INT` | No | FK → `Instructors.InstructorID` | |
| `SlotDate` | `DATE` | No | - | |
| `StartTime` / `EndTime` | `TIME` | No | - | |
| `IsAvailable` | `BIT` | No | DEFAULT 1 | Flip to `0` once booked. |

### 48. `ConsultationBookings`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `BookingID` | `INT IDENTITY(1,1)` | No | PK | |
| `SlotID` | `INT` | No | FK → `ConsultationSlots.SlotID` | |
| `StudentID` | `INT` | No | FK → `Students.StudentID` | |
| `Topic` | `NVARCHAR(255)` | Yes | - | |
| `Status` | `NVARCHAR(20)` | No | DEFAULT 'Pending', CHECK | `Pending` / `Confirmed` / `Cancelled`. |
| `BookedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |

### 49. `Feedback`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `FeedbackID` | `INT IDENTITY(1,1)` | No | PK | |
| `StudentID` | `INT` | No | FK → `Students.StudentID` | |
| `InstructorID` | `INT` | No | FK → `Instructors.InstructorID` | |
| `ClassroomID` | `INT` | No | FK → `Classrooms.ClassroomID` | |
| `SubmissionID` | `INT` | Yes | FK → `AssignmentSubmissions.SubmissionID` | `NULL` for general (non-submission-tied) feedback. |
| `FeedbackText` | `NVARCHAR(MAX)` | No | - | |
| `Grade` | `NVARCHAR(10)` | Yes | - | Letter grade, e.g. `A+`, `B`. |
| `CreatedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |

---

## Section J — Moderation, Audit & Notifications

### 50. `Reports`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `ReportID` | `INT IDENTITY(1,1)` | No | PK | |
| `ReportedByUserID` | `INT` | No | FK → `Users.UserID` | |
| `ReportedUserID` | `INT` | Yes | FK → `Users.UserID` | |
| `ReportedContentType` | `NVARCHAR(30)` | Yes | - | e.g. `'FunRoom'`, `'DiscussionReply'` — free text, validate in app logic. |
| `ReportedContentID` | `INT` | Yes | - | Not an enforced FK — polymorphic, paired with `ReportedContentType`. |
| `Reason` | `NVARCHAR(MAX)` | No | - | |
| `Status` | `NVARCHAR(20)` | No | DEFAULT 'Open', CHECK | `Open` / `Reviewed` / `ActionTaken` / `Dismissed`. |
| `ReviewedByAdminID` | `INT` | Yes | FK → `Admins.AdminID` | |
| `CreatedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |

### 51. `AuditLogs`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `LogID` | `INT IDENTITY(1,1)` | No | PK | |
| `PerformedByUserID` | `INT` | No | FK → `Users.UserID` | |
| `ActionType` | `NVARCHAR(100)` | No | - | e.g. `'APPROVE_INSTRUCTOR'`, `'REJECT_FUNROOM'`, `'BAN_USER'`. |
| `TargetTable` | `NVARCHAR(100)` | Yes | - | Free text — not an enforced FK. |
| `TargetID` | `INT` | Yes | - | Paired with `TargetTable`; can be `NULL` for actions with no single target row (e.g. a dismissed report). |
| `Details` | `NVARCHAR(MAX)` | Yes | - | |
| `CreatedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |

### 52. `Notifications`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `NotificationID` | `INT IDENTITY(1,1)` | No | PK | |
| `UserID` | `INT` | No | FK → `Users.UserID` | Recipient. |
| `Message` | `NVARCHAR(500)` | No | - | |
| `NotificationType` | `NVARCHAR(30)` | Yes | - | Free text used in sample data: `BadgeAwarded`, `FeedbackReceived`, `AssignmentPosted`, `CertIssued`, `ChallengeAlert`, `ConsultBooked`, `FunRoomRejected`, `MaterialUploaded`, `NewModule`, `BossFightWon`, `BossFightLost` — not DB-enforced, keep a shared constant list in application code. |
| `IsRead` | `BIT` | No | DEFAULT 0 | |
| `CreatedAt` | `DATETIME2` | No | DEFAULT GETDATE() | |

---

# Website Development Guide

## A. Do Not Rename Database Fields

Use the exact latest names, including SQL Server's casing conventions (PascalCase throughout — unlike some other coursework schemas that use camelCase):

- `Students.TPNumber`, not `TpNumber` or `tpNumber`
- `Modules.PrerequisiteModuleID`, not `PreRequisiteModuleId`
- `BossFightQuestions.BossFightQuestionID`, not `QuestionID` (this table's PK is fully qualified, unlike `Questions.QuestionID`)
- `userChat`-style lowerCamel names do **not** appear anywhere in this schema — every table and column here is PascalCase.

## B. Use Parameterized Queries

Never concatenate user input into SQL strings. Example pattern (ADO.NET / C#):

```csharp
SqlCommand cmd = new SqlCommand(
    "SELECT * FROM Users WHERE Email = @email AND PasswordHash = @passwordHash AND IsActive = 1 AND IsBanned = 0",
    conn
);
cmd.Parameters.AddWithValue("@email", email);
cmd.Parameters.AddWithValue("@passwordHash", passwordHash);
```

## C. Use Correct Boolean Handling

SQL Server `BIT` uses `1` = true, `0` = false. Applies to every `Is*` column in the schema, including:

`Users.IsActive`, `Users.IsBanned`, `Modules.IsFoundationOnly`, `Modules.IsPublished`, `SubTopics.IsPublished`, `AnswerOptions.IsCorrect`, `PracticeQuestionOptions.IsCorrect`, `PracticeAnswers.IsCorrect`, `ExamQuestionOptions.IsCorrect`, `ExamAnswers.IsCorrect`, `ExamAttempts.IsPassed`, `AssignmentQuestionOptions.IsCorrect`, `SubscriptionPlans.CanAccessFoundationOnly`, `UserSubscriptions.IsActive`, `Challenges.IsGlobalAdminChallenge`, `ConsultationSlots.IsAvailable`, `Notifications.IsRead`, `BossFightRooms.IsPublished`, `BossFightQuestionOptions.IsCorrect`, `BattleSessionAnswers.IsCorrect`.

## D. Password Storage

The sample data stores plaintext `'password123'` in `Users.PasswordHash` for demo/testing convenience only. Real deployment code must hash passwords (e.g. bcrypt/PBKDF2) before insert, and compare hashes on login — never store or compare plaintext.

## E. Recommended Module-to-Table Mapping

| Website Module | Main Tables |
|---|---|
| Login / Authentication | `Users`, `AuditLogs` |
| Role Onboarding | `Students`, `Instructors`, `Admins`, `UserSubscriptions`, `SubscriptionPlans` |
| Student Dashboard | `Students`, `ModuleProgress`, `SubTopicProgress`, `UserBadges`, `XPTransactions`, `Notifications` |
| Learning Roadmap | `Pathways`, `Modules`, `SubTopics`, `LearningMaterials`, `Questions`, `AnswerOptions` |
| Practice Library | `PracticeQuestions`, `PracticeQuestionOptions`, `PracticeAttempts`, `PracticeAnswers` (supports guest sessions) |
| Module Exams | `ExamQuestions`, `ExamQuestionOptions`, `ExamAttempts`, `ExamAnswers` |
| Certificates | `Certifications`, `UserCertifications`, `Pathways` |
| Classrooms | `Classrooms`, `ClassroomEnrollments`, `ClassroomMaterials`, `ClassroomAssignments`, `AssignmentQuestions`, `AssignmentQuestionOptions`, `AssignmentSubmissions`, `Feedback` |
| Guest / Anonymous Access | `GuestModuleAccess`, `PracticeAttempts` (nullable `StudentID` path) |
| Challenges | `Challenges`, `ChallengeParticipation` |
| Fun Rooms (community content) | `FunRooms`, `Users`, `Admins` |
| Boss Fight (gamified battles) | `BossFightRooms`, `Bosses`, `BossFightQuestions`, `BossFightQuestionOptions`, `BattleSessions`, `BattleSessionAnswers` |
| Forum | `DiscussionThreads`, `DiscussionReplies` |
| Consultation Booking | `ConsultationSlots`, `ConsultationBookings` |
| Moderation & Admin | `Reports`, `AuditLogs`, `Users`, `Admins` |
| Notifications | `Notifications` |

## F. Safe Filtering Rules

- Block login for any user where `IsActive = 0` or `IsBanned = 1`.
- Instructor full features (creating classrooms, modules, subtopics, questions, materials) should be gated on `Instructors.LicenseStatus = 'Approved'`.
- Only show `Modules`/`SubTopics` where `IsPublished = 1` to students; instructors/admins reviewing their own drafts can see unpublished rows.
- Only show `FunRooms` where `Status = 'Approved'` in public listings; show `Pending`/`Rejected` only to the author and to admins.
- `BossFightRooms` should only be playable when `IsPublished = 1`.
- `ConsultationSlots` shown as bookable only where `IsAvailable = 1`.

## G. Useful Verification Queries

Check all tables exist:

```sql
USE CloudPhoria;
GO

SELECT name
FROM sys.tables
ORDER BY name;
```

Check row counts quickly:

```sql
SELECT 'Users' AS TableName, COUNT(*) AS TotalRows FROM Users
UNION ALL SELECT 'Students', COUNT(*) FROM Students
UNION ALL SELECT 'Instructors', COUNT(*) FROM Instructors
UNION ALL SELECT 'Modules', COUNT(*) FROM Modules
UNION ALL SELECT 'SubTopics', COUNT(*) FROM SubTopics
UNION ALL SELECT 'Questions', COUNT(*) FROM Questions
UNION ALL SELECT 'ExamAttempts', COUNT(*) FROM ExamAttempts
UNION ALL SELECT 'BossFightRooms', COUNT(*) FROM BossFightRooms
UNION ALL SELECT 'BattleSessions', COUNT(*) FROM BattleSessions;
```

Check for the `USE` statement mismatch noted in Section 1 before running seed scripts:

```sql
SELECT name FROM sys.databases WHERE name IN ('CloudPhoria', 'CloudPhoriaDB');
```

Check for the duplicate-reseed issue noted in Section 6 — flags modules/rooms that look like repeated copies by name/title:

```sql
-- Duplicate Modules by name (expect 1 per name if no repeated reseed occurred)
SELECT ModuleName, COUNT(*) AS Copies
FROM Modules
GROUP BY ModuleName
HAVING COUNT(*) > 1
ORDER BY Copies DESC;

-- BossFightRooms with no Boss row yet (should return 0 rows after cloudphoria_exams_and_bossfights.sql)
SELECT r.RoomID, r.Title
FROM BossFightRooms r
LEFT JOIN Bosses b ON b.RoomID = r.RoomID
WHERE b.BossID IS NULL;
```

---

# Final Reminder

This guide documents the structure, relationships, and development rules of the **CloudPhoria** database (Group 14 | CT050-3-2-WAPP), including the content added by `cloudphoria_additional_content.sql` and `cloudphoria_exams_and_bossfights.sql`. It intentionally does not restate every sample data row — for exact seed/sample records, refer back to the SQL files directly.

**Action items before your next fresh run:**
1. Resolve the `USE CloudPhoria;` vs `USE CloudPhoriaDB;` inconsistency described in Section 1 so all script sections target the same database.
2. Run all five scripts in the order in Section 2: `create_tables.sql` → `seed_constants.sql` → `seed_dummy_data.sql` → `cloudphoria_additional_content.sql` → `cloudphoria_exams_and_bossfights.sql`.
3. Before re-running the full sequence again on a shared/existing database, note the duplicate-reseed issue in Section 6 — without a guard, re-running `seed_dummy_data.sql` will keep duplicating `Modules` and `BossFightRooms`.


---

## 9. Additional Tables (Added During Development)

These tables were added via SQL scripts in the `Database/` folder to support new features. Run the corresponding scripts after the initial 5 scripts.

### 53. `ClassroomMessages` (Classroom Chat)
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `MessageID` | `INT IDENTITY(1,1)` | No | PK | |
| `ClassroomID` | `INT` | No | FK → `Classrooms.ClassroomID` | |
| `SenderID` | `INT` | No | FK → `Users.UserID` | Any enrolled student or the classroom instructor. |
| `MessageText` | `NVARCHAR(2000)` | No | - | |
| `SentAt` | `DATETIME` | No | DEFAULT GETDATE() | |

Index: `IX_ClassroomMessages_ClassroomID_SentAt` on `(ClassroomID, SentAt DESC)`.

Script: `Database/add_classroom_chat.sql`

---

### 54. `FunRoomQuestions` (Fun Room Quiz Questions)
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `FunRoomQuestionID` | `INT IDENTITY(1,1)` | No | PK | |
| `FunRoomID` | `INT` | No | FK → `FunRooms.FunRoomID` | |
| `QuestionText` | `NVARCHAR(500)` | No | - | |
| `XPReward` | `INT` | No | DEFAULT 5 | |
| `OrderIndex` | `INT` | No | DEFAULT 0 | |

### 55. `FunRoomQuestionOptions`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `OptionID` | `INT IDENTITY(1,1)` | No | PK | |
| `FunRoomQuestionID` | `INT` | No | FK → `FunRoomQuestions.FunRoomQuestionID` | |
| `OptionText` | `NVARCHAR(300)` | No | - | |
| `IsCorrect` | `BIT` | No | DEFAULT 0 | |

Script: `Database/fix_funrooms.sql`

---

### 56. `ChallengeQuestions`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `ChallengeQuestionID` | `INT IDENTITY(1,1)` | No | PK | |
| `ChallengeID` | `INT` | No | FK → `Challenges.ChallengeID` | |
| `QuestionText` | `NVARCHAR(500)` | No | - | |
| `Points` | `INT` | No | DEFAULT 10 | Points for correct answer. |
| `TimeLimitSeconds` | `INT` | No | DEFAULT 30 | Per-question countdown. |
| `OrderIndex` | `INT` | No | DEFAULT 0 | |

### 57. `ChallengeQuestionOptions`
| Column | Type | Null? | Key | Notes |
|---|---|---|---|---|
| `OptionID` | `INT IDENTITY(1,1)` | No | PK | |
| `ChallengeQuestionID` | `INT` | No | FK → `ChallengeQuestions.ChallengeQuestionID` | |
| `OptionText` | `NVARCHAR(300)` | No | - | |
| `IsCorrect` | `BIT` | No | DEFAULT 0 | |

Script: `Database/fix_challenges.sql` seeds 3 sample challenges with real questions/options (Cloud Fundamentals Speed Run, Networking Blitz, Security Sprint). **Both tables are now actively read and written by the application** — `Instructor/Challenges.aspx.cs`/`Admin/Challenges.aspx.cs` (question management, `?manageQuestions=X`) and `Student/Challenges.aspx.cs` (quiz-taking flow, `?challengeID=X`). See "Challenges — Fixed" in Section 10 below for the full flow.

---

## 10. Updated Feature Notes

### Subscription Plans (Simplified)
- Only 2 plans: **Free** (PlanID 1) and **Pro** (PlanID 2)
- Free: `CanAccessFoundationOnly = 1`, Price = $0
- Pro: `CanAccessFoundationOnly = 0`, Price = $9.99/month
- Script: `Database/fix_subscription_plans.sql`

### Pathway Enrollment Flow
- Students must explicitly enroll via PathwayDetail page (no auto-enrollment)
- Enrollment inserts `ModuleProgress` rows for all modules in the pathway with status `InProgress`
- Non-Foundation pathways require Pro subscription; Free users see "Upgrade to Pro to Enroll"
- Script: `Database/fix_enrollment.sql`

### Module Exams (Corrected — `ExamStart.aspx`/`ExamTake.aspx` do not exist)
- Exams are locked until all subtopics in the module are completed
- Student takes the exam via `Student/Exams.aspx?moduleID=X` — this ONE page handles both the listing view and the exam-taking view (switched by query string), NOT two separate `ExamStart.aspx`/`ExamTake.aspx` pages. Those two pages were merged into `Exams.aspx` during the Task 6 page-reduction pass and must not be recreated.
- One question at a time with countdown timer (server-side authoritative, per Section 17 of ProjectRules)
- Score calculated server-side, XP awarded on pass

### Classroom Features
- Teams-style layout with tabs: Chat, Files, Assignments, Members
- Real-time-style chat using `ClassroomMessages` table
- Both students and instructor can send messages
- Assignments are clickable → opens `AssignmentDetail.aspx` for answering
- Files & Attachments tab reads `ClassroomMaterials`; instructors now have a working upload UI for this table via `Instructor/Classrooms.aspx` (see Section 15b) — this used to be read-only with no writer.

### Fun Rooms — PERMANENTLY DELETED, do not rebuild
This feature (and this entire subsection describing it) is historical only. `FunRooms`, `FunRoomQuestions`, `FunRoomQuestionOptions` have no corresponding pages anywhere in the current codebase. The user explicitly said "forget about the fun rooms" — see ProjectRules Section 39 user corrections. If you are reading an older copy of this doc that describes Fun Rooms as a working feature with quiz questions and admin approval, that description is stale and describes a version of the project from before the 30-page squeeze (Task 6).

### Challenges — Fixed (previously documented inaccurately, then genuinely broken, now genuinely working)
Earlier versions of this document described Challenges as a fully working timed-quiz-with-leaderboard feature. That description was later found to be false (the quiz-taking side didn't exist), and this section was corrected to say so. **As of this update, the missing piece has actually been built**, so the feature now matches something close to the original description:

- `Instructor/Challenges.aspx` and `Admin/Challenges.aspx` — create/list/delete `Challenges` rows, PLUS a new "Questions" link (`?manageQuestions=X`) that opens a question-management view on the same page: add an MCQ question (text, points, time limit, 2+ options with one marked correct) → inserts into `ChallengeQuestions`/`ChallengeQuestionOptions`; list + delete existing questions per challenge.
- `Student/Challenges.aspx?challengeID=X` — clicking "Join Challenge" now leads to a real quiz flow: intro screen → one question at a time with shuffled options and a countdown timer → server-side correctness check against `ChallengeQuestionOptions.IsCorrect` → score accumulated across all questions → on completion, INSERTs into `ChallengeParticipation` (guarded against duplicate submission) and awards XP via `XPTransactions`/`Students.TotalXP` in the same transaction, same pattern as Boss Fight XP awards.
- `Student/Challenges.aspx?leaderboard=X` — top-10 leaderboard (`ORDER BY Score DESC, CompletedAt ASC`), linked from both the active list and the past-participation table.
- `ChallengeQuestions` and `ChallengeQuestionOptions` (Section 56/57 above) are no longer orphaned — both are now read and written by the pages above.
- A challenge with zero questions shows "No questions yet" instead of a clickable "Join Challenge" link, so students can never enter an empty challenge and get stuck.

### Deleted / Orphaned Tables — Full List (verified against every .cs file, see note on `PracticeQuestions` below)
The following database tables exist but have NO corresponding web pages in the current implementation:
- `FunRooms`, `FunRoomQuestions`, `FunRoomQuestionOptions` — Fun Room pages deleted permanently (user decision, do not rebuild even under the 40-page budget)
- `PracticeQuestionOptions`, `PracticeAttempts`, `PracticeAnswers` — Practice-taking pages deleted (no page creates, lists, or lets a student attempt a practice quiz)
- `DiscussionThreads`, `DiscussionReplies` — Discussion/Forum pages deleted
- `ConsultationSlots`, `ConsultationBookings` — Consultation pages deleted permanently (restored once during the 40-page budget, then removed again per user decision, see Section 15)
- `GuestModuleAccess` — Guest browse feature not implemented (guest read-only browsing is handled via `isGuest` checks in code-behind instead, see Section 11)
- `ChallengeQuestions`, `ChallengeQuestionOptions` — created and seeded with real data, but never read/written by any page. See "Challenges — CORRECTION" above. This is different from the others in this list: those tables lost their *pages* but the *feature concept* (Fun Rooms, Practice, Discussions, Consultations) was cleanly removed. Challenges' quiz mechanic was never built in the first place — it's an unfinished feature, not a removed one.

**Important nuance on `PracticeQuestions` (no trailing "s" issue — this is the table WITHOUT the Options/Attempts/Answers suffix):** unlike its child tables above, `PracticeQuestions` is NOT fully orphaned. `Admin/Courses.aspx.cs`'s module-reassignment cascade (Section 15b) still runs `UPDATE PracticeQuestions SET CreatedByInstructorID=@IID WHERE ModuleID=@MID` when an Admin reassigns a module to a different instructor. So `PracticeQuestions` rows can still have their ownership changed by code, even though no page lets anyone create, view, or answer a practice question. If you see `PracticeQuestions` referenced somewhere, check whether it's this cascade before assuming it's dead code.

These tables remain in the database for schema completeness but are not actively used by their originally-intended website pages.

### Current Page Count: 38 total
The page budget was raised from 30 to 40 by the lecturer to give Admin (1 person) and Instructor (1 person) a fairer share relative to Student (2 people). The project sits at 38 (2 under the 40 budget) since Consultations (2 pages) was removed again.
- Shared: Default.aspx, LogIn.aspx, Register.aspx (3)
- Admin: 9 pages (Dashboard, Users, InstructorApprovals, Courses, Challenges, Reports, AuditLogs, Notifications, Profile)
- Instructor: 10 pages
- Student: 16 pages

See `CloudPhoria_ProjectRules.md` Sections 39, 43, and 44 for the full page-by-page breakdown and rationale.

### SQL Script Run Order (Additional)
Run these AFTER the original 5 scripts:

| Order | Script | Purpose |
|---:|---|---|
| 6 | `Database/add_classroom_chat.sql` | Creates ClassroomMessages table |
| 7 | `Database/fix_subscription_plans.sql` | Simplifies to Free + Pro plans |
| 8 | `Database/fix_enrollment.sql` | Cleans auto-enrollment data |
| 9 | `Database/fix_funrooms.sql` | Creates FunRoom question tables + seeds data |
| 10 | `Database/fix_challenges.sql` | Creates Challenge question tables + seeds data |
| 11 | `Database/add_subtopic_content.sql` | Adds detailed learning content to subtopics |


---

## 11. Guest Read-Only Access (Added)

No new tables were created for guest access — guests are simply **unauthenticated requests** (`Session["UserID"] == null`). The existing `GuestModuleAccess` table exists in the schema but is still NOT used; guest browsing is handled entirely by `isGuest` checks in code-behind, not by inserting tracking rows.

Pages updated to support `isGuest` (see ProjectRules Section 40 for the full list and pattern): `Pathways.aspx.cs`, `PathwayDetail.aspx.cs`, `ModuleDetail.aspx.cs`, `SubTopicView.aspx.cs`, `BossFights.aspx.cs`, `Challenges.aspx.cs`, `Upgrade.aspx.cs`, `Site.Master.cs`.

## 12. Additional Boss Fight Rooms (Added via `Database/add_more_bossfights.sql`)

No schema changes. This script only INSERTs into existing tables:

| Table | New rows added |
|---|---|
| `BossFightRooms` | 4 new rooms (Easy/Medium/Hard/Legendary) |
| `Bosses` | 4 new bosses, one per new room (1:1, same as existing rule) |
| `BossFightQuestions` | 16 new questions (4 per room) |
| `BossFightQuestionOptions` | 64 new options (4 per question) |

Run this script AFTER `create_tables.sql`, `seed_dummy_data.sql`, `cloudphoria_exams_and_bossfights.sql`, and `bossfight_difficulty_questions.sql` (it needs at least one `Admins` row to exist for `CreatedByAdminID`).

The **drag-and-drop battle UI** built on top of these rows does not change how answers are stored — `BattleSessionAnswers.SelectedOptionID` still references `BossFightQuestionOptions.OptionID` exactly as before. Only the front-end interaction method changed (drag/tap instead of click-a-button).

## 13. Full SQL Script Run Order (Current, Consolidated)

Run in this exact order on a fresh database:

| # | Script | Location |
|---:|---|---|
| 1 | `create_tables.sql` | project root scripts |
| 2 | `seed_constants.sql` | project root scripts |
| 3 | `seed_dummy_data.sql` | project root scripts |
| 4 | `cloudphoria_additional_content.sql` | project root scripts |
| 5 | `cloudphoria_exams_and_bossfights.sql` | project root scripts |
| 6 | `Database/rebuild_learning_content.sql` | Database/ |
| 7 | `Database/fix_duplicate_questions.sql` | Database/ |
| 8 | `Database/fix_duplicate_options.sql` | Database/ |
| 9 | `Database/bossfight_difficulty_questions.sql` | Database/ |
| 10 | `Database/add_subtopic_questions.sql` | Database/ |
| 11 | `Database/fix_all_database.sql` | Database/ |
| 12 | `Database/add_classroom_chat.sql` | Database/ |
| 13 | `Database/fix_subscription_plans.sql` | Database/ |
| 14 | `Database/fix_enrollment.sql` | Database/ |
| 15 | `Database/fix_funrooms.sql` | Database/ |
| 16 | `Database/fix_challenges.sql` | Database/ |
| 17 | `Database/add_subtopic_content.sql` | Database/ |
| 18 | `Database/add_more_bossfights.sql` | Database/ |
| 19 | `Database/fix_duplicate_bossfights.sql` | Database/ — run ONLY if you see duplicate boss fight room titles; safe to run anytime, no-op if there are no duplicates |

`Database/check_data.sql` is read-only (SELECT statements) and safe to run at any point for verification — it is not part of the setup sequence.


---

## 14. Admin Dashboard Implementation (Added)

No new tables. `Admin/Dashboard.aspx` now reads/writes these existing tables that previously had no admin-facing UI:

| Table | New usage |
|---|---|
| `Users` | Admin can INSERT (create), UPDATE `IsActive`/`IsBanned`, DELETE |
| `Students` / `Instructors` / `Admins` | INSERT alongside `Users` when Admin creates a new account (shared-PK pattern, `SET IDENTITY_INSERT ... ON/OFF`) |
| `Instructors.LicenseStatus` / `ApprovedBy` / `ApprovedAt` | Now actually settable via Admin Approve/Reject buttons — previously only settable via direct SQL |
| `Modules.CreatedByInstructorID` | Admin can reassign a module to a different Approved instructor. **This cascades** — see "Module Reassignment Cascade" below, not just a single-column update. |
| `Modules.IsPublished` | Admin can publish/unpublish any module regardless of owner |
| `Challenges` | Admin INSERT with `CreatedByAdminID` set and `IsGlobalAdminChallenge = 1` |
| `AuditLogs` | Every admin action now writes a row here via a shared `LogAction()` helper — `ActionType` values used: `BAN_USER`, `UNBAN_USER`, `DEACTIVATE_USER`, `ACTIVATE_USER`, `DELETE_USER`, `CREATE_USER`, `APPROVE_INSTRUCTOR`, `REJECT_INSTRUCTOR`, `ASSIGN_MODULE_INSTRUCTOR`, `PUBLISH_MODULE`, `UNPUBLISH_MODULE`, `CREATE_GLOBAL_CHALLENGE`, `DELETE_GLOBAL_CHALLENGE` |
| `Notifications` | Instructor gets a row here when Admin approves/rejects their licence |

**Explicitly NOT touched by Admin UI (by user decision):** `SubscriptionPlans`, `FunRooms`, any gamification/XP-formula config (no such table exists in the schema anyway — XP values are hard-coded per-item on `Modules.XPReward`, `Challenges.XPReward`, etc., per table).

Script: `Database/admin_setup.sql` (read-only verification query; the bulk-approve statement is commented out on purpose).

### Module Reassignment Cascade (Fixed)

There is no single "owner" column for a module's full content tree — `Modules`, `SubTopics`, `Questions`, `LearningMaterials`, `PracticeQuestions`, and `ExamQuestions` each have their own independent instructor-ownership column (`CreatedByInstructorID` or `InstructorID`), and instructor-facing pages filter strictly by their own table's column, never by the parent module's owner. Originally, `Admin/Courses.aspx`'s "Assign Instructor" dropdown only updated `Modules.CreatedByInstructorID`, so reassigning a module didn't actually transfer edit access to anything inside it — the previous instructor silently kept full control of the subtopics/questions/materials.

This is now fixed: assigning a module to an instructor (any value other than "Unassigned") updates all of the following in a single transaction, keyed off `ModuleID` (joining through `SubTopics.ModuleID` for `Questions` and `LearningMaterials`, which don't have a direct `ModuleID` column):

```sql
UPDATE Modules SET CreatedByInstructorID=@IID WHERE ModuleID=@MID;
UPDATE SubTopics SET CreatedByInstructorID=@IID WHERE ModuleID=@MID;
UPDATE q SET q.CreatedByInstructorID=@IID FROM Questions q
    INNER JOIN SubTopics st ON st.SubTopicID = q.SubTopicID WHERE st.ModuleID=@MID;
UPDATE lm SET lm.InstructorID=@IID FROM LearningMaterials lm
    INNER JOIN SubTopics st ON st.SubTopicID = lm.SubTopicID WHERE st.ModuleID=@MID;
UPDATE PracticeQuestions SET CreatedByInstructorID=@IID WHERE ModuleID=@MID;
UPDATE ExamQuestions SET CreatedByInstructorID=@IID WHERE ModuleID=@MID;
```

**Unassigning does not cascade.** `Modules.CreatedByInstructorID` is nullable (`Yes` in Section D/E tables above), but `Questions`, `LearningMaterials`, `PracticeQuestions`, and `ExamQuestions` all have their ownership column as `NOT NULL` — there is no valid "unowned" state to cascade to. Selecting "-- Unassigned --" only clears the `Modules` row; the underlying content keeps its current instructor.

**Note:** the table above describes the tables/columns touched by the Admin feature set. As of the 40-page budget, this functionality is split across **9 dedicated Admin pages** (`Admin/Dashboard.aspx`, `Users.aspx`, `InstructorApprovals.aspx`, `Courses.aspx`, `Challenges.aspx`, `Reports.aspx`, `AuditLogs.aspx`, `Notifications.aspx`, `Profile.aspx`) instead of one single tabbed page — see `CloudPhoria_ProjectRules.md` Section 43 for the current page-by-page breakdown. `Reports.aspx` and `AuditLogs.aspx` are new dedicated pages that did not exist when this section was first written; they read/write the `Reports` and `AuditLogs` tables respectively, both already documented in Section 27 of the schema (Section H/I tables above).

## 15. Consultations Feature (Permanently Removed)

Consultations went through a full cycle: built, deleted during the 30-page squeeze, restored as 2 dedicated pages when the budget was raised to 40, then **permanently removed** per the user's final decision ("i dont want consultation anymore"). `Instructor/Consultations.aspx`, `Student/Consultations.aspx`, their code-behind/designer files, csproj entries, and `Site.Master` nav links have all been deleted. Do not rebuild this feature again unless explicitly requested.

`ConsultationSlots` and `ConsultationBookings` remain in the schema (never dropped) but have no corresponding pages — same status as `FunRooms`, `PracticeQuestions`, and `DiscussionThreads` in the "Deleted Features" list above. See `CloudPhoria_ProjectRules.md` Sections 26 and 44 for the full history.

## 15b. Report Submission and Classroom Material Upload — New Table Usage (Added)

No schema changes for either of these — both close a gap where a table existed but had no writer (Reports) or no per-classroom writer (ClassroomMaterials).

**`Reports` (Section J, table 50):** previously only read/updated by `Admin/Reports.aspx` — nothing ever INSERTed into it. Now `Student/Profile.aspx` and `Instructor/Profile.aspx` both have a "Report an Issue" form that does:
```sql
INSERT INTO Reports (ReportedByUserID, ReportedContentType, Reason, Status, CreatedAt)
VALUES (@UID, @Type, @Reason, 'Open', GETDATE());
```
`ReportedUserID` and `ReportedContentID` are left `NULL` (simple free-text report, not tied to one specific row). `ReportedContentType` is restricted to a fixed dropdown (`User`/`Classroom`/`Challenge`/`Other`) rather than arbitrary user input, consistent with the "validate `ReportedContentType` against a known allowlist" rule in ProjectRules Section 27.

**`ClassroomMaterials` (Section D, table 9):** previously only read by `Student/ClassroomDetail.aspx`'s Files & Attachments tab — no instructor-facing writer existed anywhere in the codebase. Now `Instructor/Classrooms.aspx` has an upload/list/delete UI (shown when a classroom is selected via `?id=`), using the exact same table:
```sql
INSERT INTO ClassroomMaterials (ClassroomID, InstructorID, FileName, FilePath, Description, UploadedAt)
VALUES (@CID, @IID, @FName, @FPath, @Desc, GETDATE());
```
Files are saved to `/uploads/classroom/{ClassroomID}/` — the path convention documented in Section 3's naming table was already written up before any code actually used it; this is the first real writer for that path pattern. Same upload validation policy as `Instructor/Materials.aspx` (extension allowlist, 10 MB limit, ownership check against `Classrooms.InstructorID`).

## 16. Demo/Test Data Script — Instructor Approval (Added)

`Database/demo_instructor_approval.sql` creates one demo `Instructors` row with `LicenseStatus = 'Pending'` (email `jane.demo@cloudphoria.test`, password `Demo@123`, plaintext per current auth approach — see Section D below), purely to demo the `Admin/InstructorApprovals.aspx` Approve/Reject flow without needing a real registration.

- Idempotent: checks for the email first; if it already exists, it just resets `LicenseStatus` back to `Pending` (and clears `ApprovedBy`/`ApprovedAt`) instead of failing on the `UNIQUE` constraint, so it can be re-run to re-demo the flow.
- Not part of the main setup sequence in Section 13 — run it on demand, any time after `create_tables.sql` has run.
- Ends with a verification `SELECT` that matches the exact query `Admin/InstructorApprovals.aspx` uses for its "Pending Approvals" list, so you can confirm the row is visible before opening the page.
