USE CloudPhoria;
GO

-- ============================================================
-- FIX ENROLLMENT: Reset module progress for fresh testing
-- This clears auto-enrollment from the old code so students
-- must explicitly enroll via the PathwayDetail page
-- ============================================================

-- Remove all ModuleProgress rows that are still 'InProgress' with no subtopic progress
-- (These were created by auto-enrollment, not real learning)
DELETE mp FROM ModuleProgress mp
WHERE mp.Status = 'InProgress'
AND NOT EXISTS (
    SELECT 1 FROM SubTopicProgress stp
    INNER JOIN SubTopics st ON st.SubTopicID = stp.SubTopicID
    WHERE st.ModuleID = mp.ModuleID AND stp.StudentID = mp.StudentID
);
GO

-- Also ensure all students have a Free subscription if they don't have any active one
INSERT INTO UserSubscriptions (StudentID, PlanID, StartDate, EndDate, IsActive)
SELECT s.StudentID, 1, GETDATE(), NULL, 1
FROM Students s
WHERE NOT EXISTS (
    SELECT 1 FROM UserSubscriptions us
    WHERE us.StudentID = s.StudentID AND us.IsActive = 1
);
GO

PRINT 'Enrollment data cleaned and subscriptions ensured.';
GO
