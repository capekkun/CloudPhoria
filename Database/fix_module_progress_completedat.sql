-- ============================================================
-- Fix: ModuleProgress rows marked Completed but missing CompletedAt
-- (and XPEarned), which crashes Student/MyLearning.aspx with
-- "InvalidCastException: Object cannot be cast from DBNull to
-- other types" on Convert.ToDateTime(Eval("CompletedAt")).
--
-- Root cause: Student/SubTopicView.aspx.cs only set
-- ModuleProgress.Status='Completed' when all subtopics finished,
-- without setting CompletedAt/XPEarned. Fixed in code (this
-- script backfills the existing bad rows in the live DB).
--
-- Safe to re-run; only touches rows that are already Completed
-- but have a NULL CompletedAt.
-- ============================================================
USE CloudPhoria;
GO

UPDATE mp
SET mp.CompletedAt = GETDATE(),
    mp.XPEarned = ISNULL((
        SELECT SUM(stp.XPEarned)
        FROM SubTopicProgress stp
        INNER JOIN SubTopics st ON st.SubTopicID = stp.SubTopicID
        WHERE st.ModuleID = mp.ModuleID
          AND stp.StudentID = mp.StudentID
          AND stp.Status = 'Completed'
    ), 0)
FROM ModuleProgress mp
WHERE mp.Status = 'Completed'
  AND mp.CompletedAt IS NULL;
GO

-- Verify: should return 0 rows
SELECT ProgressID, StudentID, ModuleID, Status, XPEarned, CompletedAt
FROM ModuleProgress
WHERE Status = 'Completed' AND CompletedAt IS NULL;
GO
