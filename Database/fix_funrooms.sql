USE CloudPhoria;
GO

-- ============================================================
-- FIX FUN ROOMS: Clear duplicates, add question tables, seed data
-- ============================================================

-- 1. Clear all existing fun room data (duplicates and blank rooms)
DELETE FROM FunRooms;
GO

-- Reset identity
DBCC CHECKIDENT ('FunRooms', RESEED, 0);
GO

-- 2. Create FunRoomQuestions table (quiz questions inside a fun room)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FunRoomQuestions')
BEGIN
    CREATE TABLE FunRoomQuestions (
        FunRoomQuestionID   INT IDENTITY(1,1) PRIMARY KEY,
        FunRoomID           INT NOT NULL,
        QuestionText        NVARCHAR(500) NOT NULL,
        XPReward            INT NOT NULL DEFAULT 5,
        OrderIndex          INT NOT NULL DEFAULT 0,
        CONSTRAINT FK_FunRoomQuestions_FunRoom FOREIGN KEY (FunRoomID) REFERENCES FunRooms(FunRoomID)
    );
END
GO

-- 3. Create FunRoomQuestionOptions table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'FunRoomQuestionOptions')
BEGIN
    CREATE TABLE FunRoomQuestionOptions (
        OptionID            INT IDENTITY(1,1) PRIMARY KEY,
        FunRoomQuestionID   INT NOT NULL,
        OptionText          NVARCHAR(300) NOT NULL,
        IsCorrect           BIT NOT NULL DEFAULT 0,
        CONSTRAINT FK_FunRoomQuestionOptions_Question FOREIGN KEY (FunRoomQuestionID) REFERENCES FunRoomQuestions(FunRoomQuestionID)
    );
END
GO

-- 4. Seed sample fun rooms (created by existing users, already approved)
-- Using UserID that exists — assuming user 5 is a student
INSERT INTO FunRooms (CreatedByUserID, RoomTitle, ContentBody, Status, ReviewedByAdminID, CreatedAt)
VALUES
(5, 'Cloud Computing Trivia', 'Test your knowledge of cloud computing basics! Answer these fun questions to earn XP.', 'Approved', 1, '2025-06-01'),
(5, 'Networking Brain Teasers', 'Think you know networking? Try these challenging brain teasers about TCP/IP, DNS, and more!', 'Approved', 1, '2025-06-05'),
(5, 'Security Quiz Challenge', 'How well do you understand cybersecurity? Take this quiz and find out!', 'Approved', 1, '2025-06-10'),
(5, 'DevOps Quick Fire', 'Fast-paced questions about CI/CD, containers, and cloud deployment.', 'Approved', 1, '2025-06-15'),
(5, 'Database Riddles', 'SQL, NoSQL, and everything in between. Can you solve these database riddles?', 'Approved', 1, '2025-06-20');
GO

-- 5. Seed questions for each fun room
-- Room 1: Cloud Computing Trivia
INSERT INTO FunRoomQuestions (FunRoomID, QuestionText, XPReward, OrderIndex) VALUES
(1, 'What does IaaS stand for?', 5, 1),
(1, 'Which cloud provider launched first: AWS, Azure, or GCP?', 5, 2),
(1, 'What is the purpose of a load balancer?', 5, 3),
(1, 'What does "serverless" actually mean?', 5, 4),
(1, 'Which service is used for object storage in AWS?', 5, 5);

-- Room 2: Networking Brain Teasers
INSERT INTO FunRoomQuestions (FunRoomID, QuestionText, XPReward, OrderIndex) VALUES
(2, 'What port does HTTPS use by default?', 5, 1),
(2, 'What does DNS stand for?', 5, 2),
(2, 'Which layer of the OSI model handles routing?', 5, 3),
(2, 'What is the maximum size of a TCP segment?', 5, 4),
(2, 'What protocol does ping use?', 5, 5);

-- Room 3: Security Quiz Challenge
INSERT INTO FunRoomQuestions (FunRoomID, QuestionText, XPReward, OrderIndex) VALUES
(3, 'What does SQL injection exploit?', 5, 1),
(3, 'What is the purpose of a firewall?', 5, 2),
(3, 'What does HTTPS encrypt?', 5, 3),
(3, 'What is two-factor authentication?', 5, 4),
(3, 'What is a zero-day vulnerability?', 5, 5);

-- Room 4: DevOps Quick Fire
INSERT INTO FunRoomQuestions (FunRoomID, QuestionText, XPReward, OrderIndex) VALUES
(4, 'What does CI/CD stand for?', 5, 1),
(4, 'Which tool is commonly used for containerization?', 5, 2),
(4, 'What is the purpose of Kubernetes?', 5, 3),
(4, 'What is Infrastructure as Code?', 5, 4),
(4, 'Name one popular CI/CD pipeline tool.', 5, 5);

-- Room 5: Database Riddles
INSERT INTO FunRoomQuestions (FunRoomID, QuestionText, XPReward, OrderIndex) VALUES
(5, 'What does ACID stand for in databases?', 5, 1),
(5, 'What is the difference between SQL and NoSQL?', 5, 2),
(5, 'What is a primary key?', 5, 3),
(5, 'What does JOIN do in SQL?', 5, 4),
(5, 'What is database normalization?', 5, 5);
GO

-- 6. Seed options for questions
-- Room 1, Q1: What does IaaS stand for?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(1, 'Infrastructure as a Service', 1),
(1, 'Internet as a Service', 0),
(1, 'Integration as a Service', 0),
(1, 'Information as a Service', 0);

-- Room 1, Q2: Which cloud provider launched first?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(2, 'AWS', 1),
(2, 'Azure', 0),
(2, 'Google Cloud', 0),
(2, 'IBM Cloud', 0);

-- Room 1, Q3: Purpose of load balancer?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(3, 'Distribute traffic across multiple servers', 1),
(3, 'Encrypt data in transit', 0),
(3, 'Store database backups', 0),
(3, 'Monitor server health only', 0);

-- Room 1, Q4: What does serverless mean?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(4, 'You dont manage the server infrastructure', 1),
(4, 'There are no servers at all', 0),
(4, 'It runs on your local machine', 0),
(4, 'The code runs without an OS', 0);

-- Room 1, Q5: AWS object storage?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(5, 'S3', 1),
(5, 'EC2', 0),
(5, 'RDS', 0),
(5, 'Lambda', 0);

-- Room 2, Q1: HTTPS port?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(6, '443', 1),
(6, '80', 0),
(6, '8080', 0),
(6, '22', 0);

-- Room 2, Q2: DNS stands for?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(7, 'Domain Name System', 1),
(7, 'Dynamic Network Service', 0),
(7, 'Data Name Server', 0),
(7, 'Domain Network System', 0);

-- Room 2, Q3: OSI routing layer?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(8, 'Network Layer (Layer 3)', 1),
(8, 'Transport Layer (Layer 4)', 0),
(8, 'Data Link Layer (Layer 2)', 0),
(8, 'Application Layer (Layer 7)', 0);

-- Room 2, Q4: Max TCP segment?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(9, '65535 bytes', 1),
(9, '1500 bytes', 0),
(9, '1024 bytes', 0),
(9, '4096 bytes', 0);

-- Room 2, Q5: Ping protocol?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(10, 'ICMP', 1),
(10, 'TCP', 0),
(10, 'UDP', 0),
(10, 'HTTP', 0);

-- Room 3, Q1: SQL injection exploits?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(11, 'Unsanitized user input in database queries', 1),
(11, 'Weak passwords', 0),
(11, 'Unencrypted network traffic', 0),
(11, 'Missing firewall rules', 0);

-- Room 3, Q2: Firewall purpose?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(12, 'Filter network traffic based on rules', 1),
(12, 'Encrypt stored data', 0),
(12, 'Scan for viruses', 0),
(12, 'Back up servers', 0);

-- Room 3, Q3: HTTPS encrypts?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(13, 'Data transmitted between client and server', 1),
(13, 'Only the URL', 0),
(13, 'Only passwords', 0),
(13, 'Data stored on the server', 0);

-- Room 3, Q4: Two-factor authentication?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(14, 'Using two different types of credentials to verify identity', 1),
(14, 'Having two passwords', 0),
(14, 'Logging in from two devices', 0),
(14, 'Using a password twice', 0);

-- Room 3, Q5: Zero-day vulnerability?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(15, 'A vulnerability unknown to the vendor with no patch available', 1),
(15, 'A virus that activates at midnight', 0),
(15, 'A bug that has been fixed for zero days', 0),
(15, 'An attack that takes zero seconds', 0);

-- Room 4, Q1: CI/CD stands for?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(16, 'Continuous Integration / Continuous Deployment', 1),
(16, 'Code Integration / Code Delivery', 0),
(16, 'Central Infrastructure / Central Deployment', 0),
(16, 'Cloud Integration / Cloud Delivery', 0);

-- Room 4, Q2: Containerization tool?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(17, 'Docker', 1),
(17, 'Git', 0),
(17, 'Jenkins', 0),
(17, 'Nginx', 0);

-- Room 4, Q3: Kubernetes purpose?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(18, 'Container orchestration and management', 1),
(18, 'Code version control', 0),
(18, 'Database management', 0),
(18, 'Network monitoring', 0);

-- Room 4, Q4: Infrastructure as Code?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(19, 'Managing infrastructure using code and automation', 1),
(19, 'Writing code that runs on bare metal', 0),
(19, 'Building physical servers', 0),
(19, 'A programming language for networks', 0);

-- Room 4, Q5: CI/CD pipeline tool?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(20, 'Jenkins', 1),
(20, 'Photoshop', 0),
(20, 'Excel', 0),
(20, 'Notepad', 0);

-- Room 5, Q1: ACID stands for?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(21, 'Atomicity, Consistency, Isolation, Durability', 1),
(21, 'Access, Control, Integration, Data', 0),
(21, 'Automatic, Concurrent, Independent, Distributed', 0),
(21, 'Authentication, Caching, Indexing, Deployment', 0);

-- Room 5, Q2: SQL vs NoSQL?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(22, 'SQL uses structured tables; NoSQL uses flexible document/key-value stores', 1),
(22, 'SQL is faster than NoSQL', 0),
(22, 'NoSQL cannot store data permanently', 0),
(22, 'They are the same thing', 0);

-- Room 5, Q3: Primary key?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(23, 'A unique identifier for each row in a table', 1),
(23, 'The first column in a table', 0),
(23, 'A password for the database', 0),
(23, 'The largest value in a column', 0);

-- Room 5, Q4: JOIN in SQL?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(24, 'Combines rows from two or more tables based on a related column', 1),
(24, 'Deletes duplicate rows', 0),
(24, 'Creates a new table', 0),
(24, 'Sorts the results', 0);

-- Room 5, Q5: Database normalization?
INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect) VALUES
(25, 'Organizing data to reduce redundancy and improve integrity', 1),
(25, 'Making all values uppercase', 0),
(25, 'Deleting unused tables', 0),
(25, 'Converting data to binary', 0);
GO

PRINT 'Fun Rooms fixed and seeded successfully!';
GO
