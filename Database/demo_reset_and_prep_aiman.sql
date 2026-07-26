-- ============================================================
-- Demo prep for Aiman Haziq (StudentID = 5)
--
-- Goal: reset boss fight history and all module/pathway progress,
-- then bring Cloud Architecture up to "last module remaining" so
-- the demo can show: answer the final module's exam live -> badge
-- + certification awarded immediately (via Student/Exams.aspx.cs
-- FinishExam()).
--
-- Not part of the app build — run manually in SSMS.
-- Safe to re-run from a clean or partially-run state.
-- ============================================================
USE CloudPhoria;
GO

DECLARE @StudentID INT = 5; -- Aiman Haziq

-- 1) Wipe all Boss Fight history for this student
DELETE bsa
FROM BattleSessionAnswers bsa
INNER JOIN BattleSessions bs ON bs.SessionID = bsa.SessionID
WHERE bs.StudentID = @StudentID;

DELETE FROM BattleSessions WHERE StudentID = @StudentID;
GO

-- 2) Wipe all module/pathway progress for this student
DECLARE @StudentID INT = 5;

DELETE FROM ExamAnswers
WHERE ExamAttemptID IN (SELECT ExamAttemptID FROM ExamAttempts WHERE StudentID = @StudentID);

DELETE FROM ExamAttempts        WHERE StudentID = @StudentID;
DELETE FROM SubTopicProgress    WHERE StudentID = @StudentID;
DELETE FROM ModuleProgress      WHERE StudentID = @StudentID;
DELETE FROM UserBadges          WHERE StudentID = @StudentID;
DELETE FROM UserCertifications  WHERE StudentID = @StudentID;

-- Wipe the XP ledger and reset the running total so the demo starts at 0
DELETE FROM XPTransactions      WHERE StudentID = @StudentID;
UPDATE Students SET TotalXP = 0 WHERE StudentID = @StudentID;
GO

-- 3) Enroll in Cloud Architecture and complete every module EXCEPT
--    the last one (Module 8 - Cost Optimization & Performance),
--    so only one exam remains to demo live.
DECLARE @StudentID INT = 5;
DECLARE @PathwayName NVARCHAR(100) = N'Cloud Architecture';
DECLARE @LastModuleID INT = 8; -- last module in this pathway

-- Enroll in every published module of the pathway
INSERT INTO ModuleProgress (StudentID, ModuleID, Status)
SELECT @StudentID, m.ModuleID, 'InProgress'
FROM Modules m
INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
WHERE p.PathwayName = @PathwayName
  AND m.IsPublished = 1
  AND NOT EXISTS (
      SELECT 1 FROM ModuleProgress mp
      WHERE mp.StudentID = @StudentID AND mp.ModuleID = m.ModuleID
  );

-- Complete every subtopic in every module of the pathway (including
-- the last module — subtopics done, only the exam is left to demo)
INSERT INTO SubTopicProgress (StudentID, SubTopicID, Status, XPEarned, CompletedAt)
SELECT @StudentID, st.SubTopicID, 'Completed', st.XPReward, GETDATE()
FROM SubTopics st
INNER JOIN Modules m ON m.ModuleID = st.ModuleID
INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
WHERE p.PathwayName = @PathwayName
  AND st.IsPublished = 1
  AND NOT EXISTS (
      SELECT 1 FROM SubTopicProgress sp
      WHERE sp.StudentID = @StudentID AND sp.SubTopicID = st.SubTopicID
  );
GO

-- 4) Mark every module EXCEPT the last one as Completed + pass its
--    exam, awarding XP + badge (mirrors FinishExam() in Exams.aspx.cs).
--    The last module stays "InProgress" with its exam unlocked but
--    NOT taken — that's the one you answer live in the demo.
DECLARE @StudentID INT = 5;
DECLARE @PathwayName NVARCHAR(100) = N'Cloud Architecture';
DECLARE @LastModuleID INT = 8;

DECLARE @ModuleID INT, @XPReward INT;

DECLARE moduleCursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT m.ModuleID, m.XPReward
    FROM Modules m
    INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
    WHERE p.PathwayName = @PathwayName
      AND m.IsPublished = 1
      AND m.ModuleID <> @LastModuleID
      AND EXISTS (SELECT 1 FROM ExamQuestions eq WHERE eq.ModuleID = m.ModuleID)
      AND NOT EXISTS (
          SELECT 1 FROM ExamAttempts ea
          WHERE ea.StudentID = @StudentID AND ea.ModuleID = m.ModuleID AND ea.IsPassed = 1
      );

OPEN moduleCursor;
FETCH NEXT FROM moduleCursor INTO @ModuleID, @XPReward;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Passing exam attempt with a full score
    INSERT INTO ExamAttempts (StudentID, ModuleID, StartedAt, SubmittedAt, ScorePercent, IsPassed, XPAwarded)
    VALUES (@StudentID, @ModuleID, GETDATE(), GETDATE(), 100, 1, @XPReward);

    -- XP ledger + running total
    INSERT INTO XPTransactions (StudentID, SourceType, SourceID, XPAmount, CreatedAt)
    VALUES (@StudentID, 'ModuleExam', @ModuleID, @XPReward, GETDATE());

    UPDATE Students SET TotalXP = TotalXP + @XPReward WHERE StudentID = @StudentID;

    -- Module status + module badge (same guard as the live award path)
    UPDATE ModuleProgress
    SET Status = 'Completed', XPEarned = @XPReward, CompletedAt = GETDATE()
    WHERE StudentID = @StudentID AND ModuleID = @ModuleID;

    INSERT INTO UserBadges (StudentID, BadgeID, AwardedAt)
    SELECT @StudentID, b.BadgeID, GETDATE()
    FROM Badges b
    WHERE b.ModuleID = @ModuleID
      AND NOT EXISTS (
          SELECT 1 FROM UserBadges ub
          WHERE ub.StudentID = @StudentID AND ub.BadgeID = b.BadgeID
      );

    FETCH NEXT FROM moduleCursor INTO @ModuleID, @XPReward;
END

CLOSE moduleCursor;
DEALLOCATE moduleCursor;
GO

-- 5) Verify: last module (8) should be the only one still InProgress
--    with no passing exam attempt yet — that's what you demo live.
DECLARE @StudentID INT = 5;
DECLARE @PathwayName NVARCHAR(100) = N'Cloud Architecture';

SELECT m.ModuleID, m.ModuleName, mp.Status AS ModuleProgressStatus,
       ea.ScorePercent, ea.IsPassed, ea.XPAwarded,
       (SELECT COUNT(*) FROM UserBadges ub INNER JOIN Badges b ON b.BadgeID = ub.BadgeID
        WHERE ub.StudentID = @StudentID AND b.ModuleID = m.ModuleID) AS HasBadge
FROM Modules m
INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
LEFT JOIN ModuleProgress mp ON mp.ModuleID = m.ModuleID AND mp.StudentID = @StudentID
LEFT JOIN ExamAttempts ea ON ea.ModuleID = m.ModuleID AND ea.StudentID = @StudentID AND ea.IsPassed = 1
WHERE p.PathwayName = @PathwayName
ORDER BY m.ModuleID;

-- Should show 0 rows — certification not earned yet, only awarded
-- once you pass the last module's exam live in the demo.
SELECT * FROM UserCertifications WHERE StudentID = @StudentID;

-- Confirm boss fight history is empty.
SELECT * FROM BattleSessions WHERE StudentID = @StudentID;
GO
