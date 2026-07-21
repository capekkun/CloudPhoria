USE CloudPhoria;
GO

-- ============================================================
-- ADD MORE BOSS FIGHT ROOMS
-- Uses the SAME BossFightQuestions/BossFightQuestionOptions
-- schema — the drag-and-drop battle UI just changes how the
-- student answers (drag the correct option into the drop zone
-- instead of clicking a button). No schema changes needed.
-- ============================================================

DECLARE @AdminID INT = (SELECT TOP 1 AdminID FROM Admins ORDER BY AdminID);
DECLARE @RoomID INT;
DECLARE @BossID INT;
DECLARE @QID INT;

-- ============================================================
-- ROOM 1: The Load Balancer Leviathan (Easy)
-- Guarded — this script is now safe to re-run. If a room with
-- this exact title already exists, skip creating it again.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM BossFightRooms WHERE Title = 'The Load Balancer Leviathan')
BEGIN
INSERT INTO BossFightRooms (Title, DifficultyLevel, XPReward, IsPublished, CreatedByAdminID)
VALUES ('The Load Balancer Leviathan', 'Easy', 40, 1, @AdminID);
SET @RoomID = SCOPE_IDENTITY();

INSERT INTO Bosses (RoomID, BossName, MaxHP, AttackStrength, IconPath)
VALUES (@RoomID, 'Leviathan', 80, 8, NULL);
SET @BossID = SCOPE_IDENTITY();

INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds) VALUES
(@RoomID, 'Drag the correct answer: What distributes incoming traffic across multiple servers?', 20, 25);
SET @QID = SCOPE_IDENTITY();
INSERT INTO BossFightQuestionOptions (BossFightQuestionID, OptionText, IsCorrect) VALUES
(@QID, 'Load Balancer', 1), (@QID, 'Firewall', 0), (@QID, 'DNS Server', 0), (@QID, 'VPN', 0);

INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds) VALUES
(@RoomID, 'Drag the correct answer: Which HTTP status code means "Service Unavailable"?', 20, 25);
SET @QID = SCOPE_IDENTITY();
INSERT INTO BossFightQuestionOptions (BossFightQuestionID, OptionText, IsCorrect) VALUES
(@QID, '503', 1), (@QID, '404', 0), (@QID, '200', 0), (@QID, '301', 0);

INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds) VALUES
(@RoomID, 'Drag the correct answer: What algorithm sends requests to servers in rotation?', 20, 25);
SET @QID = SCOPE_IDENTITY();
INSERT INTO BossFightQuestionOptions (BossFightQuestionID, OptionText, IsCorrect) VALUES
(@QID, 'Round Robin', 1), (@QID, 'Binary Search', 0), (@QID, 'Quick Sort', 0), (@QID, 'Depth First', 0);

INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds) VALUES
(@RoomID, 'Drag the correct answer: Which check verifies a server is still healthy?', 20, 25);
SET @QID = SCOPE_IDENTITY();
INSERT INTO BossFightQuestionOptions (BossFightQuestionID, OptionText, IsCorrect) VALUES
(@QID, 'Health Check', 1), (@QID, 'Credit Check', 0), (@QID, 'Type Check', 0), (@QID, 'Spell Check', 0);
END
GO

-- ============================================================
-- ROOM 2: The Ransomware Wraith (Medium)
-- Guarded — safe to re-run.
-- ============================================================
DECLARE @AdminID2 INT = (SELECT TOP 1 AdminID FROM Admins ORDER BY AdminID);
DECLARE @RoomID2 INT;
DECLARE @BossID2 INT;
DECLARE @QID2 INT;

IF NOT EXISTS (SELECT 1 FROM BossFightRooms WHERE Title = 'The Ransomware Wraith')
BEGIN
INSERT INTO BossFightRooms (Title, DifficultyLevel, XPReward, IsPublished, CreatedByAdminID)
VALUES ('The Ransomware Wraith', 'Medium', 65, 1, @AdminID2);
SET @RoomID2 = SCOPE_IDENTITY();

INSERT INTO Bosses (RoomID, BossName, MaxHP, AttackStrength, IconPath)
VALUES (@RoomID2, 'Wraith', 120, 12, NULL);
SET @BossID2 = SCOPE_IDENTITY();

INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds) VALUES
(@RoomID2, 'Drag the correct answer: What type of malware encrypts your files for ransom?', 25, 20);
SET @QID2 = SCOPE_IDENTITY();
INSERT INTO BossFightQuestionOptions (BossFightQuestionID, OptionText, IsCorrect) VALUES
(@QID2, 'Ransomware', 1), (@QID2, 'Adware', 0), (@QID2, 'Spyware', 0), (@QID2, 'Firmware', 0);

INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds) VALUES
(@RoomID2, 'Drag the correct answer: Best defense against ransomware is regular what?', 25, 20);
SET @QID2 = SCOPE_IDENTITY();
INSERT INTO BossFightQuestionOptions (BossFightQuestionID, OptionText, IsCorrect) VALUES
(@QID2, 'Backups', 1), (@QID2, 'Downloads', 0), (@QID2, 'Uploads', 0), (@QID2, 'Streaming', 0);

INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds) VALUES
(@RoomID2, 'Drag the correct answer: What do attackers demand after encrypting your files?', 25, 20);
SET @QID2 = SCOPE_IDENTITY();
INSERT INTO BossFightQuestionOptions (BossFightQuestionID, OptionText, IsCorrect) VALUES
(@QID2, 'Ransom payment', 1), (@QID2, 'A software update', 0), (@QID2, 'A password reset', 0), (@QID2, 'A subscription', 0);

INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds) VALUES
(@RoomID2, 'Drag the correct answer: Which email tactic often delivers ransomware?', 25, 20);
SET @QID2 = SCOPE_IDENTITY();
INSERT INTO BossFightQuestionOptions (BossFightQuestionID, OptionText, IsCorrect) VALUES
(@QID2, 'Phishing', 1), (@QID2, 'Newsletter', 0), (@QID2, 'Auto-reply', 0), (@QID2, 'CC/BCC', 0);
END
GO

-- ============================================================
-- ROOM 3: The Kubernetes Kraken (Hard)
-- Guarded — safe to re-run.
-- ============================================================
DECLARE @AdminID3 INT = (SELECT TOP 1 AdminID FROM Admins ORDER BY AdminID);
DECLARE @RoomID3 INT;
DECLARE @BossID3 INT;
DECLARE @QID3 INT;

IF NOT EXISTS (SELECT 1 FROM BossFightRooms WHERE Title = 'The Kubernetes Kraken')
BEGIN
INSERT INTO BossFightRooms (Title, DifficultyLevel, XPReward, IsPublished, CreatedByAdminID)
VALUES ('The Kubernetes Kraken', 'Hard', 90, 1, @AdminID3);
SET @RoomID3 = SCOPE_IDENTITY();

INSERT INTO Bosses (RoomID, BossName, MaxHP, AttackStrength, IconPath)
VALUES (@RoomID3, 'Kraken', 160, 16, NULL);
SET @BossID3 = SCOPE_IDENTITY();

INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds) VALUES
(@RoomID3, 'Drag the correct answer: The smallest deployable unit in Kubernetes is called a?', 30, 20);
SET @QID3 = SCOPE_IDENTITY();
INSERT INTO BossFightQuestionOptions (BossFightQuestionID, OptionText, IsCorrect) VALUES
(@QID3, 'Pod', 1), (@QID3, 'Container', 0), (@QID3, 'Node', 0), (@QID3, 'Cluster', 0);

INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds) VALUES
(@RoomID3, 'Drag the correct answer: Which component schedules pods onto nodes?', 30, 20);
SET @QID3 = SCOPE_IDENTITY();
INSERT INTO BossFightQuestionOptions (BossFightQuestionID, OptionText, IsCorrect) VALUES
(@QID3, 'Scheduler', 1), (@QID3, 'Ingress', 0), (@QID3, 'ConfigMap', 0), (@QID3, 'Secret', 0);

INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds) VALUES
(@RoomID3, 'Drag the correct answer: What manages a set of identical pods and keeps them running?', 30, 20);
SET @QID3 = SCOPE_IDENTITY();
INSERT INTO BossFightQuestionOptions (BossFightQuestionID, OptionText, IsCorrect) VALUES
(@QID3, 'ReplicaSet', 1), (@QID3, 'Namespace', 0), (@QID3, 'Volume', 0), (@QID3, 'Taint', 0);

INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds) VALUES
(@RoomID3, 'Drag the correct answer: What exposes a set of pods as a network service?', 30, 20);
SET @QID3 = SCOPE_IDENTITY();
INSERT INTO BossFightQuestionOptions (BossFightQuestionID, OptionText, IsCorrect) VALUES
(@QID3, 'Service', 1), (@QID3, 'Deployment', 0), (@QID3, 'DaemonSet', 0), (@QID3, 'Job', 0);
END
GO

-- ============================================================
-- ROOM 4: The Data Breach Devourer (Legendary)
-- Guarded — safe to re-run.
-- ============================================================
DECLARE @AdminID4 INT = (SELECT TOP 1 AdminID FROM Admins ORDER BY AdminID);
DECLARE @RoomID4 INT;
DECLARE @BossID4 INT;
DECLARE @QID4 INT;

IF NOT EXISTS (SELECT 1 FROM BossFightRooms WHERE Title = 'The Data Breach Devourer')
BEGIN
INSERT INTO BossFightRooms (Title, DifficultyLevel, XPReward, IsPublished, CreatedByAdminID)
VALUES ('The Data Breach Devourer', 'Legendary', 150, 1, @AdminID4);
SET @RoomID4 = SCOPE_IDENTITY();

INSERT INTO Bosses (RoomID, BossName, MaxHP, AttackStrength, EnrageThresholdPct, IconPath)
VALUES (@RoomID4, 'Devourer', 220, 22, 30, NULL);
SET @BossID4 = SCOPE_IDENTITY();

INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds) VALUES
(@RoomID4, 'Drag the correct answer: What principle limits users to only the access they need?', 35, 18);
SET @QID4 = SCOPE_IDENTITY();
INSERT INTO BossFightQuestionOptions (BossFightQuestionID, OptionText, IsCorrect) VALUES
(@QID4, 'Least Privilege', 1), (@QID4, 'Full Access', 0), (@QID4, 'Open Policy', 0), (@QID4, 'Zero Trust Bypass', 0);

INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds) VALUES
(@RoomID4, 'Drag the correct answer: Which law protects EU citizens'' personal data?', 35, 18);
SET @QID4 = SCOPE_IDENTITY();
INSERT INTO BossFightQuestionOptions (BossFightQuestionID, OptionText, IsCorrect) VALUES
(@QID4, 'GDPR', 1), (@QID4, 'HIPAA', 0), (@QID4, 'PCI-DSS', 0), (@QID4, 'SOX', 0);

INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds) VALUES
(@RoomID4, 'Drag the correct answer: What should you do FIRST when a breach is detected?', 35, 18);
SET @QID4 = SCOPE_IDENTITY();
INSERT INTO BossFightQuestionOptions (BossFightQuestionID, OptionText, IsCorrect) VALUES
(@QID4, 'Contain the breach', 1), (@QID4, 'Post on social media', 0), (@QID4, 'Delete all logs', 0), (@QID4, 'Ignore it', 0);

INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds) VALUES
(@RoomID4, 'Drag the correct answer: Encrypting data so only authorized keys can read it is called?', 35, 18);
SET @QID4 = SCOPE_IDENTITY();
INSERT INTO BossFightQuestionOptions (BossFightQuestionID, OptionText, IsCorrect) VALUES
(@QID4, 'Encryption', 1), (@QID4, 'Compression', 0), (@QID4, 'Replication', 0), (@QID4, 'Virtualization', 0);
END
GO

PRINT 'Boss fight rooms are present (created now, or already existed from a previous run — this script is idempotent).';
GO
