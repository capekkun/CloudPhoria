-- ============================================================
-- Fix: Badges.IconPath values used kebab-case filenames
-- (e.g. cloud-starter.png) that don't match the actual uploaded
-- files in /uploads/badges/, which are named with underscores
-- and Title Case (e.g. Cloud_Starter.png). This made every
-- badge icon a broken image on Achievements.aspx.
--
-- Safe to re-run.
-- ============================================================
USE CloudPhoria;
GO

UPDATE Badges SET IconPath = '/uploads/badges/Cloud_Starter.png'         WHERE BadgeName = 'Cloud Starter';
UPDATE Badges SET IconPath = '/uploads/badges/Service_Explorer.png'      WHERE BadgeName = 'Service Explorer';
UPDATE Badges SET IconPath = '/uploads/badges/Deployment_Pro.png'        WHERE BadgeName = 'Deployment Pro';
UPDATE Badges SET IconPath = '/uploads/badges/Cloud_Economist.png'       WHERE BadgeName = 'Cloud Economist';
UPDATE Badges SET IconPath = '/uploads/badges/Architecture_Beginner.png' WHERE BadgeName = 'Architecture Beginner';
UPDATE Badges SET IconPath = '/uploads/badges/HA_Designer.png'           WHERE BadgeName = 'HA Designer';
UPDATE Badges SET IconPath = '/uploads/badges/Microservices_Master.png'  WHERE BadgeName = 'Microservices Master';
UPDATE Badges SET IconPath = '/uploads/badges/Cost_Optimizer.png'        WHERE BadgeName = 'Cost Optimizer';
UPDATE Badges SET IconPath = '/uploads/badges/Security_Aware.png'        WHERE BadgeName = 'Security Aware';
UPDATE Badges SET IconPath = '/uploads/badges/IAM_Expert.png'            WHERE BadgeName = 'IAM Expert';
UPDATE Badges SET IconPath = '/uploads/badges/Encryption_Guard.png'      WHERE BadgeName = 'Encryption Guard';
UPDATE Badges SET IconPath = '/uploads/badges/Compliance_Pro.png'        WHERE BadgeName = 'Compliance Pro';
UPDATE Badges SET IconPath = '/uploads/badges/DevOps_Initiate.png'       WHERE BadgeName = 'DevOps Initiate';
UPDATE Badges SET IconPath = '/uploads/badges/Pipeline_Builder.png'      WHERE BadgeName = 'Pipeline Builder';
UPDATE Badges SET IconPath = '/uploads/badges/IaC_Engineer.png'          WHERE BadgeName = 'IaC Engineer';
UPDATE Badges SET IconPath = '/uploads/badges/Observability_Guru.png'    WHERE BadgeName = 'Observability Guru';
UPDATE Badges SET IconPath = '/uploads/badges/Data_Starter.png'          WHERE BadgeName = 'Data Starter';
UPDATE Badges SET IconPath = '/uploads/badges/Database_Specialist.png'   WHERE BadgeName = 'Database Specialist';
UPDATE Badges SET IconPath = '/uploads/badges/Pipeline_Architect.png'    WHERE BadgeName = 'Pipeline Architect';
UPDATE Badges SET IconPath = '/uploads/badges/Analytics_Expert.png'      WHERE BadgeName = 'Analytics Expert';
UPDATE Badges SET IconPath = '/uploads/badges/Network_Novice.png'        WHERE BadgeName = 'Network Novice';
UPDATE Badges SET IconPath = '/uploads/badges/VPC_Designer.png'          WHERE BadgeName = 'VPC Designer';
UPDATE Badges SET IconPath = '/uploads/badges/Traffic_Manager.png'       WHERE BadgeName = 'Traffic Manager';
UPDATE Badges SET IconPath = '/uploads/badges/Hybrid_Connector.png'      WHERE BadgeName = 'Hybrid Connector';
UPDATE Badges SET IconPath = '/uploads/badges/Serverless_Starter.png'    WHERE BadgeName = 'Serverless Starter';
UPDATE Badges SET IconPath = '/uploads/badges/Container_Captain.png'     WHERE BadgeName = 'Container Captain';
UPDATE Badges SET IconPath = '/uploads/badges/K8s_Commander.png'         WHERE BadgeName = 'K8s Commander';
UPDATE Badges SET IconPath = '/uploads/badges/Serverless_Architect.png'  WHERE BadgeName = 'Serverless Architect';
GO

-- Verify
SELECT BadgeID, ModuleID, BadgeName, IconPath FROM Badges ORDER BY ModuleID;
GO
