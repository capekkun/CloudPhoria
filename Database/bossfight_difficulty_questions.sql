USE CloudPhoria;
GO

-- ============================================================
-- CLEAR existing boss fight questions and rebuild with
-- difficulty-appropriate content per room
-- ============================================================

-- First remove all existing battle session data
DELETE FROM BattleSessionAnswers;
DELETE FROM BattleSessions;
DELETE FROM BossFightQuestionOptions;
DELETE FROM BossFightQuestions;
PRINT 'Cleared old boss fight questions.';
GO

-- ============================================================
-- EASY ROOMS — Basic cloud fundamentals
-- ============================================================
DECLARE @RoomID INT;
DECLARE easy_cursor CURSOR FOR
    SELECT RoomID FROM BossFightRooms WHERE DifficultyLevel = 'Easy' AND IsPublished = 1;
OPEN easy_cursor;
FETCH NEXT FROM easy_cursor INTO @RoomID;
WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @Q INT;

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What does "cloud computing" primarily refer to?', 10, 30, 1); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Delivering computing services over the internet', 1), (@Q, 'Computing done in the sky', 0), (@Q, 'A type of weather forecasting', 0), (@Q, 'Physical servers in your office', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'Which of these is a cloud deployment model?', 10, 30, 2); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Public Cloud', 1), (@Q, 'Desktop Cloud', 0), (@Q, 'USB Cloud', 0), (@Q, 'Personal Cloud Drive', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What does SaaS stand for?', 10, 30, 3); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Software as a Service', 1), (@Q, 'Server as a Service', 0), (@Q, 'Storage as a Service', 0), (@Q, 'Security as a Service', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'Which company provides AWS?', 10, 30, 4); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Amazon', 1), (@Q, 'Microsoft', 0), (@Q, 'Google', 0), (@Q, 'Apple', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is the main benefit of cloud computing?', 10, 30, 5); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Pay only for what you use', 1), (@Q, 'Free unlimited storage', 0), (@Q, 'No internet required', 0), (@Q, 'Guaranteed 100% uptime', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What does IaaS provide?', 10, 25, 6); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Virtual machines, storage, and networks', 1), (@Q, 'Only email services', 0), (@Q, 'Only website hosting', 0), (@Q, 'Physical hardware delivery', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'Which is an example of PaaS?', 10, 25, 7); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Google App Engine', 1), (@Q, 'Microsoft Word', 0), (@Q, 'A USB drive', 0), (@Q, 'A physical server rack', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is "elasticity" in cloud computing?', 10, 25, 8); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Automatically scaling resources up or down', 1), (@Q, 'Stretching network cables', 0), (@Q, 'Flexible pricing plans', 0), (@Q, 'Bending server racks', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is a Virtual Machine?', 10, 25, 9); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'A software-based computer running on physical hardware', 1), (@Q, 'A hologram computer', 0), (@Q, 'A robot that computes', 0), (@Q, 'A VR headset', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What does "on-demand" mean in cloud?', 10, 25, 10); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Available whenever you need it', 1), (@Q, 'Only available on weekdays', 0), (@Q, 'Requires 24-hour notice', 0), (@Q, 'Available only in emergencies', 0);

    FETCH NEXT FROM easy_cursor INTO @RoomID;
END;
CLOSE easy_cursor; DEALLOCATE easy_cursor;
PRINT 'Easy rooms populated with 10 beginner questions each.';
GO

-- ============================================================
-- MEDIUM ROOMS — Intermediate cloud concepts
-- ============================================================
DECLARE @RoomID INT, @Q INT;
DECLARE med_cursor CURSOR FOR
    SELECT RoomID FROM BossFightRooms WHERE DifficultyLevel = 'Medium' AND IsPublished = 1;
OPEN med_cursor;
FETCH NEXT FROM med_cursor INTO @RoomID;
WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is the purpose of a load balancer?', 15, 25, 1); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Distribute incoming traffic across multiple servers', 1), (@Q, 'Balance the weight of physical servers', 0), (@Q, 'Reduce electricity usage', 0), (@Q, 'Compress data packets', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is auto-scaling?', 15, 25, 2); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Automatically adjusting resources based on demand', 1), (@Q, 'Manually adding servers', 0), (@Q, 'Scaling a weight measurement', 0), (@Q, 'Automatically restarting crashed servers', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is a CDN?', 15, 20, 3); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Content Delivery Network — caches content at edge locations', 1), (@Q, 'Central Data Node', 0), (@Q, 'Cloud Database Namespace', 0), (@Q, 'Certified Domain Name', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is the difference between vertical and horizontal scaling?', 15, 25, 4); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Vertical = bigger server, Horizontal = more servers', 1), (@Q, 'Vertical = more servers, Horizontal = bigger server', 0), (@Q, 'They are the same thing', 0), (@Q, 'Vertical = up/down, Horizontal = left/right physically', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is a container in cloud computing?', 15, 20, 5); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'A lightweight, portable unit that packages an app with its dependencies', 1), (@Q, 'A physical box that holds servers', 0), (@Q, 'A folder on a hard drive', 0), (@Q, 'A type of virtual machine', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What tool is commonly used for container orchestration?', 15, 20, 6); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Kubernetes', 1), (@Q, 'Photoshop', 0), (@Q, 'Excel', 0), (@Q, 'PowerPoint', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is a VPC?', 15, 20, 7); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Virtual Private Cloud — isolated network in the cloud', 1), (@Q, 'Very Personal Computer', 0), (@Q, 'Virtual Processing Core', 0), (@Q, 'Verified Public Certificate', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is the purpose of IAM in AWS?', 15, 20, 8); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Manage access and permissions for users and services', 1), (@Q, 'Install Applications Manually', 0), (@Q, 'Internet Access Management', 0), (@Q, 'Internal Audit Module', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is object storage used for?', 15, 20, 9); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Storing unstructured data like images, videos, and backups', 1), (@Q, 'Only storing database tables', 0), (@Q, 'Running applications', 0), (@Q, 'Sending emails', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What does "multi-tenancy" mean?', 15, 20, 10); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Multiple customers share the same physical infrastructure', 1), (@Q, 'A building with many tenants', 0), (@Q, 'Running multiple operating systems', 0), (@Q, 'Having multiple passwords', 0);

    FETCH NEXT FROM med_cursor INTO @RoomID;
END;
CLOSE med_cursor; DEALLOCATE med_cursor;
PRINT 'Medium rooms populated with 10 intermediate questions each.';
GO

-- ============================================================
-- HARD ROOMS — Advanced cloud architecture & security
-- ============================================================
DECLARE @RoomID INT, @Q INT;
DECLARE hard_cursor CURSOR FOR
    SELECT RoomID FROM BossFightRooms WHERE DifficultyLevel = 'Hard' AND IsPublished = 1;
OPEN hard_cursor;
FETCH NEXT FROM hard_cursor INTO @RoomID;
WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is the CAP theorem in distributed systems?', 20, 20, 1); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'You can only guarantee 2 of: Consistency, Availability, Partition tolerance', 1), (@Q, 'Computers Always Perform well', 0), (@Q, 'Cloud Architecture Principles', 0), (@Q, 'All three can always be guaranteed', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is eventual consistency?', 20, 20, 2); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'All replicas will converge to the same value given enough time', 1), (@Q, 'Data is always immediately consistent', 0), (@Q, 'Consistency is never achieved', 0), (@Q, 'Only the master node is consistent', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is a microservices architecture?', 20, 20, 3); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Breaking an application into small, independently deployable services', 1), (@Q, 'Very small applications under 1MB', 0), (@Q, 'Using micro-processors in servers', 0), (@Q, 'A monolithic architecture with small functions', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is the principle of least privilege?', 20, 15, 4); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Grant only the minimum permissions needed to perform a task', 1), (@Q, 'Give everyone admin access for convenience', 0), (@Q, 'Use the cheapest cloud tier possible', 0), (@Q, 'Limit cloud spending to minimum', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is a service mesh?', 20, 20, 5); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Infrastructure layer for managing service-to-service communication', 1), (@Q, 'A physical network of cables', 0), (@Q, 'A mesh WiFi network', 0), (@Q, 'A database connection pool', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What does "infrastructure as code" mean?', 20, 20, 6); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Managing infrastructure through machine-readable definition files', 1), (@Q, 'Writing code on physical infrastructure', 0), (@Q, 'Coding directly on servers', 0), (@Q, 'Building servers from source code', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is a blue-green deployment?', 20, 15, 7); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Running two identical environments and switching traffic between them', 1), (@Q, 'Deploying to servers painted blue and green', 0), (@Q, 'A deployment that uses recycled resources', 0), (@Q, 'Deploying during day (blue sky) vs night (green aurora)', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is a distributed denial of service (DDoS) attack?', 20, 15, 8); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Overwhelming a system with traffic from many sources', 1), (@Q, 'Denying employees access to cloud services', 0), (@Q, 'A failed deployment', 0), (@Q, 'A network speed test', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is the purpose of a WAF?', 20, 15, 9); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Web Application Firewall — protects web apps from common exploits', 1), (@Q, 'Wide Area Firewall — covers large physical areas', 0), (@Q, 'Wireless Authentication Framework', 0), (@Q, 'Web Application Format', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is chaos engineering?', 20, 15, 10); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Deliberately introducing failures to test system resilience', 1), (@Q, 'Writing messy code intentionally', 0), (@Q, 'A disordered development methodology', 0), (@Q, 'Random server maintenance scheduling', 0);

    FETCH NEXT FROM hard_cursor INTO @RoomID;
END;
CLOSE hard_cursor; DEALLOCATE hard_cursor;
PRINT 'Hard rooms populated with 10 advanced questions each.';
GO

-- ============================================================
-- LEGENDARY ROOMS — Expert-level cloud & distributed systems
-- ============================================================
DECLARE @RoomID INT, @Q INT;
DECLARE leg_cursor CURSOR FOR
    SELECT RoomID FROM BossFightRooms WHERE DifficultyLevel = 'Legendary' AND IsPublished = 1;
OPEN leg_cursor;
FETCH NEXT FROM leg_cursor INTO @RoomID;
WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'In Paxos consensus, what is the role of the "proposer"?', 25, 15, 1); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Initiates a value proposal that acceptors vote on', 1), (@Q, 'Executes the final decision', 0), (@Q, 'Stores the agreed value permanently', 0), (@Q, 'Monitors network health', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What problem does vector clocks solve in distributed systems?', 25, 15, 2); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Determining causal ordering of events across nodes', 1), (@Q, 'Synchronizing system time zones', 0), (@Q, 'Measuring network latency', 0), (@Q, 'Scheduling cron jobs', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is the split-brain problem in a cluster?', 25, 15, 3); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Two partitions both believe they are the active primary', 1), (@Q, 'A server running out of memory', 0), (@Q, 'A CPU overheating issue', 0), (@Q, 'A database lock conflict', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is the Byzantine Generals Problem about?', 25, 15, 4); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Achieving consensus when some nodes may be malicious or faulty', 1), (@Q, 'Military strategy simulation', 0), (@Q, 'Network routing optimization', 0), (@Q, 'Load balancing algorithms', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is CRDTs in distributed computing?', 25, 15, 5); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Conflict-free Replicated Data Types — merge without coordination', 1), (@Q, 'Cloud Resource Distribution Tables', 0), (@Q, 'Centralized Redundant Data Transfer', 0), (@Q, 'Certified Recovery Data Templates', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What does the Raft consensus algorithm improve over Paxos?', 25, 12, 6); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Understandability while maintaining similar guarantees', 1), (@Q, 'Speed of consensus by 10x', 0), (@Q, 'Elimination of all network failures', 0), (@Q, 'Removal of the need for a leader', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'In CQRS pattern, what are the two sides?', 25, 15, 7); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Command (write) and Query (read) are separated', 1), (@Q, 'Client and Queue are separated', 0), (@Q, 'Cache and Queue run simultaneously', 0), (@Q, 'CPU and RAM are isolated', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is the Saga pattern used for?', 25, 15, 8); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Managing distributed transactions across microservices', 1), (@Q, 'Telling stories in documentation', 0), (@Q, 'A logging framework', 0), (@Q, 'Sequential API Gateway Architecture', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is consistent hashing primarily used for?', 25, 12, 9); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Distributing data across nodes with minimal redistribution on changes', 1), (@Q, 'Encrypting passwords securely', 0), (@Q, 'Verifying file integrity', 0), (@Q, 'Generating unique IDs', 0);

    INSERT INTO BossFightQuestions (RoomID, QuestionText, DamageValue, TimeLimitSeconds, OrderIndex) VALUES (@RoomID, 'What is the thundering herd problem?', 25, 12, 10); SET @Q = SCOPE_IDENTITY();
    INSERT INTO BossFightQuestionOptions VALUES (@Q, 'Many processes simultaneously competing for the same resource after an event', 1), (@Q, 'Too many servers running at once', 0), (@Q, 'A network congestion issue from large file transfers', 0), (@Q, 'Multiple users logging in simultaneously', 0);

    FETCH NEXT FROM leg_cursor INTO @RoomID;
END;
CLOSE leg_cursor; DEALLOCATE leg_cursor;
PRINT 'Legendary rooms populated with 10 expert questions each.';
GO

-- Verify
SELECT DifficultyLevel, COUNT(DISTINCT bfq.BossFightQuestionID) AS Questions,
       COUNT(DISTINCT bfqo.OptionID) AS Options
FROM BossFightRooms bfr
INNER JOIN BossFightQuestions bfq ON bfq.RoomID = bfr.RoomID
LEFT JOIN BossFightQuestionOptions bfqo ON bfqo.BossFightQuestionID = bfq.BossFightQuestionID
GROUP BY DifficultyLevel
ORDER BY CASE DifficultyLevel WHEN 'Easy' THEN 1 WHEN 'Medium' THEN 2 WHEN 'Hard' THEN 3 WHEN 'Legendary' THEN 4 END;

PRINT 'All boss fight rooms now have difficulty-appropriate questions!';
PRINT 'Easy: Basic cloud concepts, 30s timer, 10 damage';
PRINT 'Medium: Intermediate concepts, 20-25s timer, 15 damage';
PRINT 'Hard: Advanced architecture & security, 15-20s timer, 20 damage';
PRINT 'Legendary: Expert distributed systems, 12-15s timer, 25 damage';
GO
