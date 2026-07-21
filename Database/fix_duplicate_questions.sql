USE CloudPhoria;
GO

-- ============================================================
-- FIX DUPLICATE QUESTIONS (same text for same module/room/subtopic)
-- ============================================================

-- Step 1: Delete duplicate PracticeQuestions (keep first one per module + text)
-- First delete their options
DELETE FROM PracticeQuestionOptions
WHERE PracticeQuestionID IN (
    SELECT PracticeQuestionID FROM PracticeQuestions
    WHERE PracticeQuestionID NOT IN (
        SELECT MIN(PracticeQuestionID)
        FROM PracticeQuestions
        GROUP BY ModuleID, QuestionText
    )
);
PRINT 'Removed options for duplicate practice questions: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- Also delete any PracticeAnswers referencing them
DELETE FROM PracticeAnswers
WHERE PracticeQuestionID IN (
    SELECT PracticeQuestionID FROM PracticeQuestions
    WHERE PracticeQuestionID NOT IN (
        SELECT MIN(PracticeQuestionID)
        FROM PracticeQuestions
        GROUP BY ModuleID, QuestionText
    )
);

-- Now delete the duplicate questions themselves
DELETE FROM PracticeQuestions
WHERE PracticeQuestionID NOT IN (
    SELECT MIN(PracticeQuestionID)
    FROM PracticeQuestions
    GROUP BY ModuleID, QuestionText
);
PRINT 'Removed duplicate PracticeQuestions: ' + CAST(@@ROWCOUNT AS VARCHAR);
GO

-- Step 2: Delete duplicate BossFightQuestions (keep first per room + text)
DELETE FROM BossFightQuestionOptions
WHERE BossFightQuestionID IN (
    SELECT BossFightQuestionID FROM BossFightQuestions
    WHERE BossFightQuestionID NOT IN (
        SELECT MIN(BossFightQuestionID)
        FROM BossFightQuestions
        GROUP BY RoomID, QuestionText
    )
);
PRINT 'Removed options for duplicate boss fight questions: ' + CAST(@@ROWCOUNT AS VARCHAR);

DELETE FROM BattleSessionAnswers
WHERE BossFightQuestionID IN (
    SELECT BossFightQuestionID FROM BossFightQuestions
    WHERE BossFightQuestionID NOT IN (
        SELECT MIN(BossFightQuestionID)
        FROM BossFightQuestions
        GROUP BY RoomID, QuestionText
    )
);

DELETE FROM BossFightQuestions
WHERE BossFightQuestionID NOT IN (
    SELECT MIN(BossFightQuestionID)
    FROM BossFightQuestions
    GROUP BY RoomID, QuestionText
);
PRINT 'Removed duplicate BossFightQuestions: ' + CAST(@@ROWCOUNT AS VARCHAR);
GO

-- Step 3: Delete duplicate ExamQuestions (keep first per module + text)
DELETE FROM ExamQuestionOptions
WHERE ExamQuestionID IN (
    SELECT ExamQuestionID FROM ExamQuestions
    WHERE ExamQuestionID NOT IN (
        SELECT MIN(ExamQuestionID)
        FROM ExamQuestions
        GROUP BY ModuleID, QuestionText
    )
);

DELETE FROM ExamAnswers
WHERE ExamQuestionID IN (
    SELECT ExamQuestionID FROM ExamQuestions
    WHERE ExamQuestionID NOT IN (
        SELECT MIN(ExamQuestionID)
        FROM ExamQuestions
        GROUP BY ModuleID, QuestionText
    )
);

DELETE FROM ExamQuestions
WHERE ExamQuestionID NOT IN (
    SELECT MIN(ExamQuestionID)
    FROM ExamQuestions
    GROUP BY ModuleID, QuestionText
);
PRINT 'Removed duplicate ExamQuestions: ' + CAST(@@ROWCOUNT AS VARCHAR);
GO

-- Step 4: Delete duplicate Questions (subtopic, keep first per subtopic + text)
DELETE FROM AnswerOptions
WHERE QuestionID IN (
    SELECT QuestionID FROM Questions
    WHERE QuestionID NOT IN (
        SELECT MIN(QuestionID)
        FROM Questions
        GROUP BY SubTopicID, QuestionText
    )
);

DELETE FROM Questions
WHERE QuestionID NOT IN (
    SELECT MIN(QuestionID)
    FROM Questions
    GROUP BY SubTopicID, QuestionText
);
PRINT 'Removed duplicate SubTopic Questions: ' + CAST(@@ROWCOUNT AS VARCHAR);
GO

-- Step 5: Also remove duplicate options one more time (safety)
DELETE FROM PracticeQuestionOptions
WHERE OptionID NOT IN (
    SELECT MIN(OptionID)
    FROM PracticeQuestionOptions
    GROUP BY PracticeQuestionID, OptionText
);

DELETE FROM BossFightQuestionOptions
WHERE OptionID NOT IN (
    SELECT MIN(OptionID)
    FROM BossFightQuestionOptions
    GROUP BY BossFightQuestionID, OptionText
);

DELETE FROM ExamQuestionOptions
WHERE OptionID NOT IN (
    SELECT MIN(OptionID)
    FROM ExamQuestionOptions
    GROUP BY ExamQuestionID, OptionText
);

DELETE FROM AnswerOptions
WHERE OptionID NOT IN (
    SELECT MIN(OptionID)
    FROM AnswerOptions
    GROUP BY QuestionID, OptionText
);
PRINT 'Final option duplicate cleanup done.';
GO

-- Step 6: Verify
SELECT 'Practice' AS Type, COUNT(*) AS Questions,
    (SELECT COUNT(*) FROM PracticeQuestionOptions) AS TotalOptions
FROM PracticeQuestions;

SELECT 'BossFight' AS Type, COUNT(*) AS Questions,
    (SELECT COUNT(*) FROM BossFightQuestionOptions) AS TotalOptions
FROM BossFightQuestions;

SELECT 'Exam' AS Type, COUNT(*) AS Questions,
    (SELECT COUNT(*) FROM ExamQuestionOptions) AS TotalOptions
FROM ExamQuestions;

SELECT 'SubTopic' AS Type, COUNT(*) AS Questions,
    (SELECT COUNT(*) FROM AnswerOptions) AS TotalOptions
FROM Questions;

PRINT 'ALL DUPLICATES FIXED. Refresh browser and test.';
GO
