USE CloudPhoria;
GO

-- ============================================================
-- DEMO: Instructor Approval Flow
-- Creates one Pending instructor account so you can demo the
-- Admin/InstructorApprovals.aspx page (Approve/Reject buttons).
--
-- After running this script:
--   1. Log in as Admin -> go to /Admin/InstructorApprovals.aspx
--   2. You will see "Jane Demo" listed under Pending Approvals
--   3. Click Approve (or Reject) to test the flow
--   4. Log in as the demo instructor (email/password below) to see
--      the before/after difference in what they can access
--      (Modules/SubTopics/Questions/Classrooms/Materials/
--      Assignments/Challenges are blocked until Approved,
--      per CloudPhoria_ProjectRules.md Section 12)
--
-- Safe to re-run: it checks for an existing email first and
-- skips the insert if the demo account already exists.
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'jane.demo@cloudphoria.test')
BEGIN
    DECLARE @NewUserID INT;

    INSERT INTO Users (FullName, Email, PasswordHash, Role, IsActive, IsBanned, CreatedAt)
    VALUES ('Jane Demo', 'jane.demo@cloudphoria.test', 'Demo@123', 'Instructor', 1, 0, GETDATE());

    SET @NewUserID = SCOPE_IDENTITY();

    INSERT INTO Instructors (InstructorID, Qualification, LicenseStatus, ApprovedBy, ApprovedAt)
    VALUES (@NewUserID, 'B.Sc. Cloud Computing, AWS Certified Solutions Architect', 'Pending', NULL, NULL);

    PRINT 'Demo instructor created: jane.demo@cloudphoria.test / Demo@123 (LicenseStatus = Pending)';
END
ELSE
BEGIN
    PRINT 'Demo instructor already exists — resetting status back to Pending for re-demo.';

    UPDATE Instructors
    SET LicenseStatus = 'Pending', ApprovedBy = NULL, ApprovedAt = NULL
    WHERE InstructorID = (SELECT UserID FROM Users WHERE Email = 'jane.demo@cloudphoria.test');
END
GO

-- Verify: this is exactly the query Admin/InstructorApprovals.aspx runs
-- for the "Pending Approvals" list.
SELECT i.InstructorID, u.FullName, u.Email, i.Qualification, u.CreatedAt
FROM Instructors i
INNER JOIN Users u ON u.UserID = i.InstructorID
WHERE i.LicenseStatus = 'Pending'
ORDER BY u.CreatedAt;
GO
