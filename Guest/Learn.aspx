<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Learn.aspx.cs" Inherits="CloudPhoria.Guest.Learn" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Learn – CloudPhoria</title>
<link href="../Content/bootstrap.css" rel="stylesheet" type="text/css" />
<style>
/* ================================================================
   GLOBAL RESET — override Site.css dashboard rules on this page
   ================================================================ */
*, *::before, *::after { box-sizing: border-box; }
html, body {
    margin: 0; padding: 0;
    height: auto !important;
    min-height: 100vh;
    overflow-x: hidden !important;
    overflow-y: auto !important;
    background: #0B1120;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
    color: #FFFFFF;
}
.cp-layout { height: auto !important; overflow: visible !important; }
a { text-decoration: none; }
</style>
</head>
<body>
<form id="form1" runat="server">
<div style="min-height:100vh;display:flex;flex-direction:column;">

<%-- ============================================================ HEADER ============================================================ --%>
<style>
.gl-hdr{background:#0F172A;border-bottom:1px solid rgba(255,255,255,0.07);position:sticky;top:0;z-index:300;}
.gl-hdr-in{display:flex;align-items:center;padding:0 40px;height:58px;gap:28px;}
.gl-brand{display:flex;align-items:center;gap:9px;text-decoration:none;flex-shrink:0;}
.gl-brand-logo{width:34px;height:34px;background:linear-gradient(135deg,#0EA5E9,#6366F1);border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:900;color:#fff;}
.gl-brand-name{font-size:17px;font-weight:700;color:#fff;letter-spacing:-0.3px;}
.gl-brand-name em{font-style:normal;color:#0EA5E9;}
.gl-nav-links{display:flex;align-items:center;gap:2px;flex:1;list-style:none;margin:0;padding:0;}
.gl-nav-links a{display:flex;align-items:center;gap:6px;padding:6px 13px;color:rgba(255,255,255,0.65);font-size:13px;font-weight:500;border-radius:7px;transition:background 0.15s,color 0.15s;}
.gl-nav-links a:hover{background:rgba(255,255,255,0.07);color:#fff;}
.gl-nav-links a.active{color:#0EA5E9;font-weight:600;}
.gl-nav-acts{display:flex;gap:10px;align-items:center;flex-shrink:0;}
.gl-btn-login{padding:6px 18px;border:1.5px solid rgba(255,255,255,0.22);border-radius:7px;color:rgba(255,255,255,0.85);font-size:13px;font-weight:500;transition:border-color 0.15s,color 0.15s;}
.gl-btn-login:hover{border-color:#0EA5E9;color:#0EA5E9;}
.gl-btn-join{padding:6px 18px;background:#0EA5E9;border-radius:7px;color:#fff;font-size:13px;font-weight:700;transition:background 0.15s;}
.gl-btn-join:hover{background:#0284C7;color:#fff;}
@media(max-width:768px){.gl-nav-links{display:none;}.gl-hdr-in{padding:0 16px;}}
</style>
<header class="gl-hdr">
    <div class="gl-hdr-in">
        <a class="gl-brand" href="../Default.aspx">
            <div class="gl-brand-logo" aria-hidden="true">CP</div>
            <span class="gl-brand-name">Cloud<em>Phoria</em></span>
        </a>
        <ul class="gl-nav-links" role="list">
            <li><a href="Learn.aspx" class="active">&#x1F4DA; Learn</a></li>
            <li><a href="#">&#x270F; Practice</a></li>
            <li><a href="#">&#x26A1; Challenges</a></li>
            <li><a href="#">&#x1F3EB; Classrooms</a></li>
            <li><a href="#">&#x1F4B0; Pricing</a></li>
            <li><a href="#">&#x1F3C5; Certifications</a></li>
        </ul>
        <div class="gl-nav-acts">
            <a class="gl-btn-login" href="../LogIn.aspx">Log In</a>
            <a class="gl-btn-join"  href="../LogIn.aspx">Join for Free</a>
        </div>
    </div>
</header>

<%-- ============================================================ HERO ============================================================ --%>
<style>
.gl-hero{background:linear-gradient(135deg,#0F172A 0%,#1A2744 55%,#0F172A 100%);position:relative;overflow:hidden;}
.gl-hero::before{content:'';position:absolute;inset:0;background-image:linear-gradient(rgba(14,165,233,0.04) 1px,transparent 1px),linear-gradient(90deg,rgba(14,165,233,0.04) 1px,transparent 1px);background-size:48px 48px;pointer-events:none;}
.gl-hero-in{max-width:1280px;margin:0 auto;padding:52px 40px 56px;display:flex;align-items:center;gap:40px;position:relative;z-index:1;}
.gl-hero-text{flex:1;}
.gl-hero-text h1{font-size:48px;font-weight:800;color:#fff;margin:0 0 14px;letter-spacing:-0.5px;line-height:1.1;}
.gl-hero-text p{font-size:15px;color:rgba(255,255,255,0.6);max-width:540px;line-height:1.75;margin:0 0 32px;}
.gl-stats{display:flex;gap:40px;flex-wrap:wrap;}
.gl-stat-num{font-size:26px;font-weight:800;color:#fff;display:block;}
.gl-stat-lbl{font-size:12px;color:rgba(255,255,255,0.45);margin-top:2px;display:block;}
.gl-hero-vis{flex:0 0 300px;display:flex;align-items:center;justify-content:center;position:relative;}
.gl-hero-glow{position:absolute;width:260px;height:260px;border-radius:50%;background:radial-gradient(circle,rgba(14,165,233,0.2) 0%,transparent 70%);}
@keyframes glHeroFloat{0%,100%{transform:translateY(0);}50%{transform:translateY(-14px);}}
.gl-hero-svg{animation:glHeroFloat 4s ease-in-out infinite;filter:drop-shadow(0 0 40px rgba(14,165,233,0.3));}
@media(max-width:768px){.gl-hero-in{flex-direction:column;padding:32px 20px 40px;}.gl-hero-text h1{font-size:32px;}.gl-hero-vis{display:none;}}
</style>
<section class="gl-hero" aria-labelledby="heroTitle">
    <div class="gl-hero-in">
        <div class="gl-hero-text">
            <h1 id="heroTitle">Learn</h1>
            <p>Master cloud computing the fun way — free, interactive, and guided. Follow structured pathways, complete modules, earn XP and badges, and battle bosses to prove your skills at every level.</p>
            <div class="gl-stats">
                <div><span class="gl-stat-num"><asp:Literal ID="litPathwayCount" runat="server" Text="7"/>+</span><span class="gl-stat-lbl">Learning Pathways</span></div>
                <div><span class="gl-stat-num"><asp:Literal ID="litModuleCount" runat="server" Text="0"/>+</span><span class="gl-stat-lbl">Cloud Modules</span></div>
                <div><span class="gl-stat-num">6+</span><span class="gl-stat-lbl">Certifications</span></div>
            </div>
        </div>
        <div class="gl-hero-vis" aria-hidden="true">
            <div class="gl-hero-glow"></div>
            <svg class="gl-hero-svg" width="260" height="220" viewBox="0 0 260 220" fill="none" xmlns="http://www.w3.org/2000/svg">
                <defs>
                    <linearGradient id="hg1" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="#1E3A5F"/><stop offset="100%" stop-color="#0F2847"/></linearGradient>
                    <linearGradient id="hg2" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="#0EA5E9" stop-opacity="0.9"/><stop offset="100%" stop-color="#6366F1" stop-opacity="0.85"/></linearGradient>
                </defs>
                <rect x="20" y="130" width="220" height="16" rx="6" fill="#1E3A5F"/>
                <ellipse cx="130" cy="146" rx="110" ry="5" fill="rgba(14,165,233,0.15)"/>
                <rect x="35" y="30" width="190" height="106" rx="10" fill="url(#hg1)" stroke="rgba(14,165,233,0.3)" stroke-width="1.5"/>
                <text x="130" y="75" text-anchor="middle" font-size="28" fill="#0EA5E9">&#x2601;</text>
                <rect x="70" y="90" width="30" height="5" rx="2.5" fill="rgba(14,165,233,0.5)"/>
                <rect x="115" y="90" width="50" height="5" rx="2.5" fill="rgba(99,102,241,0.5)"/>
                <rect x="90" y="100" width="80" height="5" rx="2.5" fill="rgba(14,165,233,0.3)"/>
                <rect x="38" y="33" width="186" height="40" rx="8" fill="url(#hg2)" opacity="0.08"/>
                <rect x="168" y="16" width="52" height="22" rx="11" fill="#F59E0B"/>
                <text x="194" y="31" text-anchor="middle" font-family="sans-serif" font-size="10" font-weight="700" fill="#0B1120">+XP</text>
                <circle cx="28" cy="80" r="8" fill="#0EA5E9" opacity="0.4"/>
                <circle cx="234" cy="60" r="6" fill="#6366F1" opacity="0.45"/>
                <circle cx="240" cy="90" r="10" fill="#0EA5E9" opacity="0.25"/>
            </svg>
        </div>
    </div>
</section>

<%-- ============================================================ SUB-NAV TABS ============================================================ --%>
<style>
.gl-tabs{background:#111827;border-bottom:1px solid rgba(255,255,255,0.08);position:sticky;top:58px;z-index:200;}
.gl-tabs-in{max-width:1280px;margin:0 auto;padding:0 40px;display:flex;gap:0;overflow-x:auto;}
.gl-tab{display:flex;align-items:center;gap:7px;padding:16px 20px;font-size:13.5px;font-weight:500;color:rgba(255,255,255,0.5);cursor:pointer;background:none;border:none;border-bottom:2.5px solid transparent;margin-bottom:-1px;white-space:nowrap;transition:color 0.15s;font-family:inherit;}
.gl-tab:hover{color:#fff;}
.gl-tab.active{color:#0EA5E9;border-bottom-color:#0EA5E9;font-weight:600;}
.gl-tab:focus-visible{outline:2px solid #0EA5E9;outline-offset:2px;}
@media(max-width:768px){.gl-tabs-in{padding:0 16px;}}
</style>
<nav class="gl-tabs" aria-label="Learn navigation">
    <div class="gl-tabs-in">
        <button class="gl-tab active" type="button" onclick="glTab('roadmap',this)">&#x1F5FA; Roadmap</button>
        <button class="gl-tab" type="button" onclick="glTab('pathways',this)">&#x25B6; Pathways</button>
        <button class="gl-tab" type="button" onclick="glTab('modules',this)">&#x1F4D6; Modules</button>
        <button class="gl-tab" type="button" onclick="glTab('challenges',this)">&#x26A1; Challenges</button>
        <button class="gl-tab" type="button" onclick="glTab('bossfights',this)">&#x1F480; Boss Fights</button>
        <button class="gl-tab" type="button" onclick="glTab('classrooms',this)">&#x1F3EB; Live Classes</button>
    </div>
</nav>

<%-- ============================================================ MAIN CONTENT ============================================================ --%>
<style>
.gl-main{flex:1;background:#0B1120;}
.gl-panel{display:none;}
.gl-panel.active{display:block;}

/* ---- Roadmap ---- */
.rm-wrap{padding:40px;}
.rm-cta{background:linear-gradient(135deg,rgba(14,165,233,0.1),rgba(99,102,241,0.1));border:1px solid rgba(14,165,233,0.2);border-radius:12px;padding:18px 24px;display:flex;align-items:center;justify-content:space-between;gap:16px;margin-bottom:36px;max-width:1200px;margin-left:auto;margin-right:auto;flex-wrap:wrap;}
.rm-cta-ttl{font-size:14px;font-weight:700;color:#fff;margin-bottom:4px;}
.rm-cta-sub{font-size:13px;color:rgba(255,255,255,0.5);}
.rm-cta-btn{padding:9px 22px;background:#0EA5E9;color:#fff;border-radius:8px;font-size:13.5px;font-weight:700;white-space:nowrap;flex-shrink:0;}
.rm-cta-btn:hover{background:#0284C7;color:#fff;}
.rm-hdr{text-align:center;margin-bottom:40px;}
.rm-hdr h2{font-size:26px;font-weight:700;color:#fff;margin:0 0 10px;}
.rm-hdr p{font-size:14px;color:rgba(255,255,255,0.5);max-width:580px;margin:0 auto;line-height:1.7;}

/* Foundation node */
.rm-root{display:flex;flex-direction:column;align-items:center;margin-bottom:0;}
.rm-found-box{background:#1F2A45;border:1px solid rgba(255,255,255,0.12);border-radius:12px;padding:20px 32px;text-align:center;max-width:420px;width:100%;}
.rm-found-box h3{font-size:15px;font-weight:700;color:#fff;margin:0 0 7px;}
.rm-found-box p{font-size:12.5px;color:rgba(255,255,255,0.5);margin:0;line-height:1.6;}
.rm-stem{width:2px;background:rgba(255,255,255,0.1);}
.rm-hbar{width:80%;max-width:1100px;height:2px;background:rgba(255,255,255,0.09);margin:0 auto;}

/* Pathway columns */
.rm-cols{max-width:1200px;margin:0 auto;display:grid;gap:16px;}
.rm-col{display:flex;flex-direction:column;gap:0;}
.rm-col-hdr{text-align:center;padding:22px 12px 16px;}
.rm-col-hdr h3{font-size:13px;font-weight:700;color:#fff;margin:0 0 6px;}
.rm-col-hdr p{font-size:11.5px;color:rgba(255,255,255,0.4);margin:0;line-height:1.5;}
.rm-col-stem{width:2px;height:20px;background:rgba(255,255,255,0.09);margin:0 auto;}

/* Module card */
.rm-card{display:flex;align-items:center;gap:12px;border-radius:10px;padding:12px 14px;margin-bottom:10px;position:relative;border:1px solid rgba(255,255,255,0.08);background:#162032;transition:border-color 0.15s,background 0.15s;}
.rm-card:hover{border-color:rgba(14,165,233,0.35);background:#1F2D45;}
.rm-card-icon{width:44px;height:44px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:19px;flex-shrink:0;}
.rm-card-name{font-size:12.5px;font-weight:600;color:#fff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;display:block;}
.rm-card-meta{display:flex;align-items:center;gap:5px;margin-top:4px;}
.rm-card-dot{width:5px;height:5px;border-radius:50%;background:#0EA5E9;display:inline-block;flex-shrink:0;}
.rm-card-meta span{font-size:11px;color:rgba(255,255,255,0.4);}
.rm-lock{position:absolute;top:8px;right:9px;font-size:11px;color:rgba(255,255,255,0.25);}
.rm-card.locked{opacity:0.5;}
.rm-card.locked:hover{border-color:rgba(255,255,255,0.08);background:#162032;}

/* Cert card */
.rm-cert{display:flex;align-items:center;gap:12px;border-radius:10px;padding:12px 14px;margin-bottom:10px;background:rgba(99,102,241,0.1);border:1px solid rgba(99,102,241,0.25);opacity:0.65;position:relative;}
.rm-cert-badge{width:44px;height:44px;border-radius:9px;background:linear-gradient(135deg,#4F46E5,#6366F1);display:flex;align-items:center;justify-content:center;font-size:19px;flex-shrink:0;}
.rm-cert-name{font-size:12.5px;font-weight:600;color:#fff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;display:block;}
.rm-cert-lbl{font-size:10px;font-weight:700;color:#A5B4FC;text-transform:uppercase;letter-spacing:0.05em;display:block;margin-top:3px;}

/* Empty col */
.rm-empty{background:rgba(255,255,255,0.03);border:1px dashed rgba(255,255,255,0.07);border-radius:9px;padding:20px;text-align:center;font-size:11.5px;color:rgba(255,255,255,0.2);margin-bottom:10px;}

/* What's next */
.rm-next{text-align:center;padding:48px 24px 20px;}
.rm-next h3{font-size:22px;font-weight:700;color:#fff;margin:0 0 10px;}
.rm-next p{font-size:14px;color:rgba(255,255,255,0.5);margin:0 0 24px;}
.rm-next-btn{display:inline-block;padding:13px 32px;background:#0EA5E9;color:#fff;border-radius:9px;font-size:15px;font-weight:700;border:2px solid #0EA5E9;transition:all 0.15s;}
.rm-next-btn:hover{background:#0284C7;border-color:#0284C7;color:#fff;}

/* Other panels */
.gl-pnl-wrap{max-width:1200px;margin:0 auto;padding:32px 40px;}
.gl-pnl-hdr{margin-bottom:24px;}
.gl-pnl-hdr h2{font-size:22px;font-weight:700;color:#fff;margin:0 0 6px;}
.gl-pnl-hdr p{font-size:14px;color:rgba(255,255,255,0.5);margin:0;}
.gl-locked-pnl{text-align:center;padding:60px 24px;}
.gl-locked-pnl .gl-lock-ico{font-size:52px;opacity:0.3;display:block;margin-bottom:16px;}
.gl-locked-pnl p{color:rgba(255,255,255,0.45);font-size:14px;margin:0;}
.gl-locked-pnl a{color:#0EA5E9;font-weight:600;}

/* Pathway cards */
.gl-pw-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:16px;}
.gl-pw-card{background:#162032;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:22px;display:flex;flex-direction:column;gap:10px;position:relative;overflow:hidden;transition:border-color 0.15s,background 0.15s;}
.gl-pw-card:hover{border-color:rgba(14,165,233,0.3);background:#1F2D45;}
.gl-pw-accent{position:absolute;top:0;left:0;right:0;height:3px;}
.gl-pw-icon{font-size:28px;display:block;margin-top:6px;}
.gl-pw-card h3{font-size:15px;font-weight:700;color:#fff;margin:0;}
.gl-pw-card p{font-size:13px;color:rgba(255,255,255,0.5);margin:0;line-height:1.6;}
.gl-pw-meta{display:flex;gap:12px;flex-wrap:wrap;font-size:12px;color:rgba(255,255,255,0.35);}
.gl-pw-free{background:rgba(34,197,94,0.12);color:#22C55E;border:1px solid rgba(34,197,94,0.25);border-radius:20px;font-size:11px;font-weight:700;padding:2px 10px;display:inline-block;}
.gl-pw-lock{background:rgba(100,116,139,0.1);color:rgba(255,255,255,0.35);border:1px solid rgba(100,116,139,0.2);border-radius:20px;font-size:11px;padding:2px 10px;display:inline-block;}

/* Module list */
.gl-mod-list{display:flex;flex-direction:column;gap:10px;}
.gl-mod-row{background:#162032;border:1px solid rgba(255,255,255,0.08);border-radius:10px;padding:14px 18px;display:flex;align-items:center;gap:16px;transition:border-color 0.15s;}
.gl-mod-row:hover{border-color:rgba(14,165,233,0.25);}
.gl-mod-ico{font-size:22px;flex-shrink:0;}
.gl-mod-name{font-size:14px;font-weight:600;color:#fff;}
.gl-mod-sub{font-size:12px;color:rgba(255,255,255,0.4);margin-top:3px;}
.gl-mod-free{background:rgba(34,197,94,0.12);color:#22C55E;border:1px solid rgba(34,197,94,0.25);border-radius:20px;font-size:11px;font-weight:700;padding:2px 10px;white-space:nowrap;}
.gl-mod-lock{background:rgba(100,116,139,0.1);color:rgba(255,255,255,0.35);border:1px solid rgba(100,116,139,0.2);border-radius:20px;font-size:11px;padding:2px 10px;white-space:nowrap;}

@media(max-width:768px){.rm-wrap,.gl-pnl-wrap{padding:20px 16px;}.rm-cta{flex-direction:column;align-items:flex-start;}}
</style>

<main class="gl-main" role="main">
    <%-- Error panel --%>
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div style="max-width:1200px;margin:0 auto;padding:24px 40px 0;">
            <div style="background:rgba(239,68,68,0.1);border:1px solid rgba(239,68,68,0.25);border-radius:10px;padding:14px 18px;color:#FCA5A5;font-size:13px;" role="alert">
                <asp:Literal ID="litError" runat="server" />
            </div>
        </div>
    </asp:Panel>

    <%-- ======= TAB: ROADMAP ======= --%>
    <div id="panel-roadmap" class="gl-panel active">
        <div class="rm-wrap">
            <div class="rm-cta">
                <div><div class="rm-cta-ttl">You are browsing as a guest</div><div class="rm-cta-sub">Create a free account to track your progress, earn XP, unlock badges and access all Foundation modules.</div></div>
                <a href="../LogIn.aspx" class="rm-cta-btn">Join for Free</a>
            </div>
            <div class="rm-hdr">
                <h2>Cloud Computing Learning Roadmap</h2>
                <p>From fundamental cloud concepts to advanced specialisations — structured resources, real certifications, and gamified progress to build your complete skill set.</p>
            </div>
            <div class="rm-root">
                <div class="rm-found-box">
                    <h3>&#x2601; Cloud Foundations</h3>
                    <p>Acquire the core cloud computing skills needed to begin your journey into any specialisation pathway.</p>
                </div>
                <div class="rm-stem" style="height:36px;"></div>
            </div>
            <div class="rm-hbar"></div>
            <asp:Panel ID="pnlRoadmapColumns" runat="server" />
            <div class="rm-next">
                <h3>What's next?</h3>
                <p>Explore cloud pathways, complete challenge rooms, and earn real certifications — with new content added regularly.</p>
                <a href="../LogIn.aspx" class="rm-next-btn">Join for Free</a>
            </div>
        </div>
    </div>

    <%-- ======= TAB: PATHWAYS ======= --%>
    <div id="panel-pathways" class="gl-panel">
        <div class="gl-pnl-wrap">
            <div class="gl-pnl-hdr"><h2>Learning Pathways</h2><p>Structured learning tracks from foundation to specialisation. Free accounts access the Foundation pathway.</p></div>
            <div class="gl-pw-grid"><asp:Panel ID="pnlPathwayCards" runat="server" /></div>
        </div>
    </div>

    <%-- ======= TAB: MODULES ======= --%>
    <div id="panel-modules" class="gl-panel">
        <div class="gl-pnl-wrap">
            <div class="gl-pnl-hdr"><h2>Modules</h2><p>All published modules across every pathway. Sign in to track progress and earn XP.</p></div>
            <div class="gl-mod-list"><asp:Panel ID="pnlModuleList" runat="server" /></div>
        </div>
    </div>

    <%-- ======= TAB: CHALLENGES ======= --%>
    <div id="panel-challenges" class="gl-panel">
        <div class="gl-pnl-wrap">
            <div class="gl-pnl-hdr"><h2>Challenges</h2><p>Time-limited challenges to test your cloud knowledge and earn XP.</p></div>
            <div class="gl-locked-pnl"><span class="gl-lock-ico">&#x26A1;</span><p><a href="../LogIn.aspx">Sign in</a> to view and join active challenges.</p></div>
        </div>
    </div>

    <%-- ======= TAB: BOSS FIGHTS ======= --%>
    <div id="panel-bossfights" class="gl-panel">
        <div class="gl-pnl-wrap">
            <div class="gl-pnl-hdr"><h2>Boss Fights</h2><p>Battle cloud knowledge bosses in dramatic quiz rooms. Earn XP for every win.</p></div>
            <div class="gl-locked-pnl"><span class="gl-lock-ico">&#x1F480;</span><p><a href="../LogIn.aspx">Sign in</a> to access Boss Fight rooms.</p></div>
        </div>
    </div>

    <%-- ======= TAB: CLASSROOMS ======= --%>
    <div id="panel-classrooms" class="gl-panel">
        <div class="gl-pnl-wrap">
            <div class="gl-pnl-hdr"><h2>Live Classes</h2><p>Instructor-led classrooms with assignments, materials, and consultations.</p></div>
            <div class="gl-locked-pnl"><span class="gl-lock-ico">&#x1F3EB;</span><p><a href="../LogIn.aspx">Sign in</a> to access your classrooms.</p></div>
        </div>
    </div>

</main>

<%-- ============================================================ FOOTER ============================================================ --%>
<style>
.gl-footer{background:#070D1A;border-top:1px solid rgba(255,255,255,0.06);}
.gl-footer-inner{max-width:1280px;margin:0 auto;padding:56px 40px 40px;display:grid;grid-template-columns:1fr 1fr 1fr 1fr 1.8fr;gap:40px;}
.gl-footer-col-title{font-size:12px;font-weight:700;color:#fff;letter-spacing:0.06em;text-transform:uppercase;margin-bottom:18px;}
.gl-footer-link{display:block;font-size:13px;color:rgba(255,255,255,0.45);margin-bottom:11px;transition:color 0.15s;}
.gl-footer-link:hover{color:#0EA5E9;}
.gl-footer-brand{display:flex;align-items:center;gap:10px;margin-bottom:16px;}
.gl-footer-logo{width:38px;height:38px;background:linear-gradient(135deg,#0EA5E9,#6366F1);border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:900;color:#fff;flex-shrink:0;}
.gl-footer-wordmark{font-size:18px;font-weight:700;color:#fff;letter-spacing:-0.3px;}
.gl-footer-wordmark em{font-style:normal;color:#0EA5E9;}
.gl-footer-desc{font-size:13px;color:rgba(255,255,255,0.4);line-height:1.75;margin:0 0 20px;}
.gl-footer-socials{display:flex;gap:10px;}
.gl-footer-social{width:34px;height:34px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:15px;transition:background 0.15s,border-color 0.15s;cursor:pointer;}
.gl-footer-social:hover{background:rgba(14,165,233,0.15);border-color:rgba(14,165,233,0.3);}
.gl-footer-bottom{max-width:1280px;margin:0 auto;padding:18px 40px;border-top:1px solid rgba(255,255,255,0.06);display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;}
.gl-footer-bottom span{font-size:12px;color:rgba(255,255,255,0.28);}
@media(max-width:1024px){.gl-footer-inner{grid-template-columns:1fr 1fr 1fr;gap:32px;}}
@media(max-width:640px){.gl-footer-inner{grid-template-columns:1fr 1fr;gap:24px;padding:36px 20px 24px;}.gl-footer-bottom{padding:14px 20px;}}
</style>
<footer class="gl-footer">
    <div class="gl-footer-inner">

        <div>
            <div class="gl-footer-col-title">Learning</div>
            <a href="Learn.aspx" class="gl-footer-link">Roadmap</a>
            <a href="Learn.aspx" class="gl-footer-link">Pathways</a>
            <a href="Learn.aspx" class="gl-footer-link">Modules</a>
            <a href="Learn.aspx" class="gl-footer-link">Challenges</a>
            <a href="Learn.aspx" class="gl-footer-link">Boss Fights</a>
            <a href="Learn.aspx" class="gl-footer-link">Certifications</a>
        </div>

        <div>
            <div class="gl-footer-col-title">Platform</div>
            <a href="../LogIn.aspx" class="gl-footer-link">Student Login</a>
            <a href="../LogIn.aspx" class="gl-footer-link">Instructor Login</a>
            <a href="../LogIn.aspx" class="gl-footer-link">Join for Free</a>
            <a href="Learn.aspx"   class="gl-footer-link">Guest Access</a>
            <a href="Learn.aspx"   class="gl-footer-link">Pricing</a>
        </div>

        <div>
            <div class="gl-footer-col-title">Resources</div>
            <a href="../Default.aspx" class="gl-footer-link">About CloudPhoria</a>
            <a href="Learn.aspx"      class="gl-footer-link">Community Rooms</a>
            <a href="Learn.aspx"      class="gl-footer-link">Classroom Support</a>
            <a href="Learn.aspx"      class="gl-footer-link">Instructor Guide</a>
            <a href="Learn.aspx"      class="gl-footer-link">FAQ</a>
        </div>

        <div>
            <div class="gl-footer-col-title">Privacy &amp; Legal</div>
            <a href="#" class="gl-footer-link">Privacy Policy</a>
            <a href="#" class="gl-footer-link">Terms of Use</a>
            <a href="#" class="gl-footer-link">AI Terms of Use</a>
            <a href="#" class="gl-footer-link">Acceptable Use Policy</a>
            <a href="#" class="gl-footer-link">Cookie Policy</a>
        </div>

        <div>
            <div class="gl-footer-brand">
                <div class="gl-footer-logo" aria-hidden="true">CP</div>
                <span class="gl-footer-wordmark">Cloud<em>Phoria</em></span>
            </div>
            <p class="gl-footer-desc">A gamified cloud computing learning platform that lets you master real-world cloud skills through structured pathways, interactive modules, XP rewards, badges, and boss battle rooms — available to students and professionals at every level.</p>
            <div class="gl-footer-socials" aria-label="Social links">
                <div class="gl-footer-social" title="Website" aria-hidden="true">&#x1F310;</div>
                <div class="gl-footer-social" title="Discord" aria-hidden="true">&#x1F4AC;</div>
                <div class="gl-footer-social" title="Mobile"  aria-hidden="true">&#x1F4F1;</div>
                <div class="gl-footer-social" title="Email"   aria-hidden="true">&#x1F4E7;</div>
            </div>
        </div>

    </div>
    <div class="gl-footer-bottom">
        <span>&copy; <%: DateTime.Now.Year %> CloudPhoria. All rights reserved.</span>
        <span>CT050-3-2-WAPP &mdash; Group 14</span>
    </div>
</footer>

</div><%-- end page flex wrapper --%>
</form>

<script src="../Scripts/bootstrap.bundle.js"></script>
<script>
function glTab(id, btn) {
    document.querySelectorAll('.gl-panel').forEach(function(p){ p.classList.remove('active'); });
    document.querySelectorAll('.gl-tab').forEach(function(t){ t.classList.remove('active'); });
    var p = document.getElementById('panel-' + id);
    if (p) p.classList.add('active');
    if (btn) btn.classList.add('active');
}
</script>
</body>
</html>
