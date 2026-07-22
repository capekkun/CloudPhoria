USE CloudPhoria;
GO

-- ============================================================
-- FIX CHALLENGES: Add question tables, clear duplicates, seed live data
-- ============================================================

-- 1. Create ChallengeQuestions table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ChallengeQuestions')
BEGIN
    CREATE TABLE ChallengeQuestions (
        ChallengeQuestionID INT IDENTITY(1,1) PRIMARY KEY,
        ChallengeID         INT NOT NULL,
        QuestionText        NVARCHAR(500) NOT NULL,
        Points              INT NOT NULL DEFAULT 10,
        TimeLimitSeconds    INT NOT NULL DEFAULT 30,
        OrderIndex          INT NOT NULL DEFAULT 0,
        CONSTRAINT FK_ChallengeQuestions_Challenge FOREIGN KEY (ChallengeID) REFERENCES Challenges(ChallengeID)
    );
END
GO

-- 2. Create ChallengeQuestionOptions table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ChallengeQuestionOptions')
BEGIN
    CREATE TABLE ChallengeQuestionOptions (
        OptionID            INT IDENTITY(1,1) PRIMARY KEY,
        ChallengeQuestionID INT NOT NULL,
        OptionText          NVARCHAR(300) NOT NULL,
        IsCorrect           BIT NOT NULL DEFAULT 0,
        CONSTRAINT FK_ChallengeQuestionOptions_Question FOREIGN KEY (ChallengeQuestionID) REFERENCES ChallengeQuestions(ChallengeQuestionID)
    );
END
GO

-- 3. Clear existing challenge data (duplicates/empty)
DELETE FROM ChallengeParticipation;
DELETE FROM Challenges;
GO
DBCC CHECKIDENT ('Challenges', RESEED, 0);
DBCC CHECKIDENT ('ChallengeParticipation', RESEED, 0);
GO

-- 4. Seed live challenges (admin-created, with start/end dates spanning current time)
INSERT INTO Challenges (Title, Description, CreatedByAdminID, XPReward, StartDate, EndDate, IsGlobalAdminChallenge)
VALUES
('Cloud Fundamentals Speed Run', 'Test your cloud basics knowledge in this timed challenge! Answer fast and climb the leaderboard.', 1, 50, '2025-07-01', '2026-08-01', 1),
('Networking Blitz', 'How fast can you answer networking questions? Race against other students!', 1, 75, '2025-07-10', '2026-08-15', 1),
('Security Sprint', 'Cybersecurity rapid-fire questions. Every second counts for your score!', 1, 60, '2025-07-15', '2026-09-01', 1);
GO

-- 5. Seed questions for Challenge 1: Cloud Fundamentals Speed Run
INSERT INTO ChallengeQuestions (ChallengeID, QuestionText, Points, TimeLimitSeconds, OrderIndex) VALUES
(1, 'What does SaaS stand for?', 10, 20, 1),
(1, 'Which is NOT a cloud deployment model?', 10, 20, 2),
(1, 'What is auto-scaling?', 10, 25, 3),
(1, 'Which service model gives you the most control?', 10, 20, 4),
(1, 'What is a Virtual Private Cloud (VPC)?', 10, 25, 5),
(1, 'What does high availability mean?', 10, 20, 6),
(1, 'CDN stands for?', 10, 15, 7),
(1, 'What is cloud elasticity?', 10, 25, 8);

-- Challenge 1 Options
INSERT INTO ChallengeQuestionOptions (ChallengeQuestionID, OptionText, IsCorrect) VALUES
(1, 'Software as a Service', 1), (1, 'Storage as a Service', 0), (1, 'System as a Service', 0), (1, 'Security as a Service', 0),
(2, 'Local', 1), (2, 'Public', 0), (2, 'Private', 0), (2, 'Hybrid', 0),
(3, 'Automatically adjusting resources based on demand', 1), (3, 'Manually adding servers', 0), (3, 'Reducing costs by shutting down', 0), (3, 'Backing up data hourly', 0),
(4, 'IaaS', 1), (4, 'PaaS', 0), (4, 'SaaS', 0), (4, 'FaaS', 0),
(5, 'An isolated section of the cloud for your resources', 1), (5, 'A physical data center you rent', 0), (5, 'A type of VPN', 0), (5, 'A virtual machine', 0),
(6, 'System remains operational with minimal downtime', 1), (6, 'Data is always encrypted', 0), (6, 'Servers are always at full capacity', 0), (6, 'Backups happen every minute', 0),
(7, 'Content Delivery Network', 1), (7, 'Cloud Data Node', 0), (7, 'Central DNS Network', 0), (7, 'Compute Distribution Network', 0),
(8, 'Ability to dynamically scale resources up or down', 1), (8, 'Making cloud free', 0), (8, 'Running without internet', 0), (8, 'Using only one server', 0);
GO

-- 6. Seed questions for Challenge 2: Networking Blitz
INSERT INTO ChallengeQuestions (ChallengeID, QuestionText, Points, TimeLimitSeconds, OrderIndex) VALUES
(2, 'What is the default port for SSH?', 10, 15, 1),
(2, 'What does ARP resolve?', 10, 20, 2),
(2, 'Which protocol is connectionless?', 10, 20, 3),
(2, 'What is a subnet mask used for?', 10, 25, 4),
(2, 'What does NAT stand for?', 10, 20, 5),
(2, 'What layer does a switch operate at?', 10, 20, 6),
(2, 'What is the purpose of DHCP?', 10, 20, 7),
(2, 'What is a MAC address?', 10, 20, 8);

-- Challenge 2 Options
INSERT INTO ChallengeQuestionOptions (ChallengeQuestionID, OptionText, IsCorrect) VALUES
(9, '22', 1), (9, '80', 0), (9, '443', 0), (9, '21', 0),
(10, 'IP address to MAC address', 1), (10, 'Domain to IP', 0), (10, 'MAC to port number', 0), (10, 'URL to IP', 0),
(11, 'UDP', 1), (11, 'TCP', 0), (11, 'FTP', 0), (11, 'SMTP', 0),
(12, 'Divide a network into smaller subnetworks', 1), (12, 'Encrypt data', 0), (12, 'Assign IP addresses', 0), (12, 'Route traffic', 0),
(13, 'Network Address Translation', 1), (13, 'Node Access Terminal', 0), (13, 'Network Authentication Token', 0), (13, 'New Address Table', 0),
(14, 'Layer 2 (Data Link)', 1), (14, 'Layer 3 (Network)', 0), (14, 'Layer 4 (Transport)', 0), (14, 'Layer 1 (Physical)', 0),
(15, 'Automatically assign IP addresses to devices', 1), (15, 'Encrypt network traffic', 0), (15, 'Resolve domain names', 0), (15, 'Filter packets', 0),
(16, 'A unique hardware identifier for a network interface', 1), (16, 'A type of IP address', 0), (16, 'A network protocol', 0), (16, 'A wireless standard', 0);
GO

-- 7. Seed questions for Challenge 3: Security Sprint
INSERT INTO ChallengeQuestions (ChallengeID, QuestionText, Points, TimeLimitSeconds, OrderIndex) VALUES
(3, 'What is phishing?', 10, 20, 1),
(3, 'What does a VPN do?', 10, 20, 2),
(3, 'What is ransomware?', 10, 20, 3),
(3, 'What is the principle of least privilege?', 10, 25, 4),
(3, 'What is multi-factor authentication?', 10, 20, 5),
(3, 'What is a DDoS attack?', 10, 25, 6),
(3, 'What does encryption do?', 10, 20, 7),
(3, 'What is social engineering?', 10, 25, 8);

-- Challenge 3 Options
INSERT INTO ChallengeQuestionOptions (ChallengeQuestionID, OptionText, IsCorrect) VALUES
(17, 'Tricking users into revealing sensitive information', 1), (17, 'A type of firewall', 0), (17, 'Scanning for vulnerabilities', 0), (17, 'Encrypting emails', 0),
(18, 'Creates an encrypted tunnel for secure internet access', 1), (18, 'Speeds up internet connection', 0), (18, 'Blocks all ads', 0), (18, 'Replaces a firewall', 0),
(19, 'Malware that encrypts files and demands payment', 1), (19, 'A type of antivirus', 0), (19, 'A network monitoring tool', 0), (19, 'An authentication method', 0),
(20, 'Give users only the minimum access they need', 1), (20, 'Give everyone admin access', 0), (20, 'Remove all passwords', 0), (20, 'Trust all internal users', 0),
(21, 'Using multiple methods to verify identity', 1), (21, 'Having multiple passwords', 0), (21, 'Using two monitors', 0), (21, 'Logging in from multiple devices', 0),
(22, 'Flooding a server with traffic to make it unavailable', 1), (22, 'Stealing passwords', 0), (22, 'Deleting database records', 0), (22, 'Injecting malicious code', 0),
(23, 'Converts data into unreadable format without a key', 1), (23, 'Compresses files to save space', 0), (23, 'Deletes sensitive data', 0), (23, 'Backs up data to cloud', 0),
(24, 'Manipulating people into giving up confidential info', 1), (24, 'Building social media apps', 0), (24, 'A type of programming', 0), (24, 'Network engineering', 0);
GO

PRINT 'Challenges fixed and seeded with questions!';
GO
