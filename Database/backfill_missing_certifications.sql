-- ============================================================
-- Backfill: award pathway certifications retroactively to
-- students who already passed every module's exam in a pathway
-- before certification-awarding was wired up in
-- Student/Exams.aspx.cs (FinishExam()).
--
-- A student earns a pathway's certification once they have a
-- passing ExamAttempts row for every IsPublished=1 module in
-- that pathway.
--
-- Safe to re-run; respects UNIQUE (StudentID, CertificationID).
-- ============================================================
USE CloudPhoria;
GO

INSERT INTO UserCertifications (StudentID, CertificationID, IssuedAt)
SELECT DISTINCT s.StudentID, c.CertificationID, GETDATE()
FROM Students s
CROSS JOIN Certifications c
WHERE NOT EXISTS (
    SELECT 1 FROM UserCertifications uc
    WHERE uc.StudentID = s.StudentID AND uc.CertificationID = c.CertificationID
)
AND EXISTS (
    -- must have at least one published module in the pathway
    SELECT 1 FROM Modules m WHERE m.PathwayID = c.PathwayID AND m.IsPublished = 1
)
AND NOT EXISTS (
    -- no published module in the pathway that the student hasn't passed
    SELECT 1 FROM Modules m2
    WHERE m2.PathwayID = c.PathwayID AND m2.IsPublished = 1
      AND NOT EXISTS (
          SELECT 1 FROM ExamAttempts ea
          WHERE ea.StudentID = s.StudentID AND ea.ModuleID = m2.ModuleID AND ea.IsPassed = 1
      )
);
GO

-- Verify
SELECT s.StudentID, u.FullName, c.CertificateName, uc.IssuedAt
FROM UserCertifications uc
INNER JOIN Students s ON s.StudentID = uc.StudentID
INNER JOIN Users u ON u.UserID = s.StudentID
INNER JOIN Certifications c ON c.CertificationID = uc.CertificationID
ORDER BY uc.IssuedAt DESC;
GO
