# CloudPhoria Project Rules

> **Project:** CloudPhoria  
> **Module:** CT050-3-2-WAPP  
> **Purpose:** This document is the main development rulebook for the CloudPhoria ASP.NET Web Forms project.

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
- Book instructor consultations
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

## 18. XP Rules

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

## 26. Consultation Rules

Consultations use:

    ConsultationSlots
    ConsultationBookings

Supported booking statuses are:

    Pending
    Confirmed
    Cancelled

Students may only book available slots.

Booking logic should prevent two students from successfully booking the same slot.

Where booking and slot availability are updated together, use a database transaction.

An Instructor may only manage their own consultation slots unless the current user is an authorised Admin.

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
- Booking a consultation slot
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
- Consultation slot belongs to current Instructor
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
- Consultation slots
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

### Page Count Summary (30 pages total)

**Shared (3 pages):** Default.aspx (landing), LogIn.aspx, Register.aspx

**Admin (1 page):** Dashboard.aspx

**Instructor (10 pages):** Dashboard, Modules, SubTopics, Questions, Classrooms, Materials, Assignments, Challenges, Notifications, Profile

**Student (16 pages):** Dashboard, Pathways, PathwayDetail, ModuleDetail, SubTopicView, MyLearning, Exams, Challenges, BossFights, Classrooms, ClassroomDetail, AssignmentDetail, Achievements, Notifications, Profile, Upgrade

### Guest Access
- Guests can ONLY see `Default.aspx` (the landing page)
- The landing page includes a "Browse Pathways" section showing all pathways with descriptions, module counts, and Free/Pro badges
- Guests can read pathway names and descriptions to preview what's available
- No navigation bar for guests — only "Browse Pathways", "Log In" and "Join for Free" buttons
- Guests CANNOT click into modules, subtopics, or any interactive content
- All protected pages check `Session["UserID"]` and redirect to `LogIn.aspx` if missing
- The `Guest/` folder is empty and unused
- The `GuestModuleAccess` table exists in the schema but is NOT used in the current implementation
- This satisfies the "non-registered user can browse" requirement without needing extra pages

### Registration (Register.aspx)
- Students: fill name, email, password, optional TP number → instant account creation + auto-login + Free subscription assigned
- Instructors: fill name, email, password, qualification, teaching permit description → account created with `LicenseStatus = 'Pending'` → admin notified → must wait for approval before accessing instructor features
- Duplicate email check prevents multiple accounts

### Merged Pages
- `Exams.aspx` handles both exam listing AND exam taking (via `?moduleID=` query parameter)
- `Challenges.aspx` handles both challenge listing AND live challenge (via `?challengeID=` parameter)
- `BossFights.aspx` handles both boss listing AND battle (via `?roomID=` parameter)

### Deleted Features (to reduce page count)
- Fun Rooms (FunRooms, FunRoomDetail, FunRoomCreate) — REMOVED
- Practice Quizzes (Practice, PracticeQuiz) — REMOVED
- Consultations (Student + Instructor) — REMOVED
- Discussions/Forum (Discussions, DiscussionThread, DiscussionCreate) — REMOVED
- Guest/Learn page — REMOVED
- About.aspx, Contact.aspx — REMOVED

### Classroom Chat
- Uses `ClassroomMessages` table for Teams-style messaging
- Both enrolled students and the classroom instructor can send messages
- Messages displayed with sender avatar initials, name, timestamp
- Instructor messages highlighted with special badge
- Page: `Student/ClassroomDetail.aspx` (Teams-style layout with sidebar tabs)

### Live Challenges
- Uses `ChallengeQuestions` and `ChallengeQuestionOptions` tables
- Admin-created only (`CreatedByAdminID`)
- Per-question countdown timer (configurable via `TimeLimitSeconds`)
- Live leaderboard showing top 10 participants by score
- One attempt per student per challenge (UNIQUE constraint)
- Handled within `Student/Challenges.aspx`

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

## 42. Updated Page List (Student — 20 pages, verify against actual folder)

`Dashboard, Pathways, PathwayDetail, ModuleDetail, SubTopicView, MyLearning, Exams, Challenges, BossFights, Classrooms, ClassroomDetail, AssignmentDetail, Achievements, Notifications, Profile, Upgrade`

Note: `Exams.aspx` (exam taking), `Challenges.aspx` (live challenge), and `BossFights.aspx` (drag-and-drop battle) are each **merged pages** — the listing view and the interactive/detail view live in the same `.aspx`/`.aspx.cs`, switched via query string (`?moduleID=`, `?challengeID=`, `?roomID=`) or ViewState panel visibility. Do not recreate `ExamStart.aspx`, `ExamTake.aspx`, `ChallengeDetail.aspx`, or `BossFightBattle.aspx` — they were intentionally deleted and merged to stay at the 30-page budget.
