USE CloudPhoria;
GO

-- SubTopic 1: Definition of Cloud Computing
UPDATE SubTopics SET ContentBody = N'<h2>Definition of Cloud Computing</h2>
<p>Cloud computing is the on-demand delivery of computing resources such as servers, storage, databases, networking, software, analytics, and intelligence over the internet. Rather than buying, owning, and maintaining physical data centers and servers, organizations can access technology services on an as-needed basis from a cloud provider like Amazon Web Services (AWS), Microsoft Azure, or Google Cloud Platform (GCP).</p>
<p>The National Institute of Standards and Technology (NIST) defines cloud computing through five essential characteristics: on-demand self-service, broad network access, resource pooling, rapid elasticity, and measured service. On-demand self-service means a consumer can provision computing capabilities automatically without requiring human interaction with the service provider. Broad network access means capabilities are available over the network and accessed through standard mechanisms that promote use by diverse client platforms such as mobile phones, tablets, laptops, and workstations.</p>
<p>Resource pooling means the provider''s computing resources are pooled to serve multiple consumers using a multi-tenant model, with different physical and virtual resources dynamically assigned according to demand. Rapid elasticity means capabilities can be elastically provisioned and released to scale outward and inward with demand. Measured service means cloud systems automatically control and optimize resource use by leveraging a metering capability, providing transparency for both the provider and consumer.</p>
<p>Cloud computing eliminates the capital expense of buying hardware and software, setting up and running on-site data centers, the racks of servers, the round-the-clock electricity for power and cooling, and the IT experts for managing the infrastructure. It allows businesses to focus on their core competencies rather than spending time and money on IT infrastructure management.</p>
<p>There are three main deployment models: public cloud where services are delivered over the public internet and shared across organizations, private cloud where computing resources are used exclusively by one business or organization, and hybrid cloud which combines public and private clouds allowing data and applications to be shared between them. Each model has its own advantages and use cases depending on security requirements, compliance needs, and budget constraints.</p>'
WHERE SubTopicID = 1;
GO

-- SubTopic 2: History and Evolution
UPDATE SubTopics SET ContentBody = N'<h2>History and Evolution of Cloud Computing</h2>
<p>The concept of cloud computing has its roots in the 1960s when computer scientist John McCarthy suggested that computing could someday be organized as a public utility, similar to electricity or water. This vision took decades to materialize, but the foundational technologies were being developed throughout the latter half of the 20th century.</p>
<p>In the 1970s and 1980s, mainframe computing dominated the enterprise landscape. Organizations would purchase or lease large, expensive mainframe computers and share their processing power among many users through time-sharing systems. This was an early form of shared computing resources, though it was limited to a single physical location and organization.</p>
<p>The 1990s brought the rise of the internet and virtualization technology. VMware, founded in 1998, pioneered x86 virtualization which allowed multiple virtual machines to run on a single physical server. This was a crucial enabling technology for cloud computing because it allowed providers to efficiently partition and allocate computing resources to multiple customers from shared hardware infrastructure.</p>
<p>The modern era of cloud computing began in 2006 when Amazon launched Amazon Web Services (AWS) with its Elastic Compute Cloud (EC2) service, allowing anyone to rent virtual servers by the hour. This was revolutionary because it democratized access to computing infrastructure that previously required millions of dollars in capital investment. Google launched Google App Engine in 2008, and Microsoft entered the market with Azure in 2010.</p>
<p>Since then, cloud computing has evolved rapidly. We have seen the emergence of containers with Docker in 2013, container orchestration with Kubernetes in 2014, serverless computing with AWS Lambda in 2014, and the rise of edge computing in recent years. Today, cloud computing is a multi-hundred-billion-dollar industry that underpins virtually every modern technology service from social media and streaming to banking and healthcare.</p>'
WHERE SubTopicID = 2;
GO

-- SubTopic 3 onwards: Generic but educational content for all remaining subtopics
DECLARE @id INT = 3;
WHILE @id <= (SELECT MAX(SubTopicID) FROM SubTopics WHERE IsPublished = 1)
BEGIN
    DECLARE @name NVARCHAR(200);
    SELECT @name = SubTopicName FROM SubTopics WHERE SubTopicID = @id AND IsPublished = 1;
    
    IF @name IS NOT NULL AND (SELECT LEN(ISNULL(ContentBody, '')) FROM SubTopics WHERE SubTopicID = @id) < 200
    BEGIN
        UPDATE SubTopics SET ContentBody = N'<h2>' + @name + N'</h2>
<p>This lesson provides a detailed exploration of <strong>' + @name + N'</strong>, one of the essential topics in cloud computing and modern IT infrastructure. Understanding this concept thoroughly will help you build practical skills that are directly applicable in real-world technology roles.</p>

<h3>What You Will Learn</h3>
<p>In this section, we cover the fundamental principles behind ' + @name + N', explain why it matters in today''s technology landscape, and show you how professionals apply this knowledge in production environments every day. By the end of this lesson, you should be able to explain the concept clearly, identify its key components, and understand how it fits into the broader cloud computing ecosystem.</p>

<h3>Detailed Explanation</h3>
<p>Cloud computing relies on many interconnected concepts working together to deliver scalable, reliable, and secure services. ' + @name + N' is one such concept that plays a critical role in how modern systems are designed, built, and operated. When cloud engineers and architects discuss system design, this topic frequently comes up because it directly impacts decisions about cost, performance, availability, and security.</p>

<p>To understand this properly, consider how traditional IT infrastructure worked before the cloud era. Organizations had to purchase physical servers, install them in data centers, configure networking equipment, set up storage arrays, and hire specialized staff to maintain everything. This process was expensive, slow, and inflexible. If a company needed more capacity for a product launch, they had to order hardware weeks or months in advance and hope they estimated correctly.</p>

<p>Cloud computing changed this completely. With concepts like ' + @name + N', organizations can now provision resources in minutes rather than months, scale automatically based on actual demand rather than forecasts, and pay only for what they actually use rather than maintaining idle capacity. This represents a fundamental shift in how technology is consumed and delivered.</p>

<h3>Key Principles</h3>
<p>There are several important principles to understand when studying this topic:</p>
<p><strong>Abstraction:</strong> Cloud services abstract away the underlying complexity. You do not need to know which specific physical server your application runs on or how the network is physically wired. The cloud provider handles all of that, allowing you to focus on your application logic and business requirements.</p>
<p><strong>Automation:</strong> Repetitive tasks should be automated rather than performed manually. This reduces human error, increases speed, ensures consistency, and allows teams to focus on higher-value work. Infrastructure as Code tools like Terraform and CloudFormation embody this principle.</p>
<p><strong>Resilience:</strong> Systems should be designed to handle failures gracefully. Components will fail, networks will have issues, and services will experience problems. A well-designed system anticipates these failures and continues operating, perhaps in a degraded mode, rather than failing completely.</p>
<p><strong>Security by Default:</strong> Security should not be an afterthought added at the end of a project. It must be baked into every layer of the system from the beginning. This includes encrypting data, controlling access, monitoring for threats, and having incident response plans ready.</p>

<h3>Practical Application</h3>
<p>In practice, professionals apply these concepts daily when building and maintaining cloud-based systems. A typical workflow might involve designing the architecture using proven patterns, writing infrastructure as code to provision resources, deploying application code through automated pipelines, monitoring system health through dashboards and alerts, and continuously iterating to improve performance and reduce costs.</p>

<p>Companies like Netflix, Spotify, Airbnb, and Uber all build their services on cloud infrastructure using these same principles. Netflix, for example, runs entirely on AWS and has pioneered many cloud-native practices including chaos engineering where they deliberately inject failures into their production systems to verify that their resilience measures actually work.</p>

<h3>Preparing for Assessment</h3>
<p>Before attempting the questions below, make sure you can explain what ' + @name + N' is in your own words, describe at least two real-world scenarios where it applies, identify the main benefits and potential challenges, and understand how it relates to other cloud computing concepts you have studied. Take your time with the material and refer back to specific sections if needed.</p>'
        WHERE SubTopicID = @id;
    END
    
    SET @id = @id + 1;
END
GO

PRINT 'All subtopic content updated successfully!';
GO
