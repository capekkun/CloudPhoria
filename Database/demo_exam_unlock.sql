-- ============================================================
-- Demo helper: check / force-unlock a Module Exam for a student
-- Not part of the app build — run manually in SSMS when demoing.
--
-- USAGE: edit @StudentID and @ModuleID in the block below, then
-- run the WHOLE script (or select individual numbered sections —
-- each section is self-contained and declares its own variables,
-- since SQL Server does not carry variables across GO batches).
-- ============================================================
USE CloudPhoria;
GO

-- 1) See which modules exist and their subtopic/exam question counts
SELECT m.ModuleID, m.ModuleName, p.PathwayName,
       (SELECT COUNT(*) FROM SubTopics st WHERE st.ModuleID = m.ModuleID AND st.IsPublished = 1) AS PublishedSubTopics,
       (SELECT COUNT(*) FROM ExamQuestions eq WHERE eq.ModuleID = m.ModuleID) AS ExamQuestionCount
FROM Modules m
INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
WHERE m.IsPublished = 1
ORDER BY m.ModuleID;
GO

-- 2) Check current status for a given student/module:
--    - has the student enrolled in the module? (ModuleProgress row must exist)
--    - how many subtopics are completed vs total?
--    - has the student already passed this module's exam?
DECLARE @StudentID INT = 5;   -- <-- EDIT: StudentID to check
DECLARE @ModuleID  INT = 1;   -- <-- EDIT: ModuleID to check

SELECT
    (SELECT COUNT(*) FROM ModuleProgress WHERE StudentID=@StudentID AND ModuleID=@ModuleID) AS IsEnrolledInModule,
    (SELECT COUNT(*) FROM SubTopics WHERE ModuleID=@ModuleID AND IsPublished=1) AS TotalPublishedSubTopics,
    (SELECT COUNT(*) FROM SubTopicProgress stp
        INNER JOIN SubTopics st ON st.SubTopicID = stp.SubTopicID
        WHERE st.ModuleID=@ModuleID AND stp.StudentID=@StudentID AND stp.Status='Completed') AS CompletedSubTopics,
    (SELECT COUNT(*) FROM ExamAttempts WHERE StudentID=@StudentID AND ModuleID=@ModuleID AND IsPassed=1) AS AlreadyPassedExam;
GO

-- 3) Enroll the student in the module if not already enrolled
--    (mirrors what "Enroll in Pathway" does — safe to re-run, guarded by NOT EXISTS)
DECLARE @StudentID INT = 5;   -- <-- EDIT: same StudentID as above
DECLARE @ModuleID  INT = 1;   -- <-- EDIT: same ModuleID as above

IF NOT EXISTS (SELECT 1 FROM ModuleProgress WHERE StudentID=@StudentID AND ModuleID=@ModuleID)
BEGIN
    INSERT INTO ModuleProgress (StudentID, ModuleID, Status)
    VALUES (@StudentID, @ModuleID, 'InProgress');
END
GO

-- 4) Mark every published subtopic in the module as Completed for the student
--    (mirrors what happens when a student finishes reading + answering each subtopic)
DECLARE @StudentID INT = 5;   -- <-- EDIT: same StudentID as above
DECLARE @ModuleID  INT = 1;   -- <-- EDIT: same ModuleID as above

INSERT INTO SubTopicProgress (StudentID, SubTopicID, Status, XPEarned, CompletedAt)
SELECT @StudentID, st.SubTopicID, 'Completed', st.XPReward, GETDATE()
FROM SubTopics st
WHERE st.ModuleID = @ModuleID
  AND st.IsPublished = 1
  AND NOT EXISTS (
      SELECT 1 FROM SubTopicProgress sp
      WHERE sp.StudentID = @StudentID AND sp.SubTopicID = st.SubTopicID
  );

-- Update any existing rows that were NotStarted/InProgress to Completed too
UPDATE sp
SET sp.Status = 'Completed', sp.CompletedAt = GETDATE()
FROM SubTopicProgress sp
INNER JOIN SubTopics st ON st.SubTopicID = sp.SubTopicID
WHERE sp.StudentID = @StudentID
  AND st.ModuleID = @ModuleID
  AND sp.Status <> 'Completed';
GO

-- 5) (Optional) If the student had already passed this exam before and you
--    want to demo taking it again from scratch, delete their prior attempts.
--    CAUTION: this permanently deletes exam history for this student/module.
--    Only run this if you specifically want a clean slate — uncomment first.
-- DECLARE @StudentID INT = 5;
-- DECLARE @ModuleID  INT = 1;
-- DELETE ea FROM ExamAnswers ea
--     INNER JOIN ExamAttempts att ON att.ExamAttemptID = ea.ExamAttemptID
--     WHERE att.StudentID = @StudentID AND att.ModuleID = @ModuleID;
-- DELETE FROM ExamAttempts WHERE StudentID = @StudentID AND ModuleID = @ModuleID;
-- GO

-- 6) Re-run section 2's check to confirm CompletedSubTopics = TotalPublishedSubTopics
--    and AlreadyPassedExam = 0 — once both are true, "Start Exam" will be enabled
--    on Student/Exams.aspx?moduleID=<ModuleID> for this student.
DECLARE @StudentID INT = 5;
DECLARE @ModuleID  INT = 1;

SELECT
    (SELECT COUNT(*) FROM ModuleProgress WHERE StudentID=@StudentID AND ModuleID=@ModuleID) AS IsEnrolledInModule,
    (SELECT COUNT(*) FROM SubTopics WHERE ModuleID=@ModuleID AND IsPublished=1) AS TotalPublishedSubTopics,
    (SELECT COUNT(*) FROM SubTopicProgress stp
        INNER JOIN SubTopics st ON st.SubTopicID = stp.SubTopicID
        WHERE st.ModuleID=@ModuleID AND stp.StudentID=@StudentID AND stp.Status='Completed') AS CompletedSubTopics,
    (SELECT COUNT(*) FROM ExamAttempts WHERE StudentID=@StudentID AND ModuleID=@ModuleID AND IsPassed=1) AS AlreadyPassedExam;
GO
