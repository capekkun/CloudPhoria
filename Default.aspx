<%@ Page Title="Welcome to CloudPhoria" Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="CloudPhoria._Default" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Welcome to CloudPhoria</title>
    <link href="Content/bootstrap.css" rel="stylesheet" type="text/css" />
    <link href="Content/Site.css" rel="stylesheet" type="text/css" />
    <style>
        /* Landing page specific styles */
        .cp-landing {
            min-height: 100vh;
            background: linear-gradient(135deg, #0F172A 0%, #172033 50%, #0F172A 100%);
            display: flex;
            flex-direction: column;
        }

        /* Top nav bar */
        .cp-landing-nav {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 20px 48px;
            flex-shrink: 0;
        }
        .cp-landing-brand {
            display: flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
        }
        .cp-landing-logo {
            width: 38px;
            height: 38px;
            background: linear-gradient(135deg, #0EA5E9, #6366F1);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            font-weight: 800;
            color: #fff;
        }
        .cp-landing-wordmark {
            font-size: 20px;
            font-weight: 700;
            color: #FFFFFF;
            letter-spacing: -0.3px;
        }
        .cp-landing-wordmark span { color: #0EA5E9; }

        .cp-landing-nav-actions {
            display: flex;
            gap: 12px;
            align-items: center;
        }
        .cp-landing-btn-outline {
            padding: 8px 20px;
            border: 1px solid rgba(255,255,255,0.25);
            border-radius: 8px;
            color: rgba(255,255,255,0.85);
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.15s;
        }
        .cp-landing-btn-outline:hover {
            border-color: #0EA5E9;
            color: #0EA5E9;
            text-decoration: none;
        }
        .cp-landing-btn-primary {
            padding: 8px 20px;
            background: #0EA5E9;
            border: 1px solid #0EA5E9;
            border-radius: 8px;
            color: #ffffff;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.15s;
        }
        .cp-landing-btn-primary:hover {
            background: #0284C7;
            border-color: #0284C7;
            color: #ffffff;
            text-decoration: none;
        }

        /* Hero section */
        .cp-landing-hero {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            padding: 60px 24px 80px;
        }
        .cp-landing-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(14,165,233,0.12);
            border: 1px solid rgba(14,165,233,0.3);
            color: #0EA5E9;
            padding: 5px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.04em;
            text-transform: uppercase;
            margin-bottom: 28px;
        }
        .cp-landing-hero h1 {
            font-size: 56px;
            font-weight: 800;
            color: #FFFFFF;
            line-height: 1.1;
            margin: 0 0 12px 0;
            letter-spacing: -1px;
            max-width: 700px;
        }
        .cp-landing-hero h1 span { color: #0EA5E9; }
        .cp-landing-hero p {
            font-size: 18px;
            color: rgba(255,255,255,0.6);
            max-width: 520px;
            margin: 0 0 40px 0;
            line-height: 1.7;
        }
        .cp-landing-cta {
            display: flex;
            gap: 14px;
            justify-content: center;
            flex-wrap: wrap;
        }
        .cp-cta-primary {
            padding: 14px 32px;
            background: #0EA5E9;
            color: #ffffff;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.15s;
            border: 2px solid #0EA5E9;
        }
        .cp-cta-primary:hover {
            background: #0284C7;
            border-color: #0284C7;
            color: #ffffff;
            text-decoration: none;
            transform: translateY(-1px);
        }
        .cp-cta-secondary {
            padding: 14px 32px;
            background: transparent;
            color: rgba(255,255,255,0.8);
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.15s;
            border: 2px solid rgba(255,255,255,0.2);
        }
        .cp-cta-secondary:hover {
            border-color: rgba(255,255,255,0.5);
            color: #ffffff;
            text-decoration: none;
        }

        /* Feature cards row */
        .cp-landing-features {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
            max-width: 860px;
            margin: 60px auto 0;
            padding: 0 24px;
            width: 100%;
        }
        .cp-feature-card {
            background: rgba(255,255,255,0.04);
            border: 1px solid rgba(255,255,255,0.08);
            border-radius: 14px;
            padding: 24px;
            text-align: left;
        }
        .cp-feature-icon {
            font-size: 26px;
            margin-bottom: 12px;
            display: block;
        }
        .cp-feature-card h3 {
            font-size: 15px;
            font-weight: 600;
            color: #FFFFFF;
            margin: 0 0 6px 0;
        }
        .cp-feature-card p {
            font-size: 13px;
            color: rgba(255,255,255,0.5);
            margin: 0;
            line-height: 1.6;
        }

        /* Footer */
        .cp-landing-footer {
            text-align: center;
            padding: 24px;
            color: rgba(255,255,255,0.3);
            font-size: 13px;
            border-top: 1px solid rgba(255,255,255,0.06);
        }

        /* Responsive */
        @media (max-width: 768px) {
            .cp-landing-nav { padding: 16px 20px; }
            .cp-landing-hero h1 { font-size: 36px; }
            .cp-landing-hero p { font-size: 15px; }
            .cp-landing-features { grid-template-columns: 1fr; }
            .cp-landing-nav-actions .cp-landing-btn-outline { display: none; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <div class="cp-landing">

        <%-- Top navigation bar --%>
        <nav class="cp-landing-nav" aria-label="Site navigation">
            <a class="cp-landing-brand" href="Default.aspx">
                <div class="cp-landing-logo" aria-hidden="true">CP</div>
                <span class="cp-landing-wordmark">Cloud<span>Phoria</span></span>
            </a>
            <div class="cp-landing-nav-actions">
                <a class="cp-landing-btn-outline" href="Guest/Learn.aspx">Try as Guest</a>
                <a class="cp-landing-btn-primary" href="LogIn.aspx">Log In</a>
            </div>
        </nav>

        <%-- Hero --%>
        <section class="cp-landing-hero" aria-labelledby="heroTitle">
            <div class="cp-landing-badge">&#x2601; Cloud Computing Learning Platform</div>
            <h1 id="heroTitle">Master the Cloud,<br /><span>Level Up Your Skills</span></h1>
            <p>
                A gamified learning platform for cloud computing. Earn XP, unlock badges,
                battle bosses, and build real skills — one module at a time.
            </p>
            <div class="cp-landing-cta">
                <a class="cp-cta-primary" href="LogIn.aspx">Get Started</a>
                <a class="cp-cta-secondary" href="Guest/Learn.aspx">Explore as Guest</a>
            </div>
        </section>

        <%-- Feature highlights --%>
        <div class="cp-landing-features">
            <div class="cp-feature-card">
                <span class="cp-feature-icon" aria-hidden="true">&#x1F4DA;</span>
                <h3>Structured Pathways</h3>
                <p>Follow guided cloud learning tracks from foundation to specialisation.</p>
            </div>
            <div class="cp-feature-card">
                <span class="cp-feature-icon" aria-hidden="true">&#x1F3C5;</span>
                <h3>XP &amp; Achievements</h3>
                <p>Earn experience points, unlock badges, and earn certifications as you progress.</p>
            </div>
            <div class="cp-feature-card">
                <span class="cp-feature-icon" aria-hidden="true">&#x1F480;</span>
                <h3>Boss Fights</h3>
                <p>Test your knowledge in dramatic boss battle rooms with real stakes.</p>
            </div>
        </div>

        <%-- Footer --%>
        <footer class="cp-landing-footer">
            <p>&copy; <%: DateTime.Now.Year %> CloudPhoria &mdash; CT050-3-2-WAPP</p>
        </footer>

    </div>

</form>
<script src="Scripts/bootstrap.bundle.js"></script>
</body>
</html>
