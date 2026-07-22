USE CloudPhoria;
GO

-- ============================================================
-- COMPLETE REBUILD OF LEARNING CONTENT (FIXED VERSION v3)
-- Structure: 7 Pathways -> 4 Modules each -> 5 SubTopics each -> 5 Questions each
-- Clear flow: Enroll -> Complete Modules (Easy->Hard) -> Get Certification
-- Also fixes duplicate notifications
-- ============================================================
-- FIXES APPLIED (v3):
--   Certifications: uses CertificateName (NOT CertificationName), no Description column
--   Modules: no OrderIndex column in Modules table
--   SubTopics: uses ContentBody (NOT Content)
--   Questions (inline): HAS QuestionType and CorrectAnswer columns
--   PracticeQuestions: NO QuestionType or CorrectAnswer columns
--   ExamQuestions: NO QuestionType or CorrectAnswer columns
--   Badges: inserted AFTER Modules so FK_Badges_Modules is satisfied
-- ============================================================

-- STEP 1: Clear all existing learning content and progress
DELETE FROM PracticeAnswers;
DELETE FROM PracticeAttempts;
DELETE FROM ExamAnswers;
DELETE FROM ExamAttempts;
DELETE FROM SubTopicProgress;
DELETE FROM ModuleProgress;
DELETE FROM UserBadges;
DELETE FROM UserCertifications;
DELETE FROM XPTransactions;
DELETE FROM AnswerOptions;
DELETE FROM Questions;
DELETE FROM LearningMaterials;
DELETE FROM PracticeQuestionOptions;
DELETE FROM PracticeQuestions;
DELETE FROM ExamQuestionOptions;
DELETE FROM ExamQuestions;
DELETE FROM Badges;
DELETE FROM GuestModuleAccess;
DELETE FROM DiscussionReplies;
DELETE FROM DiscussionThreads;
DELETE FROM SubTopics;
DELETE FROM Modules;
DELETE FROM Certifications;
DELETE FROM Pathways;
GO

-- Fix duplicate notifications
DELETE FROM Notifications
WHERE NotificationID NOT IN (
    SELECT MIN(NotificationID)
    FROM Notifications
    GROUP BY UserID, Message, CAST(CreatedAt AS DATE)
);
PRINT 'Duplicate notifications removed.';
GO

PRINT 'All old learning content cleared successfully.';
GO

-- ============================================================
-- STEP 2: INSERT 7 PATHWAYS
-- ============================================================

SET IDENTITY_INSERT Pathways ON;

INSERT INTO Pathways (PathwayID, PathwayName, Description, IsFoundation) VALUES
(1, 'Cloud Foundations', 'Core cloud computing concepts, service models, and deployment strategies.', 1),
(2, 'Cloud Architecture', 'Design scalable, resilient, and cost-efficient cloud architectures.', 0),
(3, 'Cloud Security', 'Protect cloud environments with identity management, encryption, and compliance.', 0),
(4, 'DevOps Engineering', 'Automate software delivery with CI/CD pipelines and infrastructure as code.', 0),
(5, 'Data Engineering', 'Build and manage data pipelines, warehouses, and analytics solutions.', 0),
(6, 'Cloud Networking', 'Design and manage virtual networks, load balancers, and hybrid connectivity.', 0),
(7, 'Serverless & Containers', 'Build modern apps using serverless functions, containers, and orchestration.', 0);

SET IDENTITY_INSERT Pathways OFF;
PRINT '7 Pathways inserted.';
GO

-- ============================================================
-- STEP 3: INSERT CERTIFICATIONS (one per specialization pathway)
-- Schema: CertificationID, PathwayID, CertificateName
-- NOTE: No Description column exists in Certifications table
-- ============================================================

SET IDENTITY_INSERT Certifications ON;

INSERT INTO Certifications (CertificationID, PathwayID, CertificateName) VALUES
(1, 2, 'Certified Cloud Architect'),
(2, 3, 'Certified Cloud Security Specialist'),
(3, 4, 'Certified DevOps Engineer'),
(4, 5, 'Certified Data Engineer'),
(5, 6, 'Certified Cloud Network Engineer'),
(6, 7, 'Certified Serverless Developer');

SET IDENTITY_INSERT Certifications OFF;
PRINT '6 Certifications inserted.';
GO

-- ============================================================
-- STEP 4: INSERT MODULES (4 per pathway = 28 total)
-- Schema: ModuleID, PathwayID, ModuleName, Description, DifficultyLevel,
--         PrerequisiteModuleID, XPReward, ExamDurationMinutes, ExamPassMarkPercent,
--         IsPublished, CreatedByInstructorID
-- NOTE: No OrderIndex column exists in Modules table
-- ============================================================

SET IDENTITY_INSERT Modules ON;

INSERT INTO Modules (ModuleID, PathwayID, ModuleName, Description, DifficultyLevel, PrerequisiteModuleID, XPReward, ExamDurationMinutes, ExamPassMarkPercent, IsPublished, CreatedByInstructorID) VALUES
-- Pathway 1: Cloud Foundations (ModuleID 1-4)
(1, 1, 'What is Cloud Computing', 'Introduction to cloud computing, its history, benefits, and key characteristics.', 'Easy', NULL, 100, 15, 60, 1, 2),
(2, 1, 'Cloud Service Models', 'Understanding IaaS, PaaS, and SaaS - comparing responsibilities and use cases.', 'Easy', 1, 100, 15, 60, 1, 2),
(3, 1, 'Cloud Deployment Models', 'Public, private, hybrid, and multi-cloud deployments explained.', 'Medium', 2, 150, 20, 65, 1, 2),
(4, 1, 'Cloud Economics & Billing', 'Pay-as-you-go pricing, reserved instances, cost optimization strategies.', 'Hard', 3, 200, 25, 70, 1, 2),
-- Pathway 2: Cloud Architecture (ModuleID 5-8)
(5, 2, 'Architecture Fundamentals', 'Core principles: scalability, elasticity, and fault tolerance.', 'Easy', NULL, 100, 15, 60, 1, 2),
(6, 2, 'High Availability Design', 'Designing systems with redundancy, failover, and disaster recovery.', 'Medium', 5, 150, 20, 65, 1, 2),
(7, 2, 'Microservices Architecture', 'Decomposing monoliths, service communication, and API gateways.', 'Hard', 6, 200, 25, 70, 1, 2),
(8, 2, 'Cost Optimization & Performance', 'Right-sizing resources, auto-scaling, caching, and CDN strategies.', 'Hard', 7, 200, 25, 70, 1, 2),
-- Pathway 3: Cloud Security (ModuleID 9-12)
(9, 3, 'Security Fundamentals', 'CIA triad, shared responsibility model, and security best practices.', 'Easy', NULL, 100, 15, 60, 1, 2),
(10, 3, 'Identity & Access Management', 'Authentication, authorization, MFA, roles, and policies.', 'Medium', 9, 150, 20, 65, 1, 2),
(11, 3, 'Data Protection & Encryption', 'Encryption at rest and in transit, key management, and data classification.', 'Hard', 10, 200, 25, 70, 1, 2),
(12, 3, 'Compliance & Threat Detection', 'Regulatory frameworks, auditing, SIEM, and incident response.', 'Hard', 11, 200, 25, 70, 1, 2),
-- Pathway 4: DevOps Engineering (ModuleID 13-16)
(13, 4, 'DevOps Culture & Principles', 'DevOps philosophy, collaboration, continuous improvement, and toolchains.', 'Easy', NULL, 100, 15, 60, 1, 2),
(14, 4, 'CI/CD Pipelines', 'Building automated build, test, and deployment pipelines.', 'Medium', 13, 150, 20, 65, 1, 2),
(15, 4, 'Infrastructure as Code', 'Managing infrastructure with Terraform, CloudFormation, and Ansible.', 'Hard', 14, 200, 25, 70, 1, 2),
(16, 4, 'Monitoring & Observability', 'Metrics, logging, tracing, alerting, and SRE practices.', 'Hard', 15, 200, 25, 70, 1, 2),
-- Pathway 5: Data Engineering (ModuleID 17-20)
(17, 5, 'Data Engineering Basics', 'Data lifecycle, ETL vs ELT, and data quality fundamentals.', 'Easy', NULL, 100, 15, 60, 1, 2),
(18, 5, 'Cloud Databases', 'Relational, NoSQL, and in-memory databases in the cloud.', 'Medium', 17, 150, 20, 65, 1, 2),
(19, 5, 'Data Pipelines & Streaming', 'Batch processing, real-time streaming, and event-driven architectures.', 'Hard', 18, 200, 25, 70, 1, 2),
(20, 5, 'Data Warehousing & Analytics', 'Data warehouses, data lakes, BI tools, and ML integration.', 'Hard', 19, 200, 25, 70, 1, 2),
-- Pathway 6: Cloud Networking (ModuleID 21-24)
(21, 6, 'Networking Fundamentals', 'OSI model, TCP/IP, DNS, and how networking applies to cloud.', 'Easy', NULL, 100, 15, 60, 1, 2),
(22, 6, 'Virtual Networks & Subnets', 'VPCs, subnets, route tables, and network ACLs.', 'Medium', 21, 150, 20, 65, 1, 2),
(23, 6, 'Load Balancing & CDN', 'Application and network load balancers, traffic routing, and CDN.', 'Hard', 22, 200, 25, 70, 1, 2),
(24, 6, 'Hybrid & Multi-Cloud Connectivity', 'VPN, Direct Connect, peering, and multi-cloud networking.', 'Hard', 23, 200, 25, 70, 1, 2),
-- Pathway 7: Serverless & Containers (ModuleID 25-28)
(25, 7, 'Serverless Computing Basics', 'Function-as-a-Service, event-driven design, and serverless use cases.', 'Easy', NULL, 100, 15, 60, 1, 2),
(26, 7, 'Containers & Docker', 'Container fundamentals, Dockerfiles, images, and container registries.', 'Medium', 25, 150, 20, 65, 1, 2),
(27, 7, 'Kubernetes & Orchestration', 'Pods, services, deployments, scaling, and cluster management.', 'Hard', 26, 200, 25, 70, 1, 2),
(28, 7, 'Advanced Serverless Patterns', 'Step functions, event buses, serverless APIs, and cost management.', 'Hard', 27, 200, 25, 70, 1, 2);

SET IDENTITY_INSERT Modules OFF;
PRINT '28 Modules inserted (4 per pathway).';
GO

-- ============================================================
-- STEP 5: INSERT BADGES (one per module = 28 total)
-- Schema: BadgeID (identity), ModuleID, BadgeName, Description, IconPath
-- ============================================================

INSERT INTO Badges (ModuleID, BadgeName, Description, IconPath) VALUES
(1, 'Cloud Starter', 'Completed What is Cloud Computing', '/uploads/badges/cloud-starter.png'),
(2, 'Service Explorer', 'Completed Cloud Service Models', '/uploads/badges/service-explorer.png'),
(3, 'Deployment Pro', 'Completed Cloud Deployment Models', '/uploads/badges/deployment-pro.png'),
(4, 'Cloud Economist', 'Completed Cloud Economics & Billing', '/uploads/badges/cloud-economist.png'),
(5, 'Architecture Beginner', 'Completed Architecture Fundamentals', '/uploads/badges/arch-beginner.png'),
(6, 'HA Designer', 'Completed High Availability Design', '/uploads/badges/ha-designer.png'),
(7, 'Microservices Master', 'Completed Microservices Architecture', '/uploads/badges/microservices.png'),
(8, 'Cost Optimizer', 'Completed Cost Optimization & Performance', '/uploads/badges/cost-optimizer.png'),
(9, 'Security Aware', 'Completed Security Fundamentals', '/uploads/badges/security-aware.png'),
(10, 'IAM Expert', 'Completed Identity & Access Management', '/uploads/badges/iam-expert.png'),
(11, 'Encryption Guard', 'Completed Data Protection & Encryption', '/uploads/badges/encryption.png'),
(12, 'Compliance Pro', 'Completed Compliance & Threat Detection', '/uploads/badges/compliance.png'),
(13, 'DevOps Initiate', 'Completed DevOps Culture & Principles', '/uploads/badges/devops-init.png'),
(14, 'Pipeline Builder', 'Completed CI/CD Pipelines', '/uploads/badges/pipeline.png'),
(15, 'IaC Engineer', 'Completed Infrastructure as Code', '/uploads/badges/iac.png'),
(16, 'Observability Guru', 'Completed Monitoring & Observability', '/uploads/badges/observability.png'),
(17, 'Data Starter', 'Completed Data Engineering Basics', '/uploads/badges/data-starter.png'),
(18, 'Database Specialist', 'Completed Cloud Databases', '/uploads/badges/database.png'),
(19, 'Pipeline Architect', 'Completed Data Pipelines & Streaming', '/uploads/badges/data-pipeline.png'),
(20, 'Analytics Expert', 'Completed Data Warehousing & Analytics', '/uploads/badges/analytics.png'),
(21, 'Network Novice', 'Completed Networking Fundamentals', '/uploads/badges/network-novice.png'),
(22, 'VPC Designer', 'Completed Virtual Networks & Subnets', '/uploads/badges/vpc.png'),
(23, 'Traffic Manager', 'Completed Load Balancing & CDN', '/uploads/badges/traffic.png'),
(24, 'Hybrid Connector', 'Completed Hybrid & Multi-Cloud Connectivity', '/uploads/badges/hybrid.png'),
(25, 'Serverless Starter', 'Completed Serverless Computing Basics', '/uploads/badges/serverless.png'),
(26, 'Container Captain', 'Completed Containers & Docker', '/uploads/badges/container.png'),
(27, 'K8s Commander', 'Completed Kubernetes & Orchestration', '/uploads/badges/k8s.png'),
(28, 'Serverless Architect', 'Completed Advanced Serverless Patterns', '/uploads/badges/serverless-adv.png');

PRINT '28 Badges inserted (one per module).';
GO

-- ============================================================
-- STEP 6: INSERT SUBTOPICS (5 per module = 140 total)
-- Schema: SubTopicID, ModuleID, SubTopicName, ContentBody, OrderIndex,
--         XPReward, CreatedByInstructorID, IsPublished
-- NOTE: Column is ContentBody, NOT Content
-- ============================================================

SET IDENTITY_INSERT SubTopics ON;

-- Module 1: What is Cloud Computing
INSERT INTO SubTopics (SubTopicID, ModuleID, SubTopicName, ContentBody, OrderIndex, XPReward, CreatedByInstructorID, IsPublished) VALUES
(1, 1, 'Definition of Cloud Computing', 'Cloud computing is the delivery of computing services over the internet, including servers, storage, databases, networking, software, and analytics.', 1, 20, 2, 1),
(2, 1, 'History and Evolution', 'From mainframes to virtualization to modern cloud — tracing the evolution of shared computing resources.', 2, 20, 2, 1),
(3, 1, 'Key Characteristics', 'On-demand self-service, broad network access, resource pooling, rapid elasticity, and measured service.', 3, 20, 2, 1),
(4, 1, 'Benefits of Cloud', 'Cost savings, scalability, flexibility, disaster recovery, and automatic updates.', 4, 20, 2, 1),
(5, 1, 'Cloud Providers Overview', 'Major providers include AWS, Microsoft Azure, and Google Cloud Platform, each offering hundreds of services.', 5, 20, 2, 1),

-- Module 2: Cloud Service Models
(6, 2, 'Infrastructure as a Service (IaaS)', 'IaaS provides virtualized computing resources over the internet: VMs, storage, and networking.', 1, 20, 2, 1),
(7, 2, 'Platform as a Service (PaaS)', 'PaaS offers a development platform with tools, libraries, and runtime environments managed by the provider.', 2, 20, 2, 1),
(8, 2, 'Software as a Service (SaaS)', 'SaaS delivers complete applications over the internet on a subscription basis.', 3, 20, 2, 1),
(9, 2, 'Shared Responsibility Model', 'Understanding which security and management tasks belong to the provider vs. the customer.', 4, 20, 2, 1),
(10, 2, 'Choosing the Right Model', 'Decision criteria: control needs, development speed, cost structure, and team expertise.', 5, 20, 2, 1),

-- Module 3: Cloud Deployment Models
(11, 3, 'Public Cloud', 'Resources owned and operated by a third-party provider, shared across multiple organizations.', 1, 25, 2, 1),
(12, 3, 'Private Cloud', 'Dedicated infrastructure for a single organization, offering greater control and security.', 2, 25, 2, 1),
(13, 3, 'Hybrid Cloud', 'Combines public and private clouds, allowing data and applications to move between them.', 3, 25, 2, 1),
(14, 3, 'Multi-Cloud Strategy', 'Using services from multiple cloud providers to avoid vendor lock-in and optimize costs.', 4, 25, 2, 1),
(15, 3, 'Choosing a Deployment Model', 'Factors: compliance requirements, data sensitivity, cost, and existing infrastructure.', 5, 25, 2, 1),

-- Module 4: Cloud Economics & Billing
(16, 4, 'Pay-As-You-Go Pricing', 'Pay only for what you use — no upfront costs, scale up or down as needed.', 1, 30, 2, 1),
(17, 4, 'Reserved Instances', 'Commit to 1-3 year terms for significant discounts on compute resources.', 2, 30, 2, 1),
(18, 4, 'Spot and Preemptible Instances', 'Use spare capacity at deep discounts for fault-tolerant and flexible workloads.', 3, 30, 2, 1),
(19, 4, 'Cost Monitoring Tools', 'Budgets, alerts, cost explorers, and tagging strategies for tracking cloud spending.', 4, 30, 2, 1),
(20, 4, 'TCO and ROI Analysis', 'Total Cost of Ownership comparison between on-premises and cloud solutions.', 5, 30, 2, 1);

-- Module 5: Architecture Fundamentals
INSERT INTO SubTopics (SubTopicID, ModuleID, SubTopicName, ContentBody, OrderIndex, XPReward, CreatedByInstructorID, IsPublished) VALUES
(21, 5, 'Scalability Concepts', 'Vertical vs horizontal scaling, stateless design, and auto-scaling groups.', 1, 20, 2, 1),
(22, 5, 'Elasticity in the Cloud', 'Automatically adjusting resources based on demand to optimize performance and cost.', 2, 20, 2, 1),
(23, 5, 'Fault Tolerance', 'Designing systems that continue operating despite component failures.', 3, 20, 2, 1),
(24, 5, 'Loose Coupling', 'Reducing interdependencies between components using queues, events, and APIs.', 4, 20, 2, 1),
(25, 5, 'Design for Failure', 'Assuming everything can fail and building recovery mechanisms into the architecture.', 5, 20, 2, 1),

-- Module 6: High Availability Design
(26, 6, 'Availability Zones', 'Isolated locations within a region that provide redundancy and fault isolation.', 1, 25, 2, 1),
(27, 6, 'Redundancy Patterns', 'Active-active, active-passive, and N+1 redundancy strategies.', 2, 25, 2, 1),
(28, 6, 'Failover Mechanisms', 'Automatic detection and rerouting of traffic when a primary resource fails.', 3, 25, 2, 1),
(29, 6, 'Disaster Recovery Planning', 'RPO, RTO, backup strategies, and cross-region replication.', 4, 25, 2, 1),
(30, 6, 'Health Checks and Monitoring', 'Implementing probes and alerts to detect and respond to failures quickly.', 5, 25, 2, 1),

-- Module 7: Microservices Architecture
(31, 7, 'Monolith vs Microservices', 'Comparing monolithic applications with distributed microservice architectures.', 1, 30, 2, 1),
(32, 7, 'Service Decomposition', 'Strategies for breaking a monolith into bounded contexts and independent services.', 2, 30, 2, 1),
(33, 7, 'Inter-Service Communication', 'Synchronous REST/gRPC vs asynchronous messaging patterns.', 3, 30, 2, 1),
(34, 7, 'API Gateways', 'Central entry point for managing routing, authentication, and rate limiting.', 4, 30, 2, 1),
(35, 7, 'Service Discovery and Registry', 'How services find and communicate with each other in dynamic environments.', 5, 30, 2, 1),

-- Module 8: Cost Optimization & Performance
(36, 8, 'Right-Sizing Resources', 'Matching instance types and sizes to actual workload requirements.', 1, 30, 2, 1),
(37, 8, 'Auto-Scaling Strategies', 'Target tracking, step scaling, and predictive scaling policies.', 2, 30, 2, 1),
(38, 8, 'Caching Strategies', 'In-memory caches, CDN caching, and database query caching for performance.', 3, 30, 2, 1),
(39, 8, 'Content Delivery Networks', 'Distributing content globally to reduce latency and improve user experience.', 4, 30, 2, 1),
(40, 8, 'Performance Testing', 'Load testing, stress testing, and benchmarking cloud applications.', 5, 30, 2, 1);

-- Module 9: Security Fundamentals
INSERT INTO SubTopics (SubTopicID, ModuleID, SubTopicName, ContentBody, OrderIndex, XPReward, CreatedByInstructorID, IsPublished) VALUES
(41, 9, 'CIA Triad', 'Confidentiality, Integrity, and Availability — the three pillars of information security.', 1, 20, 2, 1),
(42, 9, 'Shared Responsibility Model', 'Dividing security duties between the cloud provider and the customer.', 2, 20, 2, 1),
(43, 9, 'Defense in Depth', 'Layered security controls: network, host, application, and data layers.', 3, 20, 2, 1),
(44, 9, 'Least Privilege Principle', 'Granting only the minimum permissions necessary for a task.', 4, 20, 2, 1),
(45, 9, 'Security Best Practices', 'Regular patching, logging, encryption, and incident response planning.', 5, 20, 2, 1),

-- Module 10: Identity & Access Management
(46, 10, 'Authentication Methods', 'Passwords, tokens, certificates, and biometric authentication mechanisms.', 1, 25, 2, 1),
(47, 10, 'Multi-Factor Authentication', 'Adding extra verification layers: SMS, TOTP, hardware keys, and biometrics.', 2, 25, 2, 1),
(48, 10, 'IAM Roles and Policies', 'Defining roles with specific permissions and attaching policies to users or groups.', 3, 25, 2, 1),
(49, 10, 'Federation and SSO', 'Single sign-on across applications using SAML, OAuth, and OpenID Connect.', 4, 25, 2, 1),
(50, 10, 'Access Control Models', 'RBAC, ABAC, and MAC — choosing the right model for your organization.', 5, 25, 2, 1),

-- Module 11: Data Protection & Encryption
(51, 11, 'Encryption at Rest', 'Protecting stored data with AES-256, server-side encryption, and key management.', 1, 30, 2, 1),
(52, 11, 'Encryption in Transit', 'TLS/SSL, certificate management, and secure communication channels.', 2, 30, 2, 1),
(53, 11, 'Key Management Services', 'Centralized key creation, rotation, and access control using KMS.', 3, 30, 2, 1),
(54, 11, 'Data Classification', 'Categorizing data by sensitivity level to apply appropriate protection controls.', 4, 30, 2, 1),
(55, 11, 'Data Loss Prevention', 'Policies and tools to detect and prevent unauthorized data exfiltration.', 5, 30, 2, 1),

-- Module 12: Compliance & Threat Detection
(56, 12, 'Regulatory Frameworks', 'GDPR, HIPAA, SOC 2, ISO 27001 — understanding compliance requirements.', 1, 30, 2, 1),
(57, 12, 'Auditing and Logging', 'Cloud trail logs, audit policies, and maintaining evidence for compliance.', 2, 30, 2, 1),
(58, 12, 'SIEM Solutions', 'Security Information and Event Management for real-time threat detection.', 3, 30, 2, 1),
(59, 12, 'Incident Response', 'Preparation, detection, containment, eradication, and recovery procedures.', 4, 30, 2, 1),
(60, 12, 'Vulnerability Management', 'Scanning, patching, and remediation workflows for cloud infrastructure.', 5, 30, 2, 1);

-- Module 13: DevOps Culture & Principles
INSERT INTO SubTopics (SubTopicID, ModuleID, SubTopicName, ContentBody, OrderIndex, XPReward, CreatedByInstructorID, IsPublished) VALUES
(61, 13, 'What is DevOps', 'A culture and set of practices that unifies software development and IT operations.', 1, 20, 2, 1),
(62, 13, 'Continuous Improvement', 'Kaizen philosophy applied to software: retrospectives, metrics, and iteration.', 2, 20, 2, 1),
(63, 13, 'Collaboration and Communication', 'Breaking down silos between development, operations, and QA teams.', 3, 20, 2, 1),
(64, 13, 'DevOps Toolchains', 'Overview of tools for version control, CI/CD, containers, and monitoring.', 4, 20, 2, 1),
(65, 13, 'Measuring DevOps Success', 'DORA metrics: deployment frequency, lead time, MTTR, and change failure rate.', 5, 20, 2, 1),

-- Module 14: CI/CD Pipelines
(66, 14, 'Continuous Integration', 'Automatically building and testing code on every commit to catch issues early.', 1, 25, 2, 1),
(67, 14, 'Continuous Delivery vs Deployment', 'Delivery: ready to deploy anytime. Deployment: automatically released to production.', 2, 25, 2, 1),
(68, 14, 'Pipeline Stages', 'Source, build, test, staging, and production stages in a typical pipeline.', 3, 25, 2, 1),
(69, 14, 'Testing in Pipelines', 'Unit tests, integration tests, security scans, and performance tests in CI/CD.', 4, 25, 2, 1),
(70, 14, 'Pipeline Tools', 'Jenkins, GitHub Actions, GitLab CI, Azure DevOps, and AWS CodePipeline.', 5, 25, 2, 1),

-- Module 15: Infrastructure as Code
(71, 15, 'IaC Concepts', 'Managing infrastructure through machine-readable definition files instead of manual config.', 1, 30, 2, 1),
(72, 15, 'Terraform Basics', 'Declarative infrastructure provisioning with HCL, state management, and providers.', 2, 30, 2, 1),
(73, 15, 'CloudFormation', 'AWS-native IaC using JSON/YAML templates for stack management.', 3, 30, 2, 1),
(74, 15, 'Configuration Management', 'Ansible, Chef, and Puppet for configuring and maintaining server state.', 4, 30, 2, 1),
(75, 15, 'IaC Best Practices', 'Version control, modular design, testing, and drift detection.', 5, 30, 2, 1),

-- Module 16: Monitoring & Observability
(76, 16, 'Metrics Collection', 'CPU, memory, disk, network, and custom application metrics.', 1, 30, 2, 1),
(77, 16, 'Centralized Logging', 'Aggregating logs from distributed systems using ELK, CloudWatch, or Datadog.', 2, 30, 2, 1),
(78, 16, 'Distributed Tracing', 'Following requests across microservices with correlation IDs and tracing tools.', 3, 30, 2, 1),
(79, 16, 'Alerting Strategies', 'Setting thresholds, anomaly detection, and reducing alert fatigue.', 4, 30, 2, 1),
(80, 16, 'SRE Practices', 'SLIs, SLOs, SLAs, error budgets, and toil reduction.', 5, 30, 2, 1);

-- Module 17: Data Engineering Basics
INSERT INTO SubTopics (SubTopicID, ModuleID, SubTopicName, ContentBody, OrderIndex, XPReward, CreatedByInstructorID, IsPublished) VALUES
(81, 17, 'Data Lifecycle', 'Collection, storage, processing, analysis, and archival of data.', 1, 20, 2, 1),
(82, 17, 'ETL vs ELT', 'Extract-Transform-Load vs Extract-Load-Transform: when to use each approach.', 2, 20, 2, 1),
(83, 17, 'Data Quality', 'Accuracy, completeness, consistency, and timeliness of data.', 3, 20, 2, 1),
(84, 17, 'Data Governance', 'Policies, standards, and processes for managing data assets.', 4, 20, 2, 1),
(85, 17, 'Data Formats', 'JSON, Parquet, Avro, CSV — choosing the right format for your use case.', 5, 20, 2, 1),

-- Module 18: Cloud Databases
(86, 18, 'Relational Databases', 'Cloud-managed SQL databases: RDS, Azure SQL, Cloud SQL — features and scaling.', 1, 25, 2, 1),
(87, 18, 'NoSQL Databases', 'Document, key-value, column-family, and graph databases in the cloud.', 2, 25, 2, 1),
(88, 18, 'In-Memory Databases', 'Redis, Memcached, and ElastiCache for ultra-low latency data access.', 3, 25, 2, 1),
(89, 18, 'Database Scaling', 'Read replicas, sharding, partitioning, and auto-scaling strategies.', 4, 25, 2, 1),
(90, 18, 'Database Migration', 'Strategies and tools for migrating on-premises databases to the cloud.', 5, 25, 2, 1),

-- Module 19: Data Pipelines & Streaming
(91, 19, 'Batch Processing', 'Processing large volumes of data at scheduled intervals using MapReduce or Spark.', 1, 30, 2, 1),
(92, 19, 'Real-Time Streaming', 'Processing data as it arrives using Kafka, Kinesis, or Pub/Sub.', 2, 30, 2, 1),
(93, 19, 'Event-Driven Architecture', 'Designing systems that react to events with loose coupling and high scalability.', 3, 30, 2, 1),
(94, 19, 'Data Pipeline Orchestration', 'Workflow management with Airflow, Step Functions, and Data Factory.', 4, 30, 2, 1),
(95, 19, 'Stream Processing Patterns', 'Windowing, watermarks, exactly-once semantics, and late data handling.', 5, 30, 2, 1),

-- Module 20: Data Warehousing & Analytics
(96, 20, 'Data Warehouse Concepts', 'Star schema, snowflake schema, fact tables, and dimension tables.', 1, 30, 2, 1),
(97, 20, 'Cloud Data Warehouses', 'Redshift, BigQuery, Synapse Analytics — comparing performance and pricing.', 2, 30, 2, 1),
(98, 20, 'Data Lakes', 'Storing raw data in its native format for flexible analysis and ML.', 3, 30, 2, 1),
(99, 20, 'BI and Visualization', 'Connecting BI tools like Power BI, Tableau, and QuickSight to cloud data.', 4, 30, 2, 1),
(100, 20, 'ML Integration', 'Using warehouse data for machine learning model training and inference.', 5, 30, 2, 1);

-- Module 21: Networking Fundamentals
INSERT INTO SubTopics (SubTopicID, ModuleID, SubTopicName, ContentBody, OrderIndex, XPReward, CreatedByInstructorID, IsPublished) VALUES
(101, 21, 'OSI Model', 'The 7-layer networking model: Physical through Application layers.', 1, 20, 2, 1),
(102, 21, 'TCP/IP Protocol Suite', 'IP addressing, TCP vs UDP, ports, and how data travels across networks.', 2, 20, 2, 1),
(103, 21, 'DNS Fundamentals', 'Domain Name System: resolution process, record types, and DNS in the cloud.', 3, 20, 2, 1),
(104, 21, 'IP Addressing and CIDR', 'IPv4, IPv6, subnetting, and CIDR notation for cloud network design.', 4, 20, 2, 1),
(105, 21, 'Network Security Basics', 'Firewalls, security groups, NACLs, and traffic filtering concepts.', 5, 20, 2, 1),

-- Module 22: Virtual Networks & Subnets
(106, 22, 'Virtual Private Clouds', 'Creating isolated network environments in the cloud with custom IP ranges.', 1, 25, 2, 1),
(107, 22, 'Subnets and Availability', 'Public vs private subnets, multi-AZ deployment, and subnet sizing.', 2, 25, 2, 1),
(108, 22, 'Route Tables', 'Directing traffic between subnets, internet gateways, and NAT gateways.', 3, 25, 2, 1),
(109, 22, 'Network ACLs', 'Stateless packet filtering at the subnet level for defense in depth.', 4, 25, 2, 1),
(110, 22, 'VPC Peering', 'Connecting VPCs for private communication without traversing the internet.', 5, 25, 2, 1),

-- Module 23: Load Balancing & CDN
(111, 23, 'Application Load Balancers', 'Layer 7 load balancing with path-based and host-based routing.', 1, 30, 2, 1),
(112, 23, 'Network Load Balancers', 'Layer 4 ultra-low latency load balancing for TCP/UDP traffic.', 2, 30, 2, 1),
(113, 23, 'Traffic Routing Policies', 'Weighted, latency-based, geolocation, and failover routing strategies.', 3, 30, 2, 1),
(114, 23, 'CDN Architecture', 'Edge locations, caching behavior, invalidation, and origin servers.', 4, 30, 2, 1),
(115, 23, 'SSL/TLS Termination', 'Offloading encryption at the load balancer for performance optimization.', 5, 30, 2, 1),

-- Module 24: Hybrid & Multi-Cloud Connectivity
(116, 24, 'VPN Connections', 'Site-to-site and client VPN for secure connectivity between on-premises and cloud.', 1, 30, 2, 1),
(117, 24, 'Direct Connect', 'Dedicated private network connections for high bandwidth and low latency.', 2, 30, 2, 1),
(118, 24, 'Network Peering', 'Exchanging traffic between cloud providers or between cloud and ISPs.', 3, 30, 2, 1),
(119, 24, 'Transit Gateway', 'Hub-and-spoke network topology connecting multiple VPCs and on-premises.', 4, 30, 2, 1),
(120, 24, 'Multi-Cloud Networking', 'Challenges and solutions for networking across AWS, Azure, and GCP.', 5, 30, 2, 1);

-- Module 25: Serverless Computing Basics
INSERT INTO SubTopics (SubTopicID, ModuleID, SubTopicName, ContentBody, OrderIndex, XPReward, CreatedByInstructorID, IsPublished) VALUES
(121, 25, 'What is Serverless', 'Running code without managing servers — the provider handles all infrastructure.', 1, 20, 2, 1),
(122, 25, 'Function as a Service', 'AWS Lambda, Azure Functions, Google Cloud Functions — event-driven execution.', 2, 20, 2, 1),
(123, 25, 'Event-Driven Design', 'Triggering functions from API calls, queues, schedules, and file uploads.', 3, 20, 2, 1),
(124, 25, 'Serverless Use Cases', 'APIs, data processing, chatbots, IoT backends, and scheduled tasks.', 4, 20, 2, 1),
(125, 25, 'Cold Starts and Limitations', 'Understanding latency on first invocation and workarounds.', 5, 20, 2, 1),

-- Module 26: Containers & Docker
(126, 26, 'Container Fundamentals', 'Lightweight, portable units that package code with all dependencies.', 1, 25, 2, 1),
(127, 26, 'Docker Basics', 'Images, containers, Dockerfiles, and the build-ship-run workflow.', 2, 25, 2, 1),
(128, 26, 'Container Registries', 'ECR, ACR, Docker Hub — storing and distributing container images.', 3, 25, 2, 1),
(129, 26, 'Multi-Stage Builds', 'Optimizing image size by separating build and runtime environments.', 4, 25, 2, 1),
(130, 26, 'Container Networking', 'Bridge networks, overlay networks, and service mesh for containers.', 5, 25, 2, 1),

-- Module 27: Kubernetes & Orchestration
(131, 27, 'Kubernetes Architecture', 'Control plane, worker nodes, etcd, and the Kubernetes API server.', 1, 30, 2, 1),
(132, 27, 'Pods and Deployments', 'The smallest deployable unit and managing replica sets for availability.', 2, 30, 2, 1),
(133, 27, 'Services and Ingress', 'Exposing applications internally and externally with load balancing.', 3, 30, 2, 1),
(134, 27, 'Scaling and Auto-Scaling', 'Horizontal Pod Autoscaler, Vertical Pod Autoscaler, and Cluster Autoscaler.', 4, 30, 2, 1),
(135, 27, 'Helm and Package Management', 'Templating Kubernetes manifests and managing releases with Helm charts.', 5, 30, 2, 1),

-- Module 28: Advanced Serverless Patterns
(136, 28, 'Step Functions', 'Orchestrating multi-step workflows with state machines and error handling.', 1, 30, 2, 1),
(137, 28, 'Event Buses', 'EventBridge and similar services for decoupled event routing.', 2, 30, 2, 1),
(138, 28, 'Serverless APIs', 'API Gateway patterns, authorization, throttling, and caching.', 3, 30, 2, 1),
(139, 28, 'Serverless Databases', 'DynamoDB, Aurora Serverless, and Cosmos DB for on-demand scaling.', 4, 30, 2, 1),
(140, 28, 'Cost Management', 'Optimizing serverless costs with provisioned concurrency and right-sizing.', 5, 30, 2, 1);

SET IDENTITY_INSERT SubTopics OFF;
PRINT '140 SubTopics inserted (5 per module).';
GO

-- ============================================================
-- STEP 7: INSERT QUESTIONS (5 per module = 140 total, one per subtopic)
-- Schema: QuestionID, SubTopicID, QuestionText, QuestionType, CorrectAnswer,
--         OrderIndex, XPReward, CreatedByInstructorID
-- NOTE: Questions table DOES have QuestionType and CorrectAnswer columns
-- ============================================================

SET IDENTITY_INSERT Questions ON;

-- Module 1 Questions (SubTopics 1-5)
INSERT INTO Questions (QuestionID, SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(1, 1, 'What is cloud computing?', 'MCQ', 'Delivery of computing services over the internet', 1, 10, 2),
(2, 2, 'Which decade saw the birth of cloud computing as we know it today?', 'MCQ', '2000s', 1, 10, 2),
(3, 3, 'Which is NOT a key characteristic of cloud computing?', 'MCQ', 'Manual provisioning required', 1, 10, 2),
(4, 4, 'What is a primary benefit of cloud computing?', 'MCQ', 'Scalability on demand', 1, 10, 2),
(5, 5, 'Which is one of the three major cloud providers?', 'MCQ', 'Amazon Web Services', 1, 10, 2),

-- Module 2 Questions (SubTopics 6-10)
(6, 6, 'What does IaaS provide?', 'MCQ', 'Virtualized computing resources', 1, 10, 2),
(7, 7, 'PaaS primarily offers what to developers?', 'MCQ', 'A managed development platform', 1, 10, 2),
(8, 8, 'Which is an example of SaaS?', 'MCQ', 'Google Workspace', 1, 10, 2),
(9, 9, 'In the shared responsibility model, who manages the physical infrastructure?', 'MCQ', 'The cloud provider', 1, 10, 2),
(10, 10, 'When should you choose IaaS over PaaS?', 'MCQ', 'When you need full control over the OS', 1, 10, 2),

-- Module 3 Questions (SubTopics 11-15)
(11, 11, 'What defines a public cloud?', 'MCQ', 'Resources shared across multiple organizations', 1, 10, 2),
(12, 12, 'What is the main advantage of a private cloud?', 'MCQ', 'Greater control and security', 1, 10, 2),
(13, 13, 'Hybrid cloud combines which two models?', 'MCQ', 'Public and private clouds', 1, 10, 2),
(14, 14, 'What is a key benefit of multi-cloud strategy?', 'MCQ', 'Avoiding vendor lock-in', 1, 10, 2),
(15, 15, 'Which factor is MOST important when choosing a deployment model for healthcare data?', 'MCQ', 'Compliance requirements', 1, 10, 2),

-- Module 4 Questions (SubTopics 16-20)
(16, 16, 'What is pay-as-you-go pricing?', 'MCQ', 'Pay only for resources you consume', 1, 10, 2),
(17, 17, 'Reserved instances offer discounts in exchange for what?', 'MCQ', 'A 1-3 year commitment', 1, 10, 2),
(18, 18, 'Spot instances are best for which workloads?', 'MCQ', 'Fault-tolerant batch processing', 1, 10, 2),
(19, 19, 'What is a cost allocation tag used for?', 'MCQ', 'Tracking spending by project or team', 1, 10, 2),
(20, 20, 'TCO stands for what?', 'MCQ', 'Total Cost of Ownership', 1, 10, 2);

-- Module 5 Questions (SubTopics 21-25)
INSERT INTO Questions (QuestionID, SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(21, 21, 'What is horizontal scaling?', 'MCQ', 'Adding more instances to handle load', 1, 10, 2),
(22, 22, 'Elasticity in cloud means what?', 'MCQ', 'Automatically adjusting resources based on demand', 1, 10, 2),
(23, 23, 'Fault tolerance ensures what?', 'MCQ', 'Systems continue operating despite failures', 1, 10, 2),
(24, 24, 'Loose coupling is achieved through what?', 'MCQ', 'Message queues and event-driven patterns', 1, 10, 2),
(25, 25, 'Design for failure means what?', 'MCQ', 'Assuming any component can fail at any time', 1, 10, 2),

-- Module 6 Questions (SubTopics 26-30)
(26, 26, 'What are Availability Zones?', 'MCQ', 'Isolated locations within a region', 1, 10, 2),
(27, 27, 'Active-active redundancy means what?', 'MCQ', 'All instances serve traffic simultaneously', 1, 10, 2),
(28, 28, 'What triggers automatic failover?', 'MCQ', 'Health check failure detection', 1, 10, 2),
(29, 29, 'RPO stands for what?', 'MCQ', 'Recovery Point Objective', 1, 10, 2),
(30, 30, 'What is the purpose of health checks?', 'MCQ', 'Detecting and responding to failures quickly', 1, 10, 2),

-- Module 7 Questions (SubTopics 31-35)
(31, 31, 'What is a key disadvantage of monolithic architecture?', 'MCQ', 'Difficult to scale individual components', 1, 10, 2),
(32, 32, 'Bounded context is a concept from which methodology?', 'MCQ', 'Domain-Driven Design', 1, 10, 2),
(33, 33, 'Which is an asynchronous communication pattern?', 'MCQ', 'Message queue', 1, 10, 2),
(34, 34, 'An API Gateway provides what?', 'MCQ', 'Central entry point with routing and auth', 1, 10, 2),
(35, 35, 'Service discovery helps services to what?', 'MCQ', 'Find each other in dynamic environments', 1, 10, 2),

-- Module 8 Questions (SubTopics 36-40)
(36, 36, 'Right-sizing means what?', 'MCQ', 'Matching resources to actual workload needs', 1, 10, 2),
(37, 37, 'Target tracking scaling adjusts capacity based on what?', 'MCQ', 'A target metric value like CPU utilization', 1, 10, 2),
(38, 38, 'Which caching layer is closest to the user?', 'MCQ', 'CDN edge cache', 1, 10, 2),
(39, 39, 'A CDN improves performance by doing what?', 'MCQ', 'Serving content from geographically closer locations', 1, 10, 2),
(40, 40, 'Load testing verifies what?', 'MCQ', 'System behavior under expected peak traffic', 1, 10, 2);

-- Module 9 Questions (SubTopics 41-45)
INSERT INTO Questions (QuestionID, SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(41, 41, 'What does CIA stand for in security?', 'MCQ', 'Confidentiality, Integrity, Availability', 1, 10, 2),
(42, 42, 'Who manages physical security in the shared responsibility model?', 'MCQ', 'The cloud provider', 1, 10, 2),
(43, 43, 'Defense in depth uses what approach?', 'MCQ', 'Multiple layers of security controls', 1, 10, 2),
(44, 44, 'Least privilege means what?', 'MCQ', 'Only granting minimum necessary permissions', 1, 10, 2),
(45, 45, 'Which is a security best practice?', 'MCQ', 'Regular patching and updates', 1, 10, 2),

-- Module 10 Questions (SubTopics 46-50)
(46, 46, 'Which is a form of authentication?', 'MCQ', 'Password and username combination', 1, 10, 2),
(47, 47, 'MFA adds security by requiring what?', 'MCQ', 'Multiple verification factors', 1, 10, 2),
(48, 48, 'IAM policies define what?', 'MCQ', 'What actions are allowed or denied', 1, 10, 2),
(49, 49, 'SSO allows users to do what?', 'MCQ', 'Log in once to access multiple applications', 1, 10, 2),
(50, 50, 'RBAC assigns permissions based on what?', 'MCQ', 'User roles', 1, 10, 2),

-- Module 11 Questions (SubTopics 51-55)
(51, 51, 'AES-256 is used for what?', 'MCQ', 'Encrypting data at rest', 1, 10, 2),
(52, 52, 'TLS protects data in what state?', 'MCQ', 'In transit', 1, 10, 2),
(53, 53, 'KMS is used for what?', 'MCQ', 'Managing encryption keys centrally', 1, 10, 2),
(54, 54, 'Data classification helps determine what?', 'MCQ', 'What level of protection data needs', 1, 10, 2),
(55, 55, 'DLP tools prevent what?', 'MCQ', 'Unauthorized data exfiltration', 1, 10, 2),

-- Module 12 Questions (SubTopics 56-60)
(56, 56, 'GDPR applies to data of citizens in which region?', 'MCQ', 'European Union', 1, 10, 2),
(57, 57, 'Audit logs provide what?', 'MCQ', 'Evidence of who did what and when', 1, 10, 2),
(58, 58, 'SIEM systems do what?', 'MCQ', 'Correlate security events for threat detection', 1, 10, 2),
(59, 59, 'The first step in incident response is what?', 'MCQ', 'Preparation', 1, 10, 2),
(60, 60, 'Vulnerability scanning identifies what?', 'MCQ', 'Known security weaknesses', 1, 10, 2);

-- Module 13 Questions (SubTopics 61-65)
INSERT INTO Questions (QuestionID, SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(61, 61, 'DevOps is best described as what?', 'MCQ', 'A culture unifying development and operations', 1, 10, 2),
(62, 62, 'Continuous improvement in DevOps is inspired by what?', 'MCQ', 'Kaizen philosophy', 1, 10, 2),
(63, 63, 'Breaking down silos means what?', 'MCQ', 'Improving collaboration between teams', 1, 10, 2),
(64, 64, 'Git is an example of what type of tool?', 'MCQ', 'Version control', 1, 10, 2),
(65, 65, 'DORA metrics measure what?', 'MCQ', 'Software delivery performance', 1, 10, 2),

-- Module 14 Questions (SubTopics 66-70)
(66, 66, 'Continuous Integration means what?', 'MCQ', 'Automatically building and testing on every commit', 1, 10, 2),
(67, 67, 'What distinguishes Continuous Deployment from Delivery?', 'MCQ', 'Automatic release to production', 1, 10, 2),
(68, 68, 'What comes after the build stage in a typical pipeline?', 'MCQ', 'Test stage', 1, 10, 2),
(69, 69, 'Which test type runs fastest in CI?', 'MCQ', 'Unit tests', 1, 10, 2),
(70, 70, 'GitHub Actions is what type of tool?', 'MCQ', 'CI/CD pipeline tool', 1, 10, 2),

-- Module 15 Questions (SubTopics 71-75)
(71, 71, 'IaC replaces what?', 'MCQ', 'Manual infrastructure configuration', 1, 10, 2),
(72, 72, 'Terraform uses which configuration language?', 'MCQ', 'HCL (HashiCorp Configuration Language)', 1, 10, 2),
(73, 73, 'CloudFormation is specific to which provider?', 'MCQ', 'AWS', 1, 10, 2),
(74, 74, 'Ansible is primarily used for what?', 'MCQ', 'Configuration management', 1, 10, 2),
(75, 75, 'Drift detection identifies what?', 'MCQ', 'Differences between desired and actual state', 1, 10, 2),

-- Module 16 Questions (SubTopics 76-80)
(76, 76, 'CPU utilization is what type of metric?', 'MCQ', 'Infrastructure metric', 1, 10, 2),
(77, 77, 'ELK stack is used for what?', 'MCQ', 'Centralized logging and search', 1, 10, 2),
(78, 78, 'Distributed tracing helps with what?', 'MCQ', 'Following requests across microservices', 1, 10, 2),
(79, 79, 'Alert fatigue is caused by what?', 'MCQ', 'Too many non-actionable alerts', 1, 10, 2),
(80, 80, 'An SLO defines what?', 'MCQ', 'Target level for a service reliability metric', 1, 10, 2);

-- Module 17 Questions (SubTopics 81-85)
INSERT INTO Questions (QuestionID, SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(81, 81, 'The data lifecycle starts with what phase?', 'MCQ', 'Collection', 1, 10, 2),
(82, 82, 'ELT differs from ETL how?', 'MCQ', 'Data is transformed after loading', 1, 10, 2),
(83, 83, 'Data quality includes which attribute?', 'MCQ', 'Accuracy and completeness', 1, 10, 2),
(84, 84, 'Data governance establishes what?', 'MCQ', 'Policies for managing data assets', 1, 10, 2),
(85, 85, 'Parquet is optimized for what?', 'MCQ', 'Columnar analytical queries', 1, 10, 2),

-- Module 18 Questions (SubTopics 86-90)
(86, 86, 'RDS is a managed service for what?', 'MCQ', 'Relational databases', 1, 10, 2),
(87, 87, 'DynamoDB is what type of database?', 'MCQ', 'NoSQL key-value and document store', 1, 10, 2),
(88, 88, 'Redis is primarily used for what?', 'MCQ', 'In-memory caching with low latency', 1, 10, 2),
(89, 89, 'Read replicas help with what?', 'MCQ', 'Scaling read-heavy workloads', 1, 10, 2),
(90, 90, 'Database migration to cloud is called what?', 'MCQ', 'Cloud migration or lift-and-shift', 1, 10, 2),

-- Module 19 Questions (SubTopics 91-95)
(91, 91, 'Batch processing handles data how?', 'MCQ', 'In large volumes at scheduled intervals', 1, 10, 2),
(92, 92, 'Kafka is used for what?', 'MCQ', 'Real-time event streaming', 1, 10, 2),
(93, 93, 'Event-driven architecture provides what benefit?', 'MCQ', 'Loose coupling between components', 1, 10, 2),
(94, 94, 'Apache Airflow is used for what?', 'MCQ', 'Workflow orchestration', 1, 10, 2),
(95, 95, 'Exactly-once semantics ensures what?', 'MCQ', 'Each event is processed only once', 1, 10, 2),

-- Module 20 Questions (SubTopics 96-100)
(96, 96, 'A star schema consists of what?', 'MCQ', 'Fact tables surrounded by dimension tables', 1, 10, 2),
(97, 97, 'BigQuery is offered by which provider?', 'MCQ', 'Google Cloud Platform', 1, 10, 2),
(98, 98, 'A data lake stores data in what format?', 'MCQ', 'Raw native format', 1, 10, 2),
(99, 99, 'Power BI is what type of tool?', 'MCQ', 'Business Intelligence and visualization', 1, 10, 2),
(100, 100, 'ML models in warehouses benefit from what?', 'MCQ', 'Large volumes of structured training data', 1, 10, 2);

-- Module 21 Questions (SubTopics 101-105)
INSERT INTO Questions (QuestionID, SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(101, 101, 'How many layers does the OSI model have?', 'MCQ', '7', 1, 10, 2),
(102, 102, 'TCP provides what guarantee that UDP does not?', 'MCQ', 'Reliable ordered delivery', 1, 10, 2),
(103, 103, 'DNS translates what to what?', 'MCQ', 'Domain names to IP addresses', 1, 10, 2),
(104, 104, 'CIDR notation /24 means how many host addresses?', 'MCQ', '254 usable addresses', 1, 10, 2),
(105, 105, 'A security group acts as what?', 'MCQ', 'A virtual firewall for instances', 1, 10, 2),

-- Module 22 Questions (SubTopics 106-110)
(106, 106, 'A VPC provides what?', 'MCQ', 'An isolated virtual network in the cloud', 1, 10, 2),
(107, 107, 'A private subnet lacks what?', 'MCQ', 'Direct route to the internet gateway', 1, 10, 2),
(108, 108, 'Route tables determine what?', 'MCQ', 'Where network traffic is directed', 1, 10, 2),
(109, 109, 'Network ACLs are stateless meaning what?', 'MCQ', 'Return traffic must be explicitly allowed', 1, 10, 2),
(110, 110, 'VPC peering allows what?', 'MCQ', 'Private communication between VPCs', 1, 10, 2),

-- Module 23 Questions (SubTopics 111-115)
(111, 111, 'An ALB operates at which OSI layer?', 'MCQ', 'Layer 7 (Application)', 1, 10, 2),
(112, 112, 'An NLB is best for what type of traffic?', 'MCQ', 'High-performance TCP/UDP traffic', 1, 10, 2),
(113, 113, 'Geolocation routing directs users based on what?', 'MCQ', 'Their geographic location', 1, 10, 2),
(114, 114, 'CDN edge locations do what?', 'MCQ', 'Cache content close to end users', 1, 10, 2),
(115, 115, 'SSL termination at the load balancer does what?', 'MCQ', 'Offloads encryption processing from backend servers', 1, 10, 2),

-- Module 24 Questions (SubTopics 116-120)
(116, 116, 'A site-to-site VPN connects what?', 'MCQ', 'On-premises network to cloud VPC', 1, 10, 2),
(117, 117, 'Direct Connect provides what over VPN?', 'MCQ', 'Dedicated private connection with consistent performance', 1, 10, 2),
(118, 118, 'Network peering exchanges traffic how?', 'MCQ', 'Directly between networks without traversing the public internet', 1, 10, 2),
(119, 119, 'Transit Gateway implements what topology?', 'MCQ', 'Hub-and-spoke network architecture', 1, 10, 2),
(120, 120, 'Multi-cloud networking challenges include what?', 'MCQ', 'Different APIs and networking models per provider', 1, 10, 2);

-- Module 25 Questions (SubTopics 121-125)
INSERT INTO Questions (QuestionID, SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID) VALUES
(121, 121, 'Serverless means what?', 'MCQ', 'No server management required by the developer', 1, 10, 2),
(122, 122, 'AWS Lambda is what type of service?', 'MCQ', 'Function as a Service (FaaS)', 1, 10, 2),
(123, 123, 'Functions can be triggered by what?', 'MCQ', 'Events like API calls, queues, or schedules', 1, 10, 2),
(124, 124, 'Serverless is ideal for what use case?', 'MCQ', 'Event-driven APIs and data processing', 1, 10, 2),
(125, 125, 'A cold start is what?', 'MCQ', 'Latency on first function invocation after idle', 1, 10, 2),

-- Module 26 Questions (SubTopics 126-130)
(126, 126, 'Containers package what together?', 'MCQ', 'Application code and all its dependencies', 1, 10, 2),
(127, 127, 'A Dockerfile defines what?', 'MCQ', 'Instructions to build a container image', 1, 10, 2),
(128, 128, 'A container registry stores what?', 'MCQ', 'Container images for distribution', 1, 10, 2),
(129, 129, 'Multi-stage builds optimize what?', 'MCQ', 'Final image size by separating build and runtime', 1, 10, 2),
(130, 130, 'Container networking enables what?', 'MCQ', 'Communication between containers and external services', 1, 10, 2),

-- Module 27 Questions (SubTopics 131-135)
(131, 131, 'The Kubernetes control plane includes what?', 'MCQ', 'API server, scheduler, and etcd', 1, 10, 2),
(132, 132, 'A Pod is what in Kubernetes?', 'MCQ', 'The smallest deployable unit', 1, 10, 2),
(133, 133, 'A Kubernetes Service provides what?', 'MCQ', 'Stable network endpoint for a set of Pods', 1, 10, 2),
(134, 134, 'HPA scales based on what?', 'MCQ', 'CPU or custom metrics', 1, 10, 2),
(135, 135, 'Helm charts are used for what?', 'MCQ', 'Packaging and deploying Kubernetes applications', 1, 10, 2),

-- Module 28 Questions (SubTopics 136-140)
(136, 136, 'Step Functions orchestrate what?', 'MCQ', 'Multi-step workflows with state machines', 1, 10, 2),
(137, 137, 'EventBridge is what type of service?', 'MCQ', 'Serverless event bus for routing events', 1, 10, 2),
(138, 138, 'API Gateway provides what for serverless APIs?', 'MCQ', 'Request routing, auth, and throttling', 1, 10, 2),
(139, 139, 'Aurora Serverless scales what automatically?', 'MCQ', 'Database capacity based on demand', 1, 10, 2),
(140, 140, 'Provisioned concurrency solves what problem?', 'MCQ', 'Cold start latency', 1, 10, 2);

SET IDENTITY_INSERT Questions OFF;
PRINT '140 Questions inserted (1 per subtopic, 5 per module).';
GO

-- ============================================================
-- STEP 8: INSERT ANSWER OPTIONS (4 per question = 560 total)
-- Schema: OptionID (identity), QuestionID, OptionText, IsCorrect
-- ============================================================

-- Module 1 Options (Questions 1-5)
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(1, 'Delivery of computing services over the internet', 1),
(1, 'Installing software on local computers', 0),
(1, 'A type of weather formation', 0),
(1, 'Storing files on USB drives', 0),
(2, '2000s', 1),
(2, '1970s', 0),
(2, '2020s', 0),
(2, '1990s', 0),
(3, 'Manual provisioning required', 1),
(3, 'On-demand self-service', 0),
(3, 'Broad network access', 0),
(3, 'Resource pooling', 0),
(4, 'Scalability on demand', 1),
(4, 'Higher upfront costs', 0),
(4, 'Slower deployment times', 0),
(4, 'Less flexibility', 0),
(5, 'Amazon Web Services', 1),
(5, 'Adobe Creative Cloud', 0),
(5, 'Dropbox', 0),
(5, 'Norton Antivirus', 0),

-- Module 2 Options (Questions 6-10)
(6, 'Virtualized computing resources', 1),
(6, 'Complete applications ready to use', 0),
(6, 'Only storage services', 0),
(6, 'Physical hardware delivered to your office', 0),
(7, 'A managed development platform', 1),
(7, 'Raw virtual machines only', 0),
(7, 'End-user email software', 0),
(7, 'Physical server hosting', 0),
(8, 'Google Workspace', 1),
(8, 'AWS EC2', 0),
(8, 'Kubernetes', 0),
(8, 'VMware vSphere', 0),
(9, 'The cloud provider', 1),
(9, 'The customer only', 0),
(9, 'A third-party auditor', 0),
(9, 'Nobody — it is automated', 0),
(10, 'When you need full control over the OS', 1),
(10, 'When you want zero management', 0),
(10, 'When budget is unlimited', 0),
(10, 'When you only need email', 0);

-- Module 3 Options (Questions 11-15)
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(11, 'Resources shared across multiple organizations', 1),
(11, 'Dedicated to one company only', 0),
(11, 'Only available on local servers', 0),
(11, 'Free for everyone', 0),
(12, 'Greater control and security', 1),
(12, 'Lower cost than public cloud', 0),
(12, 'Unlimited scalability', 0),
(12, 'No maintenance needed', 0),
(13, 'Public and private clouds', 1),
(13, 'Two public clouds', 0),
(13, 'On-premises only', 0),
(13, 'Mobile and desktop', 0),
(14, 'Avoiding vendor lock-in', 1),
(14, 'Reducing all costs to zero', 0),
(14, 'Using only one provider', 0),
(14, 'Eliminating the need for IT staff', 0),
(15, 'Compliance requirements', 1),
(15, 'Color of the logo', 0),
(15, 'Number of employees', 0),
(15, 'Office location', 0),

-- Module 4 Options (Questions 16-20)
(16, 'Pay only for resources you consume', 1),
(16, 'Pay a fixed monthly fee regardless of usage', 0),
(16, 'Free for the first year only', 0),
(16, 'Pay upfront for 5 years', 0),
(17, 'A 1-3 year commitment', 1),
(17, 'Using spot instances', 0),
(17, 'Paying more per hour', 0),
(17, 'Switching providers annually', 0),
(18, 'Fault-tolerant batch processing', 1),
(18, 'Mission-critical real-time databases', 0),
(18, 'Production web servers', 0),
(18, 'Authentication services', 0),
(19, 'Tracking spending by project or team', 1),
(19, 'Encrypting data at rest', 0),
(19, 'Improving application performance', 0),
(19, 'Managing user permissions', 0),
(20, 'Total Cost of Ownership', 1),
(20, 'Technical Configuration Overhead', 0),
(20, 'Third-party Cloud Operations', 0),
(20, 'Temporary Compute Option', 0);

-- Module 5 Options (Questions 21-25)
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(21, 'Adding more instances to handle load', 1),
(21, 'Adding more CPU to one server', 0),
(21, 'Reducing the number of users', 0),
(21, 'Deleting old data', 0),
(22, 'Automatically adjusting resources based on demand', 1),
(22, 'Manually adding servers each week', 0),
(22, 'Keeping resources constant at all times', 0),
(22, 'Shutting down during low traffic', 0),
(23, 'Systems continue operating despite failures', 1),
(23, 'Systems never fail', 0),
(23, 'Systems restart quickly after failure', 0),
(23, 'Systems are backed up weekly', 0),
(24, 'Message queues and event-driven patterns', 1),
(24, 'Direct database connections between services', 0),
(24, 'Shared global variables', 0),
(24, 'Monolithic deployment', 0),
(25, 'Assuming any component can fail at any time', 1),
(25, 'Building perfect components that never fail', 0),
(25, 'Ignoring potential failures', 0),
(25, 'Only testing in production', 0),

-- Module 6 Options (Questions 26-30)
(26, 'Isolated locations within a region', 1),
(26, 'Different cloud providers', 0),
(26, 'Virtual machines', 0),
(26, 'Database replicas', 0),
(27, 'All instances serve traffic simultaneously', 1),
(27, 'Only one instance is active at a time', 0),
(27, 'Instances take turns serving traffic', 0),
(27, 'All instances are in standby', 0),
(28, 'Health check failure detection', 1),
(28, 'Manual administrator intervention', 0),
(28, 'Scheduled maintenance windows', 0),
(28, 'User complaints', 0),
(29, 'Recovery Point Objective', 1),
(29, 'Recovery Process Order', 0),
(29, 'Replication Protocol Options', 0),
(29, 'Resource Provisioning Overhead', 0),
(30, 'Detecting and responding to failures quickly', 1),
(30, 'Billing customers accurately', 0),
(30, 'Measuring user satisfaction', 0),
(30, 'Tracking code deployments', 0);

-- Module 7 Options (Questions 31-35)
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(31, 'Difficult to scale individual components', 1),
(31, 'Easy to deploy', 0),
(31, 'Simple architecture', 0),
(31, 'Fast initial development', 0),
(32, 'Domain-Driven Design', 1),
(32, 'Agile methodology', 0),
(32, 'Waterfall model', 0),
(32, 'ITIL framework', 0),
(33, 'Message queue', 1),
(33, 'REST API call with await', 0),
(33, 'Database stored procedure', 0),
(33, 'Synchronous RPC', 0),
(34, 'Central entry point with routing and auth', 1),
(34, 'A database proxy', 0),
(34, 'A container orchestrator', 0),
(34, 'A version control system', 0),
(35, 'Find each other in dynamic environments', 1),
(35, 'Share a single database', 0),
(35, 'Deploy simultaneously', 0),
(35, 'Use the same programming language', 0),

-- Module 8 Options (Questions 36-40)
(36, 'Matching resources to actual workload needs', 1),
(36, 'Always using the largest instance type', 0),
(36, 'Reducing staff count', 0),
(36, 'Deleting unused code', 0),
(37, 'A target metric value like CPU utilization', 1),
(37, 'Time of day only', 0),
(37, 'Manual triggers', 0),
(37, 'Number of deployments', 0),
(38, 'CDN edge cache', 1),
(38, 'Database cache', 0),
(38, 'Application memory cache', 0),
(38, 'CPU L1 cache', 0),
(39, 'Serving content from geographically closer locations', 1),
(39, 'Compressing all files to ZIP', 0),
(39, 'Reducing image quality', 0),
(39, 'Blocking international users', 0),
(40, 'System behavior under expected peak traffic', 1),
(40, 'Code compilation speed', 0),
(40, 'Developer productivity', 0),
(40, 'Network cable quality', 0);

-- Module 9 Options (Questions 41-45)
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(41, 'Confidentiality, Integrity, Availability', 1),
(41, 'Cost, Innovation, Automation', 0),
(41, 'Cloud, Infrastructure, Applications', 0),
(41, 'Central Intelligence Agency', 0),
(42, 'The cloud provider', 1),
(42, 'The customer', 0),
(42, 'A government agency', 0),
(42, 'The ISP', 0),
(43, 'Multiple layers of security controls', 1),
(43, 'One very strong firewall', 0),
(43, 'Hiding servers underground', 0),
(43, 'Using only encryption', 0),
(44, 'Only granting minimum necessary permissions', 1),
(44, 'Giving everyone admin access', 0),
(44, 'Using one shared password', 0),
(44, 'Removing all access controls', 0),
(45, 'Regular patching and updates', 1),
(45, 'Ignoring security alerts', 0),
(45, 'Using default passwords', 0),
(45, 'Disabling logging', 0),

-- Module 10 Options (Questions 46-50)
(46, 'Password and username combination', 1),
(46, 'IP address filtering only', 0),
(46, 'Server location', 0),
(46, 'Application version', 0),
(47, 'Multiple verification factors', 1),
(47, 'A longer password', 0),
(47, 'Faster login speed', 0),
(47, 'Fewer login attempts', 0),
(48, 'What actions are allowed or denied', 1),
(48, 'Server hardware specifications', 0),
(48, 'Network bandwidth limits', 0),
(48, 'Application color themes', 0),
(49, 'Log in once to access multiple applications', 1),
(49, 'Create multiple accounts', 0),
(49, 'Share passwords with coworkers', 0),
(49, 'Bypass all security', 0),
(50, 'User roles', 1),
(50, 'User location', 0),
(50, 'Time of day', 0),
(50, 'Device type only', 0);

-- Module 11 Options (Questions 51-55)
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(51, 'Encrypting data at rest', 1),
(51, 'Compressing files for storage', 0),
(51, 'Backing up to tape drives', 0),
(51, 'Hashing passwords', 0),
(52, 'In transit', 1),
(52, 'At rest', 0),
(52, 'In use', 0),
(52, 'In archive', 0),
(53, 'Managing encryption keys centrally', 1),
(53, 'Storing passwords in code', 0),
(53, 'Generating random numbers', 0),
(53, 'Compressing encrypted files', 0),
(54, 'What level of protection data needs', 1),
(54, 'How fast data can be accessed', 0),
(54, 'Who created the data', 0),
(54, 'How old the data is', 0),
(55, 'Unauthorized data exfiltration', 1),
(55, 'Slow database queries', 0),
(55, 'High CPU usage', 0),
(55, 'Network latency', 0),

-- Module 12 Options (Questions 56-60)
(56, 'European Union', 1),
(56, 'United States only', 0),
(56, 'Asia Pacific', 0),
(56, 'Africa', 0),
(57, 'Evidence of who did what and when', 1),
(57, 'Application source code', 0),
(57, 'User passwords', 0),
(57, 'Marketing analytics', 0),
(58, 'Correlate security events for threat detection', 1),
(58, 'Send marketing emails', 0),
(58, 'Manage user accounts', 0),
(58, 'Deploy applications', 0),
(59, 'Preparation', 1),
(59, 'Blame assignment', 0),
(59, 'System shutdown', 0),
(59, 'Password reset', 0),
(60, 'Known security weaknesses', 1),
(60, 'Performance bottlenecks', 0),
(60, 'Code syntax errors', 0),
(60, 'Missing documentation', 0);

-- Module 13 Options (Questions 61-65)
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(61, 'A culture unifying development and operations', 1),
(61, 'A specific programming language', 0),
(61, 'A cloud provider', 0),
(61, 'A type of database', 0),
(62, 'Kaizen philosophy', 1),
(62, 'Waterfall methodology', 0),
(62, 'Six Sigma', 0),
(62, 'PRINCE2', 0),
(63, 'Improving collaboration between teams', 1),
(63, 'Firing underperforming staff', 0),
(63, 'Outsourcing all development', 0),
(63, 'Removing QA entirely', 0),
(64, 'Version control', 1),
(64, 'Database management', 0),
(64, 'Load balancing', 0),
(64, 'Container orchestration', 0),
(65, 'Software delivery performance', 1),
(65, 'Hardware specifications', 0),
(65, 'Office space utilization', 0),
(65, 'Employee satisfaction only', 0),

-- Module 14 Options (Questions 66-70)
(66, 'Automatically building and testing on every commit', 1),
(66, 'Deploying directly to production without tests', 0),
(66, 'Writing code once and never changing it', 0),
(66, 'Manual code reviews only', 0),
(67, 'Automatic release to production', 1),
(67, 'Manual approval before release', 0),
(67, 'Only running tests', 0),
(67, 'Building Docker images', 0),
(68, 'Test stage', 1),
(68, 'Production deployment', 0),
(68, 'Planning stage', 0),
(68, 'Design stage', 0),
(69, 'Unit tests', 1),
(69, 'End-to-end tests', 0),
(69, 'Performance tests', 0),
(69, 'Security penetration tests', 0),
(70, 'CI/CD pipeline tool', 1),
(70, 'Database migration tool', 0),
(70, 'Container registry', 0),
(70, 'Cloud monitoring service', 0);

-- Module 15 Options (Questions 71-75)
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(71, 'Manual infrastructure configuration', 1),
(71, 'Automated testing', 0),
(71, 'Container orchestration', 0),
(71, 'Code compilation', 0),
(72, 'HCL (HashiCorp Configuration Language)', 1),
(72, 'Python', 0),
(72, 'Java', 0),
(72, 'SQL', 0),
(73, 'AWS', 1),
(73, 'Azure', 0),
(73, 'Google Cloud', 0),
(73, 'All providers equally', 0),
(74, 'Configuration management', 1),
(74, 'Container building', 0),
(74, 'Load balancing', 0),
(74, 'Database queries', 0),
(75, 'Differences between desired and actual state', 1),
(75, 'Code syntax errors', 0),
(75, 'Network latency', 0),
(75, 'User behavior patterns', 0),

-- Module 16 Options (Questions 76-80)
(76, 'Infrastructure metric', 1),
(76, 'Business metric', 0),
(76, 'User experience metric', 0),
(76, 'Security metric', 0),
(77, 'Centralized logging and search', 1),
(77, 'Container orchestration', 0),
(77, 'CI/CD pipelines', 0),
(77, 'Infrastructure provisioning', 0),
(78, 'Following requests across microservices', 1),
(78, 'Debugging local applications', 0),
(78, 'Managing database connections', 0),
(78, 'Writing unit tests', 0),
(79, 'Too many non-actionable alerts', 1),
(79, 'Not enough monitoring', 0),
(79, 'Slow deployment speed', 0),
(79, 'Lack of documentation', 0),
(80, 'Target level for a service reliability metric', 1),
(80, 'A legal contract with customers', 0),
(80, 'A deployment schedule', 0),
(80, 'A type of load balancer', 0);

-- Module 17 Options (Questions 81-85)
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(81, 'Collection', 1),
(81, 'Archival', 0),
(81, 'Analysis', 0),
(81, 'Deletion', 0),
(82, 'Data is transformed after loading', 1),
(82, 'Data is never transformed', 0),
(82, 'Data is transformed before extraction', 0),
(82, 'ETL and ELT are identical', 0),
(83, 'Accuracy and completeness', 1),
(83, 'File size only', 0),
(83, 'Storage location', 0),
(83, 'Creation date', 0),
(84, 'Policies for managing data assets', 1),
(84, 'Database backup schedules', 0),
(84, 'Network security rules', 0),
(84, 'Application deployment plans', 0),
(85, 'Columnar analytical queries', 1),
(85, 'Real-time streaming', 0),
(85, 'Simple text storage', 0),
(85, 'Image processing', 0),

-- Module 18 Options (Questions 86-90)
(86, 'Relational databases', 1),
(86, 'Container orchestration', 0),
(86, 'Serverless functions', 0),
(86, 'Virtual machines', 0),
(87, 'NoSQL key-value and document store', 1),
(87, 'Relational SQL database', 0),
(87, 'File storage system', 0),
(87, 'Message queue', 0),
(88, 'In-memory caching with low latency', 1),
(88, 'Long-term archival storage', 0),
(88, 'Batch data processing', 0),
(88, 'Video streaming', 0),
(89, 'Scaling read-heavy workloads', 1),
(89, 'Increasing write speed', 0),
(89, 'Reducing storage costs', 0),
(89, 'Encrypting data', 0),
(90, 'Cloud migration or lift-and-shift', 1),
(90, 'Database deletion', 0),
(90, 'Schema redesign only', 0),
(90, 'Data compression', 0);

-- Module 19 Options (Questions 91-95)
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(91, 'In large volumes at scheduled intervals', 1),
(91, 'One record at a time in real-time', 0),
(91, 'Only when manually triggered', 0),
(91, 'Continuously without any schedule', 0),
(92, 'Real-time event streaming', 1),
(92, 'Batch file processing', 0),
(92, 'Static web hosting', 0),
(92, 'Email delivery', 0),
(93, 'Loose coupling between components', 1),
(93, 'Tight integration with databases', 0),
(93, 'Synchronous processing only', 0),
(93, 'Reduced system complexity', 0),
(94, 'Workflow orchestration', 1),
(94, 'Real-time streaming', 0),
(94, 'Container deployment', 0),
(94, 'Network routing', 0),
(95, 'Each event is processed only once', 1),
(95, 'Events are processed at least twice', 0),
(95, 'Events may be lost', 0),
(95, 'Events are processed in random order', 0),

-- Module 20 Options (Questions 96-100)
(96, 'Fact tables surrounded by dimension tables', 1),
(96, 'A single flat table', 0),
(96, 'Graph nodes and edges', 0),
(96, 'JSON documents', 0),
(97, 'Google Cloud Platform', 1),
(97, 'Amazon Web Services', 0),
(97, 'Microsoft Azure', 0),
(97, 'IBM Cloud', 0),
(98, 'Raw native format', 1),
(98, 'Only structured SQL tables', 0),
(98, 'Compressed ZIP archives', 0),
(98, 'Encrypted binary only', 0),
(99, 'Business Intelligence and visualization', 1),
(99, 'Database administration', 0),
(99, 'Code compilation', 0),
(99, 'Network monitoring', 0),
(100, 'Large volumes of structured training data', 1),
(100, 'Small sample datasets', 0),
(100, 'Only image data', 0),
(100, 'Real-time sensor data only', 0);

-- Module 21 Options (Questions 101-105)
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(101, '7', 1),
(101, '4', 0),
(101, '5', 0),
(101, '10', 0),
(102, 'Reliable ordered delivery', 1),
(102, 'Faster speed', 0),
(102, 'Lower overhead', 0),
(102, 'Broadcast support', 0),
(103, 'Domain names to IP addresses', 1),
(103, 'IP addresses to MAC addresses', 0),
(103, 'URLs to file paths', 0),
(103, 'Ports to protocols', 0),
(104, '254 usable addresses', 1),
(104, '256 usable addresses', 0),
(104, '128 usable addresses', 0),
(104, '512 usable addresses', 0),
(105, 'A virtual firewall for instances', 1),
(105, 'A physical router', 0),
(105, 'A DNS server', 0),
(105, 'A load balancer', 0),

-- Module 22 Options (Questions 106-110)
(106, 'An isolated virtual network in the cloud', 1),
(106, 'A physical data center', 0),
(106, 'A container runtime', 0),
(106, 'A monitoring service', 0),
(107, 'Direct route to the internet gateway', 1),
(107, 'Any network connectivity', 0),
(107, 'Access to other subnets', 0),
(107, 'A route table', 0),
(108, 'Where network traffic is directed', 1),
(108, 'How fast traffic moves', 0),
(108, 'Who can access the network', 0),
(108, 'What data is encrypted', 0),
(109, 'Return traffic must be explicitly allowed', 1),
(109, 'They remember connection state', 0),
(109, 'They only filter outbound traffic', 0),
(109, 'They are applied at instance level', 0),
(110, 'Private communication between VPCs', 1),
(110, 'Public internet access', 0),
(110, 'Database replication', 0),
(110, 'Container networking', 0);

-- Module 23 Options (Questions 111-115)
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(111, 'Layer 7 (Application)', 1),
(111, 'Layer 4 (Transport)', 0),
(111, 'Layer 3 (Network)', 0),
(111, 'Layer 2 (Data Link)', 0),
(112, 'High-performance TCP/UDP traffic', 1),
(112, 'HTTP-only web traffic', 0),
(112, 'Email delivery', 0),
(112, 'File transfer only', 0),
(113, 'Their geographic location', 1),
(113, 'Their subscription plan', 0),
(113, 'Their browser type', 0),
(113, 'Their device model', 0),
(114, 'Cache content close to end users', 1),
(114, 'Store databases', 0),
(114, 'Run serverless functions', 0),
(114, 'Manage DNS records', 0),
(115, 'Offloads encryption processing from backend servers', 1),
(115, 'Encrypts data at rest', 0),
(115, 'Blocks all HTTPS traffic', 0),
(115, 'Replaces firewalls', 0),

-- Module 24 Options (Questions 116-120)
(116, 'On-premises network to cloud VPC', 1),
(116, 'Two public websites', 0),
(116, 'Two mobile apps', 0),
(116, 'A database to a cache', 0),
(117, 'Dedicated private connection with consistent performance', 1),
(117, 'Faster internet browsing', 0),
(117, 'Free data transfer', 0),
(117, 'Automatic failover', 0),
(118, 'Directly between networks without traversing the public internet', 1),
(118, 'Through a VPN tunnel only', 0),
(118, 'Via satellite', 0),
(118, 'Using email protocols', 0),
(119, 'Hub-and-spoke network architecture', 1),
(119, 'Peer-to-peer mesh', 0),
(119, 'Ring topology', 0),
(119, 'Bus topology', 0),
(120, 'Different APIs and networking models per provider', 1),
(120, 'Identical configurations everywhere', 0),
(120, 'No security concerns', 0),
(120, 'Free data transfer between clouds', 0);

-- Module 25 Options (Questions 121-125)
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(121, 'No server management required by the developer', 1),
(121, 'There are no servers involved at all', 0),
(121, 'Servers are free to use', 0),
(121, 'Only one server is used', 0),
(122, 'Function as a Service (FaaS)', 1),
(122, 'Infrastructure as a Service', 0),
(122, 'Platform as a Service', 0),
(122, 'Software as a Service', 0),
(123, 'Events like API calls, queues, or schedules', 1),
(123, 'Only manual button clicks', 0),
(123, 'Only at midnight daily', 0),
(123, 'Only from the command line', 0),
(124, 'Event-driven APIs and data processing', 1),
(124, 'Running a 24/7 game server', 0),
(124, 'Large monolithic applications', 0),
(124, 'Real-time video encoding only', 0),
(125, 'Latency on first function invocation after idle', 1),
(125, 'Server hardware failure', 0),
(125, 'Network congestion', 0),
(125, 'Database timeout', 0),

-- Module 26 Options (Questions 126-130)
(126, 'Application code and all its dependencies', 1),
(126, 'Only the operating system', 0),
(126, 'Only configuration files', 0),
(126, 'Hardware drivers', 0),
(127, 'Instructions to build a container image', 1),
(127, 'A running container instance', 0),
(127, 'A container registry', 0),
(127, 'A Kubernetes cluster', 0),
(128, 'Container images for distribution', 1),
(128, 'Running containers', 0),
(128, 'Source code repositories', 0),
(128, 'Virtual machines', 0),
(129, 'Final image size by separating build and runtime', 1),
(129, 'Build speed only', 0),
(129, 'Network performance', 0),
(129, 'Database queries', 0),
(130, 'Communication between containers and external services', 1),
(130, 'File compression', 0),
(130, 'Code compilation', 0),
(130, 'User authentication', 0);

-- Module 27 Options (Questions 131-135)
INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect) VALUES
(131, 'API server, scheduler, and etcd', 1),
(131, 'Worker nodes only', 0),
(131, 'Docker engine', 0),
(131, 'Load balancer and CDN', 0),
(132, 'The smallest deployable unit', 1),
(132, 'A virtual machine', 0),
(132, 'A container registry', 0),
(132, 'A network namespace', 0),
(133, 'Stable network endpoint for a set of Pods', 1),
(133, 'A type of storage volume', 0),
(133, 'A deployment strategy', 0),
(133, 'A monitoring agent', 0),
(134, 'CPU or custom metrics', 1),
(134, 'Number of developers', 0),
(134, 'Time of day only', 0),
(134, 'Manual triggers only', 0),
(135, 'Packaging and deploying Kubernetes applications', 1),
(135, 'Building Docker images', 0),
(135, 'Managing cloud billing', 0),
(135, 'Writing unit tests', 0),

-- Module 28 Options (Questions 136-140)
(136, 'Multi-step workflows with state machines', 1),
(136, 'Single function executions', 0),
(136, 'Database migrations', 0),
(136, 'Network routing', 0),
(137, 'Serverless event bus for routing events', 1),
(137, 'A message queue', 0),
(137, 'A load balancer', 0),
(137, 'A container registry', 0),
(138, 'Request routing, auth, and throttling', 1),
(138, 'Database connection pooling', 0),
(138, 'File storage', 0),
(138, 'Email sending', 0),
(139, 'Database capacity based on demand', 1),
(139, 'Network bandwidth', 0),
(139, 'Number of API endpoints', 0),
(139, 'Storage encryption level', 0),
(140, 'Cold start latency', 1),
(140, 'Network timeout', 0),
(140, 'Database deadlock', 0),
(140, 'Memory leak', 0);

PRINT '560 AnswerOptions inserted (4 per question).';
GO

-- ============================================================
-- STEP 9: INSERT PRACTICE QUESTIONS (10 per module = 280 total)
-- Schema: PracticeQuestionID, ModuleID, QuestionText, OrderIndex, CreatedByInstructorID
-- NOTE: NO QuestionType or CorrectAnswer columns in PracticeQuestions table
-- ============================================================

SET IDENTITY_INSERT PracticeQuestions ON;

-- Module 1 Practice Questions
INSERT INTO PracticeQuestions (PracticeQuestionID, ModuleID, QuestionText, OrderIndex, CreatedByInstructorID) VALUES
(1, 1, 'Which NIST characteristic describes the ability to provision resources without human interaction?', 1, 2),
(2, 1, 'What type of cloud computing service provides virtual machines?', 2, 2),
(3, 1, 'Which is NOT a benefit of cloud computing?', 3, 2),
(4, 1, 'Cloud computing resources are accessed primarily through what?', 4, 2),
(5, 1, 'Resource pooling means what in cloud computing?', 5, 2),
(6, 1, 'Which company launched AWS in 2006?', 6, 2),
(7, 1, 'Measured service in cloud means what?', 7, 2),
(8, 1, 'Rapid elasticity allows what?', 8, 2),
(9, 1, 'Which is a characteristic of cloud computing?', 9, 2),
(10, 1, 'Before cloud computing, businesses primarily used what?', 10, 2),

-- Module 2 Practice Questions
(11, 2, 'Which service model gives you the most control?', 1, 2),
(12, 2, 'In PaaS, who manages the operating system?', 2, 2),
(13, 2, 'Gmail is an example of which service model?', 3, 2),
(14, 2, 'Which model requires the customer to manage applications?', 4, 2),
(15, 2, 'EC2 instances are an example of which model?', 5, 2),
(16, 2, 'Who patches the OS in a SaaS model?', 6, 2),
(17, 2, 'Heroku is an example of which service model?', 7, 2),
(18, 2, 'Which model has the least customer responsibility?', 8, 2),
(19, 2, 'Database-as-a-Service falls under which model?', 9, 2),
(20, 2, 'The shared responsibility model divides duties between whom?', 10, 2),

-- Module 3 Practice Questions
(21, 3, 'A public cloud is owned by whom?', 1, 2),
(22, 3, 'Which deployment model offers the highest security control?', 2, 2),
(23, 3, 'Hybrid cloud requires what between environments?', 3, 2),
(24, 3, 'Multi-cloud uses services from how many providers?', 4, 2),
(25, 3, 'Which deployment model is typically most cost-effective for startups?', 5, 2),
(26, 3, 'Community cloud is shared by organizations with what?', 6, 2),
(27, 3, 'Data sovereignty concerns are best addressed by which model?', 7, 2),
(28, 3, 'Which model allows bursting to public cloud during peak demand?', 8, 2),
(29, 3, 'A private cloud can be hosted where?', 9, 2),
(30, 3, 'Vendor lock-in is a concern primarily with which strategy?', 10, 2);

-- Module 4 Practice Questions
INSERT INTO PracticeQuestions (PracticeQuestionID, ModuleID, QuestionText, OrderIndex, CreatedByInstructorID) VALUES
(31, 4, 'What pricing model charges by the second or hour?', 1, 2),
(32, 4, 'Savings Plans offer discounts for committing to what?', 2, 2),
(33, 4, 'Which instance type can be interrupted by the provider?', 3, 2),
(34, 4, 'Cost allocation tags help with what?', 4, 2),
(35, 4, 'CapEx refers to what type of spending?', 5, 2),
(36, 4, 'OpEx refers to what type of spending?', 6, 2),
(37, 4, 'Right-sizing recommendations are based on what?', 7, 2),
(38, 4, 'Which tool helps visualize AWS spending?', 8, 2),
(39, 4, 'Reserved capacity is best for what type of workload?', 9, 2),
(40, 4, 'Cloud TCO calculators compare what?', 10, 2),

-- Module 5 Practice Questions
(41, 5, 'Vertical scaling means what?', 1, 2),
(42, 5, 'Which scaling type adds more machines?', 2, 2),
(43, 5, 'Stateless applications are easier to do what?', 3, 2),
(44, 5, 'Elasticity and scalability differ how?', 4, 2),
(45, 5, 'Fault tolerance requires what type of design?', 5, 2),
(46, 5, 'Which pattern reduces dependency between components?', 6, 2),
(47, 5, 'Circuit breaker pattern prevents what?', 7, 2),
(48, 5, 'Idempotent operations can be what?', 8, 2),
(49, 5, 'Eventual consistency means what?', 9, 2),
(50, 5, 'Which theorem states you can only have 2 of 3: Consistency, Availability, Partition tolerance?', 10, 2),

-- Module 6 Practice Questions
(51, 6, 'How many AZs does a typical AWS region have?', 1, 2),
(52, 6, 'Multi-AZ deployment provides what?', 2, 2),
(53, 6, 'RTO stands for what?', 3, 2),
(54, 6, 'A pilot light DR strategy keeps what running?', 4, 2),
(55, 6, 'Warm standby means what?', 5, 2),
(56, 6, 'Which has the lowest RTO: backup/restore or multi-site?', 6, 2),
(57, 6, 'Cross-region replication protects against what?', 7, 2),
(58, 6, 'Health checks should test what?', 8, 2),
(59, 6, 'Auto-healing replaces what automatically?', 9, 2),
(60, 6, 'SLA uptime of 99.99% allows how much downtime per year?', 10, 2),

-- Module 7 Practice Questions
(61, 7, 'Microservices communicate through what?', 1, 2),
(62, 7, 'Each microservice should own what?', 2, 2),
(63, 7, 'Saga pattern handles what across services?', 3, 2),
(64, 7, 'CQRS separates what two operations?', 4, 2),
(65, 7, 'Service mesh provides what?', 5, 2),
(66, 7, 'Sidecar proxy pattern does what?', 6, 2),
(67, 7, 'API versioning prevents what?', 7, 2),
(68, 7, 'Event sourcing stores what instead of current state?', 8, 2),
(69, 7, 'Strangler fig pattern is used for what?', 9, 2),
(70, 7, 'Backend for Frontend (BFF) pattern serves what purpose?', 10, 2);

-- Module 8-14 Practice Questions
INSERT INTO PracticeQuestions (PracticeQuestionID, ModuleID, QuestionText, OrderIndex, CreatedByInstructorID) VALUES
(71, 8, 'What tool shows underutilized resources?', 1, 2),
(72, 8, 'Predictive scaling uses what to forecast demand?', 2, 2),
(73, 8, 'Cache hit ratio measures what?', 3, 2),
(74, 8, 'TTL in caching stands for what?', 4, 2),
(75, 8, 'CDN cache invalidation does what?', 5, 2),
(76, 8, 'Lazy loading in caching means what?', 6, 2),
(77, 8, 'Write-through caching does what?', 7, 2),
(78, 8, 'Gzip compression reduces what?', 8, 2),
(79, 8, 'Connection pooling improves what?', 9, 2),
(80, 8, 'Stress testing goes beyond what?', 10, 2),
(81, 9, 'The A in CIA triad stands for what?', 1, 2),
(82, 9, 'Zero trust security assumes what?', 2, 2),
(83, 9, 'Network segmentation limits what?', 3, 2),
(84, 9, 'WAF protects against what?', 4, 2),
(85, 9, 'Penetration testing simulates what?', 5, 2),
(86, 9, 'Security groups are stateful meaning what?', 6, 2),
(87, 9, 'DDoS attacks aim to do what?', 7, 2),
(88, 9, 'Principle of least privilege reduces what?', 8, 2),
(89, 9, 'Security patches should be applied how often?', 9, 2),
(90, 9, 'Encryption converts plaintext to what?', 10, 2),
(91, 10, 'OAuth 2.0 is used for what?', 1, 2),
(92, 10, 'A JWT token contains what?', 2, 2),
(93, 10, 'SAML is primarily used for what?', 3, 2),
(94, 10, 'Hardware security keys provide what type of MFA?', 4, 2),
(95, 10, 'Conditional access policies evaluate what?', 5, 2),
(96, 10, 'Service accounts are used by what?', 6, 2),
(97, 10, 'API keys should be stored where?', 7, 2),
(98, 10, 'Identity federation allows what?', 8, 2),
(99, 10, 'Privilege escalation is what type of attack?', 9, 2),
(100, 10, 'Session tokens should expire after what?', 10, 2);

-- Module 11-14 Practice Questions
INSERT INTO PracticeQuestions (PracticeQuestionID, ModuleID, QuestionText, OrderIndex, CreatedByInstructorID) VALUES
(101, 11, 'Symmetric encryption uses how many keys?', 1, 2),
(102, 11, 'Asymmetric encryption uses a key pair of what?', 2, 2),
(103, 11, 'HSM stands for what?', 3, 2),
(104, 11, 'Key rotation frequency should be what?', 4, 2),
(105, 11, 'Envelope encryption uses what approach?', 5, 2),
(106, 11, 'Data at rest includes data stored where?', 6, 2),
(107, 11, 'PII stands for what?', 7, 2),
(108, 11, 'Tokenization replaces sensitive data with what?', 8, 2),
(109, 11, 'Data masking is used for what?', 9, 2),
(110, 11, 'Certificate pinning prevents what?', 10, 2),
(111, 12, 'SOC 2 Type II audits what?', 1, 2),
(112, 12, 'HIPAA protects what type of data?', 2, 2),
(113, 12, 'PCI DSS applies to what?', 3, 2),
(114, 12, 'CloudTrail logs what in AWS?', 4, 2),
(115, 12, 'A SIEM correlates events from what?', 5, 2),
(116, 12, 'Incident response teams are called what?', 6, 2),
(117, 12, 'Chain of custody is important for what?', 7, 2),
(118, 12, 'Threat modeling identifies what?', 8, 2),
(119, 12, 'Red team exercises simulate what?', 9, 2),
(120, 12, 'Compliance as code automates what?', 10, 2),
(121, 13, 'The three ways of DevOps include what?', 1, 2),
(122, 13, 'Value stream mapping visualizes what?', 2, 2),
(123, 13, 'Blameless postmortems focus on what?', 3, 2),
(124, 13, 'ChatOps integrates tools with what?', 4, 2),
(125, 13, 'Lead time measures what?', 5, 2),
(126, 13, 'Change failure rate measures what?', 6, 2),
(127, 13, 'MTTR stands for what?', 7, 2),
(128, 13, 'Deployment frequency indicates what?', 8, 2),
(129, 13, 'DevSecOps integrates what into DevOps?', 9, 2),
(130, 13, 'Platform engineering provides what to developers?', 10, 2);

-- Module 14-17 Practice Questions
INSERT INTO PracticeQuestions (PracticeQuestionID, ModuleID, QuestionText, OrderIndex, CreatedByInstructorID) VALUES
(131, 14, 'A build artifact is what?', 1, 2),
(132, 14, 'Blue-green deployment uses what?', 2, 2),
(133, 14, 'Canary deployment releases to what percentage first?', 3, 2),
(134, 14, 'Rolling deployment updates instances how?', 4, 2),
(135, 14, 'Feature flags allow what?', 5, 2),
(136, 14, 'Trunk-based development uses how many long-lived branches?', 6, 2),
(137, 14, 'GitFlow uses which main branches?', 7, 2),
(138, 14, 'Pipeline as code stores pipeline config where?', 8, 2),
(139, 14, 'Artifact registry stores what?', 9, 2),
(140, 14, 'Smoke tests verify what?', 10, 2),
(141, 15, 'Terraform state file tracks what?', 1, 2),
(142, 15, 'Terraform plan shows what?', 2, 2),
(143, 15, 'Modules in Terraform provide what?', 3, 2),
(144, 15, 'CloudFormation stacks group what?', 4, 2),
(145, 15, 'Ansible playbooks describe what?', 5, 2),
(146, 15, 'Idempotency in IaC means what?', 6, 2),
(147, 15, 'Remote state storage prevents what?', 7, 2),
(148, 15, 'Terraform providers connect to what?', 8, 2),
(149, 15, 'Infrastructure testing tools like Terratest do what?', 9, 2),
(150, 15, 'GitOps manages infrastructure through what?', 10, 2),
(151, 16, 'Prometheus is used for what?', 1, 2),
(152, 16, 'Grafana provides what?', 2, 2),
(153, 16, 'OpenTelemetry standardizes what?', 3, 2),
(154, 16, 'Log levels include which severity?', 4, 2),
(155, 16, 'Structured logging uses what format?', 5, 2),
(156, 16, 'APM stands for what?', 6, 2),
(157, 16, 'Synthetic monitoring simulates what?', 7, 2),
(158, 16, 'Error budget is consumed by what?', 8, 2),
(159, 16, 'On-call rotation ensures what?', 9, 2),
(160, 16, 'Runbooks document what?', 10, 2),
(161, 17, 'A data pipeline transforms data from what to what?', 1, 2),
(162, 17, 'Schema-on-read means what?', 2, 2),
(163, 17, 'Data lineage tracks what?', 3, 2),
(164, 17, 'A data catalog provides what?', 4, 2),
(165, 17, 'Data profiling analyzes what?', 5, 2),
(166, 17, 'Master data management ensures what?', 6, 2),
(167, 17, 'Data deduplication removes what?', 7, 2),
(168, 17, 'CDC stands for what in data engineering?', 8, 2),
(169, 17, 'Data validation ensures what?', 9, 2),
(170, 17, 'Idempotent pipelines can be what?', 10, 2);

-- Module 18-21 Practice Questions
INSERT INTO PracticeQuestions (PracticeQuestionID, ModuleID, QuestionText, OrderIndex, CreatedByInstructorID) VALUES
(171, 18, 'ACID properties apply to what type of database?', 1, 2),
(172, 18, 'BASE properties apply to what type of database?', 2, 2),
(173, 18, 'A document database stores data as what?', 3, 2),
(174, 18, 'Graph databases excel at what type of query?', 4, 2),
(175, 18, 'Connection pooling helps with what?', 5, 2),
(176, 18, 'Database indexing speeds up what?', 6, 2),
(177, 18, 'Multi-region database deployment provides what?', 7, 2),
(178, 18, 'Database snapshots are used for what?', 8, 2),
(179, 18, 'Vertical scaling of a database means what?', 9, 2),
(180, 18, 'Eventual consistency trade-off gives what benefit?', 10, 2),
(181, 19, 'Apache Spark is used for what?', 1, 2),
(182, 19, 'Kafka partitions provide what?', 2, 2),
(183, 19, 'Consumer groups in Kafka allow what?', 3, 2),
(184, 19, 'Backpressure in streaming handles what?', 4, 2),
(185, 19, 'Tumbling windows in stream processing do what?', 5, 2),
(186, 19, 'Dead letter queues store what?', 6, 2),
(187, 19, 'Checkpointing in streaming ensures what?', 7, 2),
(188, 19, 'Micro-batching is a compromise between what?', 8, 2),
(189, 19, 'Event time vs processing time differs how?', 9, 2),
(190, 19, 'Schema registry enforces what?', 10, 2),
(191, 20, 'OLAP is optimized for what?', 1, 2),
(192, 20, 'OLTP is optimized for what?', 2, 2),
(193, 20, 'Materialized views pre-compute what?', 3, 2),
(194, 20, 'Data lake vs data warehouse differs how?', 4, 2),
(195, 20, 'Lakehouse architecture combines what?', 5, 2),
(196, 20, 'Partitioning in a warehouse helps with what?', 6, 2),
(197, 20, 'Slowly changing dimensions track what?', 7, 2),
(198, 20, 'ETL pipelines for warehouses run when?', 8, 2),
(199, 20, 'Feature stores serve what purpose for ML?', 9, 2),
(200, 20, 'Data mesh decentralizes what?', 10, 2),
(201, 21, 'Layer 4 of OSI is what?', 1, 2),
(202, 21, 'A subnet mask determines what?', 2, 2),
(203, 21, 'NAT allows what?', 3, 2),
(204, 21, 'DHCP automatically assigns what?', 4, 2),
(205, 21, 'A default gateway is what?', 5, 2),
(206, 21, 'Port 443 is used for what?', 6, 2),
(207, 21, 'ARP resolves what to what?', 7, 2),
(208, 21, 'ICMP is used by what common tool?', 8, 2),
(209, 21, 'IPv6 addresses are how many bits?', 9, 2),
(210, 21, 'A VLAN segments what?', 10, 2);

-- Module 22-25 Practice Questions
INSERT INTO PracticeQuestions (PracticeQuestionID, ModuleID, QuestionText, OrderIndex, CreatedByInstructorID) VALUES
(211, 22, 'A VPC CIDR block defines what?', 1, 2),
(212, 22, 'Internet Gateway enables what?', 2, 2),
(213, 22, 'NAT Gateway allows private subnets to do what?', 3, 2),
(214, 22, 'Elastic IP is what type of address?', 4, 2),
(215, 22, 'Flow logs capture what?', 5, 2),
(216, 22, 'Bastion host provides what?', 6, 2),
(217, 22, 'VPC endpoints allow private access to what?', 7, 2),
(218, 22, 'Subnet CIDR must be within what?', 8, 2),
(219, 22, 'Security groups are attached to what?', 9, 2),
(220, 22, 'Multi-AZ subnet design provides what?', 10, 2),
(221, 23, 'Sticky sessions route requests to what?', 1, 2),
(222, 23, 'Health check interval determines what?', 2, 2),
(223, 23, 'Cross-zone load balancing distributes across what?', 3, 2),
(224, 23, 'WAF can be attached to what?', 4, 2),
(225, 23, 'Origin shield in CDN reduces what?', 5, 2),
(226, 23, 'Cache-Control headers instruct what?', 6, 2),
(227, 23, 'Global Accelerator improves what?', 7, 2),
(228, 23, 'Weighted routing distributes traffic how?', 8, 2),
(229, 23, 'DNS failover routing requires what?', 9, 2),
(230, 23, 'Lambda@Edge runs functions where?', 10, 2),
(231, 24, 'IPSec VPN encrypts traffic at what layer?', 1, 2),
(232, 24, 'Direct Connect bandwidth options range from what?', 2, 2),
(233, 24, 'A virtual private gateway connects to what?', 3, 2),
(234, 24, 'BGP is used for what in hybrid networking?', 4, 2),
(235, 24, 'Transit Gateway attachment connects what?', 5, 2),
(236, 24, 'SD-WAN optimizes what?', 6, 2),
(237, 24, 'Data transfer costs between clouds are what?', 7, 2),
(238, 24, 'A hub VPC in transit gateway serves what role?', 8, 2),
(239, 24, 'Cloud interconnect services provide what?', 9, 2),
(240, 24, 'Network latency between regions affects what?', 10, 2),
(241, 25, 'Lambda execution timeout maximum is what?', 1, 2),
(242, 25, 'Serverless concurrency limits control what?', 2, 2),
(243, 25, 'Event source mapping connects what to Lambda?', 3, 2),
(244, 25, 'Serverless framework helps with what?', 4, 2),
(245, 25, 'Lambda layers share what across functions?', 5, 2),
(246, 25, 'Provisioned concurrency keeps functions in what state?', 6, 2),
(247, 25, 'Dead letter queue catches what?', 7, 2),
(248, 25, 'API Gateway stages represent what?', 8, 2),
(249, 25, 'Serverless pricing is based on what?', 9, 2),
(250, 25, 'Environment variables in Lambda store what?', 10, 2);

-- Module 26-28 Practice Questions
INSERT INTO PracticeQuestions (PracticeQuestionID, ModuleID, QuestionText, OrderIndex, CreatedByInstructorID) VALUES
(251, 26, 'Docker Hub is what type of service?', 1, 2),
(252, 26, 'A container image is built from what?', 2, 2),
(253, 26, 'Docker Compose manages what?', 3, 2),
(254, 26, 'Container vs VM: containers share what?', 4, 2),
(255, 26, 'ENTRYPOINT in Dockerfile defines what?', 5, 2),
(256, 26, 'Docker volumes persist what?', 6, 2),
(257, 26, 'Container health checks verify what?', 7, 2),
(258, 26, '.dockerignore excludes what from builds?', 8, 2),
(259, 26, 'Alpine-based images are popular because of what?', 9, 2),
(260, 26, 'Docker layer caching speeds up what?', 10, 2),
(261, 27, 'kubectl is used for what?', 1, 2),
(262, 27, 'A Namespace in K8s provides what?', 2, 2),
(263, 27, 'ConfigMaps store what?', 3, 2),
(264, 27, 'Secrets in K8s store what?', 4, 2),
(265, 27, 'A DaemonSet ensures what?', 5, 2),
(266, 27, 'StatefulSet is used for what type of application?', 6, 2),
(267, 27, 'PersistentVolumeClaim requests what?', 7, 2),
(268, 27, 'Liveness probe determines what?', 8, 2),
(269, 27, 'Readiness probe determines what?', 9, 2),
(270, 27, 'Network policies in K8s control what?', 10, 2),
(271, 28, 'AWS Step Functions use what language for definitions?', 1, 2),
(272, 28, 'EventBridge rules match events based on what?', 2, 2),
(273, 28, 'API Gateway throttling prevents what?', 3, 2),
(274, 28, 'DynamoDB on-demand mode scales what automatically?', 4, 2),
(275, 28, 'SQS FIFO queues guarantee what?', 5, 2),
(276, 28, 'SNS fan-out pattern distributes messages to what?', 6, 2),
(277, 28, 'Serverless WebSocket APIs maintain what?', 7, 2),
(278, 28, 'Power tuning Lambda finds the optimal what?', 8, 2),
(279, 28, 'X-Ray traces help debug what?', 9, 2),
(280, 28, 'Serverless application model (SAM) simplifies what?', 10, 2);

SET IDENTITY_INSERT PracticeQuestions OFF;
PRINT '280 PracticeQuestions inserted (10 per module).';
GO

-- ============================================================
-- STEP 10: INSERT PRACTICE QUESTION OPTIONS (4 per question = 1120 total)
-- Schema: OptionID (identity), PracticeQuestionID, OptionText, IsCorrect
-- ============================================================

-- Module 1 Practice Options (PQ 1-10)
INSERT INTO PracticeQuestionOptions (PracticeQuestionID, OptionText, IsCorrect) VALUES
(1, 'On-demand self-service', 1), (1, 'Broad network access', 0), (1, 'Resource pooling', 0), (1, 'Measured service', 0),
(2, 'IaaS', 1), (2, 'SaaS', 0), (2, 'PaaS', 0), (2, 'FaaS', 0),
(3, 'Guaranteed zero downtime', 1), (3, 'Cost savings', 0), (3, 'Scalability', 0), (3, 'Flexibility', 0),
(4, 'The internet', 1), (4, 'USB cables', 0), (4, 'Bluetooth', 0), (4, 'Physical disks', 0),
(5, 'Multiple tenants share the same physical resources', 1), (5, 'Each user gets a dedicated server', 0), (5, 'Resources cannot be shared', 0), (5, 'Only storage is shared', 0),
(6, 'Amazon', 1), (6, 'Microsoft', 0), (6, 'Google', 0), (6, 'IBM', 0),
(7, 'Usage is monitored and billed accordingly', 1), (7, 'Services are free', 0), (7, 'Fixed monthly charges', 0), (7, 'No monitoring exists', 0),
(8, 'Quick scaling up and down of resources', 1), (8, 'Only scaling up', 0), (8, 'Manual scaling only', 0), (8, 'Fixed resource allocation', 0),
(9, 'Broad network access', 1), (9, 'Requires physical presence', 0), (9, 'Only works on LAN', 0), (9, 'Needs special hardware', 0),
(10, 'On-premises data centers', 1), (10, 'Cloud computing', 0), (10, 'Serverless functions', 0), (10, 'Mobile apps', 0),

-- Module 2 Practice Options (PQ 11-20)
(11, 'IaaS', 1), (11, 'PaaS', 0), (11, 'SaaS', 0), (11, 'FaaS', 0),
(12, 'The cloud provider', 1), (12, 'The customer', 0), (12, 'A third party', 0), (12, 'Nobody', 0),
(13, 'SaaS', 1), (13, 'IaaS', 0), (13, 'PaaS', 0), (13, 'BaaS', 0),
(14, 'IaaS', 1), (14, 'SaaS', 0), (14, 'PaaS', 0), (14, 'None of them', 0),
(15, 'IaaS', 1), (15, 'PaaS', 0), (15, 'SaaS', 0), (15, 'DaaS', 0),
(16, 'The cloud provider', 1), (16, 'The customer', 0), (16, 'Shared responsibility', 0), (16, 'A contractor', 0),
(17, 'PaaS', 1), (17, 'IaaS', 0), (17, 'SaaS', 0), (17, 'CaaS', 0),
(18, 'SaaS', 1), (18, 'IaaS', 0), (18, 'PaaS', 0), (18, 'FaaS', 0),
(19, 'PaaS', 1), (19, 'SaaS', 0), (19, 'IaaS', 0), (19, 'CaaS', 0),
(20, 'Cloud provider and customer', 1), (20, 'Only the customer', 0), (20, 'Only the provider', 0), (20, 'Government regulators', 0);

-- Module 3 Practice Options (PQ 21-30)
INSERT INTO PracticeQuestionOptions (PracticeQuestionID, OptionText, IsCorrect) VALUES
(21, 'A third-party cloud provider', 1), (21, 'The customer organization', 0), (21, 'The government', 0), (21, 'No one owns it', 0),
(22, 'Private cloud', 1), (22, 'Public cloud', 0), (22, 'Hybrid cloud', 0), (22, 'Community cloud', 0),
(23, 'Network connectivity between them', 1), (23, 'The same OS', 0), (23, 'Identical hardware', 0), (23, 'Same provider', 0),
(24, 'Two or more', 1), (24, 'Exactly one', 0), (24, 'None', 0), (24, 'Exactly three', 0),
(25, 'Public cloud', 1), (25, 'Private cloud', 0), (25, 'On-premises', 0), (25, 'Hybrid cloud', 0),
(26, 'Common concerns or requirements', 1), (26, 'The same office building', 0), (26, 'Identical revenue', 0), (26, 'Same number of employees', 0),
(27, 'Private cloud or hybrid with data residency', 1), (27, 'Public cloud only', 0), (27, 'Multi-cloud', 0), (27, 'Community cloud', 0),
(28, 'Hybrid cloud', 1), (28, 'Private cloud only', 0), (28, 'Public cloud only', 0), (28, 'On-premises only', 0),
(29, 'On-premises or at a third-party facility', 1), (29, 'Only on-premises', 0), (29, 'Only in public cloud', 0), (29, 'Only at home', 0),
(30, 'Single-provider public cloud', 1), (30, 'Multi-cloud', 0), (30, 'Private cloud', 0), (30, 'On-premises', 0),

-- Module 4 Practice Options (PQ 31-40)
(31, 'Pay-as-you-go / on-demand', 1), (31, 'Annual subscription', 0), (31, 'One-time purchase', 0), (31, 'Free tier only', 0),
(32, 'Consistent usage over 1-3 years', 1), (32, 'Using spot instances', 0), (32, 'Increasing usage monthly', 0), (32, 'Nothing specific', 0),
(33, 'Spot / preemptible instance', 1), (33, 'Reserved instance', 0), (33, 'On-demand instance', 0), (33, 'Dedicated host', 0),
(34, 'Categorizing and tracking costs', 1), (34, 'Improving performance', 0), (34, 'Securing data', 0), (34, 'Deploying applications', 0),
(35, 'Upfront capital expenditure', 1), (35, 'Ongoing operational cost', 0), (35, 'Variable monthly cost', 0), (35, 'Free tier usage', 0),
(36, 'Ongoing operational spending', 1), (36, 'One-time hardware purchase', 0), (36, 'Building a data center', 0), (36, 'Buying land', 0),
(37, 'Actual resource utilization metrics', 1), (37, 'Company revenue', 0), (37, 'Number of employees', 0), (37, 'Time of year', 0),
(38, 'AWS Cost Explorer', 1), (38, 'AWS Lambda', 0), (38, 'AWS EC2', 0), (38, 'AWS S3', 0),
(39, 'Steady-state predictable workloads', 1), (39, 'Highly variable workloads', 0), (39, 'Batch processing', 0), (39, 'Development environments', 0),
(40, 'On-premises vs cloud costs', 1), (40, 'Two cloud providers', 0), (40, 'Different instance types', 0), (40, 'Programming languages', 0);

-- Module 5-7 Practice Options (PQ 41-70)
INSERT INTO PracticeQuestionOptions (PracticeQuestionID, OptionText, IsCorrect) VALUES
(41, 'Adding more power to an existing machine', 1), (41, 'Adding more machines', 0), (41, 'Removing resources', 0), (41, 'Replacing the machine', 0),
(42, 'Horizontal scaling', 1), (42, 'Vertical scaling', 0), (42, 'Diagonal scaling', 0), (42, 'No scaling', 0),
(43, 'Scale horizontally', 1), (43, 'Store data locally', 0), (43, 'Require sticky sessions', 0), (43, 'Use single instances', 0),
(44, 'Elasticity is automatic, scalability may be manual', 1), (44, 'They are identical', 0), (44, 'Scalability is faster', 0), (44, 'Elasticity costs more', 0),
(45, 'Redundant components', 1), (45, 'Single points of failure', 0), (45, 'Minimal resources', 0), (45, 'No backup', 0),
(46, 'Loose coupling', 1), (46, 'Tight coupling', 0), (46, 'Direct connections', 0), (46, 'Shared state', 0),
(47, 'Cascading failures', 1), (47, 'Fast responses', 0), (47, 'Data loss', 0), (47, 'Network issues', 0),
(48, 'Repeated safely without side effects', 1), (48, 'Run only once', 0), (48, 'Never retried', 0), (48, 'Always failing', 0),
(49, 'Data will be consistent given enough time', 1), (49, 'Data is always consistent', 0), (49, 'Data is never consistent', 0), (49, 'Data is deleted eventually', 0),
(50, 'CAP theorem', 1), (50, 'ACID theorem', 0), (50, 'BASE theorem', 0), (50, 'SOA theorem', 0),
(51, '3 or more', 1), (51, 'Exactly 1', 0), (51, 'Exactly 2', 0), (51, 'More than 10', 0),
(52, 'High availability and fault tolerance', 1), (52, 'Lower cost only', 0), (52, 'Faster deployment', 0), (52, 'Better security only', 0),
(53, 'Recovery Time Objective', 1), (53, 'Real-Time Operations', 0), (53, 'Resource Transfer Option', 0), (53, 'Replication Time Order', 0),
(54, 'Minimal core infrastructure', 1), (54, 'Full production copy', 0), (54, 'Nothing at all', 0), (54, 'Only backups', 0),
(55, 'A scaled-down version of production always running', 1), (55, 'Servers are turned off', 0), (55, 'Only DNS is active', 0), (55, 'Full duplicate', 0),
(56, 'Multi-site active-active', 1), (56, 'Backup and restore', 0), (56, 'Pilot light', 0), (56, 'Cold standby', 0),
(57, 'Entire region failure', 1), (57, 'Single instance failure', 0), (57, 'Application bugs', 0), (57, 'User errors', 0),
(58, 'Application functionality end-to-end', 1), (58, 'Only CPU usage', 0), (58, 'Only disk space', 0), (58, 'Network bandwidth', 0),
(59, 'Failed or unhealthy instances', 1), (59, 'Old code versions', 0), (59, 'User accounts', 0), (59, 'Log files', 0),
(60, 'About 52 minutes', 1), (60, 'About 8 hours', 0), (60, 'Zero minutes', 0), (60, 'About 1 day', 0),
(61, 'APIs and messaging', 1), (61, 'Shared memory', 0), (61, 'Direct file access', 0), (61, 'Global variables', 0),
(62, 'Its own data store', 1), (62, 'A shared database', 0), (62, 'No data', 0), (62, 'Another services data', 0),
(63, 'Distributed transactions', 1), (63, 'Local file storage', 0), (63, 'UI rendering', 0), (63, 'DNS resolution', 0),
(64, 'Command and Query', 1), (64, 'Create and Read', 0), (64, 'Compute and Queue', 0), (64, 'Cache and Query', 0),
(65, 'Observability and traffic management between services', 1), (65, 'A type of network cable', 0), (65, 'Database connections', 0), (65, 'File sharing', 0),
(66, 'Intercepts network traffic for a service', 1), (66, 'Replaces the main service', 0), (66, 'Stores data', 0), (66, 'Manages users', 0),
(67, 'Breaking existing API consumers', 1), (67, 'Adding new features', 0), (67, 'Faster responses', 0), (67, 'Better security', 0),
(68, 'A sequence of events/changes', 1), (68, 'Only the final state', 0), (68, 'Nothing', 0), (68, 'Binary data', 0),
(69, 'Incrementally migrating from monolith to microservices', 1), (69, 'Building from scratch', 0), (69, 'Deleting old code', 0), (69, 'A type of tree', 0),
(70, 'Tailored API for each frontend type', 1), (70, 'One API for all clients', 0), (70, 'No API needed', 0), (70, 'Direct database access', 0);

-- Module 8-10 Practice Options (PQ 71-100)
INSERT INTO PracticeQuestionOptions (PracticeQuestionID, OptionText, IsCorrect) VALUES
(71, 'Cloud provider cost advisor tools', 1), (71, 'Application source code', 0), (71, 'User surveys', 0), (71, 'Marketing data', 0),
(72, 'Machine learning on historical patterns', 1), (72, 'Random guessing', 0), (72, 'User input', 0), (72, 'Fixed schedules only', 0),
(73, 'Percentage of requests served from cache', 1), (73, 'Total cache size', 0), (73, 'Cache cost', 0), (73, 'Number of cache nodes', 0),
(74, 'Time to Live', 1), (74, 'Total Transfer Limit', 0), (74, 'Token Type Level', 0), (74, 'Transmission Timeout Lag', 0),
(75, 'Removes outdated cached content', 1), (75, 'Adds more cache nodes', 0), (75, 'Encrypts cache data', 0), (75, 'Backs up the cache', 0),
(76, 'Data is only loaded into cache when requested', 1), (76, 'All data is cached upfront', 0), (76, 'Cache is never populated', 0), (76, 'Data is cached randomly', 0),
(77, 'Writes to cache and database simultaneously', 1), (77, 'Only writes to cache', 0), (77, 'Only writes to database', 0), (77, 'Writes to neither', 0),
(78, 'Response payload size', 1), (78, 'Server CPU usage', 0), (78, 'Database connections', 0), (78, 'Number of users', 0),
(79, 'Database query performance', 1), (79, 'Code compilation speed', 0), (79, 'Network cabling', 0), (79, 'Disk formatting', 0),
(80, 'Expected peak load to find breaking points', 1), (80, 'Normal operations', 0), (80, 'Cost optimization', 0), (80, 'Security testing', 0),
(81, 'Availability', 1), (81, 'Authentication', 0), (81, 'Authorization', 0), (81, 'Auditing', 0),
(82, 'No user or device is trusted by default', 1), (82, 'All internal users are trusted', 0), (82, 'Only admins need verification', 0), (82, 'Trust is based on IP', 0),
(83, 'Lateral movement of attackers', 1), (83, 'Network speed', 0), (83, 'Data storage', 0), (83, 'User signups', 0),
(84, 'Web application attacks like SQL injection', 1), (84, 'Physical theft', 0), (84, 'Email spam', 0), (84, 'Hardware failures', 0),
(85, 'Real-world attack scenarios', 1), (85, 'Code quality', 0), (85, 'User experience', 0), (85, 'Performance benchmarks', 0),
(86, 'Return traffic is automatically allowed', 1), (86, 'All traffic is blocked', 0), (86, 'Only outbound is allowed', 0), (86, 'They filter by IP only', 0),
(87, 'Overwhelm resources making services unavailable', 1), (87, 'Steal data quietly', 0), (87, 'Install malware', 0), (87, 'Modify database records', 0),
(88, 'Attack surface and potential damage', 1), (88, 'Development speed', 0), (88, 'Cost', 0), (88, 'User count', 0),
(89, 'As soon as patches are available', 1), (89, 'Once per year', 0), (89, 'Never', 0), (89, 'Only when hacked', 0),
(90, 'Ciphertext', 1), (90, 'Compressed text', 0), (90, 'Hash value', 0), (90, 'Binary code', 0),
(91, 'Delegated authorization', 1), (91, 'Password storage', 0), (91, 'File encryption', 0), (91, 'Network routing', 0),
(92, 'Claims about the user and metadata', 1), (92, 'Only the password', 0), (92, 'Database connection strings', 0), (92, 'Server IP addresses', 0),
(93, 'Enterprise single sign-on', 1), (93, 'File transfer', 0), (93, 'Database queries', 0), (93, 'Container orchestration', 0),
(94, 'Something you have (physical factor)', 1), (94, 'Something you know', 0), (94, 'Something you are', 0), (94, 'Somewhere you are', 0),
(95, 'Risk signals like location and device', 1), (95, 'Only username and password', 0), (95, 'Time of day only', 0), (95, 'Nothing', 0),
(96, 'Applications and automated processes', 1), (96, 'Only human users', 0), (96, 'Only administrators', 0), (96, 'Only guests', 0),
(97, 'In a secrets manager or vault', 1), (97, 'In source code', 0), (97, 'In environment variables in plain text', 0), (97, 'In documentation', 0),
(98, 'Using external identity providers for authentication', 1), (98, 'Merging databases', 0), (98, 'Combining networks', 0), (98, 'Sharing passwords', 0),
(99, 'Gaining higher permissions than authorized', 1), (99, 'Logging in normally', 0), (99, 'Changing password', 0), (99, 'Browsing the web', 0),
(100, 'A configured inactivity period', 1), (100, 'Never', 0), (100, 'After every click', 0), (100, 'Only on logout', 0);

-- Module 11-13 Practice Options (PQ 101-130)
INSERT INTO PracticeQuestionOptions (PracticeQuestionID, OptionText, IsCorrect) VALUES
(101, 'One key for both encrypt and decrypt', 1), (101, 'Two keys', 0), (101, 'Three keys', 0), (101, 'No keys', 0),
(102, 'Public key and private key', 1), (102, 'Two identical keys', 0), (102, 'Username and password', 0), (102, 'Token and certificate', 0),
(103, 'Hardware Security Module', 1), (103, 'High-Speed Memory', 0), (103, 'Hosted Service Manager', 0), (103, 'Hash Security Method', 0),
(104, 'Based on organizational policy, typically 90 days to 1 year', 1), (104, 'Never', 0), (104, 'Every hour', 0), (104, 'Only when compromised', 0),
(105, 'Encrypting data key with a master key', 1), (105, 'Using no encryption', 0), (105, 'Double hashing', 0), (105, 'Compressing then encrypting', 0),
(106, 'Disks, databases, and object storage', 1), (106, 'Only in transit', 0), (106, 'Only in RAM', 0), (106, 'Only in CPU cache', 0),
(107, 'Personally Identifiable Information', 1), (107, 'Private Internet Interface', 0), (107, 'Public Infrastructure Index', 0), (107, 'Primary Input Indicator', 0),
(108, 'Non-sensitive placeholder tokens', 1), (108, 'Encrypted values', 0), (108, 'Hashed values', 0), (108, 'Compressed data', 0),
(109, 'Showing only partial data in non-production environments', 1), (109, 'Deleting data', 0), (109, 'Encrypting data', 0), (109, 'Compressing data', 0),
(110, 'Man-in-the-middle attacks with fake certificates', 1), (110, 'Data loss', 0), (110, 'Slow performance', 0), (110, 'High costs', 0),
(111, 'Operating effectiveness of controls over time', 1), (111, 'Code quality', 0), (111, 'Network speed', 0), (111, 'User satisfaction', 0),
(112, 'Health information (PHI)', 1), (112, 'Financial data', 0), (112, 'Social media posts', 0), (112, 'Weather data', 0),
(113, 'Payment card data processing', 1), (113, 'Health records', 0), (113, 'Government data', 0), (113, 'Educational records', 0),
(114, 'API calls and management events', 1), (114, 'Application errors', 0), (114, 'User passwords', 0), (114, 'Network packets', 0),
(115, 'Multiple security tools and log sources', 1), (115, 'A single firewall', 0), (115, 'One server only', 0), (115, 'User feedback', 0),
(116, 'CSIRT or CERT', 1), (116, 'DevOps team', 0), (116, 'Sales team', 0), (116, 'HR department', 0),
(117, 'Digital forensics and legal proceedings', 1), (117, 'Performance optimization', 0), (117, 'Cost reduction', 0), (117, 'Marketing', 0),
(118, 'Potential threats and vulnerabilities', 1), (118, 'User preferences', 0), (118, 'Performance metrics', 0), (118, 'Cost overruns', 0),
(119, 'Real-world attacks to test defenses', 1), (119, 'Normal operations', 0), (119, 'User training', 0), (119, 'Budget planning', 0),
(120, 'Checking compliance rules automatically', 1), (120, 'Writing application code', 0), (120, 'Designing user interfaces', 0), (120, 'Managing users', 0),
(121, 'Flow, Feedback, Continuous Learning', 1), (121, 'Plan, Build, Run', 0), (121, 'Code, Test, Deploy', 0), (121, 'Design, Develop, Deliver', 0),
(122, 'The flow of work from idea to production', 1), (122, 'Network topology', 0), (122, 'Database schema', 0), (122, 'User journey', 0),
(123, 'System improvements, not individual blame', 1), (123, 'Finding who to fire', 0), (123, 'Assigning penalties', 0), (123, 'Reducing headcount', 0),
(124, 'Team chat platforms like Slack', 1), (124, 'Email only', 0), (124, 'Phone calls', 0), (124, 'Paper memos', 0),
(125, 'Time from code commit to production', 1), (125, 'Lines of code written', 0), (125, 'Number of meetings', 0), (125, 'Team size', 0),
(126, 'Percentage of deployments causing failures', 1), (126, 'Number of lines changed', 0), (126, 'Cost per deployment', 0), (126, 'Time to write code', 0),
(127, 'Mean Time to Recovery', 1), (127, 'Maximum Transfer Time Rate', 0), (127, 'Minimum Testing Time Required', 0), (127, 'Mean Throughput Rate', 0),
(128, 'How often the team ships to production', 1), (128, 'CPU frequency', 0), (128, 'Network bandwidth', 0), (128, 'Storage capacity', 0),
(129, 'Security practices', 1), (129, 'Marketing', 0), (129, 'Finance', 0), (129, 'HR processes', 0),
(130, 'Self-service internal platforms and tools', 1), (130, 'External customer support', 0), (130, 'Marketing websites', 0), (130, 'Physical infrastructure', 0);

-- Module 14-17 Practice Options (PQ 131-170)
INSERT INTO PracticeQuestionOptions (PracticeQuestionID, OptionText, IsCorrect) VALUES
(131, 'Compiled/packaged output ready for deployment', 1), (131, 'Source code', 0), (131, 'A bug report', 0), (131, 'A meeting note', 0),
(132, 'Two identical production environments', 1), (132, 'One environment with two servers', 0), (132, 'A color scheme', 0), (132, 'A testing strategy', 0),
(133, 'A small percentage like 5-10%', 1), (133, '100%', 0), (133, '50%', 0), (133, '0%', 0),
(134, 'Gradually, one batch at a time', 1), (134, 'All at once', 0), (134, 'Never', 0), (134, 'Only on weekends', 0),
(135, 'Toggling features without redeployment', 1), (135, 'Flagging code errors', 0), (135, 'Marking files as important', 0), (135, 'Blocking users', 0),
(136, 'One (main/trunk)', 1), (136, 'Many feature branches', 0), (136, 'No branches', 0), (136, 'Unlimited branches', 0),
(137, 'main and develop', 1), (137, 'Only main', 0), (137, 'staging and prod', 0), (137, 'alpha and beta', 0),
(138, 'In the version control repository', 1), (138, 'On a shared drive', 0), (138, 'In email', 0), (138, 'On a whiteboard', 0),
(139, 'Build outputs like JARs, Docker images, packages', 1), (139, 'Source code', 0), (139, 'Meeting recordings', 0), (139, 'User feedback', 0),
(140, 'Basic application functionality after deployment', 1), (140, 'Code compilation', 0), (140, 'Performance under load', 0), (140, 'Security compliance', 0),
(141, 'Current state of managed infrastructure', 1), (141, 'Application logs', 0), (141, 'User sessions', 0), (141, 'Network traffic', 0),
(142, 'What changes will be made before applying', 1), (142, 'Current resource costs', 0), (142, 'Error logs', 0), (142, 'User activity', 0),
(143, 'Reusable infrastructure components', 1), (143, 'Python modules', 0), (143, 'Docker containers', 0), (143, 'Database tables', 0),
(144, 'Related AWS resources as a single unit', 1), (144, 'Stack overflow errors', 0), (144, 'Memory allocations', 0), (144, 'Network packets', 0),
(145, 'Desired state of server configuration', 1), (145, 'A music playlist', 0), (145, 'A movie script', 0), (145, 'A recipe book', 0),
(146, 'Running it multiple times produces the same result', 1), (146, 'It can only run once', 0), (146, 'It fails on retry', 0), (146, 'It deletes everything', 0),
(147, 'Conflicts from multiple engineers running simultaneously', 1), (147, 'Data loss', 0), (147, 'Network issues', 0), (147, 'High costs', 0),
(148, 'Cloud platform APIs', 1), (148, 'User interfaces', 0), (148, 'Mobile apps', 0), (148, 'Email servers', 0),
(149, 'Validate infrastructure code before deployment', 1), (149, 'Load test applications', 0), (149, 'Monitor production', 0), (149, 'Manage users', 0),
(150, 'Git repositories as the source of truth', 1), (150, 'Manual CLI commands', 0), (150, 'Shared documents', 0), (150, 'Chat messages', 0),
(151, 'Metrics collection and alerting', 1), (151, 'Log aggregation', 0), (151, 'Container orchestration', 0), (151, 'Code compilation', 0),
(152, 'Dashboards and visualization', 1), (152, 'Data storage', 0), (152, 'Code editing', 0), (152, 'Email sending', 0),
(153, 'Telemetry collection (metrics, logs, traces)', 1), (153, 'Network protocols', 0), (153, 'Programming languages', 0), (153, 'Database schemas', 0),
(154, 'ERROR, WARN, INFO, DEBUG', 1), (154, 'Red, Yellow, Green', 0), (154, '1, 2, 3, 4', 0), (154, 'A, B, C, D', 0),
(155, 'JSON or key-value pairs', 1), (155, 'Plain English sentences', 0), (155, 'Binary format', 0), (155, 'XML only', 0),
(156, 'Application Performance Monitoring', 1), (156, 'Advanced Process Management', 0), (156, 'Automated Pipeline Module', 0), (156, 'Application Package Manager', 0),
(157, 'User interactions to proactively detect issues', 1), (157, 'Real user traffic', 0), (157, 'Server hardware', 0), (157, 'Network cables', 0),
(158, 'Incidents and outages', 1), (158, 'New feature requests', 0), (158, 'Team meetings', 0), (158, 'Marketing campaigns', 0),
(159, 'Someone is always available to respond', 1), (159, 'Alerts are ignored', 0), (159, 'Only managers respond', 0), (159, 'Issues fix themselves', 0),
(160, 'Step-by-step procedures for common incidents', 1), (160, 'Marketing materials', 0), (160, 'User manuals', 0), (160, 'Financial reports', 0),
(161, 'Source systems to target systems', 1), (161, 'Code to binary', 0), (161, 'Text to images', 0), (161, 'Nothing', 0),
(162, 'Schema is applied when data is read, not when stored', 1), (162, 'Schema is strict at write time', 0), (162, 'No schema ever', 0), (162, 'Schema is deleted on read', 0),
(163, 'Where data came from and how it was transformed', 1), (163, 'Who owns the data', 0), (163, 'How much it costs', 0), (163, 'When to delete it', 0),
(164, 'Searchable inventory of available datasets', 1), (164, 'A shopping website', 0), (164, 'A code repository', 0), (164, 'A file manager', 0),
(165, 'Structure, quality, and statistics of data', 1), (165, 'User behavior', 0), (165, 'Network traffic', 0), (165, 'Server health', 0),
(166, 'A single source of truth for key business entities', 1), (166, 'Many copies of data', 0), (166, 'Data deletion', 0), (166, 'Random data generation', 0),
(167, 'Duplicate records', 1), (167, 'Empty fields', 0), (167, 'Large files', 0), (167, 'Old records', 0),
(168, 'Change Data Capture', 1), (168, 'Central Data Center', 0), (168, 'Cloud Data Container', 0), (168, 'Certified Data Compliance', 0),
(169, 'Data meets defined rules and constraints', 1), (169, 'Data is encrypted', 0), (169, 'Data is compressed', 0), (169, 'Data is backed up', 0),
(170, 'Rerun without producing duplicates', 1), (170, 'Only run once', 0), (170, 'Never fail', 0), (170, 'Always produce different results', 0);

-- Module 18-21 Practice Options (PQ 171-210)
INSERT INTO PracticeQuestionOptions (PracticeQuestionID, OptionText, IsCorrect) VALUES
(171, 'Relational (SQL) databases', 1), (171, 'NoSQL databases', 0), (171, 'File systems', 0), (171, 'Message queues', 0),
(172, 'NoSQL databases', 1), (172, 'Relational databases', 0), (172, 'File systems', 0), (172, 'Operating systems', 0),
(173, 'JSON or BSON documents', 1), (173, 'Fixed rows and columns', 0), (173, 'Binary blobs', 0), (173, 'XML only', 0),
(174, 'Relationship traversal and pattern matching', 1), (174, 'Simple key lookups', 0), (174, 'Full text search', 0), (174, 'Numerical computation', 0),
(175, 'Reducing overhead of creating database connections', 1), (175, 'Swimming', 0), (175, 'Memory allocation', 0), (175, 'File compression', 0),
(176, 'Query read performance', 1), (176, 'Write speed', 0), (176, 'Storage reduction', 0), (176, 'Network latency', 0),
(177, 'Low latency globally and disaster recovery', 1), (177, 'Lower cost', 0), (177, 'Simpler management', 0), (177, 'Less data', 0),
(178, 'Point-in-time recovery and backups', 1), (178, 'Performance improvement', 0), (178, 'Schema changes', 0), (178, 'User management', 0),
(179, 'Upgrading to a larger instance type', 1), (179, 'Adding read replicas', 0), (179, 'Sharding data', 0), (179, 'Adding more nodes', 0),
(180, 'Higher availability and performance', 1), (180, 'Stronger data consistency', 0), (180, 'Lower cost', 0), (180, 'Simpler code', 0),
(181, 'Large-scale data processing and analytics', 1), (181, 'Web hosting', 0), (181, 'Email sending', 0), (181, 'File storage', 0),
(182, 'Parallel processing and scalability', 1), (182, 'Data encryption', 0), (182, 'User authentication', 0), (182, 'Network routing', 0),
(183, 'Parallel consumption of messages', 1), (183, 'Message encryption', 0), (183, 'Topic creation', 0), (183, 'Data compression', 0),
(184, 'Slow consumers being overwhelmed by fast producers', 1), (184, 'Network failures', 0), (184, 'Disk full errors', 0), (184, 'Authentication issues', 0),
(185, 'Fixed non-overlapping time intervals', 1), (185, 'Overlapping time periods', 0), (185, 'Random intervals', 0), (185, 'No time constraints', 0),
(186, 'Messages that failed processing', 1), (186, 'Encrypted messages', 0), (186, 'Priority messages', 0), (186, 'Archived messages', 0),
(187, 'Recovery from failures without data loss', 1), (187, 'Faster processing', 0), (187, 'Data encryption', 0), (187, 'Load balancing', 0),
(188, 'Real-time and batch processing', 1), (188, 'Cost and performance', 0), (188, 'Security and speed', 0), (188, 'Storage and compute', 0),
(189, 'When event occurred vs when it was processed', 1), (189, 'They are the same', 0), (189, 'CPU time vs wall time', 0), (189, 'Read time vs write time', 0),
(190, 'Data format compatibility across producers and consumers', 1), (190, 'User access control', 0), (190, 'Network routing', 0), (190, 'Cost management', 0),
(191, 'Analytical queries on large datasets', 1), (191, 'Transaction processing', 0), (191, 'Real-time streaming', 0), (191, 'File storage', 0),
(192, 'Many small transactions in real-time', 1), (192, 'Large analytical queries', 0), (192, 'Batch processing', 0), (192, 'File transfers', 0),
(193, 'Query results for faster access', 1), (193, 'Source code', 0), (193, 'User sessions', 0), (193, 'Network logs', 0),
(194, 'Lake stores raw data, warehouse stores structured data', 1), (194, 'They are identical', 0), (194, 'Lake is more expensive', 0), (194, 'Warehouse is newer', 0),
(195, 'Data lake flexibility with warehouse performance', 1), (195, 'Two separate systems', 0), (195, 'Only file storage', 0), (195, 'Only SQL queries', 0),
(196, 'Query performance by scanning less data', 1), (196, 'Data security', 0), (196, 'User management', 0), (196, 'Network speed', 0),
(197, 'Historical changes to dimension attributes', 1), (197, 'Fast-changing data', 0), (197, 'Real-time metrics', 0), (197, 'User sessions', 0),
(198, 'On a schedule (hourly, daily, etc.)', 1), (198, 'Never', 0), (198, 'Only manually', 0), (198, 'Continuously', 0),
(199, 'Storing and serving ML features consistently', 1), (199, 'Training models', 0), (199, 'Deploying models', 0), (199, 'Monitoring models', 0),
(200, 'Data ownership and governance', 1), (200, 'Data storage location', 0), (200, 'Data format', 0), (200, 'Data deletion', 0),
(201, 'Transport layer', 1), (201, 'Application layer', 0), (201, 'Network layer', 0), (201, 'Physical layer', 0),
(202, 'Which portion of IP is network vs host', 1), (202, 'Server speed', 0), (202, 'Encryption level', 0), (202, 'File permissions', 0),
(203, 'Private IP devices to access the internet', 1), (203, 'Encryption', 0), (203, 'Load balancing', 0), (203, 'DNS resolution', 0),
(204, 'IP addresses to devices automatically', 1), (204, 'Domain names', 0), (204, 'MAC addresses', 0), (204, 'Encryption keys', 0),
(205, 'The router that connects to other networks', 1), (205, 'A security guard', 0), (205, 'A firewall', 0), (205, 'A DNS server', 0),
(206, 'HTTPS', 1), (206, 'FTP', 0), (206, 'SSH', 0), (206, 'SMTP', 0),
(207, 'IP addresses to MAC addresses', 1), (207, 'Domain names to IPs', 0), (207, 'Ports to services', 0), (207, 'URLs to files', 0),
(208, 'Ping', 1), (208, 'SSH', 0), (208, 'FTP', 0), (208, 'HTTP', 0),
(209, '128 bits', 1), (209, '32 bits', 0), (209, '64 bits', 0), (209, '256 bits', 0),
(210, 'A broadcast domain within a physical network', 1), (210, 'A type of cloud service', 0), (210, 'A container', 0), (210, 'A virtual machine', 0);

-- Module 22-25 Practice Options (PQ 211-250)
INSERT INTO PracticeQuestionOptions (PracticeQuestionID, OptionText, IsCorrect) VALUES
(211, 'The IP address range for the entire VPC', 1), (211, 'A single IP address', 0), (211, 'A domain name', 0), (211, 'A port number', 0),
(212, 'Public internet access for VPC resources', 1), (212, 'Private connectivity only', 0), (212, 'VPN tunnels', 0), (212, 'DNS resolution', 0),
(213, 'Access the internet for updates without being publicly accessible', 1), (213, 'Accept inbound traffic', 0), (213, 'Host websites', 0), (213, 'Run DNS servers', 0),
(214, 'A static public IP address', 1), (214, 'A dynamic private IP', 0), (214, 'A domain name', 0), (214, 'A MAC address', 0),
(215, 'Network traffic metadata (source, dest, action)', 1), (215, 'Application logs', 0), (215, 'User activity', 0), (215, 'CPU metrics', 0),
(216, 'Secure SSH/RDP access to private instances', 1), (216, 'Load balancing', 0), (216, 'DNS hosting', 0), (216, 'File storage', 0),
(217, 'AWS services without going through the internet', 1), (217, 'On-premises servers', 0), (217, 'Other cloud providers', 0), (217, 'Mobile devices', 0),
(218, 'The VPC CIDR block', 1), (218, 'Any IP range', 0), (218, 'The internet', 0), (218, 'Another VPC', 0),
(219, 'Network interfaces (ENIs) on instances', 1), (219, 'Subnets directly', 0), (219, 'VPCs', 0), (219, 'Availability zones', 0),
(220, 'High availability across failure domains', 1), (220, 'Lower cost', 0), (220, 'Faster speed', 0), (220, 'Better security', 0),
(221, 'The same backend instance for a session', 1), (221, 'Random instances each time', 0), (221, 'The fastest instance', 0), (221, 'The least loaded instance', 0),
(222, 'How often backend health is verified', 1), (222, 'Response time', 0), (222, 'Cost per request', 0), (222, 'Number of users', 0),
(223, 'All availability zones evenly', 1), (223, 'One AZ only', 0), (223, 'The cheapest AZ', 0), (223, 'Randomly', 0),
(224, 'ALB or CloudFront distribution', 1), (224, 'EC2 instances directly', 0), (224, 'S3 buckets', 0), (224, 'Databases', 0),
(225, 'Load on the origin server', 1), (225, 'Edge location count', 0), (225, 'DNS queries', 0), (225, 'SSL certificates', 0),
(226, 'How long and where to cache responses', 1), (226, 'Authentication rules', 0), (226, 'Database queries', 0), (226, 'Server location', 0),
(227, 'Global application availability and performance', 1), (227, 'Database speed', 0), (227, 'Code compilation', 0), (227, 'File storage', 0),
(228, 'By percentage allocation', 1), (228, 'By geographic region', 0), (228, 'By time of day', 0), (228, 'Randomly', 0),
(229, 'Health checks on primary endpoint', 1), (229, 'Manual triggering', 0), (229, 'Time-based rules', 0), (229, 'User feedback', 0),
(230, 'At CDN edge locations', 1), (230, 'In the origin data center', 0), (230, 'On user devices', 0), (230, 'In a database', 0),
(231, 'Layer 3 (Network)', 1), (231, 'Layer 7 (Application)', 0), (231, 'Layer 4 (Transport)', 0), (231, 'Layer 2 (Data Link)', 0),
(232, '50 Mbps to 100 Gbps', 1), (232, '1 Mbps to 10 Mbps', 0), (232, 'Only 1 Gbps', 0), (232, 'Unlimited', 0),
(233, 'An on-premises network via VPN or Direct Connect', 1), (233, 'The public internet', 0), (233, 'Another VPC only', 0), (233, 'A container', 0),
(234, 'Dynamic route advertisement between networks', 1), (234, 'Static file hosting', 0), (234, 'Data encryption', 0), (234, 'User authentication', 0),
(235, 'VPCs and on-premises networks to the transit hub', 1), (235, 'Containers to pods', 0), (235, 'Users to roles', 0), (235, 'Files to storage', 0),
(236, 'WAN performance and routing between sites', 1), (236, 'Local disk speed', 0), (236, 'Database queries', 0), (236, 'Application code', 0),
(237, 'Usually expensive (egress charges)', 1), (237, 'Always free', 0), (237, 'Very cheap', 0), (237, 'Only charged for ingress', 0),
(238, 'Central routing point for all connected networks', 1), (238, 'Data storage', 0), (238, 'User authentication', 0), (238, 'Load balancing', 0),
(239, 'Dedicated private connectivity to cloud providers', 1), (239, 'Public internet access', 0), (239, 'Container networking', 0), (239, 'DNS services', 0),
(240, 'Application response time and user experience', 1), (240, 'Code quality', 0), (240, 'Team size', 0), (240, 'Storage capacity', 0),
(241, '15 minutes', 1), (241, '5 minutes', 0), (241, '60 minutes', 0), (241, '24 hours', 0),
(242, 'Maximum simultaneous function executions', 1), (242, 'Code file size', 0), (242, 'Network bandwidth', 0), (242, 'Database connections', 0),
(243, 'Event sources like SQS, DynamoDB Streams, Kinesis', 1), (243, 'User interfaces', 0), (243, 'Load balancers', 0), (243, 'DNS records', 0),
(244, 'Deploying and managing serverless applications', 1), (244, 'Building containers', 0), (244, 'Managing databases', 0), (244, 'Network routing', 0),
(245, 'Common code and libraries', 1), (245, 'User data', 0), (245, 'Database connections', 0), (245, 'Network configs', 0),
(246, 'Warm and ready to execute immediately', 1), (246, 'Shut down', 0), (246, 'In error state', 0), (246, 'Updating', 0),
(247, 'Failed event invocations', 1), (247, 'Successful results', 0), (247, 'User messages', 0), (247, 'Log files', 0),
(248, 'Different deployment environments (dev, staging, prod)', 1), (248, 'API versions', 0), (248, 'User roles', 0), (248, 'Database schemas', 0),
(249, 'Number of invocations and execution duration', 1), (249, 'Fixed monthly cost', 0), (249, 'Number of functions deployed', 0), (249, 'Code file size', 0),
(250, 'Configuration values like API keys and feature flags', 1), (250, 'Application source code', 0), (250, 'Database tables', 0), (250, 'User passwords in plain text', 0);

-- Module 26-28 Practice Options (PQ 251-280)
INSERT INTO PracticeQuestionOptions (PracticeQuestionID, OptionText, IsCorrect) VALUES
(251, 'A public container image registry', 1), (251, 'A code editor', 0), (251, 'A CI/CD tool', 0), (251, 'A cloud provider', 0),
(252, 'A Dockerfile', 1), (252, 'A Kubernetes manifest', 0), (252, 'A Terraform file', 0), (252, 'A shell script only', 0),
(253, 'Multi-container applications locally', 1), (253, 'Cloud infrastructure', 0), (253, 'Database schemas', 0), (253, 'Network routes', 0),
(254, 'The host OS kernel', 1), (254, 'Nothing', 0), (254, 'Their own OS', 0), (254, 'Hardware directly', 0),
(255, 'The default command to run in the container', 1), (255, 'Build instructions', 0), (255, 'Environment variables', 0), (255, 'Network settings', 0),
(256, 'Data beyond container lifecycle', 1), (256, 'Container images', 0), (256, 'Network settings', 0), (256, 'CPU allocations', 0),
(257, 'The container application is running correctly', 1), (257, 'Network connectivity', 0), (257, 'Disk space', 0), (257, 'Image freshness', 0),
(258, 'Unnecessary files from the build context', 1), (258, 'Important source code', 0), (258, 'Configuration files', 0), (258, 'Dependencies', 0),
(259, 'Very small image size', 1), (259, 'Better security', 0), (259, 'More pre-installed packages', 0), (259, 'Faster networking', 0),
(260, 'Image rebuild times', 1), (260, 'Network speed', 0), (260, 'Database queries', 0), (260, 'User logins', 0),
(261, 'Interacting with Kubernetes clusters', 1), (261, 'Building Docker images', 0), (261, 'Managing cloud billing', 0), (261, 'Writing code', 0),
(262, 'Logical isolation and resource organization', 1), (262, 'Physical server separation', 0), (262, 'Network encryption', 0), (262, 'Storage allocation', 0),
(263, 'Non-sensitive configuration data', 1), (263, 'Secrets and passwords', 0), (263, 'Container images', 0), (263, 'Network policies', 0),
(264, 'Sensitive data like passwords and tokens', 1), (264, 'Public configuration', 0), (264, 'Container logs', 0), (264, 'Node labels', 0),
(265, 'One pod runs on every node', 1), (265, 'Pods run on one node only', 0), (265, 'No pods are scheduled', 0), (265, 'Pods run in pairs', 0),
(266, 'Stateful applications like databases', 1), (266, 'Stateless web servers', 0), (266, 'Batch jobs', 0), (266, 'CronJobs', 0),
(267, 'Storage from the cluster', 1), (267, 'CPU from nodes', 0), (267, 'Network bandwidth', 0), (267, 'Memory allocation', 0),
(268, 'If a container is alive and should be restarted if not', 1), (268, 'If it should receive traffic', 0), (268, 'If it needs more memory', 0), (268, 'If it should be deleted', 0),
(269, 'If a pod is ready to accept traffic', 1), (269, 'If it is alive', 0), (269, 'If it needs restart', 0), (269, 'If it should scale', 0),
(270, 'Pod-to-pod communication rules', 1), (270, 'External DNS', 0), (270, 'Storage access', 0), (270, 'User permissions', 0),
(271, 'Amazon States Language (JSON)', 1), (271, 'Python', 0), (271, 'YAML only', 0), (271, 'SQL', 0),
(272, 'Event patterns (source, detail-type, detail)', 1), (272, 'Time only', 0), (272, 'Random selection', 0), (272, 'User input', 0),
(273, 'Overwhelming the API with too many requests', 1), (273, 'Data loss', 0), (273, 'Cold starts', 0), (273, 'Memory leaks', 0),
(274, 'Read and write throughput', 1), (274, 'Table count', 0), (274, 'Item size', 0), (274, 'Region count', 0),
(275, 'Ordering and exactly-once delivery', 1), (275, 'Faster processing', 0), (275, 'Lower cost', 0), (275, 'Larger messages', 0),
(276, 'Multiple subscribers (SQS queues, Lambda, etc.)', 1), (276, 'One subscriber only', 0), (276, 'Database tables', 0), (276, 'File systems', 0),
(277, 'Persistent connections with clients', 1), (277, 'Stateless requests', 0), (277, 'File uploads', 0), (277, 'Database connections', 0),
(278, 'Memory size and cost balance', 1), (278, 'Code language', 0), (278, 'Region selection', 0), (278, 'Timeout value', 0),
(279, 'Distributed application performance issues', 1), (279, 'Network cables', 0), (279, 'Hardware failures', 0), (279, 'User complaints', 0),
(280, 'Deploying serverless applications on AWS', 1), (280, 'Building containers', 0), (280, 'Managing databases', 0), (280, 'Network routing', 0);

PRINT '1120 PracticeQuestionOptions inserted (4 per practice question).';
GO

-- ============================================================
-- STEP 11: INSERT EXAM QUESTIONS (10 per module = 280 total)
-- Schema: ExamQuestionID, ModuleID, QuestionText, OrderIndex, CreatedByInstructorID
-- NOTE: NO QuestionType or CorrectAnswer columns in ExamQuestions table
-- ============================================================

SET IDENTITY_INSERT ExamQuestions ON;

-- Module 1 Exam Questions
INSERT INTO ExamQuestions (ExamQuestionID, ModuleID, QuestionText, OrderIndex, CreatedByInstructorID) VALUES
(1, 1, 'Which best describes cloud computing according to NIST?', 1, 2),
(2, 1, 'What is on-demand self-service?', 2, 2),
(3, 1, 'Which is a measured service example?', 3, 2),
(4, 1, 'Broad network access means what?', 4, 2),
(5, 1, 'Cloud computing eliminates the need for what?', 5, 2),
(6, 1, 'Which is NOT a cloud computing benefit?', 6, 2),
(7, 1, 'Rapid elasticity allows resources to do what?', 7, 2),
(8, 1, 'Multi-tenancy in cloud means what?', 8, 2),
(9, 1, 'Which decade marks the commercial availability of cloud?', 9, 2),
(10, 1, 'Virtualization is fundamental to cloud because it enables what?', 10, 2),

-- Module 2 Exam Questions
(11, 2, 'Which layer does the customer manage in IaaS?', 1, 2),
(12, 2, 'PaaS is ideal for which scenario?', 2, 2),
(13, 2, 'Microsoft 365 is an example of what?', 3, 2),
(14, 2, 'In SaaS, who handles security patches?', 4, 2),
(15, 2, 'FaaS is a subset of which model?', 5, 2),
(16, 2, 'Which model provides the highest level of abstraction?', 6, 2),
(17, 2, 'BaaS stands for what?', 7, 2),
(18, 2, 'CaaS provides what service?', 8, 2),
(19, 2, 'XaaS means what?', 9, 2),
(20, 2, 'The shared responsibility model applies to which models?', 10, 2),

-- Module 3 Exam Questions
(21, 3, 'Which model shares infrastructure with other organizations?', 1, 2),
(22, 3, 'Hybrid cloud is best for which scenario?', 2, 2),
(23, 3, 'Multi-cloud strategy reduces which risk?', 3, 2),
(24, 3, 'Private cloud provides what over public cloud?', 4, 2),
(25, 3, 'Edge computing deploys resources where?', 5, 2),
(26, 3, 'Community cloud is shared by organizations with what in common?', 6, 2),
(27, 3, 'Which is a disadvantage of public cloud?', 7, 2),
(28, 3, 'Data residency requirements may mandate what?', 8, 2),
(29, 3, 'Cloud bursting is a feature of what model?', 9, 2),
(30, 3, 'Which factor most influences deployment model choice?', 10, 2),

-- Module 4 Exam Questions
(31, 4, 'OpEx vs CapEx: cloud computing is primarily what?', 1, 2),
(32, 4, 'Which pricing gives the biggest discount for steady workloads?', 2, 2),
(33, 4, 'Spot instances can be reclaimed with how much notice?', 3, 2),
(34, 4, 'Which tool forecasts future cloud costs?', 4, 2),
(35, 4, 'Tagging resources helps with what?', 5, 2),
(36, 4, 'Right-sizing recommendations are based on what data?', 6, 2),
(37, 4, 'Which is cheaper: data ingress or egress?', 7, 2),
(38, 4, 'Reserved instance marketplace allows what?', 8, 2),
(39, 4, 'Cloud cost anomaly detection alerts on what?', 9, 2),
(40, 4, 'Consolidated billing benefits multi-account setups how?', 10, 2);

-- Module 5-7 Exam Questions
INSERT INTO ExamQuestions (ExamQuestionID, ModuleID, QuestionText, OrderIndex, CreatedByInstructorID) VALUES
(41, 5, 'Horizontal scaling adds what?', 1, 2),
(42, 5, 'Which design principle reduces blast radius?', 2, 2),
(43, 5, 'Stateless design stores session data where?', 3, 2),
(44, 5, 'Auto-scaling responds to what?', 4, 2),
(45, 5, 'Fault isolation is achieved through what?', 5, 2),
(46, 5, 'Bulkhead pattern prevents what?', 6, 2),
(47, 5, 'Retry with exponential backoff helps with what?', 7, 2),
(48, 5, 'Asynchronous processing improves what?', 8, 2),
(49, 5, 'Queue-based load leveling helps during what?', 9, 2),
(50, 5, 'Design for failure principle assumes what?', 10, 2),
(51, 6, 'What minimum AZs provide high availability?', 1, 2),
(52, 6, 'Active-passive failover means what?', 2, 2),
(53, 6, 'RPO of zero requires what?', 3, 2),
(54, 6, 'Which DR strategy has the lowest cost?', 4, 2),
(55, 6, 'Global load balancing routes traffic based on what?', 5, 2),
(56, 6, 'Database failover to a standby is called what?', 6, 2),
(57, 6, 'Chaos engineering deliberately introduces what?', 7, 2),
(58, 6, 'SLA defines what between provider and customer?', 8, 2),
(59, 6, 'Multi-region deployment protects against what?', 9, 2),
(60, 6, 'Automated failover reduces what metric?', 10, 2),
(61, 7, 'Each microservice should be independently what?', 1, 2),
(62, 7, 'Database per service pattern avoids what?', 2, 2),
(63, 7, 'Eventual consistency is acceptable when what?', 3, 2),
(64, 7, 'API Gateway pattern centralizes what?', 4, 2),
(65, 7, 'Service mesh handles what concern?', 5, 2),
(66, 7, 'Choreography vs orchestration differs how?', 6, 2),
(67, 7, 'Saga pattern compensates for what?', 7, 2),
(68, 7, 'Contract testing validates what between services?', 8, 2),
(69, 7, 'Sidecar proxy intercepts what?', 9, 2),
(70, 7, 'Distributed tracing correlates requests using what?', 10, 2);

-- Module 8-14 Exam Questions
INSERT INTO ExamQuestions (ExamQuestionID, ModuleID, QuestionText, OrderIndex, CreatedByInstructorID) VALUES
(71, 8, 'Cache invalidation strategies include what?', 1, 2),
(72, 8, 'CDN origin failover protects against what?', 2, 2),
(73, 8, 'Compute Optimizer recommends what?', 3, 2),
(74, 8, 'Graviton instances optimize what?', 4, 2),
(75, 8, 'Spot instance interruption handling requires what?', 5, 2),
(76, 8, 'Database connection pooling reduces what?', 6, 2),
(77, 8, 'Read-through cache pattern does what on cache miss?', 7, 2),
(78, 8, 'Compression before transfer reduces what?', 8, 2),
(79, 8, 'Benchmark testing establishes what?', 9, 2),
(80, 8, 'Cost per transaction is a metric for what?', 10, 2),
(81, 9, 'Confidentiality ensures what?', 1, 2),
(82, 9, 'Integrity ensures what?', 2, 2),
(83, 9, 'Availability ensures what?', 3, 2),
(84, 9, 'The customer is always responsible for what in cloud?', 4, 2),
(85, 9, 'Defense in depth uses what number of security layers?', 5, 2),
(86, 9, 'Security group vs NACL: which is stateful?', 6, 2),
(87, 9, 'Principle of least privilege limits what?', 7, 2),
(88, 9, 'Cloud security posture management (CSPM) checks what?', 8, 2),
(89, 9, 'Shared responsibility in IaaS: customer manages what?', 9, 2),
(90, 9, 'WAF operates at which OSI layer?', 10, 2),
(91, 10, 'OAuth 2.0 provides what type of access?', 1, 2),
(92, 10, 'OpenID Connect adds what on top of OAuth?', 2, 2),
(93, 10, 'MFA factors include what categories?', 3, 2),
(94, 10, 'Temporary credentials expire to limit what?', 4, 2),
(95, 10, 'Federated identity links what?', 5, 2),
(96, 10, 'IAM policy evaluation: explicit deny beats what?', 6, 2),
(97, 10, 'Cross-account access uses what mechanism?', 7, 2),
(98, 10, 'Attribute-based access control (ABAC) uses what?', 8, 2),
(99, 10, 'Session policies limit what?', 9, 2),
(100, 10, 'Privileged access management (PAM) controls what?', 10, 2),
(101, 11, 'AES-256 is what type of encryption?', 1, 2),
(102, 11, 'RSA is what type of encryption?', 2, 2),
(103, 11, 'TLS 1.3 improves what over TLS 1.2?', 3, 2),
(104, 11, 'Customer-managed keys give what benefit?', 4, 2),
(105, 11, 'Automatic key rotation provides what?', 5, 2),
(106, 11, 'Data classification levels typically include what?', 6, 2),
(107, 11, 'DLP policies can block what?', 7, 2),
(108, 11, 'Secrets rotation reduces risk of what?', 8, 2),
(109, 11, 'End-to-end encryption means what?', 9, 2),
(110, 11, 'Certificate Authority (CA) verifies what?', 10, 2),
(111, 12, 'SOC 2 Trust Service Criteria include what?', 1, 2),
(112, 12, 'GDPR data subject rights include what?', 2, 2),
(113, 12, 'Cloud compliance is whose responsibility?', 3, 2),
(114, 12, 'Audit trail should be what?', 4, 2),
(115, 12, 'SIEM rules trigger alerts based on what?', 5, 2),
(116, 12, 'Mean Time to Detect (MTTD) measures what?', 6, 2),
(117, 12, 'Containment in incident response does what?', 7, 2),
(118, 12, 'Lessons learned phase improves what?', 8, 2),
(119, 12, 'Vulnerability CVSS score indicates what?', 9, 2),
(120, 12, 'Compliance automation tools check what continuously?', 10, 2);

-- Module 13-17 Exam Questions
INSERT INTO ExamQuestions (ExamQuestionID, ModuleID, QuestionText, OrderIndex, CreatedByInstructorID) VALUES
(121, 13, 'DevOps combines which two disciplines?', 1, 2),
(122, 13, 'The first way of DevOps focuses on what?', 2, 2),
(123, 13, 'Feedback loops in DevOps enable what?', 3, 2),
(124, 13, 'Continuous learning requires what culture?', 4, 2),
(125, 13, 'Value stream efficiency is measured how?', 5, 2),
(126, 13, 'DevOps anti-pattern: what should teams avoid?', 6, 2),
(127, 13, 'Toil in SRE is defined as what?', 7, 2),
(128, 13, 'Shift-left testing means what?', 8, 2),
(129, 13, 'DevSecOps integrates security where?', 9, 2),
(130, 13, 'Platform teams provide what to development teams?', 10, 2),
(131, 14, 'CI/CD pipeline first stage is typically what?', 1, 2),
(132, 14, 'Blue-green deployment eliminates what?', 2, 2),
(133, 14, 'Canary release catches issues by doing what?', 3, 2),
(134, 14, 'Feature toggles allow what without redeployment?', 4, 2),
(135, 14, 'Pipeline gates enforce what before proceeding?', 5, 2),
(136, 14, 'Artifact immutability ensures what?', 6, 2),
(137, 14, 'Rollback capability requires what?', 7, 2),
(138, 14, 'Integration tests verify what?', 8, 2),
(139, 14, 'Deployment frequency is a key indicator of what?', 9, 2),
(140, 14, 'Pipeline parallelization improves what?', 10, 2),
(141, 15, 'Declarative IaC describes what?', 1, 2),
(142, 15, 'Imperative IaC describes what?', 2, 2),
(143, 15, 'Terraform state locking prevents what?', 3, 2),
(144, 15, 'CloudFormation drift detection finds what?', 4, 2),
(145, 15, 'Ansible is agentless meaning what?', 5, 2),
(146, 15, 'Policy as code enforces what?', 6, 2),
(147, 15, 'IaC testing pyramid includes what layers?', 7, 2),
(148, 15, 'Blast radius in IaC is reduced by what?', 8, 2),
(149, 15, 'State file contains what sensitive information?', 9, 2),
(150, 15, 'GitOps reconciliation loop does what?', 10, 2),
(151, 16, 'The four golden signals are what?', 1, 2),
(152, 16, 'SLI measures what?', 2, 2),
(153, 16, 'Error budget allows teams to do what?', 3, 2),
(154, 16, 'Cardinality in metrics refers to what?', 4, 2),
(155, 16, 'Log sampling reduces what while maintaining visibility?', 5, 2),
(156, 16, 'Correlation ID enables what in distributed systems?', 6, 2),
(157, 16, 'Alerting threshold should avoid what?', 7, 2),
(158, 16, 'Observability pillars are what?', 8, 2),
(159, 16, 'Synthetic monitoring proactively detects what?', 9, 2),
(160, 16, 'Dashboard design should prioritize what?', 10, 2),
(161, 17, 'ETL stands for what?', 1, 2),
(162, 17, 'Data lake stores data in what format?', 2, 2),
(163, 17, 'Schema evolution handles what?', 3, 2),
(164, 17, 'Data quality dimensions include what?', 4, 2),
(165, 17, 'Metadata management tracks what?', 5, 2),
(166, 17, 'Data lineage answers what question?', 6, 2),
(167, 17, 'Idempotent pipelines guarantee what?', 7, 2),
(168, 17, 'Data partitioning improves what?', 8, 2),
(169, 17, 'Schema-on-read vs schema-on-write: which is more flexible?', 9, 2),
(170, 17, 'CDC captures what type of changes?', 10, 2);

-- Module 18-22 Exam Questions
INSERT INTO ExamQuestions (ExamQuestionID, ModuleID, QuestionText, OrderIndex, CreatedByInstructorID) VALUES
(171, 18, 'ACID stands for what?', 1, 2),
(172, 18, 'CAP theorem limits what?', 2, 2),
(173, 18, 'Read replicas are best for what workload type?', 3, 2),
(174, 18, 'DynamoDB uses what type of key schema?', 4, 2),
(175, 18, 'Aurora provides what advantage over standard RDS?', 5, 2),
(176, 18, 'Database sharding distributes data how?', 6, 2),
(177, 18, 'Connection pooling helps with what problem?', 7, 2),
(178, 18, 'Multi-AZ database deployment provides what?', 8, 2),
(179, 18, 'TTL on database items enables what?', 9, 2),
(180, 18, 'Global tables replicate across what?', 10, 2),
(181, 19, 'Apache Kafka guarantees message ordering within what?', 1, 2),
(182, 19, 'Kinesis Data Streams charges based on what?', 2, 2),
(183, 19, 'Lambda with SQS uses what invocation type?', 3, 2),
(184, 19, 'Windowing functions in streaming handle what?', 4, 2),
(185, 19, 'Exactly-once processing requires what mechanism?', 5, 2),
(186, 19, 'Backpressure handling prevents what?', 6, 2),
(187, 19, 'Event sourcing differs from CRUD how?', 7, 2),
(188, 19, 'Data serialization formats like Avro provide what?', 8, 2),
(189, 19, 'Stream processing vs batch: which has lower latency?', 9, 2),
(190, 19, 'Replay capability in streaming allows what?', 10, 2),
(191, 20, 'Star schema has what at the center?', 1, 2),
(192, 20, 'Snowflake schema normalizes what?', 2, 2),
(193, 20, 'Columnar storage optimizes what type of query?', 3, 2),
(194, 20, 'Data lake vs warehouse: lake accepts what data types?', 4, 2),
(195, 20, 'Lakehouse combines what two technologies?', 5, 2),
(196, 20, 'Materialized views trade what for query speed?', 6, 2),
(197, 20, 'Feature engineering prepares data for what?', 7, 2),
(198, 20, 'BI dashboards serve what purpose?', 8, 2),
(199, 20, 'Data mesh treats data as what?', 9, 2),
(200, 20, 'Real-time analytics requires what type of data pipeline?', 10, 2),
(201, 21, 'Which OSI layer handles routing?', 1, 2),
(202, 21, 'TCP three-way handshake includes what steps?', 2, 2),
(203, 21, 'DNS CNAME record does what?', 3, 2),
(204, 21, 'A /16 CIDR block provides how many IPs?', 4, 2),
(205, 21, 'Network latency is measured in what unit?', 5, 2),
(206, 21, 'Bandwidth vs throughput: what is the difference?', 6, 2),
(207, 21, 'MTU stands for what?', 7, 2),
(208, 21, 'TTL in networking prevents what?', 8, 2),
(209, 21, 'Port 22 is used for what protocol?', 9, 2),
(210, 21, 'Stateful firewall tracks what?', 10, 2),
(211, 22, 'VPC CIDR block must be between what sizes?', 1, 2),
(212, 22, 'Internet Gateway must be attached to what?', 2, 2),
(213, 22, 'NAT Gateway is placed in what type of subnet?', 3, 2),
(214, 22, 'VPC Flow Logs capture traffic at what level?', 4, 2),
(215, 22, 'Security groups evaluate rules in what order?', 5, 2),
(216, 22, 'Private subnet instances access internet via what?', 6, 2),
(217, 22, 'VPC endpoint types include what?', 7, 2),
(218, 22, 'Transitive peering is NOT supported meaning what?', 8, 2),
(219, 22, 'Default VPC comes with what?', 9, 2),
(220, 22, 'ENI stands for what?', 10, 2);

-- Module 23-28 Exam Questions
INSERT INTO ExamQuestions (ExamQuestionID, ModuleID, QuestionText, OrderIndex, CreatedByInstructorID) VALUES
(221, 23, 'ALB supports what type of routing?', 1, 2),
(222, 23, 'NLB preserves what client information?', 2, 2),
(223, 23, 'CloudFront signed URLs restrict what?', 3, 2),
(224, 23, 'Origin Access Identity (OAI) restricts S3 access to what?', 4, 2),
(225, 23, 'Health check grace period prevents what?', 5, 2),
(226, 23, 'Weighted target groups distribute traffic how?', 6, 2),
(227, 23, 'CDN cache hit ratio below 80% indicates what?', 7, 2),
(228, 23, 'Global Accelerator uses what network?', 8, 2),
(229, 23, 'TLS termination at ALB means backend uses what?', 9, 2),
(230, 23, 'Rate limiting at API Gateway prevents what?', 10, 2),
(231, 24, 'Site-to-site VPN requires what on-premises?', 1, 2),
(232, 24, 'Direct Connect LAG provides what?', 2, 2),
(233, 24, 'BGP communities tag routes for what purpose?', 3, 2),
(234, 24, 'Transit Gateway route tables control what?', 4, 2),
(235, 24, 'VPN over Direct Connect provides what added benefit?', 5, 2),
(236, 24, 'Hybrid DNS resolution requires what?', 6, 2),
(237, 24, 'Network segmentation in hybrid environments prevents what?', 7, 2),
(238, 24, 'Cloud WAN simplifies what?', 8, 2),
(239, 24, 'PrivateLink provides access to services without what?', 9, 2),
(240, 24, 'Latency-based routing requires what setup?', 10, 2),
(241, 25, 'Lambda execution environment is isolated using what?', 1, 2),
(242, 25, 'Provisioned concurrency eliminates what?', 2, 2),
(243, 25, 'Lambda Destinations send async results where?', 3, 2),
(244, 25, 'API Gateway usage plans enforce what?', 4, 2),
(245, 25, 'Lambda power tuning optimizes what?', 5, 2),
(246, 25, 'Serverless application testing challenges include what?', 6, 2),
(247, 25, 'Event filtering at source reduces what?', 7, 2),
(248, 25, 'Lambda reserved concurrency guarantees what?', 8, 2),
(249, 25, 'Asynchronous invocation retry behavior is what?', 9, 2),
(250, 25, 'Lambda extensions add what capabilities?', 10, 2),
(251, 26, 'Container image layers are what?', 1, 2),
(252, 26, 'Docker build cache speeds up what?', 2, 2),
(253, 26, 'Container security scanning checks for what?', 3, 2),
(254, 26, 'Rootless containers improve what?', 4, 2),
(255, 26, 'Container resource limits prevent what?', 5, 2),
(256, 26, 'Docker networking bridge mode provides what?', 6, 2),
(257, 26, 'Image tagging best practices include what?', 7, 2),
(258, 26, 'Container logs should be sent where?', 8, 2),
(259, 26, 'Init containers run when?', 9, 2),
(260, 26, 'Distroless images contain what?', 10, 2),
(261, 27, 'Kubernetes RBAC controls what?', 1, 2),
(262, 27, 'Pod disruption budgets ensure what during updates?', 2, 2),
(263, 27, 'Ingress controller handles what?', 3, 2),
(264, 27, 'Horizontal Pod Autoscaler scales based on what?', 4, 2),
(265, 27, 'Kubernetes CRDs extend what?', 5, 2),
(266, 27, 'Pod affinity rules control what?', 6, 2),
(267, 27, 'Service account tokens authenticate what?', 7, 2),
(268, 27, 'Rolling update strategy ensures what?', 8, 2),
(269, 27, 'Resource quotas per namespace limit what?', 9, 2),
(270, 27, 'Kubernetes Operators automate what?', 10, 2),
(271, 28, 'Step Functions Express Workflows are for what?', 1, 2),
(272, 28, 'EventBridge archive allows what?', 2, 2),
(273, 28, 'API Gateway WebSocket APIs support what?', 3, 2),
(274, 28, 'DynamoDB Streams trigger what?', 4, 2),
(275, 28, 'SQS visibility timeout prevents what?', 5, 2),
(276, 28, 'Lambda Layers reduce what?', 6, 2),
(277, 28, 'Serverless cost optimization includes what strategy?', 7, 2),
(278, 28, 'API Gateway caching reduces what?', 8, 2),
(279, 28, 'Step Functions error handling uses what?', 9, 2),
(280, 28, 'Serverless observability requires what approach?', 10, 2);

SET IDENTITY_INSERT ExamQuestions OFF;
PRINT '280 ExamQuestions inserted (10 per module).';
GO

-- ============================================================
-- STEP 12: INSERT EXAM QUESTION OPTIONS (4 per question = 1120 total)
-- Schema: OptionID (identity), ExamQuestionID, OptionText, IsCorrect
-- ============================================================

-- Module 1 Exam Options (EQ 1-10)
INSERT INTO ExamQuestionOptions (ExamQuestionID, OptionText, IsCorrect) VALUES
(1, 'On-demand delivery of IT resources via the internet with pay-as-you-go pricing', 1), (1, 'Buying physical servers', 0), (1, 'Local file storage', 0), (1, 'A weather phenomenon', 0),
(2, 'Provisioning resources without human interaction from the provider', 1), (2, 'Calling support to provision', 0), (2, 'Waiting for approval', 0), (2, 'Filing a ticket', 0),
(3, 'Pay-per-use billing based on actual consumption', 1), (3, 'Fixed monthly fee', 0), (3, 'Free unlimited usage', 0), (3, 'Annual contract only', 0),
(4, 'Services accessible from any device over the network', 1), (4, 'Only accessible from the data center', 0), (4, 'Requires special hardware', 0), (4, 'LAN only', 0),
(5, 'Large upfront capital investment in hardware', 1), (5, 'Internet connectivity', 0), (5, 'Operating systems', 0), (5, 'Software licenses', 0),
(6, 'Guaranteed 100% uptime', 1), (6, 'Cost efficiency', 0), (6, 'Global reach', 0), (6, 'Elasticity', 0),
(7, 'Scale up and down quickly and automatically', 1), (7, 'Only scale up', 0), (7, 'Scale only on weekends', 0), (7, 'Remain fixed', 0),
(8, 'Multiple customers share the same physical infrastructure', 1), (8, 'Each customer owns hardware', 0), (8, 'No sharing occurs', 0), (8, 'Only storage is shared', 0),
(9, 'Mid-2000s with AWS launching in 2006', 1), (9, '1980s', 0), (9, '2020s', 0), (9, '1960s', 0),
(10, 'Running multiple workloads on shared physical hardware', 1), (10, 'Faster internet speeds', 0), (10, 'Better programming languages', 0), (10, 'Smaller devices', 0),

-- Module 2 Exam Options (EQ 11-20)
(11, 'Applications, data, runtime, middleware, and OS', 1), (11, 'Only applications', 0), (11, 'Nothing', 0), (11, 'Physical servers', 0),
(12, 'Developers who want to focus on code without managing infrastructure', 1), (12, 'Companies needing full OS control', 0), (12, 'End users needing email', 0), (12, 'Hardware manufacturers', 0),
(13, 'SaaS', 1), (13, 'IaaS', 0), (13, 'PaaS', 0), (13, 'DaaS', 0),
(14, 'The cloud provider', 1), (14, 'The customer', 0), (14, 'Both equally', 0), (14, 'Nobody', 0),
(15, 'PaaS (or specifically serverless compute)', 1), (15, 'IaaS', 0), (15, 'SaaS', 0), (15, 'CaaS', 0),
(16, 'SaaS', 1), (16, 'IaaS', 0), (16, 'PaaS', 0), (16, 'CaaS', 0),
(17, 'Backend as a Service', 1), (17, 'Business as a Service', 0), (17, 'Bandwidth as a Service', 0), (17, 'Billing as a Service', 0),
(18, 'Container orchestration and management', 1), (18, 'Customer analytics', 0), (18, 'Content authoring', 0), (18, 'Cache acceleration', 0),
(19, 'Anything as a Service', 1), (19, 'XML as a Service', 0), (19, 'Extra as a Service', 0), (19, 'Exchange as a Service', 0),
(20, 'All cloud service models', 1), (20, 'Only IaaS', 0), (20, 'Only SaaS', 0), (20, 'None of them', 0);

-- Module 3-4 Exam Options (EQ 21-40)
INSERT INTO ExamQuestionOptions (ExamQuestionID, OptionText, IsCorrect) VALUES
(21, 'Public cloud', 1), (21, 'Private cloud', 0), (21, 'On-premises', 0), (21, 'Personal computer', 0),
(22, 'When some data must stay on-premises for compliance while leveraging cloud scale', 1), (22, 'When everything can be public', 0), (22, 'When budget is unlimited', 0), (22, 'When only one app exists', 0),
(23, 'Vendor lock-in', 1), (23, 'Higher security', 0), (23, 'Lower cost', 0), (23, 'Faster speed', 0),
(24, 'More control over security and customization', 1), (24, 'Lower cost always', 0), (24, 'Better performance always', 0), (24, 'More services available', 0),
(25, 'Close to data sources and end users at network edge', 1), (25, 'Only in centralized data centers', 0), (25, 'In outer space', 0), (25, 'Underground bunkers', 0),
(26, 'Regulatory or industry requirements', 1), (26, 'Same office building', 0), (26, 'Same revenue level', 0), (26, 'Same founding year', 0),
(27, 'Less control over physical security and compliance', 1), (27, 'Higher cost', 0), (27, 'Slower speed', 0), (27, 'Fewer services', 0),
(28, 'Private cloud or specific geographic regions', 1), (28, 'Any region is fine', 0), (28, 'Only US regions', 0), (28, 'Client-side storage only', 0),
(29, 'Hybrid cloud', 1), (29, 'Public cloud only', 0), (29, 'Private cloud only', 0), (29, 'On-premises only', 0),
(30, 'Security, compliance, and data sensitivity requirements', 1), (30, 'Marketing strategy', 0), (30, 'Office location', 0), (30, 'Team preferences', 0),
(31, 'OpEx (operational expenditure)', 1), (31, 'CapEx (capital expenditure)', 0), (31, 'Free', 0), (31, 'Neither', 0),
(32, 'Reserved Instances or Savings Plans', 1), (32, 'On-demand pricing', 0), (32, 'Spot instances', 0), (32, 'Pay-per-use', 0),
(33, '2 minutes (varies by provider)', 1), (33, '24 hours', 0), (33, '1 week', 0), (33, 'Never reclaimed', 0),
(34, 'AWS Cost Explorer or Azure Cost Management forecasting', 1), (34, 'A crystal ball', 0), (34, 'Stack Overflow', 0), (34, 'Social media', 0),
(35, 'Cost allocation and chargeback to teams', 1), (35, 'Improving code quality', 0), (35, 'Load balancing', 0), (35, 'Security scanning', 0),
(36, 'Historical utilization metrics', 1), (36, 'Company revenue', 0), (36, 'Number of employees', 0), (36, 'Industry benchmarks only', 0),
(37, 'Ingress (data in) is typically free', 1), (37, 'Egress is free', 0), (37, 'Both are equally priced', 0), (37, 'Neither has a cost', 0),
(38, 'Selling unused reserved capacity to others', 1), (38, 'Buying new hardware', 0), (38, 'Trading stocks', 0), (38, 'Exchanging regions', 0),
(39, 'Unexpected spending spikes', 1), (39, 'Normal traffic patterns', 0), (39, 'Code quality issues', 0), (39, 'Security threats', 0),
(40, 'Volume discounts across all accounts', 1), (40, 'Separate billing per account', 0), (40, 'Higher prices', 0), (40, 'No benefit', 0);

-- Module 5-7 Exam Options (EQ 41-70)
INSERT INTO ExamQuestionOptions (ExamQuestionID, OptionText, IsCorrect) VALUES
(41, 'More instances/nodes', 1), (41, 'More CPU to one server', 0), (41, 'More storage only', 0), (41, 'More users', 0),
(42, 'Compartmentalization and isolation', 1), (42, 'Larger instances', 0), (42, 'More regions', 0), (42, 'Fewer services', 0),
(43, 'External data stores like Redis or DynamoDB', 1), (43, 'Local server memory', 0), (43, 'Local files', 0), (43, 'Cookies only', 0),
(44, 'Metrics like CPU, memory, or custom thresholds', 1), (44, 'Time of day only', 0), (44, 'Manual triggers only', 0), (44, 'Number of developers', 0),
(45, 'Separate failure domains (AZs, regions)', 1), (45, 'One large server', 0), (45, 'Shared storage', 0), (45, 'Single point of failure', 0),
(46, 'One failure from affecting the entire system', 1), (46, 'Faster responses', 0), (46, 'Lower costs', 0), (46, 'Better UI', 0),
(47, 'Transient failures and throttling', 1), (47, 'Permanent errors', 0), (47, 'Code bugs', 0), (47, 'Missing data', 0),
(48, 'Responsiveness and throughput', 1), (48, 'Data consistency', 0), (48, 'Code readability', 0), (48, 'Security', 0),
(49, 'Traffic spikes that exceed normal capacity', 1), (49, 'Low traffic periods', 0), (49, 'Security attacks', 0), (49, 'Hardware failures', 0),
(50, 'Everything will eventually fail', 1), (50, 'Nothing will ever fail', 0), (50, 'Only storage fails', 0), (50, 'Only networks fail', 0),
(51, 'At least 2, preferably 3', 1), (51, '1 is enough', 0), (51, 'Exactly 5', 0), (51, '10 or more', 0),
(52, 'Standby takes over only when primary fails', 1), (52, 'Both serve traffic equally', 0), (52, 'Neither serves traffic', 0), (52, 'Both fail together', 0),
(53, 'Synchronous replication', 1), (53, 'Daily backups', 0), (53, 'Weekly snapshots', 0), (53, 'No replication', 0),
(54, 'Backup and restore', 1), (54, 'Multi-site active-active', 0), (54, 'Warm standby', 0), (54, 'Pilot light', 0),
(55, 'Latency and geographic proximity', 1), (55, 'Random selection', 0), (55, 'Cost only', 0), (55, 'Alphabetical order', 0),
(56, 'Automatic failover or switchover', 1), (56, 'Manual backup restore', 0), (56, 'Database deletion', 0), (56, 'Schema migration', 0),
(57, 'Controlled failures to test resilience', 1), (57, 'Random bugs', 0), (57, 'Performance improvements', 0), (57, 'New features', 0),
(58, 'Agreed-upon service availability and remedies', 1), (58, 'A type of encryption', 0), (58, 'A programming language', 0), (58, 'A network protocol', 0),
(59, 'Complete regional outages', 1), (59, 'Single instance failure', 0), (59, 'Code bugs', 0), (59, 'User errors', 0),
(60, 'Recovery Time Objective (RTO)', 1), (60, 'Cost', 0), (60, 'Lines of code', 0), (60, 'Number of users', 0),
(61, 'Deployable and scalable', 1), (61, 'Large and complex', 0), (61, 'Tightly coupled', 0), (61, 'Sharing a database', 0),
(62, 'Tight coupling between services at the data layer', 1), (62, 'Data redundancy', 0), (62, 'Higher cost', 0), (62, 'Faster queries', 0),
(63, 'Perfect real-time consistency is not critical', 1), (63, 'Banking transactions', 0), (63, 'Safety-critical systems', 0), (63, 'Never', 0),
(64, 'Cross-cutting concerns like auth, logging, routing', 1), (64, 'Database queries', 0), (64, 'UI components', 0), (64, 'File storage', 0),
(65, 'Service-to-service communication reliability and observability', 1), (65, 'User interfaces', 0), (65, 'Database connections', 0), (65, 'File systems', 0),
(66, 'Choreography is decentralized, orchestration has a central coordinator', 1), (66, 'They are the same', 0), (66, 'Orchestration is always faster', 0), (66, 'Choreography needs a database', 0),
(67, 'Failed distributed transactions', 1), (67, 'Successful operations', 0), (67, 'Network latency', 0), (67, 'Database growth', 0),
(68, 'API compatibility between producer and consumer', 1), (68, 'UI rendering', 0), (68, 'Database schema', 0), (68, 'Network speed', 0),
(69, 'Network traffic to/from the service', 1), (69, 'Database queries', 0), (69, 'File system access', 0), (69, 'User input', 0),
(70, 'Trace IDs and span IDs', 1), (70, 'IP addresses', 0), (70, 'Timestamps only', 0), (70, 'User names', 0);

-- Module 8-10 Exam Options (EQ 71-100)
INSERT INTO ExamQuestionOptions (ExamQuestionID, OptionText, IsCorrect) VALUES
(71, 'TTL expiry, event-based purge, and manual invalidation', 1), (71, 'Never invalidating', 0), (71, 'Restarting servers', 0), (71, 'Deleting the database', 0),
(72, 'Origin server becoming unavailable', 1), (72, 'CDN cost increases', 0), (72, 'User complaints', 0), (72, 'DNS changes', 0),
(73, 'Optimal instance types based on utilization', 1), (73, 'Marketing strategies', 0), (73, 'Database schemas', 0), (73, 'Network topology', 0),
(74, 'Price-performance ratio for compute', 1), (74, 'Storage capacity', 0), (74, 'Network bandwidth', 0), (74, 'Display resolution', 0),
(75, 'Graceful handling and checkpointing of work', 1), (75, 'Ignoring interruptions', 0), (75, 'Paying more', 0), (75, 'Using fewer instances', 0),
(76, 'Connection creation overhead', 1), (76, 'Data storage', 0), (76, 'Query complexity', 0), (76, 'Table count', 0),
(77, 'Fetches from the origin and populates the cache', 1), (77, 'Returns an error', 0), (77, 'Waits indefinitely', 0), (77, 'Deletes the key', 0),
(78, 'Bandwidth usage and transfer time', 1), (78, 'CPU usage', 0), (78, 'Memory consumption', 0), (78, 'Disk space', 0),
(79, 'Performance baseline for comparison', 1), (79, 'Final production metrics', 0), (79, 'User satisfaction scores', 0), (79, 'Code quality metrics', 0),
(80, 'Cost efficiency of the application', 1), (80, 'Code complexity', 0), (80, 'Team velocity', 0), (80, 'User happiness', 0),
(81, 'Only authorized parties can access data', 1), (81, 'Data is always available', 0), (81, 'Data is never modified', 0), (81, 'Data is backed up', 0),
(82, 'Data has not been tampered with', 1), (82, 'Data is accessible', 0), (82, 'Data is encrypted', 0), (82, 'Data is deleted', 0),
(83, 'Systems and data are accessible when needed', 1), (83, 'Data is secret', 0), (83, 'Data is accurate', 0), (83, 'Data is compressed', 0),
(84, 'Their data and access management', 1), (84, 'Physical security', 0), (84, 'Network infrastructure', 0), (84, 'Hypervisor', 0),
(85, 'Multiple (there is no fixed number)', 1), (85, 'Exactly one', 0), (85, 'Exactly three', 0), (85, 'Zero', 0),
(86, 'Security group', 1), (86, 'NACL', 0), (86, 'Both are stateful', 0), (86, 'Neither is stateful', 0),
(87, 'Potential blast radius of compromised credentials', 1), (87, 'Application speed', 0), (87, 'Storage usage', 0), (87, 'Network traffic', 0),
(88, 'Misconfigurations and compliance violations', 1), (88, 'Application performance', 0), (88, 'User behavior', 0), (88, 'Network speed', 0),
(89, 'OS, applications, data, network controls', 1), (89, 'Only data', 0), (89, 'Nothing', 0), (89, 'Physical hardware', 0),
(90, 'Layer 7 (Application)', 1), (90, 'Layer 4', 0), (90, 'Layer 3', 0), (90, 'Layer 2', 0),
(91, 'Delegated authorization to resources', 1), (91, 'Authentication', 0), (91, 'Encryption', 0), (91, 'Auditing', 0),
(92, 'Identity/authentication layer', 1), (92, 'Encryption', 0), (92, 'Authorization only', 0), (92, 'Logging', 0),
(93, 'Something you know, have, and are', 1), (93, 'Only passwords', 0), (93, 'Only biometrics', 0), (93, 'Only tokens', 0),
(94, 'Exposure window if credentials are leaked', 1), (94, 'Performance', 0), (94, 'Cost', 0), (94, 'Usability', 0),
(95, 'External identity providers with internal access', 1), (95, 'Two databases', 0), (95, 'Network connections', 0), (95, 'File systems', 0),
(96, 'Any explicit allow', 1), (96, 'Implicit deny', 0), (96, 'Another deny', 0), (96, 'Nothing', 0),
(97, 'IAM roles with trust policies', 1), (97, 'Shared passwords', 0), (97, 'VPN connections', 0), (97, 'Physical keys', 0),
(98, 'Tags and attributes of the resource and user', 1), (98, 'Only user role', 0), (98, 'Only resource type', 0), (98, 'IP address only', 0),
(99, 'Maximum permissions for assumed-role sessions', 1), (99, 'Minimum permissions', 0), (99, 'No permissions', 0), (99, 'All permissions', 0),
(100, 'Admin and root-level access with extra safeguards', 1), (100, 'Regular user access', 0), (100, 'Guest access', 0), (100, 'No access', 0);

-- Module 11-14 Exam Options (EQ 101-140)
INSERT INTO ExamQuestionOptions (ExamQuestionID, OptionText, IsCorrect) VALUES
(101, 'Symmetric encryption', 1), (101, 'Asymmetric', 0), (101, 'Hashing', 0), (101, 'Encoding', 0),
(102, 'Asymmetric encryption', 1), (102, 'Symmetric', 0), (102, 'Hashing', 0), (102, 'Compression', 0),
(103, 'Handshake performance and security', 1), (103, 'Nothing', 0), (103, 'Backward compatibility', 0), (103, 'File size', 0),
(104, 'Full control over key lifecycle and access', 1), (104, 'Lower cost', 0), (104, 'Simpler management', 0), (104, 'No benefit', 0),
(105, 'Reduced risk from long-lived keys', 1), (105, 'Faster encryption', 0), (105, 'Lower cost', 0), (105, 'Better compression', 0),
(106, 'Public, Internal, Confidential, Restricted', 1), (106, 'Only two levels', 0), (106, 'Colors', 0), (106, 'Numbers 1-10', 0),
(107, 'Sensitive data from leaving the organization', 1), (107, 'All network traffic', 0), (107, 'User logins', 0), (107, 'Application deployments', 0),
(108, 'Compromised credentials being used indefinitely', 1), (108, 'Performance issues', 0), (108, 'Cost overruns', 0), (108, 'Data growth', 0),
(109, 'Only sender and recipient can read the data', 1), (109, 'Only in transit', 0), (109, 'Only at rest', 0), (109, 'Not encrypted at all', 0),
(110, 'The identity of the certificate owner', 1), (110, 'Network speed', 0), (110, 'Application performance', 0), (110, 'Database integrity', 0),
(111, 'Security, Availability, Processing Integrity, Confidentiality, Privacy', 1), (111, 'Only security', 0), (111, 'Only availability', 0), (111, 'Cost efficiency', 0),
(112, 'Right to access, rectify, delete personal data', 1), (112, 'Only data portability', 0), (112, 'Only deletion', 0), (112, 'No rights', 0),
(113, 'Shared between provider and customer', 1), (113, 'Only the provider', 0), (113, 'Only the customer', 0), (113, 'Government', 0),
(114, 'Immutable and tamper-evident', 1), (114, 'Editable by anyone', 0), (114, 'Optional', 0), (114, 'Deleted after 24 hours', 0),
(115, 'Predefined patterns and anomalous behavior', 1), (115, 'Random events', 0), (115, 'User preferences', 0), (115, 'Weather data', 0),
(116, 'Time between incident occurrence and detection', 1), (116, 'Recovery time', 0), (116, 'Response time', 0), (116, 'Resolution time', 0),
(117, 'Limits the spread of the incident', 1), (117, 'Eliminates the threat', 0), (117, 'Recovers all data', 0), (117, 'Notifies users', 0),
(118, 'Future incident response procedures', 1), (118, 'Nothing', 0), (118, 'Marketing', 0), (118, 'Revenue', 0),
(119, 'Severity of the vulnerability', 1), (119, 'Who found it', 0), (119, 'When it was found', 0), (119, 'Cost to fix', 0),
(120, 'Configuration against security policies and standards', 1), (120, 'Application code', 0), (120, 'User behavior', 0), (120, 'Network speed', 0),
(121, 'Development and IT Operations', 1), (121, 'Design and Marketing', 0), (121, 'Sales and Support', 0), (121, 'HR and Finance', 0),
(122, 'Flow of work from left to right (dev to ops)', 1), (122, 'Right to left feedback', 0), (122, 'Continuous learning', 0), (122, 'Cost reduction', 0),
(123, 'Rapid detection and correction of issues', 1), (123, 'Slower development', 0), (123, 'More meetings', 0), (123, 'Less communication', 0),
(124, 'Blameless and safe to fail', 1), (124, 'Punitive', 0), (124, 'Secretive', 0), (124, 'Competitive', 0),
(125, 'Ratio of value-add time to total lead time', 1), (125, 'Lines of code', 0), (125, 'Number of meetings', 0), (125, 'Team size', 0),
(126, 'Creating a separate DevOps team silo', 1), (126, 'Automation', 0), (126, 'Collaboration', 0), (126, 'Monitoring', 0),
(127, 'Repetitive manual operational work that should be automated', 1), (127, 'Creative coding work', 0), (127, 'Architecture design', 0), (127, 'Team building', 0),
(128, 'Testing earlier in the development lifecycle', 1), (128, 'Testing only in production', 0), (128, 'Not testing at all', 0), (128, 'Testing after release', 0),
(129, 'Throughout the entire pipeline from the start', 1), (129, 'Only at the end', 0), (129, 'Never', 0), (129, 'Only in production', 0),
(130, 'Reusable self-service tools and abstractions', 1), (130, 'Direct access to infrastructure', 0), (130, 'Marketing materials', 0), (130, 'Customer support', 0),
(131, 'Source code checkout/pull', 1), (131, 'Production deployment', 0), (131, 'Monitoring setup', 0), (131, 'User notification', 0),
(132, 'Downtime during deployment', 1), (132, 'All testing', 0), (132, 'The need for monitoring', 0), (132, 'Cost optimization', 0),
(133, 'Gradually routing small traffic percentage to new version', 1), (133, 'Deploying to all users at once', 0), (133, 'Only running tests', 0), (133, 'Manual testing', 0),
(134, 'Enabling or disabling features dynamically', 1), (134, 'Database changes', 0), (134, 'Network configuration', 0), (134, 'User management', 0),
(135, 'Quality criteria like test pass rate or approvals', 1), (135, 'Time limits only', 0), (135, 'Random checks', 0), (135, 'Nothing', 0),
(136, 'Built artifacts are never modified after creation', 1), (136, 'They change with every deployment', 0), (136, 'They are deleted after use', 0), (136, 'They are editable', 0),
(137, 'Previous known-good versions available for deployment', 1), (137, 'No history needed', 0), (137, 'Manual rebuilds', 0), (137, 'Customer notification', 0),
(138, 'Interaction between multiple components works correctly', 1), (138, 'Individual functions in isolation', 0), (138, 'UI rendering', 0), (138, 'Performance only', 0),
(139, 'DevOps maturity and velocity', 1), (139, 'Team size', 0), (139, 'Budget', 0), (139, 'Office space', 0),
(140, 'Build and deployment speed', 1), (140, 'Code quality', 0), (140, 'Security', 0), (140, 'Cost', 0);

-- Module 15-17 Exam Options (EQ 141-170)
INSERT INTO ExamQuestionOptions (ExamQuestionID, OptionText, IsCorrect) VALUES
(141, 'The desired end state of infrastructure', 1), (141, 'Step-by-step commands', 0), (141, 'Source code', 0), (141, 'User requirements', 0),
(142, 'Step-by-step commands to reach a state', 1), (142, 'Final state only', 0), (142, 'No instructions', 0), (142, 'User documentation', 0),
(143, 'Concurrent modifications corrupting state', 1), (143, 'Faster execution', 0), (143, 'Lower cost', 0), (143, 'Better security', 0),
(144, 'Resources modified outside of CloudFormation', 1), (144, 'New templates', 0), (144, 'Cost overruns', 0), (144, 'Performance issues', 0),
(145, 'No agent software needed on managed nodes', 1), (145, 'It has no features', 0), (145, 'It cannot manage servers', 0), (145, 'It runs on mobile', 0),
(146, 'Organizational rules and standards automatically', 1), (146, 'Code quality', 0), (146, 'User passwords', 0), (146, 'Marketing copy', 0),
(147, 'Static analysis, unit tests, integration tests', 1), (147, 'Only manual review', 0), (147, 'No testing needed', 0), (147, 'UI testing only', 0),
(148, 'Smaller, independent modules and targeted changes', 1), (148, 'One massive template', 0), (148, 'No modules', 0), (148, 'Manual provisioning', 0),
(149, 'Resource attributes, IDs, and potentially secrets', 1), (149, 'Only resource names', 0), (149, 'Nothing sensitive', 0), (149, 'Only timestamps', 0),
(150, 'Ensures actual state matches desired state in Git', 1), (150, 'Deletes all resources', 0), (150, 'Ignores changes', 0), (150, 'Only creates', 0),
(151, 'Latency, traffic, errors, saturation', 1), (151, 'Cost, speed, size, color', 0), (151, 'Only CPU and memory', 0), (151, 'Only errors', 0),
(152, 'A quantitative measure of service behavior', 1), (152, 'A legal agreement', 0), (152, 'A deployment tool', 0), (152, 'A type of alert', 0),
(153, 'Take calculated risks like deploying new features', 1), (153, 'Ignore all errors', 0), (153, 'Stop deploying', 0), (153, 'Fire team members', 0),
(154, 'Number of unique label value combinations', 1), (154, 'Data size', 0), (154, 'Query speed', 0), (154, 'Alert count', 0),
(155, 'Storage cost and query volume', 1), (155, 'Accuracy', 0), (155, 'Completeness', 0), (155, 'Security', 0),
(156, 'Tracing a single request across all services', 1), (156, 'Correlating costs', 0), (156, 'User identification', 0), (156, 'Database linking', 0),
(157, 'Too many false positive alerts (alert fatigue)', 1), (157, 'Missing all issues', 0), (157, 'Being too quiet', 0), (157, 'Costing too much', 0),
(158, 'Metrics, logs, and traces', 1), (158, 'Only metrics', 0), (158, 'Only logs', 0), (158, 'Only traces', 0),
(159, 'Issues before real users are affected', 1), (159, 'Historical problems', 0), (159, 'Cost overruns', 0), (159, 'Team productivity', 0),
(160, 'Actionable insights at a glance', 1), (160, 'Maximum complexity', 0), (160, 'All possible metrics', 0), (160, 'Artistic design', 0),
(161, 'Extract, Transform, Load', 1), (161, 'Export, Transfer, Link', 0), (161, 'Enter, Test, Launch', 0), (161, 'Edit, Translate, Log', 0),
(162, 'Raw/native format without upfront schema', 1), (162, 'Only structured tables', 0), (162, 'Only JSON', 0), (162, 'Only CSV', 0),
(163, 'Changes to data structure over time', 1), (163, 'Data deletion', 0), (163, 'Performance tuning', 0), (163, 'User management', 0),
(164, 'Accuracy, completeness, timeliness, consistency', 1), (164, 'Only size', 0), (164, 'Only format', 0), (164, 'Only age', 0),
(165, 'Information about data (data about data)', 1), (165, 'User preferences', 0), (165, 'Application logs', 0), (165, 'Network traffic', 0),
(166, 'Where did this data come from and how was it derived', 1), (166, 'How much does it cost', 0), (166, 'Who owns the server', 0), (166, 'When to delete it', 0),
(167, 'Same result regardless of how many times pipeline runs', 1), (167, 'Faster execution', 0), (167, 'Lower cost', 0), (167, 'Better security', 0),
(168, 'Query performance by reducing data scanned', 1), (168, 'Data security', 0), (168, 'Write speed', 0), (168, 'Network latency', 0),
(169, 'Schema-on-read', 1), (169, 'Schema-on-write', 0), (169, 'Both equally', 0), (169, 'Neither', 0),
(170, 'Incremental data changes (inserts, updates, deletes)', 1), (170, 'Only new records', 0), (170, 'Only schema changes', 0), (170, 'Only deletions', 0);

-- Module 18-22 Exam Options (EQ 171-220)
INSERT INTO ExamQuestionOptions (ExamQuestionID, OptionText, IsCorrect) VALUES
(171, 'Atomicity, Consistency, Isolation, Durability', 1), (171, 'Another Computer In Development', 0), (171, 'Always Correct Information Database', 0), (171, 'Automated Continuous Integration Deploy', 0),
(172, 'Having all three: Consistency, Availability, and Partition tolerance simultaneously', 1), (172, 'Query speed', 0), (172, 'Storage capacity', 0), (172, 'Network bandwidth', 0),
(173, 'Read-heavy with eventual consistency acceptable', 1), (173, 'Write-heavy', 0), (173, 'Real-time analytics', 0), (173, 'Batch processing', 0),
(174, 'Partition key (and optional sort key)', 1), (174, 'Only auto-increment ID', 0), (174, 'UUID only', 0), (174, 'No key required', 0),
(175, 'Up to 5x throughput and automatic storage scaling', 1), (175, 'Lower cost only', 0), (175, 'Simpler API', 0), (175, 'No advantage', 0),
(176, 'Across multiple database instances by key range or hash', 1), (176, 'Into one large table', 0), (176, 'By deleting old data', 0), (176, 'By compressing data', 0),
(177, 'Too many connections exhausting database limits', 1), (177, 'Slow queries', 0), (177, 'Data corruption', 0), (177, 'Disk full', 0),
(178, 'Automatic failover for high availability', 1), (178, 'Cost savings', 0), (178, 'Faster queries', 0), (178, 'More storage', 0),
(179, 'Automatic deletion of expired data', 1), (179, 'Faster reads', 0), (179, 'Better security', 0), (179, 'Compression', 0),
(180, 'Multiple AWS regions', 1), (180, 'Multiple tables', 0), (180, 'Multiple schemas', 0), (180, 'Multiple accounts', 0),
(181, 'A partition', 1), (181, 'A topic', 0), (181, 'A broker', 0), (181, 'A cluster', 0),
(182, 'Number of shards and data throughput', 1), (182, 'Number of consumers', 0), (182, 'Message size only', 0), (182, 'Region count', 0),
(183, 'Polling (synchronous pull)', 1), (183, 'Push notification', 0), (183, 'Async event', 0), (183, 'Direct invocation', 0),
(184, 'Time-bounded aggregations of streaming data', 1), (184, 'File management', 0), (184, 'User sessions', 0), (184, 'Database transactions', 0),
(185, 'Idempotent processing and transactional commits', 1), (185, 'Faster processing', 0), (185, 'More memory', 0), (185, 'Fewer consumers', 0),
(186, 'Consumer being overwhelmed and losing data', 1), (186, 'Higher costs', 0), (186, 'Better performance', 0), (186, 'Network issues', 0),
(187, 'Stores all changes as events instead of overwriting state', 1), (187, 'They are the same', 0), (187, 'It only stores deletions', 0), (187, 'It only stores final state', 0),
(188, 'Schema evolution and compact serialization', 1), (188, 'Human readability', 0), (188, 'File compression only', 0), (188, 'Network encryption', 0),
(189, 'Stream processing', 1), (189, 'Batch processing', 0), (189, 'Both are equal', 0), (189, 'Neither', 0),
(190, 'Reprocessing historical events for debugging or recovery', 1), (190, 'Faster real-time processing', 0), (190, 'Lower storage cost', 0), (190, 'Better compression', 0),
(191, 'Fact table', 1), (191, 'Dimension table', 0), (191, 'Lookup table', 0), (191, 'Bridge table', 0),
(192, 'Dimension tables into sub-dimensions', 1), (192, 'Fact tables', 0), (192, 'Nothing', 0), (192, 'Entire schema', 0),
(193, 'Analytical/aggregate queries over many rows', 1), (193, 'Single-row lookups', 0), (193, 'Write operations', 0), (193, 'Delete operations', 0),
(194, 'All types: structured, semi-structured, and unstructured', 1), (194, 'Only structured', 0), (194, 'Only JSON', 0), (194, 'Only CSV', 0),
(195, 'Data lake storage with data warehouse query performance', 1), (195, 'Two separate systems', 0), (195, 'Only files', 0), (195, 'Only SQL', 0),
(196, 'Storage space and freshness for faster reads', 1), (196, 'Nothing', 0), (196, 'Security for speed', 0), (196, 'Cost for features', 0),
(197, 'Machine learning model training', 1), (197, 'User interface design', 0), (197, 'Network routing', 0), (197, 'Server management', 0),
(198, 'Visual data-driven decision making', 1), (198, 'Code editing', 0), (198, 'File management', 0), (198, 'Email', 0),
(199, 'A product with domain ownership', 1), (199, 'A liability', 0), (199, 'Disposable', 0), (199, 'Centralized only', 0),
(200, 'Streaming pipeline', 1), (200, 'Batch pipeline only', 0), (200, 'Manual process', 0), (200, 'No pipeline', 0),
(201, 'Layer 3 (Network)', 1), (201, 'Layer 4', 0), (201, 'Layer 7', 0), (201, 'Layer 1', 0),
(202, 'SYN, SYN-ACK, ACK', 1), (202, 'Hello, OK, Done', 0), (202, 'Open, Send, Close', 0), (202, 'Request, Response, End', 0),
(203, 'Creates an alias pointing to another domain', 1), (203, 'Points to an IP address', 0), (203, 'Handles email', 0), (203, 'Defines nameservers', 0),
(204, '65,536 total IPs', 1), (204, '256 IPs', 0), (204, '1024 IPs', 0), (204, '16 million IPs', 0),
(205, 'Milliseconds', 1), (205, 'Megabytes', 0), (205, 'Gigahertz', 0), (205, 'Kilometers', 0),
(206, 'Bandwidth is max capacity, throughput is actual data transferred', 1), (206, 'They are the same', 0), (206, 'Throughput is always higher', 0), (206, 'Bandwidth is measured in seconds', 0),
(207, 'Maximum Transmission Unit', 1), (207, 'Multi-Tenant Utility', 0), (207, 'Main Transfer Upload', 0), (207, 'Managed Traffic Update', 0),
(208, 'Packets looping forever in the network', 1), (208, 'Faster delivery', 0), (208, 'Data encryption', 0), (208, 'User authentication', 0),
(209, 'SSH', 1), (209, 'HTTP', 0), (209, 'SMTP', 0), (209, 'DNS', 0),
(210, 'Connection state and return traffic', 1), (210, 'Only source IP', 0), (210, 'Only port numbers', 0), (210, 'Nothing', 0),
(211, '/16 to /28', 1), (211, '/8 to /32', 0), (211, 'Any size', 0), (211, 'Only /24', 0),
(212, 'A VPC', 1), (212, 'A subnet', 0), (212, 'An instance', 0), (212, 'A security group', 0),
(213, 'A public subnet', 1), (213, 'A private subnet', 0), (213, 'Any subnet', 0), (213, 'No subnet', 0),
(214, 'ENI (network interface) level', 1), (214, 'Instance level only', 0), (214, 'VPC level only', 0), (214, 'Region level', 0),
(215, 'All rules evaluated, most permissive wins', 1), (215, 'First match wins', 0), (215, 'Last rule wins', 0), (215, 'Random order', 0),
(216, 'NAT Gateway', 1), (216, 'Internet Gateway directly', 0), (216, 'VPN only', 0), (216, 'They cannot access internet', 0),
(217, 'Interface and Gateway endpoints', 1), (217, 'Only interface', 0), (217, 'Only gateway', 0), (217, 'Only peering', 0),
(218, 'VPC A peered with B, B with C does NOT mean A can reach C', 1), (218, 'All peered VPCs can communicate', 0), (218, 'Peering is bidirectional', 0), (218, 'Peering costs nothing', 0),
(219, 'Internet gateway, route table, subnet, and security group', 1), (219, 'Nothing', 0), (219, 'Only a subnet', 0), (219, 'Only a route table', 0),
(220, 'Elastic Network Interface', 1), (220, 'Encrypted Network Infrastructure', 0), (220, 'External Network Integration', 0), (220, 'Enhanced Node Instance', 0);

-- Module 23-28 Exam Options (EQ 221-280)
INSERT INTO ExamQuestionOptions (ExamQuestionID, OptionText, IsCorrect) VALUES
(221, 'Path-based and host-based routing', 1), (221, 'Only IP-based', 0), (221, 'Only port-based', 0), (221, 'No routing', 0),
(222, 'Source IP address', 1), (222, 'Nothing', 0), (222, 'Cookie data', 0), (222, 'User agent', 0),
(223, 'Access to content based on URL signatures', 1), (223, 'All access', 0), (223, 'Network speed', 0), (223, 'File size', 0),
(224, 'Only CloudFront', 1), (224, 'Anyone', 0), (224, 'Only EC2', 0), (224, 'Only Lambda', 0),
(225, 'Premature healthy instance deregistration during startup', 1), (225, 'Cost overrun', 0), (225, 'Data loss', 0), (225, 'Security breach', 0),
(226, 'By assigned weight percentages', 1), (226, 'Equally always', 0), (226, 'Randomly', 0), (226, 'By IP range', 0),
(227, 'Cache configuration may need optimization', 1), (227, 'Everything is perfect', 0), (227, 'Too much caching', 0), (227, 'CDN should be removed', 0),
(228, 'AWS global network (private backbone)', 1), (228, 'Public internet', 0), (228, 'Customer VPN', 0), (228, 'Satellite', 0),
(229, 'HTTP (unencrypted) or re-encrypted HTTPS', 1), (229, 'Always HTTPS', 0), (229, 'FTP', 0), (229, 'No protocol', 0),
(230, 'API abuse and denial of service', 1), (230, 'Data loss', 0), (230, 'Authentication bypass', 0), (230, 'SQL injection', 0),
(231, 'A compatible VPN device or software', 1), (231, 'Nothing special', 0), (231, 'A satellite dish', 0), (231, 'A mobile phone', 0),
(232, 'Link aggregation for higher bandwidth and redundancy', 1), (232, 'Lower cost', 0), (232, 'Faster routing', 0), (232, 'Encryption', 0),
(233, 'Influencing route preference and filtering', 1), (233, 'Data encryption', 0), (233, 'User authentication', 0), (233, 'Cost reduction', 0),
(234, 'Which attachments can communicate with each other', 1), (234, 'Network speed', 0), (234, 'Data encryption', 0), (234, 'User access', 0),
(235, 'Encryption over the dedicated private connection', 1), (235, 'Faster speed', 0), (235, 'Lower cost', 0), (235, 'Public access', 0),
(236, 'Conditional DNS forwarders or Route 53 Resolver endpoints', 1), (236, 'No configuration', 0), (236, 'Public DNS only', 0), (236, 'Manual hosts files', 0),
(237, 'Lateral movement from compromised segments', 1), (237, 'Faster traffic', 0), (237, 'Lower costs', 0), (237, 'Better UX', 0),
(238, 'Global multi-region network management', 1), (238, 'Local networking only', 0), (238, 'Database management', 0), (238, 'Application deployment', 0),
(239, 'Traversing the public internet', 1), (239, 'Using a load balancer', 0), (239, 'Authentication', 0), (239, 'Encryption', 0),
(240, 'Resources deployed in multiple regions', 1), (240, 'Single region only', 0), (240, 'No infrastructure', 0), (240, 'Only DNS', 0),
(241, 'MicroVMs (Firecracker)', 1), (241, 'Docker containers', 0), (241, 'Physical servers', 0), (241, 'VMs only', 0),
(242, 'Cold starts', 1), (242, 'Warm starts', 0), (242, 'Hot starts', 0), (242, 'All latency', 0),
(243, 'SQS, SNS, Lambda, or EventBridge', 1), (243, 'Only S3', 0), (243, 'Only email', 0), (243, 'Nowhere', 0),
(244, 'Rate limits and quotas per API key', 1), (244, 'Authentication only', 0), (244, 'Data encryption', 0), (244, 'Routing rules', 0),
(245, 'Memory/cost/performance balance', 1), (245, 'Code quality', 0), (245, 'Network speed', 0), (245, 'Team size', 0),
(246, 'Local testing of event-driven integrations', 1), (246, 'No challenges exist', 0), (246, 'Only unit testing', 0), (246, 'Performance only', 0),
(247, 'Unnecessary Lambda invocations and cost', 1), (247, 'Data loss', 0), (247, 'Security issues', 0), (247, 'Network problems', 0),
(248, 'Minimum available concurrency for that function', 1), (248, 'Maximum memory', 0), (248, 'Timeout duration', 0), (248, 'Code size', 0),
(249, 'Retries twice then sends to DLQ if configured', 1), (249, 'Retries infinitely', 0), (249, 'Never retries', 0), (249, 'Retries 10 times', 0),
(250, 'Monitoring, security, and custom runtime capabilities', 1), (250, 'Only logging', 0), (250, 'Only metrics', 0), (250, 'Nothing useful', 0),
(251, 'Read-only filesystem layers stacked together', 1), (251, 'A single file', 0), (251, 'Virtual machines', 0), (251, 'Network packets', 0),
(252, 'Subsequent image builds when layers unchanged', 1), (252, 'Container runtime', 0), (252, 'Network performance', 0), (252, 'Database queries', 0),
(253, 'Known vulnerabilities (CVEs)', 1), (253, 'Code quality', 0), (253, 'Performance', 0), (253, 'Licensing', 0),
(254, 'Security by not running as root', 1), (254, 'Performance', 0), (254, 'Networking', 0), (254, 'Storage', 0),
(255, 'A single container consuming all host resources', 1), (255, 'Faster execution', 0), (255, 'Better networking', 0), (255, 'Easier debugging', 0),
(256, 'Container-to-container communication on the same host', 1), (256, 'Internet access', 0), (256, 'Cross-host communication', 0), (256, 'Storage mounting', 0),
(257, 'Using specific version tags, not just latest', 1), (257, 'Always using latest', 0), (257, 'No tags', 0), (257, 'Random tags', 0),
(258, 'A centralized logging system', 1), (258, 'Local disk files', 0), (258, 'Stdout only', 0), (258, 'Nowhere', 0),
(259, 'Before the main container starts, for setup tasks', 1), (259, 'After the main container exits', 0), (259, 'Continuously', 0), (259, 'Never', 0),
(260, 'Only the application and its runtime dependencies', 1), (260, 'A full OS', 0), (260, 'A shell and utilities', 0), (260, 'Everything', 0),
(261, 'Who can perform what actions on which resources', 1), (261, 'Network traffic', 0), (261, 'Storage quotas', 0), (261, 'CPU limits', 0),
(262, 'Minimum number of available pods during disruption', 1), (262, 'Maximum pod count', 0), (262, 'Network policies', 0), (262, 'Storage allocation', 0),
(263, 'External traffic routing to internal services', 1), (263, 'Pod scheduling', 0), (263, 'Storage management', 0), (263, 'Secret encryption', 0),
(264, 'CPU utilization or custom metrics', 1), (264, 'Pod count only', 0), (264, 'Node count', 0), (264, 'Namespace count', 0),
(265, 'The Kubernetes API with custom resource types', 1), (265, 'Docker functionality', 0), (265, 'Network protocols', 0), (265, 'Storage drivers', 0),
(266, 'Which nodes pods are scheduled on', 1), (266, 'Network policies', 0), (266, 'Storage allocation', 0), (266, 'Image pull secrets', 0),
(267, 'Pods to the Kubernetes API and external services', 1), (267, 'Human users', 0), (267, 'External clients', 0), (267, 'Database connections', 0),
(268, 'Zero downtime during updates', 1), (268, 'Faster updates', 0), (268, 'Lower cost', 0), (268, 'Less storage', 0),
(269, 'Total resource consumption in that namespace', 1), (269, 'Pod count only', 0), (269, 'Network traffic', 0), (269, 'Image size', 0),
(270, 'Complex application lifecycle management', 1), (270, 'Simple deployments only', 0), (270, 'Network routing', 0), (270, 'Storage provisioning only', 0),
(271, 'High-volume, short-duration, event processing workloads', 1), (271, 'Long-running workflows', 0), (271, 'Human approvals', 0), (271, 'Data warehousing', 0),
(272, 'Replaying historical events', 1), (272, 'Deleting events', 0), (272, 'Encrypting events', 0), (272, 'Compressing events', 0),
(273, 'Bidirectional real-time communication', 1), (273, 'Only REST calls', 0), (273, 'Only file uploads', 0), (273, 'Only GET requests', 0),
(274, 'Lambda functions for real-time processing', 1), (274, 'EC2 instances', 0), (274, 'S3 uploads', 0), (274, 'CloudFront caches', 0),
(275, 'Other consumers from processing the same message', 1), (275, 'Message delivery', 0), (275, 'Queue creation', 0), (275, 'Message encryption', 0),
(276, 'Deployment package size by sharing common code', 1), (276, 'Execution time', 0), (276, 'Memory usage', 0), (276, 'Concurrency', 0),
(277, 'Right-sizing memory and using reserved concurrency wisely', 1), (277, 'Always using max memory', 0), (277, 'Never using provisioned concurrency', 0), (277, 'Ignoring invocation costs', 0),
(278, 'Backend invocations and latency', 1), (278, 'Storage costs', 0), (278, 'Security threats', 0), (278, 'Network bandwidth', 0),
(279, 'Catch and Retry fields in state machine definition', 1), (279, 'Try-catch in Lambda code only', 0), (279, 'No error handling', 0), (279, 'Manual intervention', 0),
(280, 'Distributed tracing with structured logging', 1), (280, 'No monitoring needed', 0), (280, 'Only CloudWatch metrics', 0), (280, 'Only error counts', 0);

PRINT '1120 ExamQuestionOptions inserted (4 per exam question).';
GO

-- ============================================================
-- FINAL SUMMARY
-- ============================================================
PRINT '========================================';
PRINT 'REBUILD COMPLETE - Summary:';
PRINT '  7 Pathways';
PRINT '  6 Certifications';
PRINT '  28 Modules (4 per pathway)';
PRINT '  28 Badges (1 per module)';
PRINT '  140 SubTopics (5 per module)';
PRINT '  140 Questions with 560 AnswerOptions';
PRINT '  280 PracticeQuestions with 1120 PracticeQuestionOptions';
PRINT '  280 ExamQuestions with 1120 ExamQuestionOptions';
PRINT '========================================';
GO
