USE CloudPhoria;
GO

-- Fix duplicate PracticeQuestionOptions
-- Keeps only the first inserted option for each unique (PracticeQuestionID, OptionText) pair
DELETE FROM PracticeQuestionOptions
WHERE OptionID NOT IN (
    SELECT MIN(OptionID)
    FROM PracticeQuestionOptions
    GROUP BY PracticeQuestionID, OptionText
);

PRINT 'Cleaned PracticeQuestionOptions duplicates: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows deleted.';
GO

-- Fix duplicate BossFightQuestionOptions
DELETE FROM BossFightQuestionOptions
WHERE OptionID NOT IN (
    SELECT MIN(OptionID)
    FROM BossFightQuestionOptions
    GROUP BY BossFightQuestionID, OptionText
);

PRINT 'Cleaned BossFightQuestionOptions duplicates: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows deleted.';
GO

-- Fix duplicate ExamQuestionOptions
DELETE FROM ExamQuestionOptions
WHERE OptionID NOT IN (
    SELECT MIN(OptionID)
    FROM ExamQuestionOptions
    GROUP BY ExamQuestionID, OptionText
);

PRINT 'Cleaned ExamQuestionOptions duplicates: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows deleted.';
GO

-- Fix duplicate AnswerOptions (subtopic questions)
DELETE FROM AnswerOptions
WHERE OptionID NOT IN (
    SELECT MIN(OptionID)
    FROM AnswerOptions
    GROUP BY QuestionID, OptionText
);

PRINT 'Cleaned AnswerOptions duplicates: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows deleted.';
GO

PRINT 'All duplicate options cleaned successfully.';
GO
