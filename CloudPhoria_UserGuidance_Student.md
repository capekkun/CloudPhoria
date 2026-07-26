# CloudPhoria — User Guidance (Student Module)

> Drafting aid only — safe to delete, doesn't affect the build. Covers "User Guidance: Screenshots of the web pages with an appropriate description." Take the screenshots yourself from the running app, then drop each one under its heading below and adjust the description to match what you actually captured (empty state vs. populated state, your own username, etc.). Descriptions are written to explain *what the page does and why it matters*, not just "this is the login page."

Pages are ordered to follow a real student's journey through the app: sign up → land on dashboard → browse and enroll → learn → get tested → get rewarded → compete/socialize. Presenting screenshots in this order (rather than alphabetically by filename) reads as a guided walkthrough instead of a random gallery, which is what "appropriate description" is really asking for.

---

## 1. Register.aspx — Account creation

**Screenshot:** the registration form, ideally mid-fill so field labels and validation are visible.

**Description:** New users choose a role (Student or Instructor) and create an account. Student accounts are activated immediately with a Free subscription; Instructor accounts are created in a Pending state and require Admin approval before login is allowed. Client-side validators (`RequiredFieldValidator`, `CompareValidator` for password confirmation) give instant feedback, and the server independently re-checks everything — including whether the email is already registered — before writing to the database.

---

## 2. LogIn.aspx — Authentication

**Screenshot:** the login form, optionally with a validation error showing (e.g. invalid email format) to demonstrate the `RegularExpressionValidator` in action.

**Description:** Returning users sign in with email and password. The system checks the account isn't banned or (for instructors) still pending approval before creating the session. On success, `Session["UserID"]` and `Session["Role"]` are set, which every protected page across the site checks on load — this single login gate is what the whole role-based navigation and access-control system is built on.

---

## 3. Student/Dashboard.aspx — Landing hub

**Screenshot:** the dashboard after logging in as a student with some progress already made (XP, badges, in-progress modules visible).

**Description:** The first page a student sees after login. It summarises total XP, modules completed, badges earned, and classrooms joined in stat cards, then lists in-progress modules with live progress bars and recent XP/notification activity. Every number here is a real-time database read (`TotalXP` from `Students`, `COUNT(*)` from `UserBadges`, etc.) — nothing is hardcoded or cached, so it reflects the student's actual current state.

---

## 4. Student/Pathways.aspx — Browse learning pathways

**Screenshot:** the pathway grid showing multiple pathway cards (e.g. Cloud Fundamentals, Cloud Architecture, Cloud Security).

**Description:** Pathways are the top-level learning tracks; each contains several modules. Free-tier students can access the Foundation pathway only, while Pro subscribers can access all pathways — this page enforces that gate before a student even reaches enrollment, showing an upgrade prompt on locked pathways rather than letting them click through and hit a wall later.

---

## 5. Student/PathwayDetail.aspx — Pathway overview & enrollment

**Screenshot:** a pathway detail page showing the module list with per-module status (Not Started / In Progress / Completed) and the certification info panel.

**Description:** Shows every module in the pathway with individual progress, and the certification a student will earn once every module's exam is passed. Enrolling here (`btnEnroll_Click`) bulk-inserts a `ModuleProgress` row for every published module in the pathway in one operation — a genuinely non-trivial database write, not just a single-row insert.

---

## 6. Student/ModuleDetail.aspx / Student/SubTopicView.aspx — Learning content

**Screenshot:** a subtopic page showing the actual lesson content plus the "Test Your Knowledge" inline question panel underneath it.

**Description:** This is the core learning experience — each subtopic has its own written content plus optional inline practice questions that award small amounts of XP immediately on a correct answer, without needing a full exam. Marking a subtopic as complete here is also what silently unlocks the module's exam once every subtopic in that module reaches `Completed` status.

---

## 7. Student/Exams.aspx — Timed module exam (intro screen)

**Screenshot:** the exam intro screen showing duration, pass mark, and XP reward before starting.

**Description:** Before starting, the student sees the exam's rules pulled directly from the `Modules` table (`ExamDurationMinutes`, `ExamPassMarkPercent`, `XPReward`) — these aren't hardcoded per page, an admin can change them and every student sees the update immediately. The "Start Exam" button is only shown if every subtopic in the module has been completed; otherwise the page explains what's still locked.

## 7b. Student/Exams.aspx — In-progress exam

**Screenshot:** a question mid-exam with the countdown timer clearly visible.

**Description:** Questions are shown one at a time with a live countdown. The timer is cosmetic only — the actual time limit is enforced by the server against a timestamp stored at exam start, so it can't be manipulated by editing the page or pausing the browser.

## 7c. Student/Exams.aspx — Result screen

**Screenshot:** the pass/fail result screen showing score, correct count, and XP awarded.

**Description:** This is the single most important screenshot in the whole Student module to explain well: it's the visible outcome of the server-side transaction that updates the exam attempt, awards XP exactly once, and — since the recent fix — also awards the module's badge and, if this was the pathway's final module, the pathway's certification. Everything visible here is the result of several database writes committed together, not just a score displayed and forgotten.

---

## 8. Student/Achievements.aspx — Badges, certifications, XP history

**Screenshot:** the Achievements page with at least one earned badge and, ideally, one certification visible.

**Description:** Shows everything a student has earned: badges (one per completed module, each with its own icon), certifications (one per fully-completed pathway), and a running XP transaction history. This page is worth pairing directly with the Exam result screenshot above in your report — the reward shown briefly on the exam result screen is the same reward now permanently visible here, demonstrating the full loop from "pass an exam" to "see it reflected in your permanent profile."

---

## 9. Student/BossFights.aspx — Boss Fight room list & battle arena

**Screenshot 1:** the room selection grid showing multiple bosses with difficulty badges and boss art.
**Screenshot 2:** an active battle mid-fight, with both HP bars visible and the drag-and-drop answer options on screen.

**Description:** The most visually distinctive feature in the app — a turn-based combat game where dragging the correct code snippet into the drop zone damages the boss, and a wrong answer lets the boss attack back. HP totals for both the student and the boss are tracked server-side and persisted after every turn, so refreshing the page mid-battle never loses or desyncs progress. This page is worth including specifically to demonstrate advanced, highly interactive dynamic content beyond standard form-based CRUD.

---

## 10. Student/Classrooms.aspx / ClassroomDetail.aspx — Classroom & chat

**Screenshot:** a classroom detail page showing the Teams-style chat, member list, and assignments tab.

**Description:** Students join an instructor's classroom using an invite code, then interact through a chat (polling-based, sender name and instructor status shown), view classroom materials, and submit assignments. This page demonstrates the social/collaborative side of the platform, distinct from the solo learning pages above — worth including to show breadth of features, not just the gamified learning loop.

---

## 11. (Optional, if space allows) Student/Profile.aspx and Student/Upgrade.aspx

**Description if included:** Profile shows account details and a "File a Report" form (a real, independent use case, not just decorative). Upgrade shows the Free vs Pro subscription comparison and the plan-gating logic referenced back in the Pathways page (§4) — useful to include if you want to show the subscription/access-control system visually, not just describe it in text.

---

## Notes on writing the final descriptions

- Write each description in your own words once you have the actual screenshot in front of you — describe what's *visible* in your specific screenshot (your own test data, your own XP numbers), not the generic version above.
- Where possible, reference the matching Implementation section snippet (e.g. "this result screen is produced by the transaction shown in Implementation §1.1") — this cross-referencing between sections is what makes a report read as one cohesive document instead of separate unrelated chapters.
- Prioritise §1–8 if you're short on space or time; §9–11 add breadth but §1–8 covers the core required journey (auth → learning → assessment → reward).
