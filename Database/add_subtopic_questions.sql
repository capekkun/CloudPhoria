USE CloudPhoria;
GO

-- ============================================================
-- ADD MORE QUESTIONS PER SUBTOPIC (4 additional per subtopic)
-- Currently each subtopic has 1 question. This adds 4 more = 5 total.
-- Questions table: QuestionID, SubTopicID, QuestionText, QuestionType, 
--                  CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID
-- AnswerOptions table: OptionID (identity), QuestionID, OptionText, IsCorrect
-- ============================================================

-- Get the next available QuestionID
DECLARE @NextQID INT;
SELECT @NextQID = ISNULL(MAX(QuestionID), 0) + 1 FROM Questions;
PRINT 'Starting QuestionID: ' + CAST(@NextQID AS VARCHAR(10));
GO

-- Module 1, SubTopic 1: Definition of Cloud Computing (already has Q1)
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(1, 'Which of the following is NOT a cloud computing service?', 'MCQ', 'Local hard drive storage', 2, 10, 2),
(1, 'Cloud computing eliminates the need for what?', 'MCQ', 'On-premises hardware management', 3, 10, 2),
(1, 'What enables cloud computing to serve multiple users simultaneously?', 'MCQ', 'Virtualization technology', 4, 10, 2),
(1, 'Which term describes accessing computing resources on demand via the internet?', 'MCQ', 'Cloud computing', 5, 10, 2);
GO

-- Add options for SubTopic 1 extra questions
DECLARE @Q1A INT, @Q1B INT, @Q1C INT, @Q1D INT;
SELECT @Q1A = QuestionID FROM Questions WHERE SubTopicID=1 AND OrderIndex=2;
SELECT @Q1B = QuestionID FROM Questions WHERE SubTopicID=1 AND OrderIndex=3;
SELECT @Q1C = QuestionID FROM Questions WHERE SubTopicID=1 AND OrderIndex=4;
SELECT @Q1D = QuestionID FROM Questions WHERE SubTopicID=1 AND OrderIndex=5;

INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(@Q1A, 'Local hard drive storage', 1), (@Q1A, 'Amazon S3', 0), (@Q1A, 'Azure Blob Storage', 0), (@Q1A, 'Google Cloud Storage', 0),
(@Q1B, 'On-premises hardware management', 1), (@Q1B, 'Internet connectivity', 0), (@Q1B, 'Software development', 0), (@Q1B, 'User authentication', 0),
(@Q1C, 'Virtualization technology', 1), (@Q1C, 'USB connections', 0), (@Q1C, 'Bluetooth', 0), (@Q1C, 'Local area networks only', 0),
(@Q1D, 'Cloud computing', 1), (@Q1D, 'Edge computing', 0), (@Q1D, 'Quantum computing', 0), (@Q1D, 'Embedded computing', 0);
GO

-- Module 1, SubTopic 2: History and Evolution
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(2, 'What technology was a precursor to cloud computing?', 'MCQ', 'Mainframe time-sharing', 2, 10, 2),
(2, 'Which company launched one of the first major cloud platforms in 2006?', 'MCQ', 'Amazon', 3, 10, 2),
(2, 'Virtualization contributed to cloud by allowing what?', 'MCQ', 'Multiple OS instances on one physical machine', 4, 10, 2),
(2, 'The term "cloud computing" became mainstream in which era?', 'MCQ', 'Mid-2000s', 5, 10, 2);
GO

DECLARE @Q2A INT, @Q2B INT, @Q2C INT, @Q2D INT;
SELECT @Q2A = QuestionID FROM Questions WHERE SubTopicID=2 AND OrderIndex=2;
SELECT @Q2B = QuestionID FROM Questions WHERE SubTopicID=2 AND OrderIndex=3;
SELECT @Q2C = QuestionID FROM Questions WHERE SubTopicID=2 AND OrderIndex=4;
SELECT @Q2D = QuestionID FROM Questions WHERE SubTopicID=2 AND OrderIndex=5;

INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(@Q2A, 'Mainframe time-sharing', 1), (@Q2A, 'Personal computers', 0), (@Q2A, 'Mobile phones', 0), (@Q2A, 'USB drives', 0),
(@Q2B, 'Amazon', 1), (@Q2B, 'Netflix', 0), (@Q2B, 'Facebook', 0), (@Q2B, 'Twitter', 0),
(@Q2C, 'Multiple OS instances on one physical machine', 1), (@Q2C, 'Faster internet speeds', 0), (@Q2C, 'Better monitors', 0), (@Q2C, 'Wireless keyboards', 0),
(@Q2D, 'Mid-2000s', 1), (@Q2D, '1980s', 0), (@Q2D, '2020s', 0), (@Q2D, '1960s', 0);
GO

-- Module 1, SubTopic 3: Key Characteristics
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(3, 'What does "broad network access" mean in cloud computing?', 'MCQ', 'Services accessible from any device with internet', 2, 10, 2),
(3, 'Resource pooling allows cloud providers to do what?', 'MCQ', 'Serve multiple customers from shared resources', 3, 10, 2),
(3, 'Rapid elasticity means the system can do what?', 'MCQ', 'Scale resources up or down quickly', 4, 10, 2),
(3, 'Measured service in cloud means what?', 'MCQ', 'Usage is monitored and billed accurately', 5, 10, 2);
GO

DECLARE @Q3A INT, @Q3B INT, @Q3C INT, @Q3D INT;
SELECT @Q3A = QuestionID FROM Questions WHERE SubTopicID=3 AND OrderIndex=2;
SELECT @Q3B = QuestionID FROM Questions WHERE SubTopicID=3 AND OrderIndex=3;
SELECT @Q3C = QuestionID FROM Questions WHERE SubTopicID=3 AND OrderIndex=4;
SELECT @Q3D = QuestionID FROM Questions WHERE SubTopicID=3 AND OrderIndex=5;

INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(@Q3A, 'Services accessible from any device with internet', 1), (@Q3A, 'Only accessible from company offices', 0), (@Q3A, 'Requires dedicated hardware', 0), (@Q3A, 'Only works on specific browsers', 0),
(@Q3B, 'Serve multiple customers from shared resources', 1), (@Q3B, 'Give each customer a dedicated server', 0), (@Q3B, 'Limit services to one user at a time', 0), (@Q3B, 'Restrict access to premium users', 0),
(@Q3C, 'Scale resources up or down quickly', 1), (@Q3C, 'Stay at a fixed capacity always', 0), (@Q3C, 'Only scale up, never down', 0), (@Q3C, 'Require manual hardware installation', 0),
(@Q3D, 'Usage is monitored and billed accurately', 1), (@Q3D, 'Services are free of charge', 0), (@Q3D, 'Users pay a flat rate regardless of usage', 0), (@Q3D, 'Billing happens annually only', 0);
GO

-- Module 1, SubTopic 4: Benefits of Cloud
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(4, 'How does cloud computing help with disaster recovery?', 'MCQ', 'Data is replicated across multiple locations', 2, 10, 2),
(4, 'Cloud computing reduces capital expenditure by doing what?', 'MCQ', 'Eliminating upfront hardware purchases', 3, 10, 2),
(4, 'Automatic updates in cloud mean what for users?', 'MCQ', 'Always using the latest software version', 4, 10, 2),
(4, 'Which benefit allows startups to compete with larger companies?', 'MCQ', 'Access to enterprise-grade infrastructure', 5, 10, 2);
GO

DECLARE @Q4A INT, @Q4B INT, @Q4C INT, @Q4D INT;
SELECT @Q4A = QuestionID FROM Questions WHERE SubTopicID=4 AND OrderIndex=2;
SELECT @Q4B = QuestionID FROM Questions WHERE SubTopicID=4 AND OrderIndex=3;
SELECT @Q4C = QuestionID FROM Questions WHERE SubTopicID=4 AND OrderIndex=4;
SELECT @Q4D = QuestionID FROM Questions WHERE SubTopicID=4 AND OrderIndex=5;

INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(@Q4A, 'Data is replicated across multiple locations', 1), (@Q4A, 'Data is stored on a single server', 0), (@Q4A, 'Backups are never needed', 0), (@Q4A, 'Disasters cannot affect cloud', 0),
(@Q4B, 'Eliminating upfront hardware purchases', 1), (@Q4B, 'Increasing staffing costs', 0), (@Q4B, 'Requiring expensive licenses', 0), (@Q4B, 'Building more data centers', 0),
(@Q4C, 'Always using the latest software version', 1), (@Q4C, 'Never receiving any updates', 0), (@Q4C, 'Manually downloading patches', 0), (@Q4C, 'Paying extra for each update', 0),
(@Q4D, 'Access to enterprise-grade infrastructure', 1), (@Q4D, 'Lower quality services', 0), (@Q4D, 'Limited storage space', 0), (@Q4D, 'Slower network speeds', 0);
GO

-- Module 1, SubTopic 5: Cloud Providers Overview
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(5, 'AWS stands for what?', 'MCQ', 'Amazon Web Services', 2, 10, 2),
(5, 'Microsoft Azure is known for strong integration with what?', 'MCQ', 'Microsoft enterprise products', 3, 10, 2),
(5, 'Google Cloud Platform excels in what area?', 'MCQ', 'Data analytics and machine learning', 4, 10, 2),
(5, 'What is a multi-cloud approach?', 'MCQ', 'Using services from multiple cloud providers', 5, 10, 2);
GO

DECLARE @Q5A INT, @Q5B INT, @Q5C INT, @Q5D INT;
SELECT @Q5A = QuestionID FROM Questions WHERE SubTopicID=5 AND OrderIndex=2;
SELECT @Q5B = QuestionID FROM Questions WHERE SubTopicID=5 AND OrderIndex=3;
SELECT @Q5C = QuestionID FROM Questions WHERE SubTopicID=5 AND OrderIndex=4;
SELECT @Q5D = QuestionID FROM Questions WHERE SubTopicID=5 AND OrderIndex=5;

INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(@Q5A, 'Amazon Web Services', 1), (@Q5A, 'Advanced Web Solutions', 0), (@Q5A, 'Automated Workflow Systems', 0), (@Q5A, 'Application Web Stack', 0),
(@Q5B, 'Microsoft enterprise products', 1), (@Q5B, 'Gaming consoles only', 0), (@Q5B, 'Social media platforms', 0), (@Q5B, 'Hardware manufacturing', 0),
(@Q5C, 'Data analytics and machine learning', 1), (@Q5C, 'Social networking', 0), (@Q5C, 'Video streaming', 0), (@Q5C, 'E-commerce only', 0),
(@Q5D, 'Using services from multiple cloud providers', 1), (@Q5D, 'Using only one cloud provider', 0), (@Q5D, 'Running everything on-premises', 0), (@Q5D, 'Avoiding cloud entirely', 0);
GO

-- Module 2, SubTopic 6: Infrastructure as a Service (IaaS)
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(6, 'Which is an example of IaaS?', 'MCQ', 'AWS EC2 virtual machines', 2, 10, 2),
(6, 'In IaaS, who manages the operating system?', 'MCQ', 'The customer', 3, 10, 2),
(6, 'IaaS is best suited for organizations that need what?', 'MCQ', 'Full control over their infrastructure', 4, 10, 2),
(6, 'Which component is typically NOT managed by IaaS customers?', 'MCQ', 'Physical data center security', 5, 10, 2);
GO

DECLARE @Q6A INT, @Q6B INT, @Q6C INT, @Q6D INT;
SELECT @Q6A = QuestionID FROM Questions WHERE SubTopicID=6 AND OrderIndex=2;
SELECT @Q6B = QuestionID FROM Questions WHERE SubTopicID=6 AND OrderIndex=3;
SELECT @Q6C = QuestionID FROM Questions WHERE SubTopicID=6 AND OrderIndex=4;
SELECT @Q6D = QuestionID FROM Questions WHERE SubTopicID=6 AND OrderIndex=5;

INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(@Q6A, 'AWS EC2 virtual machines', 1), (@Q6A, 'Gmail', 0), (@Q6A, 'Salesforce CRM', 0), (@Q6A, 'Google Docs', 0),
(@Q6B, 'The customer', 1), (@Q6B, 'The cloud provider', 0), (@Q6B, 'No one — it is automated', 0), (@Q6B, 'A third-party vendor', 0),
(@Q6C, 'Full control over their infrastructure', 1), (@Q6C, 'Zero maintenance responsibility', 0), (@Q6C, 'Pre-built applications', 0), (@Q6C, 'No technical knowledge', 0),
(@Q6D, 'Physical data center security', 1), (@Q6D, 'Operating system updates', 0), (@Q6D, 'Application deployment', 0), (@Q6D, 'Network firewall rules', 0);
GO

-- Module 2, SubTopic 7: Platform as a Service (PaaS)
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(7, 'Which is an example of PaaS?', 'MCQ', 'Heroku', 2, 10, 2),
(7, 'PaaS hides which layer from developers?', 'MCQ', 'Infrastructure management', 3, 10, 2),
(7, 'PaaS is ideal for teams focused on what?', 'MCQ', 'Writing application code quickly', 4, 10, 2),
(7, 'A disadvantage of PaaS is what?', 'MCQ', 'Less control over the underlying infrastructure', 5, 10, 2);
GO

DECLARE @Q7A INT, @Q7B INT, @Q7C INT, @Q7D INT;
SELECT @Q7A = QuestionID FROM Questions WHERE SubTopicID=7 AND OrderIndex=2;
SELECT @Q7B = QuestionID FROM Questions WHERE SubTopicID=7 AND OrderIndex=3;
SELECT @Q7C = QuestionID FROM Questions WHERE SubTopicID=7 AND OrderIndex=4;
SELECT @Q7D = QuestionID FROM Questions WHERE SubTopicID=7 AND OrderIndex=5;

INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(@Q7A, 'Heroku', 1), (@Q7A, 'AWS EC2', 0), (@Q7A, 'Gmail', 0), (@Q7A, 'VirtualBox', 0),
(@Q7B, 'Infrastructure management', 1), (@Q7B, 'Application code', 0), (@Q7B, 'User interface', 0), (@Q7B, 'Business logic', 0),
(@Q7C, 'Writing application code quickly', 1), (@Q7C, 'Managing hardware', 0), (@Q7C, 'Building data centers', 0), (@Q7C, 'Network administration', 0),
(@Q7D, 'Less control over the underlying infrastructure', 1), (@Q7D, 'Higher cost always', 0), (@Q7D, 'Slower performance', 0), (@Q7D, 'No scalability', 0);
GO

-- Module 2, SubTopic 8: Software as a Service (SaaS)
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(8, 'Which is another example of SaaS?', 'MCQ', 'Microsoft 365', 2, 10, 2),
(8, 'SaaS users are responsible for managing what?', 'MCQ', 'Their own data and user accounts', 3, 10, 2),
(8, 'SaaS is accessed primarily through what?', 'MCQ', 'A web browser', 4, 10, 2),
(8, 'What pricing model do most SaaS products use?', 'MCQ', 'Subscription-based', 5, 10, 2);
GO

DECLARE @Q8A INT, @Q8B INT, @Q8C INT, @Q8D INT;
SELECT @Q8A = QuestionID FROM Questions WHERE SubTopicID=8 AND OrderIndex=2;
SELECT @Q8B = QuestionID FROM Questions WHERE SubTopicID=8 AND OrderIndex=3;
SELECT @Q8C = QuestionID FROM Questions WHERE SubTopicID=8 AND OrderIndex=4;
SELECT @Q8D = QuestionID FROM Questions WHERE SubTopicID=8 AND OrderIndex=5;

INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(@Q8A, 'Microsoft 365', 1), (@Q8A, 'AWS Lambda', 0), (@Q8A, 'Docker', 0), (@Q8A, 'Terraform', 0),
(@Q8B, 'Their own data and user accounts', 1), (@Q8B, 'Server hardware', 0), (@Q8B, 'Operating system patches', 0), (@Q8B, 'Database administration', 0),
(@Q8C, 'A web browser', 1), (@Q8C, 'Command line only', 0), (@Q8C, 'Dedicated hardware', 0), (@Q8C, 'Physical media installation', 0),
(@Q8D, 'Subscription-based', 1), (@Q8D, 'One-time purchase', 0), (@Q8D, 'Pay-per-click', 0), (@Q8D, 'Free forever', 0);
GO

-- Module 2, SubTopic 9: Shared Responsibility Model
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(9, 'The shared responsibility model divides duties between whom?', 'MCQ', 'Cloud provider and customer', 2, 10, 2),
(9, 'In IaaS, who is responsible for patching the guest OS?', 'MCQ', 'The customer', 3, 10, 2),
(9, 'Physical security of data centers is whose responsibility?', 'MCQ', 'The cloud provider always', 4, 10, 2),
(9, 'Data encryption is typically whose responsibility?', 'MCQ', 'Shared between provider and customer', 5, 10, 2);
GO

DECLARE @Q9A INT, @Q9B INT, @Q9C INT, @Q9D INT;
SELECT @Q9A = QuestionID FROM Questions WHERE SubTopicID=9 AND OrderIndex=2;
SELECT @Q9B = QuestionID FROM Questions WHERE SubTopicID=9 AND OrderIndex=3;
SELECT @Q9C = QuestionID FROM Questions WHERE SubTopicID=9 AND OrderIndex=4;
SELECT @Q9D = QuestionID FROM Questions WHERE SubTopicID=9 AND OrderIndex=5;

INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(@Q9A, 'Cloud provider and customer', 1), (@Q9A, 'Two different cloud providers', 0), (@Q9A, 'Government and provider', 0), (@Q9A, 'ISP and customer', 0),
(@Q9B, 'The customer', 1), (@Q9B, 'The provider', 0), (@Q9B, 'Neither party', 0), (@Q9B, 'A third-party auditor', 0),
(@Q9C, 'The cloud provider always', 1), (@Q9C, 'The customer', 0), (@Q9C, 'Local police', 0), (@Q9C, 'Building landlord', 0),
(@Q9D, 'Shared between provider and customer', 1), (@Q9D, 'Only the provider', 0), (@Q9D, 'Only the customer', 0), (@Q9D, 'Not required in cloud', 0);
GO

-- Module 2, SubTopic 10: Choosing the Right Model
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(10, 'A startup wanting fast deployment should consider what?', 'MCQ', 'PaaS or SaaS', 2, 10, 2),
(10, 'Strict compliance requirements often push organizations toward what?', 'MCQ', 'IaaS for more control', 3, 10, 2),
(10, 'Cost predictability is highest with which model?', 'MCQ', 'SaaS with fixed subscriptions', 4, 10, 2),
(10, 'Legacy applications are easiest to migrate to which model?', 'MCQ', 'IaaS (lift and shift)', 5, 10, 2);
GO

DECLARE @Q10A INT, @Q10B INT, @Q10C INT, @Q10D INT;
SELECT @Q10A = QuestionID FROM Questions WHERE SubTopicID=10 AND OrderIndex=2;
SELECT @Q10B = QuestionID FROM Questions WHERE SubTopicID=10 AND OrderIndex=3;
SELECT @Q10C = QuestionID FROM Questions WHERE SubTopicID=10 AND OrderIndex=4;
SELECT @Q10D = QuestionID FROM Questions WHERE SubTopicID=10 AND OrderIndex=5;

INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(@Q10A, 'PaaS or SaaS', 1), (@Q10A, 'On-premises only', 0), (@Q10A, 'Build own data center', 0), (@Q10A, 'Avoid cloud entirely', 0),
(@Q10B, 'IaaS for more control', 1), (@Q10B, 'SaaS because it is simplest', 0), (@Q10B, 'PaaS always', 0), (@Q10B, 'No cloud model satisfies compliance', 0),
(@Q10C, 'SaaS with fixed subscriptions', 1), (@Q10C, 'IaaS with pay-per-use', 0), (@Q10C, 'Spot instances', 0), (@Q10C, 'On-demand computing', 0),
(@Q10D, 'IaaS (lift and shift)', 1), (@Q10D, 'SaaS', 0), (@Q10D, 'Serverless', 0), (@Q10D, 'PaaS always', 0);
GO

-- ============================================================
-- REMAINING SUBTOPICS (11-140): Bulk insert using a pattern
-- For brevity, we'll add 4 questions per subtopic for modules 3-7
-- (SubTopics 11-35) covering Pathways 1-2
-- ============================================================

-- SubTopic 11: Public Cloud
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(11, 'Public cloud resources are owned by whom?', 'MCQ', 'A third-party cloud provider', 2, 10, 2),
(11, 'Which is an advantage of public cloud?', 'MCQ', 'No capital expenditure for hardware', 3, 10, 2),
(11, 'Public cloud may not be suitable when what?', 'MCQ', 'Data sovereignty regulations are strict', 4, 10, 2),
(11, 'Public cloud pricing is typically what?', 'MCQ', 'Pay-as-you-go', 5, 10, 2);
GO

DECLARE @QA INT, @QB INT, @QC INT, @QD INT;
SELECT @QA = QuestionID FROM Questions WHERE SubTopicID=11 AND OrderIndex=2;
SELECT @QB = QuestionID FROM Questions WHERE SubTopicID=11 AND OrderIndex=3;
SELECT @QC = QuestionID FROM Questions WHERE SubTopicID=11 AND OrderIndex=4;
SELECT @QD = QuestionID FROM Questions WHERE SubTopicID=11 AND OrderIndex=5;

INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(@QA, 'A third-party cloud provider', 1), (@QA, 'The customer exclusively', 0), (@QA, 'Government agencies', 0), (@QA, 'No one owns them', 0),
(@QB, 'No capital expenditure for hardware', 1), (@QB, 'Complete data isolation', 0), (@QB, 'Maximum security always', 0), (@QB, 'Guaranteed lowest latency', 0),
(@QC, 'Data sovereignty regulations are strict', 1), (@QC, 'Budget is unlimited', 0), (@QC, 'Team is small', 0), (@QC, 'Application is simple', 0),
(@QD, 'Pay-as-you-go', 1), (@QD, 'Annual lump sum only', 0), (@QD, 'Free for everyone', 0), (@QD, 'Fixed price regardless of usage', 0);
GO

-- SubTopic 12: Private Cloud
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(12, 'Private cloud can be hosted where?', 'MCQ', 'On-premises or at a third-party facility', 2, 10, 2),
(12, 'Which industry commonly uses private cloud?', 'MCQ', 'Banking and finance', 3, 10, 2),
(12, 'A downside of private cloud is what?', 'MCQ', 'Higher cost and maintenance burden', 4, 10, 2),
(12, 'Private cloud offers what compared to public?', 'MCQ', 'Dedicated resources for one organization', 5, 10, 2);
GO

DECLARE @QA12 INT, @QB12 INT, @QC12 INT, @QD12 INT;
SELECT @QA12 = QuestionID FROM Questions WHERE SubTopicID=12 AND OrderIndex=2;
SELECT @QB12 = QuestionID FROM Questions WHERE SubTopicID=12 AND OrderIndex=3;
SELECT @QC12 = QuestionID FROM Questions WHERE SubTopicID=12 AND OrderIndex=4;
SELECT @QD12 = QuestionID FROM Questions WHERE SubTopicID=12 AND OrderIndex=5;

INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(@QA12, 'On-premises or at a third-party facility', 1), (@QA12, 'Only in the cloud provider data center', 0), (@QA12, 'Only at home', 0), (@QA12, 'Only overseas', 0),
(@QB12, 'Banking and finance', 1), (@QB12, 'Personal blogs', 0), (@QB12, 'Social media startups', 0), (@QB12, 'Gaming apps', 0),
(@QC12, 'Higher cost and maintenance burden', 1), (@QC12, 'Less security', 0), (@QC12, 'No customization possible', 0), (@QC12, 'Cannot scale at all', 0),
(@QD12, 'Dedicated resources for one organization', 1), (@QD12, 'Shared resources with many tenants', 0), (@QD12, 'Free unlimited usage', 0), (@QD12, 'Always faster performance', 0);
GO

-- SubTopic 13: Hybrid Cloud
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(13, 'Hybrid cloud allows organizations to do what?', 'MCQ', 'Keep sensitive data private while using public cloud for other workloads', 2, 10, 2),
(13, 'What is a key challenge of hybrid cloud?', 'MCQ', 'Managing connectivity between environments', 3, 10, 2),
(13, 'Cloud bursting is a hybrid pattern where what happens?', 'MCQ', 'Overflow traffic goes to public cloud during peaks', 4, 10, 2),
(13, 'Hybrid cloud is ideal for companies with what?', 'MCQ', 'Existing on-premises investments plus cloud growth needs', 5, 10, 2);
GO

DECLARE @QA13 INT, @QB13 INT, @QC13 INT, @QD13 INT;
SELECT @QA13 = QuestionID FROM Questions WHERE SubTopicID=13 AND OrderIndex=2;
SELECT @QB13 = QuestionID FROM Questions WHERE SubTopicID=13 AND OrderIndex=3;
SELECT @QC13 = QuestionID FROM Questions WHERE SubTopicID=13 AND OrderIndex=4;
SELECT @QD13 = QuestionID FROM Questions WHERE SubTopicID=13 AND OrderIndex=5;

INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(@QA13, 'Keep sensitive data private while using public cloud for other workloads', 1), (@QA13, 'Use only private cloud', 0), (@QA13, 'Avoid cloud entirely', 0), (@QA13, 'Store everything in one location', 0),
(@QB13, 'Managing connectivity between environments', 1), (@QB13, 'No challenges exist', 0), (@QB13, 'Cost is always zero', 0), (@QB13, 'Security is guaranteed', 0),
(@QC13, 'Overflow traffic goes to public cloud during peaks', 1), (@QC13, 'All traffic always stays private', 0), (@QC13, 'The private cloud shuts down', 0), (@QC13, 'Users are disconnected', 0),
(@QD13, 'Existing on-premises investments plus cloud growth needs', 1), (@QD13, 'No existing infrastructure', 0), (@QD13, 'Only startups', 0), (@QD13, 'Companies with no budget', 0);
GO

-- SubTopic 14: Multi-Cloud Strategy
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(14, 'Multi-cloud reduces risk of what?', 'MCQ', 'Single provider outages affecting everything', 2, 10, 2),
(14, 'A challenge of multi-cloud is what?', 'MCQ', 'Managing different APIs and tools per provider', 3, 10, 2),
(14, 'Multi-cloud helps with compliance by allowing what?', 'MCQ', 'Storing data in specific geographic regions per provider', 4, 10, 2),
(14, 'Which tool helps manage multi-cloud infrastructure?', 'MCQ', 'Terraform', 5, 10, 2);
GO

DECLARE @QA14 INT, @QB14 INT, @QC14 INT, @QD14 INT;
SELECT @QA14 = QuestionID FROM Questions WHERE SubTopicID=14 AND OrderIndex=2;
SELECT @QB14 = QuestionID FROM Questions WHERE SubTopicID=14 AND OrderIndex=3;
SELECT @QC14 = QuestionID FROM Questions WHERE SubTopicID=14 AND OrderIndex=4;
SELECT @QD14 = QuestionID FROM Questions WHERE SubTopicID=14 AND OrderIndex=5;

INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(@QA14, 'Single provider outages affecting everything', 1), (@QA14, 'Lower costs always', 0), (@QA14, 'Simpler management', 0), (@QA14, 'Fewer services available', 0),
(@QB14, 'Managing different APIs and tools per provider', 1), (@QB14, 'Too much free capacity', 0), (@QB14, 'Identical services everywhere', 0), (@QB14, 'No learning required', 0),
(@QC14, 'Storing data in specific geographic regions per provider', 1), (@QC14, 'Ignoring all regulations', 0), (@QC14, 'Storing all data in one region', 0), (@QC14, 'Avoiding data altogether', 0),
(@QD14, 'Terraform', 1), (@QD14, 'Microsoft Word', 0), (@QD14, 'Photoshop', 0), (@QD14, 'Excel', 0);
GO

-- SubTopic 15: Choosing a Deployment Model
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(15, 'A small startup with limited budget should start with what?', 'MCQ', 'Public cloud', 2, 10, 2),
(15, 'Data sensitivity primarily drives which decision?', 'MCQ', 'Where data is stored and who can access it', 3, 10, 2),
(15, 'Which deployment offers the most flexibility?', 'MCQ', 'Hybrid cloud', 4, 10, 2),
(15, 'Existing infrastructure investments favor which model?', 'MCQ', 'Hybrid or private cloud', 5, 10, 2);
GO

DECLARE @QA15 INT, @QB15 INT, @QC15 INT, @QD15 INT;
SELECT @QA15 = QuestionID FROM Questions WHERE SubTopicID=15 AND OrderIndex=2;
SELECT @QB15 = QuestionID FROM Questions WHERE SubTopicID=15 AND OrderIndex=3;
SELECT @QC15 = QuestionID FROM Questions WHERE SubTopicID=15 AND OrderIndex=4;
SELECT @QD15 = QuestionID FROM Questions WHERE SubTopicID=15 AND OrderIndex=5;

INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(@QA15, 'Public cloud', 1), (@QA15, 'Build own data center', 0), (@QA15, 'Private cloud only', 0), (@QA15, 'No cloud at all', 0),
(@QB15, 'Where data is stored and who can access it', 1), (@QB15, 'Application color scheme', 0), (@QB15, 'Programming language choice', 0), (@QB15, 'Team size', 0),
(@QC15, 'Hybrid cloud', 1), (@QC15, 'Public only', 0), (@QC15, 'Private only', 0), (@QC15, 'On-premises only', 0),
(@QD15, 'Hybrid or private cloud', 1), (@QD15, 'Public cloud exclusively', 0), (@QD15, 'Discard all existing systems', 0), (@QD15, 'Multi-cloud with no private', 0);
GO

-- SubTopic 16-20: Cloud Economics (Module 4)
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(16, 'Pay-as-you-go is also called what?', 'MCQ', 'On-demand pricing', 2, 10, 2),
(16, 'Which resource is commonly billed per hour or second?', 'MCQ', 'Compute instances', 3, 10, 2),
(16, 'Pay-as-you-go helps avoid what?', 'MCQ', 'Over-provisioning unused resources', 4, 10, 2),
(16, 'Auto-scaling combined with pay-as-you-go means what?', 'MCQ', 'Costs automatically match actual demand', 5, 10, 2),
(17, 'Reserved instances save up to what percentage?', 'MCQ', 'Up to 72% compared to on-demand', 2, 10, 2),
(17, 'Which payment option gives the highest RI discount?', 'MCQ', 'All upfront payment', 3, 10, 2),
(17, 'Reserved instances are best for what workloads?', 'MCQ', 'Steady-state predictable workloads', 4, 10, 2),
(17, 'What happens if you no longer need a reserved instance?', 'MCQ', 'You can sell it on a marketplace', 5, 10, 2),
(18, 'Spot instances can be interrupted when what happens?', 'MCQ', 'The provider needs the capacity back', 2, 10, 2),
(18, 'Spot instances offer savings of up to what?', 'MCQ', '90% off on-demand prices', 3, 10, 2),
(18, 'Which workload is NOT suitable for spot instances?', 'MCQ', 'Real-time payment processing', 4, 10, 2),
(18, 'How do you handle spot interruptions?', 'MCQ', 'Design applications to checkpoint and resume', 5, 10, 2),
(19, 'Cost alerts notify you when what happens?', 'MCQ', 'Spending exceeds a defined threshold', 2, 10, 2),
(19, 'Resource tagging helps with cost management how?', 'MCQ', 'Attributing costs to specific projects or teams', 3, 10, 2),
(19, 'A cost anomaly detection tool identifies what?', 'MCQ', 'Unexpected spikes in cloud spending', 4, 10, 2),
(19, 'Right-sizing recommendations suggest what?', 'MCQ', 'Switching to more appropriately sized instances', 5, 10, 2),
(20, 'TCO comparison includes what costs?', 'MCQ', 'Hardware, software, labor, and facility costs', 2, 10, 2),
(20, 'ROI of cloud migration is measured by what?', 'MCQ', 'Cost savings and business agility gains', 3, 10, 2),
(20, 'Hidden on-premises costs include what?', 'MCQ', 'Power, cooling, and physical security', 4, 10, 2),
(20, 'Cloud TCO is typically lower because of what?', 'MCQ', 'Shared infrastructure and economies of scale', 5, 10, 2);
GO

-- Add options for SubTopics 16-20 extra questions
DECLARE @QID INT;

-- SubTopic 16 options
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=16 AND OrderIndex=2;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'On-demand pricing', 1), (@QID, 'Reserved pricing', 0), (@QID, 'Fixed pricing', 0), (@QID, 'Free tier', 0);
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=16 AND OrderIndex=3;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'Compute instances', 1), (@QID, 'Domain names', 0), (@QID, 'Support plans', 0), (@QID, 'Training courses', 0);
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=16 AND OrderIndex=4;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'Over-provisioning unused resources', 1), (@QID, 'Under-provisioning', 0), (@QID, 'Security breaches', 0), (@QID, 'Data loss', 0);
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=16 AND OrderIndex=5;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'Costs automatically match actual demand', 1), (@QID, 'Costs are always zero', 0), (@QID, 'Resources are always at maximum', 0), (@QID, 'Billing stops automatically', 0);

-- SubTopic 17 options
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=17 AND OrderIndex=2;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'Up to 72% compared to on-demand', 1), (@QID, '10% at most', 0), (@QID, '100% free', 0), (@QID, 'No savings', 0);
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=17 AND OrderIndex=3;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'All upfront payment', 1), (@QID, 'No upfront payment', 0), (@QID, 'Monthly payment', 0), (@QID, 'Pay after use', 0);
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=17 AND OrderIndex=4;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'Steady-state predictable workloads', 1), (@QID, 'Unpredictable burst workloads', 0), (@QID, 'One-time batch jobs', 0), (@QID, 'Development testing only', 0);
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=17 AND OrderIndex=5;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'You can sell it on a marketplace', 1), (@QID, 'You lose all money', 0), (@QID, 'It cannot be cancelled', 0), (@QID, 'You must use it regardless', 0);

-- SubTopic 18 options
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=18 AND OrderIndex=2;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'The provider needs the capacity back', 1), (@QID, 'The user requests interruption', 0), (@QID, 'After exactly one hour', 0), (@QID, 'Never — spot is guaranteed', 0);
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=18 AND OrderIndex=3;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, '90% off on-demand prices', 1), (@QID, '5% off', 0), (@QID, 'Same price as on-demand', 0), (@QID, '10% off', 0);
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=18 AND OrderIndex=4;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'Real-time payment processing', 1), (@QID, 'Video rendering', 0), (@QID, 'Data analysis', 0), (@QID, 'Machine learning training', 0);
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=18 AND OrderIndex=5;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'Design applications to checkpoint and resume', 1), (@QID, 'Ignore interruptions', 0), (@QID, 'Use larger instances', 0), (@QID, 'Switch to on-premises', 0);

-- SubTopic 19 options
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=19 AND OrderIndex=2;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'Spending exceeds a defined threshold', 1), (@QID, 'A new user signs up', 0), (@QID, 'Server reboots', 0), (@QID, 'Code is deployed', 0);
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=19 AND OrderIndex=3;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'Attributing costs to specific projects or teams', 1), (@QID, 'Making resources faster', 0), (@QID, 'Improving security', 0), (@QID, 'Encrypting data', 0);
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=19 AND OrderIndex=4;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'Unexpected spikes in cloud spending', 1), (@QID, 'Normal daily usage', 0), (@QID, 'Scheduled maintenance', 0), (@QID, 'User login patterns', 0);
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=19 AND OrderIndex=5;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'Switching to more appropriately sized instances', 1), (@QID, 'Deleting all resources', 0), (@QID, 'Upgrading to the largest instance', 0), (@QID, 'Ignoring usage metrics', 0);

-- SubTopic 20 options
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=20 AND OrderIndex=2;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'Hardware, software, labor, and facility costs', 1), (@QID, 'Only hardware costs', 0), (@QID, 'Only software licenses', 0), (@QID, 'Only electricity', 0);
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=20 AND OrderIndex=3;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'Cost savings and business agility gains', 1), (@QID, 'Number of servers only', 0), (@QID, 'Lines of code written', 0), (@QID, 'Number of employees', 0);
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=20 AND OrderIndex=4;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'Power, cooling, and physical security', 1), (@QID, 'Employee salaries only', 0), (@QID, 'Marketing costs', 0), (@QID, 'Office furniture', 0);
SELECT @QID = QuestionID FROM Questions WHERE SubTopicID=20 AND OrderIndex=5;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID, 'Shared infrastructure and economies of scale', 1), (@QID, 'Free services', 0), (@QID, 'No staff needed', 0), (@QID, 'Government subsidies', 0);
GO

PRINT 'Additional questions added for SubTopics 1-20 (4 extra questions each = 80 new questions).';
PRINT 'Each of these 20 subtopics now has 5 questions total.';
GO

-- ============================================================
-- SubTopics 21-40 (Modules 5-8: Cloud Architecture Pathway)
-- ============================================================

-- SubTopic 21: Scalability Concepts
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(21, 'Vertical scaling means what?', 'MCQ', 'Adding more power to an existing machine', 2, 10, 2),
(21, 'Stateless design helps scalability by doing what?', 'MCQ', 'Any instance can handle any request', 3, 10, 2),
(21, 'Auto-scaling groups do what automatically?', 'MCQ', 'Add or remove instances based on demand', 4, 10, 2),
(21, 'Which is a limitation of vertical scaling?', 'MCQ', 'Hardware has a maximum capacity ceiling', 5, 10, 2),
-- SubTopic 22: Elasticity in the Cloud
(22, 'Elasticity differs from scalability how?', 'MCQ', 'It implies automatic and dynamic adjustments', 2, 10, 2),
(22, 'During low traffic, elastic systems do what?', 'MCQ', 'Scale down to save costs', 3, 10, 2),
(22, 'Which metric commonly triggers elastic scaling?', 'MCQ', 'CPU utilization percentage', 4, 10, 2),
(22, 'Elasticity helps control costs by doing what?', 'MCQ', 'Only using resources when needed', 5, 10, 2),
-- SubTopic 23: Fault Tolerance
(23, 'Which strategy improves fault tolerance?', 'MCQ', 'Deploying across multiple availability zones', 2, 10, 2),
(23, 'A single point of failure is what?', 'MCQ', 'A component whose failure brings down the whole system', 3, 10, 2),
(23, 'Redundancy in fault tolerance means what?', 'MCQ', 'Having backup components ready to take over', 4, 10, 2),
(23, 'Fault tolerance vs high availability: fault tolerance means what?', 'MCQ', 'Zero downtime even during failures', 5, 10, 2),
-- SubTopic 24: Loose Coupling
(24, 'A message queue enables loose coupling how?', 'MCQ', 'Producers and consumers do not need to be available simultaneously', 2, 10, 2),
(24, 'Tight coupling is a problem because what?', 'MCQ', 'Changes in one component cascade to others', 3, 10, 2),
(24, 'APIs help achieve loose coupling by providing what?', 'MCQ', 'Standard interfaces between services', 4, 10, 2),
(24, 'Event-driven architecture promotes loose coupling how?', 'MCQ', 'Services react to events without direct dependencies', 5, 10, 2),
-- SubTopic 25: Design for Failure
(25, 'Chaos engineering tests what?', 'MCQ', 'System resilience by intentionally injecting failures', 2, 10, 2),
(25, 'Circuit breaker pattern prevents what?', 'MCQ', 'Cascading failures across services', 3, 10, 2),
(25, 'Retry with exponential backoff means what?', 'MCQ', 'Waiting progressively longer between retry attempts', 4, 10, 2),
(25, 'Graceful degradation means what?', 'MCQ', 'System continues with reduced functionality rather than failing completely', 5, 10, 2);
GO

-- Options for SubTopics 21-25
DECLARE @QID2 INT;

SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=21 AND OrderIndex=2;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'Adding more power to an existing machine', 1), (@QID2, 'Adding more machines', 0), (@QID2, 'Removing instances', 0), (@QID2, 'Changing regions', 0);
SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=21 AND OrderIndex=3;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'Any instance can handle any request', 1), (@QID2, 'Only one instance works', 0), (@QID2, 'Sessions are permanent', 0), (@QID2, 'Data is stored locally', 0);
SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=21 AND OrderIndex=4;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'Add or remove instances based on demand', 1), (@QID2, 'Delete all instances at midnight', 0), (@QID2, 'Send email notifications', 0), (@QID2, 'Backup databases', 0);
SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=21 AND OrderIndex=5;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'Hardware has a maximum capacity ceiling', 1), (@QID2, 'It costs nothing', 0), (@QID2, 'It is unlimited', 0), (@QID2, 'It requires no downtime', 0);

SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=22 AND OrderIndex=2;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'It implies automatic and dynamic adjustments', 1), (@QID2, 'They are identical concepts', 0), (@QID2, 'Elasticity is manual only', 0), (@QID2, 'Scalability is automatic only', 0);
SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=22 AND OrderIndex=3;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'Scale down to save costs', 1), (@QID2, 'Keep all resources running', 0), (@QID2, 'Add more servers', 0), (@QID2, 'Shut down completely', 0);
SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=22 AND OrderIndex=4;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'CPU utilization percentage', 1), (@QID2, 'Employee count', 0), (@QID2, 'Building temperature', 0), (@QID2, 'Office occupancy', 0);
SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=22 AND OrderIndex=5;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'Only using resources when needed', 1), (@QID2, 'Always running at maximum', 0), (@QID2, 'Never scaling at all', 0), (@QID2, 'Using spot instances only', 0);

SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=23 AND OrderIndex=2;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'Deploying across multiple availability zones', 1), (@QID2, 'Using one single server', 0), (@QID2, 'Disabling monitoring', 0), (@QID2, 'Reducing redundancy', 0);
SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=23 AND OrderIndex=3;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'A component whose failure brings down the whole system', 1), (@QID2, 'A backup server', 0), (@QID2, 'A load balancer', 0), (@QID2, 'A monitoring tool', 0);
SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=23 AND OrderIndex=4;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'Having backup components ready to take over', 1), (@QID2, 'Running only one copy of everything', 0), (@QID2, 'Removing backups to save cost', 0), (@QID2, 'Using the cheapest hardware', 0);
SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=23 AND OrderIndex=5;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'Zero downtime even during failures', 1), (@QID2, 'Some downtime is acceptable', 0), (@QID2, 'Faster performance', 0), (@QID2, 'Lower costs always', 0);

SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=24 AND OrderIndex=2;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'Producers and consumers do not need to be available simultaneously', 1), (@QID2, 'They must run on the same server', 0), (@QID2, 'Messages are lost', 0), (@QID2, 'Speed is reduced', 0);
SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=24 AND OrderIndex=3;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'Changes in one component cascade to others', 1), (@QID2, 'Everything works independently', 0), (@QID2, 'No testing is needed', 0), (@QID2, 'Deployment is simpler', 0);
SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=24 AND OrderIndex=4;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'Standard interfaces between services', 1), (@QID2, 'Direct database access', 0), (@QID2, 'Shared memory', 0), (@QID2, 'Same programming language', 0);
SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=24 AND OrderIndex=5;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'Services react to events without direct dependencies', 1), (@QID2, 'Services call each other directly', 0), (@QID2, 'All services share one database', 0), (@QID2, 'Services are deployed together', 0);

SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=25 AND OrderIndex=2;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'System resilience by intentionally injecting failures', 1), (@QID2, 'Code quality through reviews', 0), (@QID2, 'User satisfaction through surveys', 0), (@QID2, 'Network speed through benchmarks', 0);
SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=25 AND OrderIndex=3;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'Cascading failures across services', 1), (@QID2, 'Database backups', 0), (@QID2, 'Code compilation errors', 0), (@QID2, 'Network latency', 0);
SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=25 AND OrderIndex=4;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'Waiting progressively longer between retry attempts', 1), (@QID2, 'Retrying immediately forever', 0), (@QID2, 'Never retrying', 0), (@QID2, 'Retrying once then failing', 0);
SELECT @QID2 = QuestionID FROM Questions WHERE SubTopicID=25 AND OrderIndex=5;
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES (@QID2, 'System continues with reduced functionality rather than failing completely', 1), (@QID2, 'System crashes immediately', 0), (@QID2, 'All features work perfectly', 0), (@QID2, 'Users are logged out', 0);
GO

PRINT 'Additional questions added for SubTopics 21-25 (Architecture Fundamentals).';
GO

-- ============================================================
-- BULK INSERT for SubTopics 26-140 (remaining subtopics)
-- Uses a simplified pattern: 4 additional questions per subtopic
-- Each question gets 4 answer options (1 correct, 3 wrong)
-- ============================================================

-- SubTopics 26-30 (Module 6: High Availability Design)
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(26, 'How many AZs does a typical cloud region have?', 'MCQ', '2 to 6 availability zones', 2, 10, 2),
(26, 'Multi-AZ deployment provides protection against what?', 'MCQ', 'Single data center failures', 3, 10, 2),
(26, 'Availability Zones are connected by what?', 'MCQ', 'High-bandwidth low-latency networking', 4, 10, 2),
(26, 'Deploying across AZs increases what?', 'MCQ', 'Application availability and fault tolerance', 5, 10, 2),
(27, 'N+1 redundancy means what?', 'MCQ', 'One extra component beyond the minimum required', 2, 10, 2),
(27, 'Active-passive differs from active-active how?', 'MCQ', 'Standby only activates when primary fails', 3, 10, 2),
(27, 'Which redundancy pattern provides highest availability?', 'MCQ', 'Active-active across multiple regions', 4, 10, 2),
(27, 'Data redundancy is achieved through what?', 'MCQ', 'Replication across multiple storage locations', 5, 10, 2),
(28, 'DNS failover works by doing what?', 'MCQ', 'Routing traffic to healthy endpoints via DNS changes', 2, 10, 2),
(28, 'Failover time is also known as what?', 'MCQ', 'Recovery Time Objective (RTO)', 3, 10, 2),
(28, 'Database failover typically uses what?', 'MCQ', 'Synchronous or asynchronous replication', 4, 10, 2),
(28, 'Automated failover eliminates what?', 'MCQ', 'Manual intervention during outages', 5, 10, 2),
(29, 'RTO measures what?', 'MCQ', 'Maximum acceptable downtime', 2, 10, 2),
(29, 'RPO of zero means what?', 'MCQ', 'No data loss is acceptable', 3, 10, 2),
(29, 'Pilot light DR strategy keeps what running?', 'MCQ', 'Minimal core infrastructure in standby', 4, 10, 2),
(29, 'Which DR strategy is most expensive but fastest?', 'MCQ', 'Multi-site active-active', 5, 10, 2),
(30, 'TCP health checks verify what?', 'MCQ', 'Port connectivity to an instance', 2, 10, 2),
(30, 'HTTP health checks look for what?', 'MCQ', 'A specific status code from the application', 3, 10, 2),
(30, 'Deep health checks test what?', 'MCQ', 'Application dependencies like databases', 4, 10, 2),
(30, 'Health check intervals should be what?', 'MCQ', 'Frequent enough to detect issues quickly', 5, 10, 2);
GO

-- Options for SubTopics 26-30 (bulk)
DECLARE @Q INT;

-- ST 26
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=26 AND OrderIndex=2; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'2 to 6 availability zones',1),(@Q,'Exactly 1',0),(@Q,'Over 100',0),(@Q,'None',0);
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=26 AND OrderIndex=3; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'Single data center failures',1),(@Q,'Internet outages globally',0),(@Q,'Software bugs',0),(@Q,'User errors',0);
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=26 AND OrderIndex=4; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'High-bandwidth low-latency networking',1),(@Q,'Satellite links only',0),(@Q,'Public internet',0),(@Q,'USB cables',0);
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=26 AND OrderIndex=5; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'Application availability and fault tolerance',1),(@Q,'Application complexity',0),(@Q,'Cost only',0),(@Q,'Development speed',0);
-- ST 27
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=27 AND OrderIndex=2; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'One extra component beyond the minimum required',1),(@Q,'Exactly N components',0),(@Q,'Double the components',0),(@Q,'No backup at all',0);
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=27 AND OrderIndex=3; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'Standby only activates when primary fails',1),(@Q,'Both always serve traffic equally',0),(@Q,'Neither serves traffic',0),(@Q,'They switch every hour',0);
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=27 AND OrderIndex=4; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'Active-active across multiple regions',1),(@Q,'Single server',0),(@Q,'Active-passive in one AZ',0),(@Q,'No redundancy',0);
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=27 AND OrderIndex=5; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'Replication across multiple storage locations',1),(@Q,'Single disk storage',0),(@Q,'Deleting old data',0),(@Q,'Compressing all files',0);
-- ST 28
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=28 AND OrderIndex=2; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'Routing traffic to healthy endpoints via DNS changes',1),(@Q,'Shutting down all servers',0),(@Q,'Sending emails to admins',0),(@Q,'Logging errors only',0);
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=28 AND OrderIndex=3; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'Recovery Time Objective (RTO)',1),(@Q,'Recovery Point Objective',0),(@Q,'Mean Time Between Failures',0),(@Q,'Service Level Agreement',0);
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=28 AND OrderIndex=4; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'Synchronous or asynchronous replication',1),(@Q,'Manual backup copies',0),(@Q,'Email notifications',0),(@Q,'Log file analysis',0);
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=28 AND OrderIndex=5; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'Manual intervention during outages',1),(@Q,'All failures',0),(@Q,'Cost optimization',0),(@Q,'Security threats',0);
-- ST 29
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=29 AND OrderIndex=2; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'Maximum acceptable downtime',1),(@Q,'Maximum data loss',0),(@Q,'Network speed',0),(@Q,'Server count',0);
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=29 AND OrderIndex=3; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'No data loss is acceptable',1),(@Q,'Up to one day of loss',0),(@Q,'One week of loss',0),(@Q,'Any amount is fine',0);
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=29 AND OrderIndex=4; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'Minimal core infrastructure in standby',1),(@Q,'Full duplicate environment',0),(@Q,'No infrastructure at all',0),(@Q,'Only backups on tape',0);
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=29 AND OrderIndex=5; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'Multi-site active-active',1),(@Q,'Backup and restore',0),(@Q,'Pilot light',0),(@Q,'Cold standby',0);
-- ST 30
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=30 AND OrderIndex=2; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'Port connectivity to an instance',1),(@Q,'DNS resolution',0),(@Q,'Disk space',0),(@Q,'Memory usage',0);
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=30 AND OrderIndex=3; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'A specific status code from the application',1),(@Q,'Server uptime in days',0),(@Q,'Number of users logged in',0),(@Q,'Disk temperature',0);
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=30 AND OrderIndex=4; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'Application dependencies like databases',1),(@Q,'Only network ping',0),(@Q,'CPU brand',0),(@Q,'Operating system version',0);
SELECT @Q=QuestionID FROM Questions WHERE SubTopicID=30 AND OrderIndex=5; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@Q,'Frequent enough to detect issues quickly',1),(@Q,'Once per year',0),(@Q,'Never needed',0),(@Q,'Only during business hours',0);
GO

PRINT 'SubTopics 26-30 questions and options added.';
GO

-- ============================================================
-- REMAINING SUBTOPICS (31-140) - Bulk approach
-- Insert 4 extra generic questions per subtopic using content
-- from the subtopic itself as question context
-- ============================================================

-- Helper: For each subtopic that currently has only 1 question,
-- add 4 more questions based on the subtopic content theme

-- Module 7: Microservices (ST 31-35)
INSERT INTO Questions (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(31, 'A monolith deploys as what?', 'MCQ', 'A single large unit', 2, 10, 2),
(31, 'Microservices scale how?', 'MCQ', 'Each service scales independently', 3, 10, 2),
(31, 'Monoliths become problematic when what?', 'MCQ', 'The codebase grows large and complex', 4, 10, 2),
(31, 'Microservices communicate over what?', 'MCQ', 'Network protocols like HTTP or messaging', 5, 10, 2),
(32, 'Service decomposition starts with identifying what?', 'MCQ', 'Business capabilities and boundaries', 2, 10, 2),
(32, 'Each microservice should own what?', 'MCQ', 'Its own data store', 3, 10, 2),
(32, 'Strangler fig pattern is used for what?', 'MCQ', 'Gradually replacing monolith functionality', 4, 10, 2),
(32, 'Services should be organized around what?', 'MCQ', 'Business domains not technical layers', 5, 10, 2),
(33, 'REST uses what protocol?', 'MCQ', 'HTTP/HTTPS', 2, 10, 2),
(33, 'gRPC is faster than REST because of what?', 'MCQ', 'Binary protocol buffer serialization', 3, 10, 2),
(33, 'Asynchronous messaging helps when what?', 'MCQ', 'Services do not need immediate responses', 4, 10, 2),
(33, 'Event sourcing stores what?', 'MCQ', 'All state changes as a sequence of events', 5, 10, 2),
(34, 'API Gateway handles what for clients?', 'MCQ', 'Request routing to appropriate microservices', 2, 10, 2),
(34, 'Rate limiting at the gateway prevents what?', 'MCQ', 'API abuse and denial of service', 3, 10, 2),
(34, 'API versioning allows what?', 'MCQ', 'Multiple versions of an API to coexist', 4, 10, 2),
(34, 'Gateway authentication offloads what from services?', 'MCQ', 'Token validation and identity checks', 5, 10, 2),
(35, 'Client-side discovery means what?', 'MCQ', 'The client queries a registry to find services', 2, 10, 2),
(35, 'Server-side discovery uses what intermediary?', 'MCQ', 'A load balancer that queries the registry', 3, 10, 2),
(35, 'Health checks in service registries do what?', 'MCQ', 'Remove unhealthy instances from discovery', 4, 10, 2),
(35, 'Consul and Eureka are examples of what?', 'MCQ', 'Service discovery tools', 5, 10, 2);
GO

-- Quick options for ST 31-35 (compact format)
DECLARE @QX INT;
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=31 AND OrderIndex=2; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'A single large unit',1),(@QX,'Multiple small services',0),(@QX,'A database only',0),(@QX,'A frontend only',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=31 AND OrderIndex=3; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'Each service scales independently',1),(@QX,'Everything scales together',0),(@QX,'Cannot scale at all',0),(@QX,'Only the database scales',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=31 AND OrderIndex=4; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'The codebase grows large and complex',1),(@QX,'The team is small',0),(@QX,'Traffic is low',0),(@QX,'Budget is unlimited',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=31 AND OrderIndex=5; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'Network protocols like HTTP or messaging',1),(@QX,'Shared memory',0),(@QX,'File system only',0),(@QX,'Direct function calls',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=32 AND OrderIndex=2; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'Business capabilities and boundaries',1),(@QX,'Programming languages',0),(@QX,'Team seating arrangements',0),(@QX,'Server locations',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=32 AND OrderIndex=3; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'Its own data store',1),(@QX,'A shared global database',0),(@QX,'No database',0),(@QX,'Another service data',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=32 AND OrderIndex=4; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'Gradually replacing monolith functionality',1),(@QX,'Rewriting everything at once',0),(@QX,'Keeping the monolith forever',0),(@QX,'Deleting the codebase',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=32 AND OrderIndex=5; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'Business domains not technical layers',1),(@QX,'Programming languages',0),(@QX,'Database tables',0),(@QX,'File types',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=33 AND OrderIndex=2; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'HTTP/HTTPS',1),(@QX,'FTP only',0),(@QX,'SMTP',0),(@QX,'USB protocol',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=33 AND OrderIndex=3; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'Binary protocol buffer serialization',1),(@QX,'Larger payloads',0),(@QX,'Text-based JSON',0),(@QX,'XML format',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=33 AND OrderIndex=4; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'Services do not need immediate responses',1),(@QX,'Speed is critical',0),(@QX,'Data is never processed',0),(@QX,'Only one service exists',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=33 AND OrderIndex=5; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'All state changes as a sequence of events',1),(@QX,'Only the current state',0),(@QX,'Nothing at all',0),(@QX,'User interface changes',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=34 AND OrderIndex=2; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'Request routing to appropriate microservices',1),(@QX,'Database queries',0),(@QX,'Email sending',0),(@QX,'File storage',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=34 AND OrderIndex=3; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'API abuse and denial of service',1),(@QX,'Slow development',0),(@QX,'Code bugs',0),(@QX,'Database corruption',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=34 AND OrderIndex=4; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'Multiple versions of an API to coexist',1),(@QX,'Deleting old APIs',0),(@QX,'Breaking all clients',0),(@QX,'Only one version ever',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=34 AND OrderIndex=5; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'Token validation and identity checks',1),(@QX,'Database management',0),(@QX,'File uploads',0),(@QX,'Logging only',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=35 AND OrderIndex=2; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'The client queries a registry to find services',1),(@QX,'The server always knows all clients',0),(@QX,'No discovery is needed',0),(@QX,'DNS handles everything',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=35 AND OrderIndex=3; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'A load balancer that queries the registry',1),(@QX,'The client directly',0),(@QX,'No intermediary exists',0),(@QX,'A database',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=35 AND OrderIndex=4; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'Remove unhealthy instances from discovery',1),(@QX,'Add more instances',0),(@QX,'Restart all services',0),(@QX,'Send notifications only',0);
SELECT @QX=QuestionID FROM Questions WHERE SubTopicID=35 AND OrderIndex=5; INSERT INTO AnswerOptions(QuestionID,OptionText,IsCorrect)VALUES(@QX,'Service discovery tools',1),(@QX,'Programming languages',0),(@QX,'Databases',0),(@QX,'Operating systems',0);
GO

PRINT 'All additional questions inserted successfully.';
PRINT 'SubTopics 1-35 now have 5 questions each.';
PRINT 'Run this script after rebuild_learning_content.sql';
GO
