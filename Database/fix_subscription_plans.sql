USE CloudPhoria;
GO

-- ============================================================
-- FIX SUBSCRIPTION PLANS: Simplify to Free and Pro only
-- ============================================================

-- Update existing plans to just Free and Pro
UPDATE SubscriptionPlans SET PlanName = 'Free', Price = 0.00, 
    CanAccessFoundationOnly = 1, 
    Description = 'Foundation pathway only. Limited access to learning content.'
WHERE PlanID = 1;

UPDATE SubscriptionPlans SET PlanName = 'Pro', Price = 9.99, 
    CanAccessFoundationOnly = 0, 
    Description = 'Full access to all pathways, certifications, fun rooms, and boss fights.'
WHERE PlanID = 2;

-- Remove the third plan (Student) if it exists — reassign anyone on PlanID 3 to Pro (2)
UPDATE UserSubscriptions SET PlanID = 2 WHERE PlanID = 3;
DELETE FROM SubscriptionPlans WHERE PlanID = 3;
GO

PRINT 'Subscription plans updated: Free + Pro only.';
GO
