-- ============================================================
-- Backfill: award badges retroactively to students who already
-- passed a module's exam before badge-awarding was wired up in
-- Student/Exams.aspx.cs (FinishExam()).
--
-- Safe to re-run; respects UNIQUE (StudentID, BadgeID).
-- ============================================================
USE CloudPhoria;
GO

INSERT INTO UserBadges (StudentID, BadgeID, AwardedAt)
SELECT DISTINCT ea.StudentID, b.BadgeID, GETDATE()
FROM ExamAttempts ea
INNER JOIN Badges b ON b.ModuleID = ea.ModuleID
WHERE ea.IsPassed = 1
  AND NOT EXISTS (
      SELECT 1 FROM UserBadges ub
      WHERE ub.StudentID = ea.StudentID AND ub.BadgeID = b.BadgeID
  );
GO

-- Verify
SELECT s.StudentID, u.FullName, b.BadgeName, ub.AwardedAt
FROM UserBadges ub
INNER JOIN Students s ON s.StudentID = ub.StudentID
INNER JOIN Users u ON u.UserID = s.StudentID
INNER JOIN Badges b ON b.BadgeID = ub.BadgeID
ORDER BY ub.AwardedAt DESC;
GO
