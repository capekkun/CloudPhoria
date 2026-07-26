# CloudPhoria — Group Member Contribution Table (Student Module)

> Drafting aid only — safe to delete, doesn't affect the build. Split for a 2-person group, weighted 60% (you) / 40% (friend). "Guest role" isn't a separate set of pages — it's an `isGuest` check built into several Student pages plus the public landing page (`Default.aspx`), so it's folded into the relevant rows below rather than listed separately.

**19 pages total** (18 Student pages + `Default.aspx`, which serves the Guest/public landing view). 11 pages to you (~58%), 8 pages to your friend (~42%) — closest even split to 60/40.

| Name | Web Forms or Pages Created (Filenames) | Data connectivity and processing |
|---|---|---|
| **You (~60%)** | `Default.aspx` | Select Record (public/Guest pathway preview — no login required) |
| | `LogIn.aspx` | User authentication (session creation, banned/pending checks) |
| | `Register.aspx` | Insert Record (create account, auto-enroll Free subscription) |
| | `Student/Pathways.aspx` | Select Record (browse pathways; Guest, Free-tier, and Pro access all handled differently) |
| | `Student/PathwayDetail.aspx` | Select + Insert Record (bulk-enroll into all modules; Guest sees a register prompt instead) |
| | `Student/ModuleDetail.aspx` | Select Record (module info, enrollment + subscription-tier gating, Guest preview) |
| | `Student/SubTopicView.aspx` | Select + Update Record (mark subtopic complete, practice questions; Guest sees preview only) |
| | `Student/Exams.aspx` | Insert/Update Record (server-timed attempt, transactional scoring + XP/badge/certification award) |
| | `Student/BossFights.aspx` | Insert/Update Record (battle session state, turn-by-turn HP updates, XP award) |
| | `Student/Achievements.aspx` | Select Record (badges, certifications, XP transaction history) |
| | `Student/Upgrade.aspx` | Select/Insert/Update Record (view plans, upgrade subscription; Guest routed to Register) |
| **Friend (~40%)** | `Student/Dashboard.aspx` | Select Record (dashboard stats aggregation) |
| | `Student/MyLearning.aspx` | Select Record (in-progress and completed module lists) |
| | `Student/Profile.aspx` | Select/Update Record (view profile, submit a report) |
| | `Student/Notifications.aspx` | Select/Update Record (list notifications, mark as read) |
| | `Student/Classrooms.aspx` | Insert/Select Record (join classroom via invite code) |
| | `Student/ClassroomDetail.aspx` | Insert/Select Record (chat messages, classroom materials, assignment list) |
| | `Student/AssignmentDetail.aspx` | Insert Record (submit assignment answers) |
| | `Student/Challenges.aspx` | Select/Insert Record (join challenge, submit answers, leaderboard; Guest sees listing only) |

**Why this split:** your 11 pages carry all the pages with real backend complexity — transactions, server-side timers, subscription/Guest access-branching, and the exam/badge/certification reward logic. Your friend's 8 pages are still genuinely necessary (dashboard, profile, classrooms, assignments, challenges) but are comparatively more standard Select/Insert/Update CRUD without the same depth of business logic.
