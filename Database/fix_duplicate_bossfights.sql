USE CloudPhoria;
GO

-- ============================================================
-- FIX DUPLICATE BOSS FIGHT ROOMS
--
-- ROOT CAUSE: Database/add_more_bossfights.sql has no duplicate
-- check before its INSERT INTO BossFightRooms statements. Every
-- time that script is run, it creates 4 more rooms named
-- "The Load Balancer Leviathan", "The Ransomware Wraith",
-- "The Kubernetes Kraken", "The Data Breach Devourer" — plus a
-- duplicate Boss, BossFightQuestions, and BossFightQuestionOptions
-- for each. If a teammate re-ran that script (e.g. thinking it
-- didn't work the first time, or running "all setup scripts"
-- again on an already-seeded database), the duplicates you're
-- seeing are the result.
--
-- This script is SAFE TO RUN MULTIPLE TIMES. It keeps the
-- oldest (lowest RoomID) copy of each duplicated title and
-- deletes every newer duplicate, cascading through Bosses ->
-- BossFightQuestions -> BossFightQuestionOptions in the correct
-- order to satisfy foreign keys. It also deletes any
-- BattleSessions/BattleSessionAnswers tied to the duplicate
-- rooms (a student may have already started a battle against
-- a duplicate before this was noticed).
-- ============================================================

-- Step 1: show what will be affected (for your own sanity check before deleting)
SELECT Title, COUNT(*) AS CopyCount
FROM BossFightRooms
GROUP BY Title
HAVING COUNT(*) > 1;
GO

-- Step 2: identify duplicate RoomIDs to delete (keep the lowest RoomID per Title)
IF OBJECT_ID('tempdb..#RoomsToDelete') IS NOT NULL DROP TABLE #RoomsToDelete;

SELECT RoomID
INTO #RoomsToDelete
FROM (
    SELECT RoomID,
           ROW_NUMBER() OVER (PARTITION BY Title ORDER BY RoomID ASC) AS rn
    FROM BossFightRooms
) ranked
WHERE rn > 1;

-- Step 3: delete dependent rows first (children before parents)

-- BattleSessionAnswers depend on BattleSessions and BossFightQuestions
DELETE bsa
FROM BattleSessionAnswers bsa
INNER JOIN BattleSessions bs ON bs.SessionID = bsa.SessionID
WHERE bs.RoomID IN (SELECT RoomID FROM #RoomsToDelete);

-- BattleSessions depend on BossFightRooms
DELETE FROM BattleSessions
WHERE RoomID IN (SELECT RoomID FROM #RoomsToDelete);

-- BossFightQuestionOptions depend on BossFightQuestions
DELETE bfqo
FROM BossFightQuestionOptions bfqo
INNER JOIN BossFightQuestions bfq ON bfq.BossFightQuestionID = bfqo.BossFightQuestionID
WHERE bfq.RoomID IN (SELECT RoomID FROM #RoomsToDelete);

-- BossFightQuestions depend on BossFightRooms
DELETE FROM BossFightQuestions
WHERE RoomID IN (SELECT RoomID FROM #RoomsToDelete);

-- Bosses depend on BossFightRooms (one boss per room)
DELETE FROM Bosses
WHERE RoomID IN (SELECT RoomID FROM #RoomsToDelete);

-- Finally, the duplicate rooms themselves
DELETE FROM BossFightRooms
WHERE RoomID IN (SELECT RoomID FROM #RoomsToDelete);

DROP TABLE #RoomsToDelete;
GO

-- Step 4: verify — should return zero rows if the fix worked
SELECT Title, COUNT(*) AS CopyCount
FROM BossFightRooms
GROUP BY Title
HAVING COUNT(*) > 1;
GO

PRINT 'Duplicate boss fight rooms removed. Run this again on your friend''s database using the same connection.';
GO
