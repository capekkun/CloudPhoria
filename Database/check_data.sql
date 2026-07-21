USE CloudPhoria;
GO

-- ============================================================
-- CHECK 1: SubTopics per Module (are there subtopics?)
-- ============================================================
SELECT m.ModuleID, m.ModuleName, p.PathwayName, m.IsPublished,
       (SELECT COUNT(*) FROM SubTopics st WHERE st.ModuleID = m.ModuleID AND st.IsPublished = 1) AS PublishedSubTopics
FROM Modules m
INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
ORDER BY p.PathwayID, m.ModuleID;
GO

-- ============================================================
-- CHECK 2: Questions per SubTopic (do subtopics have questions?)
-- ============================================================
SELECT TOP 20 st.SubTopicID, st.SubTopicName, st.ModuleID, st.IsPublished,
       (SELECT COUNT(*) FROM Questions q WHERE q.SubTopicID = st.SubTopicID) AS QuestionCount
FROM SubTopics st
WHERE st.IsPublished = 1
ORDER BY st.ModuleID, st.OrderIndex;
GO

-- ============================================================
-- CHECK 3: AnswerOptions per Question (do questions have options?)
-- ============================================================
SELECT TOP 20 q.QuestionID, q.QuestionText, q.QuestionType, q.SubTopicID,
       (SELECT COUNT(*) FROM AnswerOptions ao WHERE ao.QuestionID = q.QuestionID) AS OptionCount
FROM Questions q
ORDER BY q.SubTopicID, q.OrderIndex;
GO

-- ============================================================
-- CHECK 4: PracticeQuestions per Module + their options
-- ============================================================
SELECT pq.PracticeQuestionID, pq.ModuleID, LEFT(pq.QuestionText, 60) AS QuestionPreview,
       (SELECT COUNT(*) FROM PracticeQuestionOptions pqo WHERE pqo.PracticeQuestionID = pq.PracticeQuestionID) AS OptionCount
FROM PracticeQuestions pq
WHERE pq.ModuleID = 1
ORDER BY pq.OrderIndex;
GO

-- ============================================================
-- CHECK 5: Sample PracticeQuestionOptions for Module 1, Question 1
-- ============================================================
SELECT pqo.OptionID, pqo.PracticeQuestionID, pqo.OptionText, pqo.IsCorrect
FROM PracticeQuestionOptions pqo
WHERE pqo.PracticeQuestionID = (
    SELECT TOP 1 PracticeQuestionID FROM PracticeQuestions WHERE ModuleID = 1 ORDER BY OrderIndex
)
ORDER BY pqo.OptionID;
GO

-- ============================================================
-- CHECK 6: BossFightQuestions and their options
-- ============================================================
SELECT bfq.BossFightQuestionID, bfq.RoomID, LEFT(bfq.QuestionText, 60) AS QuestionPreview,
       (SELECT COUNT(*) FROM BossFightQuestionOptions o WHERE o.BossFightQuestionID = bfq.BossFightQuestionID) AS OptionCount
FROM BossFightQuestions bfq
WHERE bfq.RoomID = 2
ORDER BY bfq.OrderIndex;
GO

-- ============================================================
-- CHECK 7: ExamQuestions per Module
-- ============================================================
SELECT eq.ExamQuestionID, eq.ModuleID, LEFT(eq.QuestionText, 60) AS QuestionPreview,
       (SELECT COUNT(*) FROM ExamQuestionOptions eqo WHERE eqo.ExamQuestionID = eq.ExamQuestionID) AS OptionCount
FROM ExamQuestions eq
WHERE eq.ModuleID = 1
ORDER BY eq.OrderIndex;
GO

-- ============================================================
-- SUMMARY
-- ============================================================
SELECT 'Modules' AS Item, COUNT(*) AS Total, SUM(CASE WHEN IsPublished=1 THEN 1 ELSE 0 END) AS Published FROM Modules
UNION ALL
SELECT 'SubTopics', COUNT(*), SUM(CASE WHEN IsPublished=1 THEN 1 ELSE 0 END) FROM SubTopics
UNION ALL
SELECT 'Questions (SubTopic)', COUNT(*), COUNT(*) FROM Questions
UNION ALL
SELECT 'AnswerOptions', COUNT(*), COUNT(*) FROM AnswerOptions
UNION ALL
SELECT 'PracticeQuestions', COUNT(*), COUNT(*) FROM PracticeQuestions
UNION ALL
SELECT 'PracticeQuestionOptions', COUNT(*), COUNT(*) FROM PracticeQuestionOptions
UNION ALL
SELECT 'ExamQuestions', COUNT(*), COUNT(*) FROM ExamQuestions
UNION ALL
SELECT 'ExamQuestionOptions', COUNT(*), COUNT(*) FROM ExamQuestionOptions
UNION ALL
SELECT 'BossFightQuestions', COUNT(*), COUNT(*) FROM BossFightQuestions
UNION ALL
SELECT 'BossFightQuestionOptions', COUNT(*), COUNT(*) FROM BossFightQuestionOptions;
GO
