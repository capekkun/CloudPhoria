# CloudPhoria Database Schema Guide

> **Group 14 | CT050-3-2-WAPP**
> **Important rule:** Use the exact table names and column names shown here. Do not rename columns in website code unless the SQL database schema is officially changed.

---

## 1. Database Name

```sql
CloudPhoria
```

> ⚠️ **Naming inconsistency in the current script:** `create_tables.sql` runs `USE CloudPhoria;`, but `seed_constants.sql` and `seed_dummy_data.sql` both run `USE CloudPhoriaDB;`. Pick **one** database name and make all three sections consistent before running on a fresh SQL Server instance, otherwise the seed/insert scripts will fail with `Invalid object name` (because they'll be pointed at a different, empty database). This guide assumes the group standardises on **`CloudPhoria`**.

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

### 24. `ExamQuestions` (module final exam, timed, once per day per Modules.ExamDurationMinutes rule enforced in app logic)
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

### 56. `ChallengeQuestions` (Live Challenge Quiz Questions)
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

Script: `Database/fix_challenges.sql`

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

### Module Exams
- Exams are locked until all subtopics in the module are completed
- Student takes exam via `ExamStart.aspx` → `ExamTake.aspx`
- One question at a time with countdown timer
- Score calculated server-side, XP awarded on pass

### Classroom Features
- Teams-style layout with tabs: Chat, Files, Assignments, Members
- Real-time-style chat using `ClassroomMessages` table
- Both students and instructor can send messages
- Assignments are clickable → opens `AssignmentDetail.aspx` for answering

### Fun Rooms
- Now have interactive quiz questions (not just text content)
- Students/Instructors can create rooms with up to 3 questions
- Admin approval required before rooms become public
- Questions are shuffled for fairness

### Live Challenges
- Admin-created timed quiz challenges with leaderboard
- Each question has its own timer (15-30 seconds)
- Score based on correct answers × points per question
- Leaderboard shows top 10 participants
- One attempt per student per challenge

### Deleted Features (tables still exist in schema but pages removed)
The following database tables exist but have NO corresponding web pages in the current implementation:
- `FunRooms`, `FunRoomQuestions`, `FunRoomQuestionOptions` — Fun Room pages deleted
- `PracticeQuestions`, `PracticeQuestionOptions`, `PracticeAttempts`, `PracticeAnswers` — Practice pages deleted
- `ConsultationSlots`, `ConsultationBookings` — Consultation pages deleted
- `DiscussionThreads`, `DiscussionReplies` — Discussion pages deleted
- `GuestModuleAccess` — Guest browse feature not implemented

These tables remain in the database for schema completeness but are not actively used by the website.

### Current Page Count: 30 total
- Shared: Default.aspx, LogIn.aspx, Register.aspx (3)
- Admin: Dashboard.aspx (1)
- Instructor: 10 pages
- Student: 16 pages

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
