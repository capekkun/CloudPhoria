<%@ Page Title="CloudPhoria – Master the Cloud" Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="CloudPhoria._Default" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>CloudPhoria – Master the Cloud</title>
    <link href="Content/bootstrap.css" rel="stylesheet" type="text/css" />
    <style>
        /* =========================================================
           RESET & BASE
           ========================================================= */
        *, *::before, *::after { box-sizing: border-box; }

        html, body {
            margin: 0; padding: 0; height: 100%;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            background: #0B1120;
            color: #FFFFFF;
            overflow-x: hidden;
        }

        a { text-decoration: none; }

        /* =========================================================
           PAGE WRAPPER
           ========================================================= */
        .lp-page {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            background: #0B1120;
            position: relative;
            overflow: hidden;
        }

        /* Background grid pattern */
        .lp-page::before {
            content: '';
            position: absolute;
            inset: 0;
            background-image:
                linear-gradient(rgba(14,165,233,0.04) 1px, transparent 1px),
                linear-gradient(90deg, rgba(14,165,233,0.04) 1px, transparent 1px);
            background-size: 60px 60px;
            pointer-events: none;
            z-index: 0;
        }

        /* Bottom glow */
        .lp-page::after {
            content: '';
            position: absolute;
            bottom: -120px;
            left: 50%;
            transform: translateX(-50%);
            width: 900px;
            height: 400px;
            background: radial-gradient(ellipse at center, rgba(99,102,241,0.18) 0%, transparent 70%);
            pointer-events: none;
            z-index: 0;
        }

        /* =========================================================
           TOP NAVIGATION
           ========================================================= */
        .lp-nav {
            position: relative;
            z-index: 10;
            display: flex;
            align-items: center;
            padding: 0 40px;
            height: 64px;
            border-bottom: 1px solid rgba(255,255,255,0.06);
            background: rgba(11,17,32,0.85);
            backdrop-filter: blur(8px);
            gap: 0;
        }

        /* Brand */
        .lp-brand {
            display: flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
            flex-shrink: 0;
            margin-right: 32px;
        }
        .lp-brand-icon {
            width: 36px;
            height: 36px;
            background: linear-gradient(135deg, #0EA5E9 0%, #6366F1 100%);
            border-radius: 9px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            font-weight: 900;
            color: #fff;
            flex-shrink: 0;
            letter-spacing: -1px;
        }
        .lp-brand-name {
            font-size: 18px;
            font-weight: 700;
            color: #FFFFFF;
            letter-spacing: -0.3px;
        }
        .lp-brand-name em {
            font-style: normal;
            color: #0EA5E9;
        }

        /* Centre nav links */
        .lp-nav-links {
            display: flex;
            align-items: center;
            gap: 4px;
            flex: 1;
            list-style: none;
            margin: 0;
            padding: 0;
        }
        .lp-nav-links li a {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            color: rgba(255,255,255,0.7);
            font-size: 13.5px;
            font-weight: 500;
            border-radius: 7px;
            transition: background 0.15s, color 0.15s;
        }
        .lp-nav-links li a:hover {
            background: rgba(255,255,255,0.07);
            color: #FFFFFF;
        }
        .lp-nav-links .nav-icon {
            font-size: 15px;
            opacity: 0.7;
        }

        /* Right nav actions */
        .lp-nav-actions {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-shrink: 0;
            margin-left: 16px;
        }
        .lp-btn-ghost {
            padding: 7px 18px;
            border: 1.5px solid rgba(255,255,255,0.22);
            border-radius: 7px;
            color: rgba(255,255,255,0.85);
            font-size: 13.5px;
            font-weight: 500;
            transition: border-color 0.15s, color 0.15s;
        }
        .lp-btn-ghost:hover {
            border-color: #0EA5E9;
            color: #0EA5E9;
        }
        .lp-btn-green {
            padding: 7px 18px;
            background: #0EA5E9;
            border: 1.5px solid #0EA5E9;
            border-radius: 7px;
            color: #FFFFFF;
            font-size: 13.5px;
            font-weight: 700;
            letter-spacing: 0.01em;
            transition: background 0.15s, border-color 0.15s;
        }
        .lp-btn-green:hover {
            background: #0284C7;
            border-color: #0284C7;
            color: #FFFFFF;
        }

        /* =========================================================
           HERO SECTION
           ========================================================= */
        .lp-hero {
            position: relative;
            z-index: 1;
            flex: 1;
            display: flex;
            align-items: center;
            padding: 0 40px;
            min-height: calc(100vh - 64px - 54px);
            gap: 0;
        }

        /* Left: text content */
        .lp-hero-text {
            flex: 1;
            max-width: 560px;
            padding: 60px 0;
        }

        .lp-hero-text h1 {
            font-size: 48px;
            font-weight: 800;
            line-height: 1.12;
            color: #FFFFFF;
            margin: 0 0 16px 0;
            letter-spacing: -0.5px;
        }
        .lp-hero-text h1 .hl {
            color: #0EA5E9;
        }

        .lp-hero-text p {
            font-size: 16px;
            color: rgba(255,255,255,0.6);
            line-height: 1.7;
            margin: 0 0 32px 0;
            max-width: 460px;
        }

        /* CTA buttons row */
        .lp-cta-row {
            display: flex;
            align-items: center;
            gap: 14px;
            flex-wrap: wrap;
            margin-bottom: 24px;
        }
        .lp-cta-primary {
            padding: 13px 28px;
            background: #0EA5E9;
            color: #FFFFFF;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 700;
            border: 2px solid #0EA5E9;
            transition: all 0.15s;
            letter-spacing: 0.01em;
        }
        .lp-cta-primary:hover {
            background: #0284C7;
            border-color: #0284C7;
            color: #FFFFFF;
            transform: translateY(-1px);
        }
        .lp-cta-outline {
            padding: 13px 28px;
            background: transparent;
            color: rgba(255,255,255,0.85);
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            border: 2px solid rgba(255,255,255,0.2);
            transition: all 0.15s;
        }
        .lp-cta-outline:hover {
            border-color: rgba(255,255,255,0.5);
            color: #FFFFFF;
        }

        /* Checklist row */
        .lp-checklist {
            display: flex;
            gap: 22px;
            flex-wrap: wrap;
        }
        .lp-checklist-item {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 13.5px;
            color: rgba(255,255,255,0.65);
        }
        .lp-checklist-item .check {
            color: #0EA5E9;
            font-size: 14px;
            font-weight: 700;
        }

        /* Right: decorative visual */
        .lp-hero-visual {
            flex: 0 0 480px;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 0 40px 40px;
            position: relative;
        }

        /* Cloud character SVG illustration */
        .lp-cloud-char {
            width: 380px;
            height: 380px;
            position: relative;
            filter: drop-shadow(0 0 60px rgba(14,165,233,0.25));
            animation: float 4s ease-in-out infinite;
        }
        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50%       { transform: translateY(-18px); }
        }

        /* Glow behind the character */
        .lp-hero-visual::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 320px;
            height: 320px;
            background: radial-gradient(circle, rgba(14,165,233,0.15) 0%, transparent 70%);
            border-radius: 50%;
            pointer-events: none;
        }

        /* =========================================================
           FOOTER STRIP
           ========================================================= */
        .lp-footer {
            position: relative;
            z-index: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 16px 40px;
            border-top: 1px solid rgba(255,255,255,0.06);
            font-size: 12px;
            color: rgba(255,255,255,0.28);
            gap: 24px;
        }
        .lp-footer a {
            color: rgba(255,255,255,0.35);
            transition: color 0.15s;
        }
        .lp-footer a:hover { color: rgba(255,255,255,0.7); }

        /* =========================================================
           RESPONSIVE
           ========================================================= */
        @media (max-width: 1024px) {
            .lp-hero-visual { flex: 0 0 340px; }
            .lp-cloud-char  { width: 300px; height: 300px; }
            .lp-hero-text h1 { font-size: 38px; }
        }

        @media (max-width: 768px) {
            .lp-nav { padding: 0 20px; }
            .lp-nav-links { display: none; }
            .lp-hero { flex-direction: column; padding: 32px 20px; min-height: auto; text-align: center; }
            .lp-hero-text { max-width: 100%; padding: 32px 0 0; }
            .lp-hero-text h1 { font-size: 30px; }
            .lp-hero-text p { font-size: 14px; }
            .lp-cta-row { justify-content: center; }
            .lp-checklist { justify-content: center; }
            .lp-hero-visual { flex: none; width: 100%; padding: 20px 0; }
            .lp-cloud-char { width: 220px; height: 220px; }
            .lp-footer { flex-wrap: wrap; gap: 12px; padding: 14px 20px; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="lp-page">

    <%-- =====================================================
         TOP NAVIGATION
         ===================================================== --%>
    <nav class="lp-nav" aria-label="Main navigation">

        <%-- Brand --%>
        <a class="lp-brand" href="Default.aspx" aria-label="CloudPhoria home">
            <div class="lp-brand-icon" aria-hidden="true">CP</div>
            <span class="lp-brand-name">Cloud<em>Phoria</em></span>
        </a>

        <%-- Centre navigation links — mirror TryHackMe's category nav --%>
        <ul class="lp-nav-links" role="list">
            <li>
                <a href="Student/Pathways.aspx">
                    <span class="nav-icon" aria-hidden="true">&#x2601;&#xFE0F;</span>
                    Pathways
                </a>
            </li>
            <li>
                <a href="Student/BossFights.aspx">
                    <span class="nav-icon" aria-hidden="true">&#x1F480;</span>
                    Boss Fights
                </a>
            </li>
            <li>
                <a href="Student/Challenges.aspx">
                    <span class="nav-icon" aria-hidden="true">&#x26A1;</span>
                    Challenges
                </a>
            </li>
            <li>
                <a href="Student/Upgrade.aspx">
                    <span class="nav-icon" aria-hidden="true">&#x1F4B0;</span>
                    Pricing
                </a>
            </li>
        </ul>

        <%-- Right actions --%>
        <div class="lp-nav-actions">
            <a class="lp-btn-ghost" href="#browse" style="color:rgba(255,255,255,0.6);">Browse Pathways</a>
            <a class="lp-btn-ghost" href="LogIn.aspx">Log In</a>
            <a class="lp-btn-green" href="Register.aspx">Join for Free</a>
        </div>

    </nav>

    <%-- =====================================================
         HERO — split layout: text left, visual right
         ===================================================== --%>
    <section class="lp-hero" aria-labelledby="heroHeadline">

        <%-- Left: headline + CTA --%>
        <div class="lp-hero-text">

            <h1 id="heroHeadline">
                Anyone can master<br />
                <span class="hl">cloud computing</span><br />
                with CloudPhoria
            </h1>

            <p>
                Hands-on cloud computing training through guided pathways,
                interactive modules, and gamified challenges.
            </p>

            <div class="lp-cta-row">
                <a class="lp-cta-primary" href="Register.aspx">Join for Free</a>
                <a class="lp-cta-outline" href="LogIn.aspx">Sign In</a>
            </div>

            <div class="lp-checklist" role="list">
                <div class="lp-checklist-item" role="listitem">
                    <span class="check" aria-hidden="true">&#x2713;</span>
                    Beginner-friendly
                </div>
                <div class="lp-checklist-item" role="listitem">
                    <span class="check" aria-hidden="true">&#x2713;</span>
                    Guided pathways
                </div>
                <div class="lp-checklist-item" role="listitem">
                    <span class="check" aria-hidden="true">&#x2713;</span>
                    XP &amp; badges
                </div>
                <div class="lp-checklist-item" role="listitem">
                    <span class="check" aria-hidden="true">&#x2713;</span>
                    Boss fights &amp; challenges
                </div>
            </div>

        </div>

        <%-- Right: decorative cloud character SVG --%>
        <div class="lp-hero-visual" aria-hidden="true">
            <svg class="lp-cloud-char"
                 viewBox="0 0 380 380"
                 fill="none"
                 xmlns="http://www.w3.org/2000/svg"
                 role="img"
                 aria-label="CloudPhoria mascot">

                <!-- Outer glow ring -->
                <circle cx="190" cy="190" r="170" fill="url(#outerGlow)" opacity="0.18"/>

                <!-- Body: rounded cloud shape -->
                <ellipse cx="190" cy="210" rx="110" ry="90" fill="url(#bodyGrad)"/>

                <!-- Cloud bumps on top -->
                <circle cx="140" cy="165" r="48" fill="url(#bodyGrad)"/>
                <circle cx="190" cy="148" r="56" fill="url(#bodyGrad)"/>
                <circle cx="242" cy="162" r="44" fill="url(#bodyGrad)"/>

                <!-- Inner highlight on cloud -->
                <ellipse cx="180" cy="158" rx="36" ry="22" fill="white" opacity="0.08"/>

                <!-- Visor / face plate -->
                <ellipse cx="190" cy="210" rx="62" ry="44" fill="url(#visorGrad)" opacity="0.95"/>
                <!-- Visor shine -->
                <ellipse cx="175" cy="198" rx="22" ry="12" fill="white" opacity="0.12"/>

                <!-- Eyes -->
                <circle cx="172" cy="208" r="10" fill="#0B1120"/>
                <circle cx="208" cy="208" r="10" fill="#0B1120"/>
                <!-- Eye pupils / glow -->
                <circle cx="172" cy="208" r="5" fill="#0EA5E9"/>
                <circle cx="208" cy="208" r="5" fill="#0EA5E9"/>
                <circle cx="174" cy="206" r="2" fill="white" opacity="0.7"/>
                <circle cx="210" cy="206" r="2" fill="white" opacity="0.7"/>

                <!-- Antenna -->
                <line x1="190" y1="92" x2="190" y2="118" stroke="#6366F1" stroke-width="4" stroke-linecap="round"/>
                <circle cx="190" cy="88" r="8" fill="#6366F1"/>
                <circle cx="190" cy="88" r="4" fill="#A5B4FC"/>

                <!-- Left arm -->
                <path d="M90 230 Q62 218 58 240 Q54 262 78 266 Q96 268 100 252 Z"
                      fill="url(#bodyGrad)"/>
                <!-- Right arm -->
                <path d="M290 230 Q318 218 322 240 Q326 262 302 266 Q284 268 280 252 Z"
                      fill="url(#bodyGrad)"/>

                <!-- Left hand glow (holding data) -->
                <circle cx="62" cy="248" r="14" fill="#0EA5E9" opacity="0.25"/>
                <circle cx="62" cy="248" r="8"  fill="#0EA5E9" opacity="0.6"/>

                <!-- Right hand glow (holding data) -->
                <circle cx="318" cy="248" r="14" fill="#6366F1" opacity="0.25"/>
                <circle cx="318" cy="248" r="8"  fill="#6366F1" opacity="0.6"/>

                <!-- Legs -->
                <rect x="158" y="290" width="26" height="52" rx="13" fill="url(#bodyGrad)"/>
                <rect x="196" y="290" width="26" height="52" rx="13" fill="url(#bodyGrad)"/>

                <!-- Boots -->
                <ellipse cx="171" cy="342" rx="22" ry="10" fill="#0EA5E9" opacity="0.8"/>
                <ellipse cx="209" cy="342" rx="22" ry="10" fill="#0EA5E9" opacity="0.8"/>

                <!-- Floating data orbs around character -->
                <circle cx="52"  cy="160" r="8"  fill="#0EA5E9" opacity="0.5"/>
                <circle cx="44"  cy="180" r="4"  fill="#6366F1" opacity="0.5"/>
                <circle cx="330" cy="155" r="6"  fill="#6366F1" opacity="0.5"/>
                <circle cx="340" cy="178" r="10" fill="#0EA5E9" opacity="0.4"/>
                <circle cx="120" cy="96"  r="5"  fill="#0EA5E9" opacity="0.4"/>
                <circle cx="265" cy="88"  r="7"  fill="#6366F1" opacity="0.4"/>

                <!-- XP tag floating top-right -->
                <rect x="276" y="108" width="56" height="24" rx="12" fill="#F59E0B" opacity="0.9"/>
                <text x="304" y="124" text-anchor="middle"
                      font-family="sans-serif" font-size="11" font-weight="700"
                      fill="#0B1120">+150 XP</text>

                <!-- Badge floating top-left -->
                <rect x="50" y="108" width="54" height="24" rx="12" fill="#22C55E" opacity="0.85"/>
                <text x="77" y="124" text-anchor="middle"
                      font-family="sans-serif" font-size="11" font-weight="700"
                      fill="#0B1120">&#x1F3C5; Badge</text>

                <!-- Gradient definitions -->
                <defs>
                    <radialGradient id="outerGlow" cx="50%" cy="50%" r="50%">
                        <stop offset="0%"   stop-color="#0EA5E9"/>
                        <stop offset="100%" stop-color="#0B1120" stop-opacity="0"/>
                    </radialGradient>
                    <linearGradient id="bodyGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                        <stop offset="0%"   stop-color="#1E3A5F"/>
                        <stop offset="100%" stop-color="#0F2847"/>
                    </linearGradient>
                    <linearGradient id="visorGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                        <stop offset="0%"   stop-color="#0EA5E9" stop-opacity="0.9"/>
                        <stop offset="100%" stop-color="#6366F1" stop-opacity="0.85"/>
                    </linearGradient>
                </defs>
            </svg>
        </div>

    </section>

    <%-- =====================================================
         GUEST BROWSE — Read-only pathway/module preview
         ===================================================== --%>
    <section id="browse" style="position:relative;z-index:1;padding:60px 32px;max-width:1100px;margin:0 auto;">
        <h2 style="font-size:28px;font-weight:800;text-align:center;margin:0 0 8px;">
            &#x1F4DA; Explore Learning Pathways
        </h2>
        <p style="text-align:center;color:rgba(255,255,255,0.5);font-size:14px;margin:0 0 32px;">
            Preview our pathways and modules. Create a free account to start learning.
        </p>
        <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:16px;">
            <asp:Literal ID="litGuestPathways" runat="server" />
        </div>
        <div style="text-align:center;margin-top:32px;">
            <a href="Register.aspx" style="display:inline-block;padding:14px 32px;
                background:linear-gradient(90deg,#0EA5E9,#6366F1);color:#fff;font-size:15px;
                font-weight:700;border-radius:10px;text-decoration:none;">
                Join for Free to Start Learning &#x1F680;
            </a>
        </div>
    </section>

    <%-- =====================================================
         FOOTER STRIP
         ===================================================== --%>
    <footer class="lp-footer">
        <span>&copy; <%: DateTime.Now.Year %> CloudPhoria</span>
        <a href="Default.aspx">Home</a>
        <a href="LogIn.aspx">Log In</a>
        <a href="Register.aspx">Join for Free</a>
        <span>CT050-3-2-WAPP</span>
    </footer>

</div>
</form>
<script src="Scripts/bootstrap.bundle.js"></script>
</body>
</html>
