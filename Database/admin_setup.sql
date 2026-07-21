USE CloudPhoria;
GO

-- ============================================================
-- ADMIN SETUP
-- No schema changes. This just verifies you have at least one
-- Admin account and shows any instructors stuck as Pending
-- (which is why their Modules/SubTopics/Questions/Challenges
-- pages redirect back to Dashboard — see CloudPhoria_ProjectRules.md
-- Section 12: only Approved instructors get full teaching access).
-- ============================================================

-- 1. Check you have at least one Admin account
SELECT u.UserID, u.FullName, u.Email
FROM Users u
INNER JOIN Admins a ON a.AdminID = u.UserID;

-- 2. List all instructors and their current LicenseStatus
SELECT i.InstructorID, u.FullName, u.Email, i.LicenseStatus, i.Qualification
FROM Instructors i
INNER JOIN Users u ON u.UserID = i.InstructorID
ORDER BY i.LicenseStatus, u.FullName;

-- 3. OPTIONAL: If you want to bulk-approve all currently pending
--    instructors right now (instead of approving them one by one
--    in the new Admin Dashboard), uncomment and run this:
--
-- UPDATE Instructors SET LicenseStatus = 'Approved', ApprovedAt = GETDATE()
-- WHERE LicenseStatus = 'Pending';

PRINT 'Admin setup check complete. Use Admin/Dashboard.aspx to approve instructors going forward.';
GO
