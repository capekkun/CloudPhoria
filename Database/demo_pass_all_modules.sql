-- ============================================================
-- Demo helper: mark a student as PASSED for every module in a
-- pathway (enroll, complete all subtopics, insert a passing
-- ExamAttempts row, award XP) — mirrors exactly what the real
-- app does on a first exam pass (see Student/Exams.aspx.cs).
--
-- Not part of the app build — run manually in SSMS for demos.
-- Edit @StudentID and @PathwayName below, then run the whole file.
-- ============================================================
USE CloudPhoria;
GO

DECLARE @StudentID INT = 5;                          -- Aiman Haziq
DECLARE @PathwayName NVARCHAR(100) = N'Cloud Architecture';

-- 1) Enroll the student in every published module of the pathway
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
GO

-- 2) Complete every published subtopic in every module of the pathway
DECLARE @StudentID INT = 5;
DECLARE @PathwayName NVARCHAR(100) = N'Cloud Architecture';

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

UPDATE sp
SET sp.Status = 'Completed', sp.CompletedAt = GETDATE()
FROM SubTopicProgress sp
INNER JOIN SubTopics st ON st.SubTopicID = sp.SubTopicID
INNER JOIN Modules m ON m.ModuleID = st.ModuleID
INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
WHERE sp.StudentID = @StudentID
  AND p.PathwayName = @PathwayName
  AND sp.Status <> 'Completed';
GO

-- 3) Mark every module as Completed in ModuleProgress (all subtopics done)
DECLARE @StudentID INT = 5;
DECLARE @PathwayName NVARCHAR(100) = N'Cloud Architecture';

UPDATE mp
SET mp.Status = 'Completed'
FROM ModuleProgress mp
INNER JOIN Modules m ON m.ModuleID = mp.ModuleID
INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
WHERE mp.StudentID = @StudentID
  AND p.PathwayName = @PathwayName;
GO

-- 4) Insert a passing ExamAttempts row for every module that has exam
--    questions and the student hasn't already passed, then award XP
--    exactly once per module (mirrors FinishExam() in Exams.aspx.cs).
DECLARE @StudentID INT = 5;
DECLARE @PathwayName NVARCHAR(100) = N'Cloud Architecture';

DECLARE @ModuleID INT, @XPReward INT, @PassMark INT;

DECLARE moduleCursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT m.ModuleID, m.XPReward, m.ExamPassMarkPercent
    FROM Modules m
    INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
    WHERE p.PathwayName = @PathwayName
      AND m.IsPublished = 1
      AND EXISTS (SELECT 1 FROM ExamQuestions eq WHERE eq.ModuleID = m.ModuleID)
      AND NOT EXISTS (
          SELECT 1 FROM ExamAttempts ea
          WHERE ea.StudentID = @StudentID AND ea.ModuleID = m.ModuleID AND ea.IsPassed = 1
      );

OPEN moduleCursor;
FETCH NEXT FROM moduleCursor INTO @ModuleID, @XPReward, @PassMark;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Insert a completed, passing exam attempt with a full score.
    INSERT INTO ExamAttempts (StudentID, ModuleID, StartedAt, SubmittedAt, ScorePercent, IsPassed, XPAwarded)
    VALUES (@StudentID, @ModuleID, GETDATE(), GETDATE(), 100, 1, @XPReward);

    -- Award XP via the ledger + running total, same as FinishExam().
    INSERT INTO XPTransactions (StudentID, SourceType, SourceID, XPAmount, CreatedAt)
    VALUES (@StudentID, 'ModuleExam', @ModuleID, @XPReward, GETDATE());

    UPDATE Students SET TotalXP = TotalXP + @XPReward WHERE StudentID = @StudentID;

    FETCH NEXT FROM moduleCursor INTO @ModuleID, @XPReward, @PassMark;
END

CLOSE moduleCursor;
DEALLOCATE moduleCursor;
GO

-- 5) Verify: should show all modules Completed with IsPassed = 1
DECLARE @StudentID INT = 5;
DECLARE @PathwayName NVARCHAR(100) = N'Cloud Architecture';

SELECT m.ModuleID, m.ModuleName, mp.Status AS ModuleProgressStatus,
       ea.ScorePercent, ea.IsPassed, ea.XPAwarded
FROM Modules m
INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
LEFT JOIN ModuleProgress mp ON mp.ModuleID = m.ModuleID AND mp.StudentID = @StudentID
LEFT JOIN ExamAttempts ea ON ea.ModuleID = m.ModuleID AND ea.StudentID = @StudentID AND ea.IsPassed = 1
WHERE p.PathwayName = @PathwayName
ORDER BY m.ModuleID;
GO
