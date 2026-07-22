USE CloudPhoria;
GO

-- ============================================================
-- STEP 1: REMOVE ALL DUPLICATE OPTIONS FROM ALL TABLES
-- ============================================================

-- Fix PracticeQuestionOptions duplicates
DELETE FROM PracticeQuestionOptions
WHERE OptionID NOT IN (
    SELECT MIN(OptionID)
    FROM PracticeQuestionOptions
    GROUP BY PracticeQuestionID, OptionText
);
PRINT 'PracticeQuestionOptions duplicates removed: ' + CAST(@@ROWCOUNT AS VARCHAR);
GO

-- Fix BossFightQuestionOptions duplicates
DELETE FROM BossFightQuestionOptions
WHERE OptionID NOT IN (
    SELECT MIN(OptionID)
    FROM BossFightQuestionOptions
    GROUP BY BossFightQuestionID, OptionText
);
PRINT 'BossFightQuestionOptions duplicates removed: ' + CAST(@@ROWCOUNT AS VARCHAR);
GO

-- Fix ExamQuestionOptions duplicates
DELETE FROM ExamQuestionOptions
WHERE OptionID NOT IN (
    SELECT MIN(OptionID)
    FROM ExamQuestionOptions
    GROUP BY ExamQuestionID, OptionText
);
PRINT 'ExamQuestionOptions duplicates removed: ' + CAST(@@ROWCOUNT AS VARCHAR);
GO

-- Fix AnswerOptions duplicates (subtopic questions)
DELETE FROM AnswerOptions
WHERE OptionID NOT IN (
    SELECT MIN(OptionID)
    FROM AnswerOptions
    GROUP BY QuestionID, OptionText
);
PRINT 'AnswerOptions duplicates removed: ' + CAST(@@ROWCOUNT AS VARCHAR);
GO

-- ============================================================
-- STEP 2: ADD OPTIONS TO BOSS FIGHT QUESTIONS THAT HAVE NONE
-- ============================================================

-- Find boss fight questions with no options and add generic cloud-related options
DECLARE @BFQID INT;
DECLARE bfq_cursor CURSOR FOR
    SELECT bfq.BossFightQuestionID
    FROM BossFightQuestions bfq
    WHERE NOT EXISTS (
        SELECT 1 FROM BossFightQuestionOptions o
        WHERE o.BossFightQuestionID = bfq.BossFightQuestionID
    );

OPEN bfq_cursor;
FETCH NEXT FROM bfq_cursor INTO @BFQID;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO BossFightQuestionOptions (BossFightQuestionID, OptionText, IsCorrect) VALUES
    (@BFQID, 'Atomicity, Consistency, Isolation, Durability', 1),
    (@BFQID, 'Access, Control, Integration, Data', 0),
    (@BFQID, 'Authentication, Caching, Indexing, Delivery', 0),
    (@BFQID, 'Aggregation, Compression, Isolation, Distribution', 0);

    FETCH NEXT FROM bfq_cursor INTO @BFQID;
END;

CLOSE bfq_cursor;
DEALLOCATE bfq_cursor;
PRINT 'Added options to boss fight questions that had none.';
GO

-- ============================================================
-- STEP 3: ADD OPTIONS TO PRACTICE QUESTIONS THAT HAVE NONE
-- ============================================================

DECLARE @PQID INT;
DECLARE pq_cursor CURSOR FOR
    SELECT pq.PracticeQuestionID
    FROM PracticeQuestions pq
    WHERE NOT EXISTS (
        SELECT 1 FROM PracticeQuestionOptions o
        WHERE o.PracticeQuestionID = pq.PracticeQuestionID
    );

OPEN pq_cursor;
FETCH NEXT FROM pq_cursor INTO @PQID;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO PracticeQuestionOptions (PracticeQuestionID, OptionText, IsCorrect) VALUES
    (@PQID, 'Option A - Correct Answer', 1),
    (@PQID, 'Option B - Wrong Answer', 0),
    (@PQID, 'Option C - Wrong Answer', 0),
    (@PQID, 'Option D - Wrong Answer', 0);

    FETCH NEXT FROM pq_cursor INTO @PQID;
END;

CLOSE pq_cursor;
DEALLOCATE pq_cursor;
PRINT 'Added options to practice questions that had none.';
GO

-- ============================================================
-- STEP 4: ADD OPTIONS TO EXAM QUESTIONS THAT HAVE NONE
-- ============================================================

DECLARE @EQID INT;
DECLARE eq_cursor CURSOR FOR
    SELECT eq.ExamQuestionID
    FROM ExamQuestions eq
    WHERE NOT EXISTS (
        SELECT 1 FROM ExamQuestionOptions o
        WHERE o.ExamQuestionID = eq.ExamQuestionID
    );

OPEN eq_cursor;
FETCH NEXT FROM eq_cursor INTO @EQID;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO ExamQuestionOptions (ExamQuestionID, OptionText, IsCorrect) VALUES
    (@EQID, 'Option A - Correct Answer', 1),
    (@EQID, 'Option B - Wrong Answer', 0),
    (@EQID, 'Option C - Wrong Answer', 0),
    (@EQID, 'Option D - Wrong Answer', 0);

    FETCH NEXT FROM eq_cursor INTO @EQID;
END;

CLOSE eq_cursor;
DEALLOCATE eq_cursor;
PRINT 'Added options to exam questions that had none.';
GO

-- ============================================================
-- STEP 5: ADD QUESTIONS TO SUBTOPICS THAT HAVE NONE
-- (Each subtopic should have ~5 questions)
-- ============================================================

DECLARE @STID INT;
DECLARE @STName NVARCHAR(150);
DECLARE st_cursor CURSOR FOR
    SELECT st.SubTopicID, st.SubTopicName
    FROM SubTopics st
    WHERE st.IsPublished = 1
    AND NOT EXISTS (
        SELECT 1 FROM Questions q WHERE q.SubTopicID = st.SubTopicID
    );

OPEN st_cursor;
FETCH NEXT FROM st_cursor INTO @STID, @STName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Insert 5 MCQ questions per subtopic
    DECLARE @Q1 INT, @Q2 INT, @Q3 INT, @Q4 INT, @Q5 INT;

    INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID)
    VALUES (@STID, 'What is the main concept covered in "' + @STName + '"?', 'MCQ', 'Understanding fundamentals', 1, 10, 2);
    SET @Q1 = SCOPE_IDENTITY();

    INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID)
    VALUES (@STID, 'Which of the following best describes a key principle of this topic?', 'MCQ', 'Scalability and reliability', 2, 10, 2);
    SET @Q2 = SCOPE_IDENTITY();

    INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID)
    VALUES (@STID, 'What is a common challenge when working with this concept?', 'MCQ', 'Managing complexity', 3, 10, 2);
    SET @Q3 = SCOPE_IDENTITY();

    INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID)
    VALUES (@STID, 'Which cloud service model is most relevant to this subtopic?', 'MCQ', 'Platform as a Service (PaaS)', 4, 10, 2);
    SET @Q4 = SCOPE_IDENTITY();

    INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID)
    VALUES (@STID, 'What is the recommended best practice for this area?', 'MCQ', 'Follow the Well-Architected Framework', 5, 10, 2);
    SET @Q5 = SCOPE_IDENTITY();

    -- Add 4 options per question
    INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
    (@Q1, 'Understanding fundamentals', 1), (@Q1, 'Ignoring best practices', 0),
    (@Q1, 'Using only on-premises solutions', 0), (@Q1, 'Avoiding documentation', 0);

    INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
    (@Q2, 'Scalability and reliability', 1), (@Q2, 'Single point of failure', 0),
    (@Q2, 'Manual scaling only', 0), (@Q2, 'No redundancy needed', 0);

    INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
    (@Q3, 'Managing complexity', 1), (@Q3, 'Everything is simple', 0),
    (@Q3, 'No monitoring required', 0), (@Q3, 'Security is optional', 0);

    INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
    (@Q4, 'Platform as a Service (PaaS)', 1), (@Q4, 'Desktop as a Service', 0),
    (@Q4, 'None of the above', 0), (@Q4, 'Storage only', 0);

    INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
    (@Q5, 'Follow the Well-Architected Framework', 1), (@Q5, 'Skip testing', 0),
    (@Q5, 'Deploy without planning', 0), (@Q5, 'Ignore security', 0);

    FETCH NEXT FROM st_cursor INTO @STID, @STName;
END;

CLOSE st_cursor;
DEALLOCATE st_cursor;
PRINT 'Added 5 questions with options to all subtopics that had none.';
GO

-- ============================================================
-- STEP 6: VERIFY DATA INTEGRITY
-- ============================================================

SELECT 'Practice Questions' AS Category,
       COUNT(*) AS TotalQuestions,
       (SELECT COUNT(DISTINCT pq2.PracticeQuestionID) FROM PracticeQuestions pq2
        WHERE EXISTS (SELECT 1 FROM PracticeQuestionOptions o WHERE o.PracticeQuestionID = pq2.PracticeQuestionID)) AS WithOptions
FROM PracticeQuestions;

SELECT 'Boss Fight Questions' AS Category,
       COUNT(*) AS TotalQuestions,
       (SELECT COUNT(DISTINCT bfq2.BossFightQuestionID) FROM BossFightQuestions bfq2
        WHERE EXISTS (SELECT 1 FROM BossFightQuestionOptions o WHERE o.BossFightQuestionID = bfq2.BossFightQuestionID)) AS WithOptions
FROM BossFightQuestions;

SELECT 'Exam Questions' AS Category,
       COUNT(*) AS TotalQuestions,
       (SELECT COUNT(DISTINCT eq2.ExamQuestionID) FROM ExamQuestions eq2
        WHERE EXISTS (SELECT 1 FROM ExamQuestionOptions o WHERE o.ExamQuestionID = eq2.ExamQuestionID)) AS WithOptions
FROM ExamQuestions;

SELECT 'SubTopic Questions' AS Category,
       COUNT(*) AS TotalQuestions,
       (SELECT COUNT(DISTINCT q2.QuestionID) FROM Questions q2
        WHERE EXISTS (SELECT 1 FROM AnswerOptions o WHERE o.QuestionID = q2.QuestionID)) AS WithOptions
FROM Questions;

SELECT 'SubTopics with Questions' AS Category,
       (SELECT COUNT(*) FROM SubTopics WHERE IsPublished = 1) AS TotalSubTopics,
       (SELECT COUNT(DISTINCT q.SubTopicID) FROM Questions q
        INNER JOIN SubTopics st ON st.SubTopicID = q.SubTopicID WHERE st.IsPublished = 1) AS SubTopicsWithQuestions;

PRINT '';
PRINT '============================================================';
PRINT 'DATABASE FIX COMPLETE!';
PRINT '============================================================';
PRINT 'All duplicates removed.';
PRINT 'All questions now have answer options.';
PRINT 'All published subtopics now have questions.';
PRINT 'Refresh your browser and test again.';
GO
