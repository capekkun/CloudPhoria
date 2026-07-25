# CloudPhoria — Student Flowcharts (Split by Feature)

> Drafting aid only — not referenced by the project, safe to delete anytime, does not affect the build. Split into 7 smaller flowcharts instead of one large diagram, so each one is readable on its own and can be dropped into a separate slot in your report. Each renders on https://mermaid.live (paste the code block without the triple backticks) or in VS Code with the Mermaid preview extension.

---

## 1. Authentication (Login / Register)

```mermaid
flowchart TD
    Start(["Visitor arrives"]) --> HasAccount{"Has an\naccount?"}

    HasAccount -- No --> Register["Open Register page"]
    Register --> RegValid{"Valid details?\nEmail not taken?\nPassword >= 6 chars?"}
    RegValid -- No --> RegError["Show validation error"]
    RegError --> Register
    RegValid -- Yes --> AutoLogin["Auto-login as Student\n(Free plan assigned)"]
    AutoLogin --> Dashboard(["Student Dashboard"])

    HasAccount -- Yes --> Login["Open Login screen"]
    Login --> LoginCheck{"Credentials\nvalid?"}
    LoginCheck -- No --> LoginError["Show 'Invalid email\nor password'"]
    LoginError --> Login
    LoginCheck -- "Yes, but banned/inactive" --> AccStatus["Show account\nrestricted message"]
    LoginCheck -- Yes --> Dashboard
```

---

## 2. Learning Pathway → Enrollment

```mermaid
flowchart TD
    Dashboard(["Student Dashboard"]) --> Pathways["Browse Learning Pathways"]
    Pathways --> PathwaySelect["Open a Pathway"]
    PathwaySelect --> Enrolled{"Already\nenrolled?"}

    Enrolled -- No --> PlanCheck{"Free plan and\nnot a Foundation\npathway?"}
    PlanCheck -- Yes --> UpgradePrompt["Show upgrade prompt"]
    UpgradePrompt --> UpgradeFlow(["Go to Upgrade flow"])
    PlanCheck -- No --> EnrollBtn["Click Enroll"]
    EnrollBtn --> EnrollDone["System creates ModuleProgress\nfor every published module"]
    EnrollDone --> ModuleList

    Enrolled -- Yes --> ModuleList["View Module list\nwith progress"]
    ModuleList --> NextFlow(["Go to SubTopic flow"])
```

---

## 3. SubTopic Completion → Module Exam

```mermaid
flowchart TD
    ModuleList(["From: Module list"]) --> OpenModule["Open a Module"]
    OpenModule --> SubList["View SubTopic list"]
    SubList --> OpenSub["Open a SubTopic"]
    OpenSub --> ReadContent["Read content + materials"]
    ReadContent --> HasQuestions{"Has inline\nquestions?"}
    HasQuestions -- Yes --> AnswerQ["Answer each question\n(server-validated)"]
    AnswerQ --> MarkComplete["Mark SubTopic Completed\n+ award XP"]
    HasQuestions -- No --> MarkComplete
    MarkComplete --> AllSubsDone{"All subtopics in\nmodule completed?"}
    AllSubsDone -- No --> SubList
    AllSubsDone -- Yes --> ExamUnlocked["Module Exam unlocked"]

    ExamUnlocked --> StartExam{"Start\nExam?"}
    StartExam -- No --> Dashboard(["Return to Dashboard"])
    StartExam -- Yes --> ExamIntro["Exam intro screen\n(duration, pass mark, XP)"]
    ExamIntro --> AlreadyPassed{"Already\npassed?"}
    AlreadyPassed -- Yes --> ShowPassed["Show 'already passed'\n— no re-attempt"]
    ShowPassed --> Dashboard
    AlreadyPassed -- No --> ExamLoop["Answer questions one at a time\nwith live countdown"]
    ExamLoop --> TimeUp{"Time ran out?"}
    TimeUp -- Yes --> ScoreExam["Remaining questions\ncounted incorrect"]
    TimeUp -- No --> AllAnswered{"All questions\nanswered?"}
    AllAnswered -- No --> ExamLoop
    AllAnswered -- Yes --> ScoreExam
    ScoreExam --> PassCheck{"Score >=\npass mark?"}
    PassCheck -- Yes --> AwardXP["Award XP\n(first pass only)"]
    PassCheck -- No --> NoXP["No XP awarded"]
    AwardXP --> Dashboard
    NoXP --> Dashboard
```

---

## 4. Classroom (Join → Assignment Submission)

```mermaid
flowchart TD
    Dashboard(["Student Dashboard"]) --> Classrooms["Open Classrooms tab"]
    Classrooms --> HasCode{"Have an\ninvite code?"}

    HasCode -- Yes --> EnterCode["Enter invite code"]
    EnterCode --> CodeValid{"Code matches\na classroom?"}
    CodeValid -- No --> CodeError["Show 'invite code\nnot found'"]
    CodeError --> Classrooms
    CodeValid -- Yes --> AlreadyEnrolledC{"Already\nenrolled?"}
    AlreadyEnrolledC -- Yes --> AlreadyMsg["Show 'already enrolled'"]
    AlreadyEnrolledC -- No --> JoinedClassroom["Enrolled — show success"]
    AlreadyMsg --> ExistingClassrooms
    JoinedClassroom --> ExistingClassrooms

    HasCode -- No --> ExistingClassrooms["View existing classrooms"]
    ExistingClassrooms --> OpenAssignment["Open an assignment"]
    OpenAssignment --> SubmittedCheck{"Already\nsubmitted?"}
    SubmittedCheck -- Yes --> ViewAnswers["Show submitted answers\n(read-only)"]
    SubmittedCheck -- No --> AnswerAsgn["Answer questions\n(MCQ or text)"]
    AnswerAsgn --> SubmitAsgn["Click Submit"]
    SubmitAsgn --> SavedAsgn["Answers saved to\nAssignmentSubmissions"]
    SavedAsgn --> Dashboard2(["Return to Dashboard"])
    ViewAnswers --> Dashboard2
```

---

## 5. Challenges (Time-boxed Quiz)

```mermaid
flowchart TD
    Dashboard(["Student Dashboard"]) --> Challenges["Open Challenges tab"]
    Challenges --> SelectChallenge["Select an active challenge"]
    SelectChallenge --> AlreadyDoneC{"Already\nparticipated?"}
    AlreadyDoneC -- Yes --> ShowScore["Show existing score\n— no re-attempt"]
    ShowScore --> Dashboard2(["Return to Dashboard"])
    AlreadyDoneC -- No --> ChallengeLoop["Answer timed questions\none at a time"]
    ChallengeLoop --> TimeCheck{"Answered before\ntime limit?"}
    TimeCheck -- No --> NextQ["Counted incorrect,\nmove to next question"]
    TimeCheck -- Yes --> NextQ2["Move to next question"]
    NextQ --> MoreQ{"More\nquestions?"}
    NextQ2 --> MoreQ
    MoreQ -- Yes --> ChallengeLoop
    MoreQ -- No --> ChallengeDone["Score calculated,\nsaved to ChallengeParticipation"]
    ChallengeDone --> AwardXP["Award XP"]
    AwardXP --> Leaderboard["Show leaderboard rank"]
    Leaderboard --> Dashboard2
```

---

## 6. Boss Fight (Battle Loop)

```mermaid
flowchart TD
    Dashboard(["Student Dashboard"]) --> BossFights["Open Boss Fights tab"]
    BossFights --> SelectRoom["Select a published room"]
    SelectRoom --> StartBattle["System creates BattleSessions record"]
    StartBattle --> BattleLoop["Show boss + next question"]
    BattleLoop --> AnswerCheck{"Answer correct\nwithin time limit?"}
    AnswerCheck -- Yes --> DamageBoss["Damage the boss"]
    AnswerCheck -- No --> SkipTurn["Skip turn\n(timeout recorded as NULL)"]
    DamageBoss --> BattleEnd{"Boss defeated or\nout of health/questions?"}
    SkipTurn --> BattleEnd
    BattleEnd -- "Not yet" --> BattleLoop
    BattleEnd -- "Boss defeated" --> AwardXP["Record Won\n+ award XP"]
    BattleEnd -- "Ran out" --> RecordLost["Record Lost\n— no XP"]
    AwardXP --> Dashboard2(["Return to Dashboard"])
    RecordLost --> Dashboard2
```

---

## 7. Account (Profile / Report / Achievements / Notifications / Upgrade)

```mermaid
flowchart TD
    Dashboard(["Student Dashboard"]) --> AccountChoice{"Which page?"}

    AccountChoice -- Profile --> Profile["View profile\n(read-only)"]
    Profile --> FileReport{"File a report?"}
    FileReport -- Yes --> ReportForm["Select type + reason,\nclick Submit"]
    ReportForm --> ReportValid{"Reason\nfilled in?"}
    ReportValid -- No --> ReportForm
    ReportValid -- Yes --> ReportSaved["Saved to Reports\n(Status = Open)"]
    ReportSaved --> Profile
    FileReport -- No --> Dashboard2(["Return to Dashboard"])

    AccountChoice -- Achievements --> Achievements["View XP history,\nbadges, certifications\n(read-only)"]
    Achievements --> Dashboard2

    AccountChoice -- Notifications --> Notifications["View notifications,\nmark as read"]
    Notifications --> Dashboard2

    AccountChoice -- Upgrade --> Upgrade["View subscription plans"]
    Upgrade --> AlreadyPro{"Already on\nselected plan?"}
    AlreadyPro -- Yes --> CurrentPlanMsg["Show 'this is your\ncurrent plan'"]
    AlreadyPro -- No --> PayForm["Enter payment details"]
    PayForm --> PayValid{"Payment fields\nvalid?"}
    PayValid -- No --> PayError["Show validation error"]
    PayError --> PayForm
    PayValid -- Yes --> UpgradeDone["Subscription updated,\nnotification sent"]
    UpgradeDone --> Dashboard2
    CurrentPlanMsg --> Dashboard2

    AccountChoice -- "Log Out" --> Logout["Session cleared"]
    Logout --> End(["Return to Login screen"])
```

---

## How to view/export these

- **Quickest:** paste any single code block above (without the triple backticks) into https://mermaid.live — renders instantly, export as PNG/SVG for your report.
- **In VS Code / Kiro:** install the "Markdown Preview Mermaid Support" extension, open this file, use the Markdown preview — all 7 render inline.
- **In your Word report:** render each on mermaid.live, screenshot or export as image, paste into the relevant section (e.g. flowchart #3 next to your "Take Module Exam" use case description).

## Notes

- Each flowchart starts and ends at a shared point (Dashboard) so they can be read independently, but you can see how they connect if you look at flowcharts 2 and 3 together (Pathway enrollment feeds into the SubTopic/Exam flow).
- Flowchart 3 shows the enrollment/completion precondition chain that was corrected in the use case audit (`CloudPhoria_UseCase_Student_Audit.md`) — a module's exam only unlocks after all its subtopics are completed.
- Flowchart 7's Achievements branch has no "badge awarded" step, since no code path in the system currently awards a badge or certification (verified: zero `INSERT INTO UserBadges`/`UserCertifications` anywhere in the codebase) — only XP is genuinely automatic.
- If you want the Guest-only preview behavior (browse without login) broken out as its own 8th flowchart, just ask.

---

## 0. Simple Overview Flowchart (high-level only)

If you just need one clean, simple diagram showing the overall Student journey without all the branching detail, use this instead:

```mermaid
flowchart TD
    Start(["Visitor"]) --> Login["Register / Login"]
    Login --> Dashboard["Student Dashboard"]
    Dashboard --> Learn["Browse Pathway → Enroll →\nComplete SubTopics → Take Exam"]
    Dashboard --> Classroom["Join Classroom →\nSubmit Assignment"]
    Dashboard --> Compete["Join Challenge /\nBattle Boss Fight"]
    Dashboard --> Account["View Profile / Achievements /\nNotifications / Upgrade"]
    Learn --> XP["Earn XP"]
    Classroom --> XP
    Compete --> XP
    XP --> Dashboard
    Account --> Logout["Log Out"]
    Logout --> End(["Login screen"])
```

This is the one to use if your report just needs a quick, readable visual rather than full decision logic — paste it into https://mermaid.live the same way as the others.
