<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="CloudPhoria.Guest.Dashboard" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>CloudPhoria – Free Cloud Computing Learning</title>
<link href="../Content/bootstrap.css" rel="stylesheet" type="text/css" />
<style>
*, *::before, *::after { box-sizing: border-box; }
html, body { margin:0; padding:0; min-height:100vh; background:#0B1120;
    font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Arial,sans-serif;
    color:#fff; overflow-x:hidden; }
a { text-decoration:none; }
/* ---- shared header / footer (same as Learn.aspx) ---- */
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
</head>
<body>
<form id="form1" runat="server">
<div style="min-height:100vh;display:flex;flex-direction:column;">

<header class="gl-hdr">
    <div class="gl-hdr-in">
        <a class="gl-brand" href="../Default.aspx">
            <div class="gl-brand-logo" aria-hidden="true">CP</div>
            <span class="gl-brand-name">Cloud<em>Phoria</em></span>
        </a>
        <ul class="gl-nav-links" role="list">
            <li><a href="Dashboard.aspx" class="active">&#x1F3E0; Home</a></li>
            <li><a href="Learn.aspx">&#x1F4DA; Learn</a></li>
            <li><a href="Pathways.aspx">&#x25B6; Pathways</a></li>
            <li><a href="Modules.aspx">&#x1F4D6; Modules</a></li>
            <li><a href="Practice.aspx">&#x270F; Practice</a></li>
            <li><a href="Pricing.aspx">&#x1F4B0; Pricing</a></li>
            <li><a href="Certifications.aspx">&#x1F3C5; Certifications</a></li>
        </ul>
        <div class="gl-nav-acts">
            <a class="gl-btn-login" href="../LogIn.aspx">Log In</a>
            <a class="gl-btn-join"  href="../LogIn.aspx">Join for Free</a>
        </div>
    </div>
</header>

<%-- ===== HERO ===== --%>
<style>
.gd-hero{background:linear-gradient(135deg,#0F172A 0%,#1A2744 55%,#0F172A 100%);position:relative;overflow:hidden;}
.gd-hero::before{content:'';position:absolute;inset:0;background-image:linear-gradient(rgba(14,165,233,0.04) 1px,transparent 1px),linear-gradient(90deg,rgba(14,165,233,0.04) 1px,transparent 1px);background-size:48px 48px;pointer-events:none;}
.gd-hero-in{max-width:1280px;margin:0 auto;padding:60px 40px 64px;display:flex;align-items:center;gap:48px;position:relative;z-index:1;}
.gd-hero-text{flex:1;}
.gd-hero-text h1{font-size:50px;font-weight:800;color:#fff;margin:0 0 16px;letter-spacing:-0.5px;line-height:1.08;}
.gd-hero-text h1 em{font-style:normal;color:#0EA5E9;}
.gd-hero-text p{font-size:16px;color:rgba(255,255,255,0.6);max-width:520px;line-height:1.75;margin:0 0 32px;}
.gd-hero-btns{display:flex;gap:12px;flex-wrap:wrap;}
.gd-btn-primary{padding:13px 28px;background:#0EA5E9;border-radius:9px;color:#fff;font-size:15px;font-weight:700;border:2px solid #0EA5E9;transition:all 0.15s;}
.gd-btn-primary:hover{background:#0284C7;border-color:#0284C7;color:#fff;}
.gd-btn-outline{padding:13px 28px;background:transparent;border-radius:9px;color:#fff;font-size:15px;font-weight:600;border:2px solid rgba(255,255,255,0.2);transition:all 0.15s;}
.gd-btn-outline:hover{border-color:#0EA5E9;color:#0EA5E9;}
.gd-stats{display:flex;gap:40px;flex-wrap:wrap;margin-top:36px;}
.gd-stat-num{font-size:26px;font-weight:800;color:#fff;display:block;}
.gd-stat-lbl{font-size:12px;color:rgba(255,255,255,0.45);margin-top:2px;display:block;}
@keyframes gdFloat{0%,100%{transform:translateY(0);}50%{transform:translateY(-14px);}}
.gd-hero-art{flex:0 0 320px;display:flex;align-items:center;justify-content:center;position:relative;}
.gd-hero-glow{position:absolute;width:280px;height:280px;border-radius:50%;background:radial-gradient(circle,rgba(14,165,233,0.18) 0%,transparent 70%);}
.gd-hero-svg{animation:gdFloat 4s ease-in-out infinite;filter:drop-shadow(0 0 40px rgba(14,165,233,0.3));}
@media(max-width:900px){.gd-hero-in{flex-direction:column;padding:36px 20px 44px;}.gd-hero-text h1{font-size:34px;}.gd-hero-art{display:none;}}
</style>
<section class="gd-hero" aria-labelledby="gdHeroTitle">
    <div class="gd-hero-in">
        <div class="gd-hero-text">
            <h1 id="gdHeroTitle">Master <em>Cloud Computing</em><br/>the Fun Way</h1>
            <p>Follow structured learning pathways, complete interactive modules, earn XP, badges and certifications — all free to start, no login needed for the Foundation pathway.</p>
            <div class="gd-hero-btns">
                <a class="gd-btn-primary" href="Learn.aspx">&#x1F4DA; Start Learning</a>
                <a class="gd-btn-outline" href="../LogIn.aspx">Join for Free &#x2192;</a>
            </div>
            <div class="gd-stats">
                <div><span class="gd-stat-num"><asp:Literal ID="litPathwayCount" runat="server" Text="7"/>+</span><span class="gd-stat-lbl">Pathways</span></div>
                <div><span class="gd-stat-num"><asp:Literal ID="litModuleCount" runat="server" Text="0"/>+</span><span class="gd-stat-lbl">Modules</span></div>
                <div><span class="gd-stat-num">6+</span><span class="gd-stat-lbl">Certifications</span></div>
                <div><span class="gd-stat-num"><asp:Literal ID="litPracticeCount" runat="server" Text="0"/>+</span><span class="gd-stat-lbl">Practice Questions</span></div>
            </div>
        </div>
        <div class="gd-hero-art" aria-hidden="true">
            <div class="gd-hero-glow"></div>
            <svg class="gd-hero-svg" width="280" height="240" viewBox="0 0 280 240" fill="none" xmlns="http://www.w3.org/2000/svg">
                <defs>
                    <linearGradient id="dg1" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="#1E3A5F"/><stop offset="100%" stop-color="#0F2847"/></linearGradient>
                    <linearGradient id="dg2" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="#0EA5E9" stop-opacity="0.9"/><stop offset="100%" stop-color="#6366F1" stop-opacity="0.85"/></linearGradient>
                </defs>
                <rect x="25" y="140" width="230" height="18" rx="7" fill="#1E3A5F"/>
                <ellipse cx="140" cy="158" rx="115" ry="6" fill="rgba(14,165,233,0.12)"/>
                <rect x="40" y="34" width="200" height="112" rx="11" fill="url(#dg1)" stroke="rgba(14,165,233,0.28)" stroke-width="1.5"/>
                <text x="140" y="84" text-anchor="middle" font-size="32" fill="#0EA5E9">&#x2601;</text>
                <rect x="80" y="100" width="32" height="6" rx="3" fill="rgba(14,165,233,0.45)"/>
                <rect x="128" y="100" width="54" height="6" rx="3" fill="rgba(99,102,241,0.45)"/>
                <rect x="100" y="112" width="80" height="6" rx="3" fill="rgba(14,165,233,0.28)"/>
                <rect x="174" y="18" width="56" height="24" rx="12" fill="#F59E0B"/>
                <text x="202" y="34" text-anchor="middle" font-family="sans-serif" font-size="11" font-weight="700" fill="#0B1120">+XP</text>
                <circle cx="30" cy="88" r="9" fill="#0EA5E9" opacity="0.35"/>
                <circle cx="250" cy="66" r="7" fill="#6366F1" opacity="0.4"/>
                <circle cx="256" cy="100" r="11" fill="#0EA5E9" opacity="0.2"/>
            </svg>
        </div>
    </div>
</section>

<%-- ===== FEATURES STRIP ===== --%>
<style>
.gd-features{background:#111827;border-top:1px solid rgba(255,255,255,0.07);border-bottom:1px solid rgba(255,255,255,0.07);}
.gd-features-in{max-width:1280px;margin:0 auto;padding:36px 40px;display:grid;grid-template-columns:repeat(4,1fr);gap:24px;}
.gd-feat{display:flex;align-items:flex-start;gap:14px;}
.gd-feat-icon{width:42px;height:42px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:20px;flex-shrink:0;}
.gd-feat h3{font-size:14px;font-weight:700;color:#fff;margin:0 0 5px;}
.gd-feat p{font-size:12.5px;color:rgba(255,255,255,0.5);margin:0;line-height:1.6;}
@media(max-width:900px){.gd-features-in{grid-template-columns:1fr 1fr;gap:20px;padding:28px 20px;}}
@media(max-width:520px){.gd-features-in{grid-template-columns:1fr;}}
</style>
<section class="gd-features" aria-label="Platform features">
    <div class="gd-features-in">
        <div class="gd-feat">
            <div class="gd-feat-icon" style="background:rgba(14,165,233,0.12);">&#x1F5FA;</div>
            <div><h3>Structured Pathways</h3><p>7 learning tracks from Cloud Foundations to DevOps, Security, AI and more.</p></div>
        </div>
        <div class="gd-feat">
            <div class="gd-feat-icon" style="background:rgba(245,158,11,0.12);">&#x26A1;</div>
            <div><h3>Earn XP &amp; Badges</h3><p>Complete modules and subtopics to level up your XP and collect badges.</p></div>
        </div>
        <div class="gd-feat">
            <div class="gd-feat-icon" style="background:rgba(99,102,241,0.12);">&#x1F480;</div>
            <div><h3>Boss Fight Rooms</h3><p>Battle bosses in epic quiz rooms. Win to earn bonus XP and bragging rights.</p></div>
        </div>
        <div class="gd-feat">
            <div class="gd-feat-icon" style="background:rgba(34,197,94,0.12);">&#x1F3C5;</div>
            <div><h3>Real Certifications</h3><p>Complete a specialisation pathway to earn a professional CloudPhoria certificate.</p></div>
        </div>
    </div>
</section>

<%-- ===== FEATURED PATHWAYS ===== --%>
<style>
.gd-section{max-width:1280px;margin:0 auto;padding:48px 40px;}
.gd-sec-hdr{display:flex;align-items:flex-end;justify-content:space-between;margin-bottom:24px;gap:16px;flex-wrap:wrap;}
.gd-sec-hdr h2{font-size:22px;font-weight:700;color:#fff;margin:0;}
.gd-sec-hdr p{font-size:13.5px;color:rgba(255,255,255,0.5);margin:0;}
.gd-sec-link{font-size:13px;color:#0EA5E9;font-weight:600;white-space:nowrap;}
.gd-sec-link:hover{color:#38BDF8;}
.gd-pw-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:16px;}
.gd-pw-card{background:#162032;border:1px solid rgba(255,255,255,0.08);border-radius:12px;padding:22px;display:flex;flex-direction:column;gap:10px;position:relative;overflow:hidden;transition:border-color 0.15s,background 0.15s;}
.gd-pw-card:hover{border-color:rgba(14,165,233,0.3);background:#1F2D45;}
.gd-pw-accent{position:absolute;top:0;left:0;right:0;height:3px;}
.gd-pw-icon{font-size:28px;margin-top:6px;}
.gd-pw-card h3{font-size:15px;font-weight:700;color:#fff;margin:0;}
.gd-pw-card p{font-size:13px;color:rgba(255,255,255,0.5);margin:0;line-height:1.6;}
.gd-pw-meta{display:flex;gap:10px;flex-wrap:wrap;font-size:12px;color:rgba(255,255,255,0.35);}
.gd-tag-free{background:rgba(34,197,94,0.12);color:#22C55E;border:1px solid rgba(34,197,94,0.25);border-radius:20px;font-size:11px;font-weight:700;padding:2px 10px;}
.gd-tag-lock{background:rgba(100,116,139,0.1);color:rgba(255,255,255,0.35);border:1px solid rgba(100,116,139,0.2);border-radius:20px;font-size:11px;padding:2px 10px;}
@media(max-width:768px){.gd-section{padding:32px 20px;}}
</style>
<section style="background:#0B1120;">
    <div class="gd-section">
        <div class="gd-sec-hdr">
            <div><h2>Learning Pathways</h2><p>Choose your cloud specialisation and follow a guided module track.</p></div>
            <a class="gd-sec-link" href="Pathways.aspx">View all &#x2192;</a>
        </div>
        <div class="gd-pw-grid">
            <asp:Panel ID="pnlPathways" runat="server" />
        </div>
    </div>
</section>

<%-- ===== FEATURED MODULES + PRACTICE CTA ===== --%>
<style>
.gd-mod-row{background:#162032;border:1px solid rgba(255,255,255,0.08);border-radius:10px;padding:14px 18px;display:flex;align-items:center;gap:16px;transition:border-color 0.15s;}
.gd-mod-row:hover{border-color:rgba(14,165,233,0.25);}
.gd-mod-ico{font-size:22px;flex-shrink:0;}
.gd-mod-name{font-size:14px;font-weight:600;color:#fff;}
.gd-mod-sub{font-size:12px;color:rgba(255,255,255,0.4);margin-top:3px;}
.gd-mod-action{margin-left:auto;padding:6px 16px;border-radius:7px;font-size:12px;font-weight:600;background:rgba(14,165,233,0.12);color:#0EA5E9;border:1px solid rgba(14,165,233,0.25);white-space:nowrap;transition:background 0.15s;}
.gd-mod-action:hover{background:rgba(14,165,233,0.22);color:#0EA5E9;}
.gd-two-col{display:grid;grid-template-columns:1fr 1fr;gap:24px;}
@media(max-width:900px){.gd-two-col{grid-template-columns:1fr;}}
.gd-practice-cta{background:linear-gradient(135deg,rgba(99,102,241,0.12),rgba(14,165,233,0.12));border:1px solid rgba(14,165,233,0.2);border-radius:14px;padding:32px;display:flex;flex-direction:column;justify-content:center;gap:16px;}
.gd-practice-cta h3{font-size:19px;font-weight:700;color:#fff;margin:0;}
.gd-practice-cta p{font-size:13.5px;color:rgba(255,255,255,0.55);margin:0;line-height:1.65;}
.gd-practice-cta a{display:inline-block;padding:11px 24px;background:#6366F1;border-radius:8px;color:#fff;font-size:14px;font-weight:700;transition:background 0.15s;align-self:flex-start;}
.gd-practice-cta a:hover{background:#4F46E5;color:#fff;}
</style>
<section style="background:#0D1526;border-top:1px solid rgba(255,255,255,0.07);">
    <div class="gd-section">
        <div class="gd-two-col">
            <div>
                <div class="gd-sec-hdr" style="margin-bottom:16px;">
                    <div><h2>Featured Modules</h2><p>Published modules available to explore now.</p></div>
                    <a class="gd-sec-link" href="Modules.aspx">View all &#x2192;</a>
                </div>
                <div style="display:flex;flex-direction:column;gap:10px;">
                    <asp:Panel ID="pnlFeaturedModules" runat="server" />
                </div>
            </div>
            <div style="display:flex;flex-direction:column;gap:16px;">
                <div class="gd-practice-cta">
                    <span style="font-size:36px;">&#x270F;</span>
                    <h3>Practice Without an Account</h3>
                    <p>Try module practice quizzes as a guest. No login required — your session is tracked anonymously so you can see your results.</p>
                    <a href="Practice.aspx">Start Practising &#x2192;</a>
                </div>
                <div class="gd-practice-cta" style="background:linear-gradient(135deg,rgba(34,197,94,0.1),rgba(16,185,129,0.1));border-color:rgba(34,197,94,0.2);">
                    <span style="font-size:36px;">&#x1F3C5;</span>
                    <h3>Earn Real Certifications</h3>
                    <p>Complete a specialisation pathway to receive a CloudPhoria professional certificate. Requires a free account.</p>
                    <a href="Certifications.aspx" style="background:#059669;">View Certifications &#x2192;</a>
                </div>
            </div>
        </div>
    </div>
</section>

<%-- ===== SIGN UP CTA BANNER ===== --%>
<style>
.gd-signup{background:linear-gradient(135deg,#0F2847 0%,#1A1F5E 100%);border-top:1px solid rgba(99,102,241,0.2);border-bottom:1px solid rgba(99,102,241,0.2);}
.gd-signup-in{max-width:900px;margin:0 auto;padding:60px 40px;text-align:center;}
.gd-signup-in h2{font-size:32px;font-weight:800;color:#fff;margin:0 0 14px;letter-spacing:-0.3px;}
.gd-signup-in p{font-size:15px;color:rgba(255,255,255,0.6);margin:0 auto 32px;max-width:560px;line-height:1.75;}
.gd-signup-btns{display:flex;gap:14px;justify-content:center;flex-wrap:wrap;}
@media(max-width:640px){.gd-signup-in{padding:40px 20px;}.gd-signup-in h2{font-size:24px;}}
</style>
<section class="gd-signup">
    <div class="gd-signup-in">
        <h2>Ready to level up your cloud skills?</h2>
        <p>Create a free account to track progress, earn XP, unlock badges, join classrooms, take exams and earn professional certifications.</p>
        <div class="gd-signup-btns">
            <a class="gd-btn-primary" href="../LogIn.aspx">&#x1F680; Create Free Account</a>
            <a class="gd-btn-outline" href="Pricing.aspx">&#x1F4B0; See Plans</a>
        </div>
    </div>
</section>

<%-- ===== FOOTER (same as Learn.aspx) ===== --%>
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
.gl-footer-social{width:34px;height:34px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.1);border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:15px;}
.gl-footer-bottom{max-width:1280px;margin:0 auto;padding:18px 40px;border-top:1px solid rgba(255,255,255,0.06);display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;}
.gl-footer-bottom span{font-size:12px;color:rgba(255,255,255,0.28);}
@media(max-width:1024px){.gl-footer-inner{grid-template-columns:1fr 1fr 1fr;gap:32px;}}
@media(max-width:640px){.gl-footer-inner{grid-template-columns:1fr 1fr;gap:24px;padding:36px 20px 24px;}.gl-footer-bottom{padding:14px 20px;}}
</style>
<footer class="gl-footer">
    <div class="gl-footer-inner">
        <div>
            <div class="gl-footer-col-title">Learning</div>
            <a href="Learn.aspx"         class="gl-footer-link">Roadmap</a>
            <a href="Pathways.aspx"      class="gl-footer-link">Pathways</a>
            <a href="Modules.aspx"       class="gl-footer-link">Modules</a>
            <a href="Practice.aspx"      class="gl-footer-link">Practice</a>
            <a href="Certifications.aspx" class="gl-footer-link">Certifications</a>
        </div>
        <div>
            <div class="gl-footer-col-title">Platform</div>
            <a href="../LogIn.aspx" class="gl-footer-link">Student Login</a>
            <a href="../LogIn.aspx" class="gl-footer-link">Instructor Login</a>
            <a href="../LogIn.aspx" class="gl-footer-link">Join for Free</a>
            <a href="Pricing.aspx"  class="gl-footer-link">Pricing</a>
        </div>
        <div>
            <div class="gl-footer-col-title">Resources</div>
            <a href="../Default.aspx" class="gl-footer-link">About CloudPhoria</a>
            <a href="Learn.aspx"      class="gl-footer-link">Guest Access</a>
            <a href="#"               class="gl-footer-link">FAQ</a>
        </div>
        <div>
            <div class="gl-footer-col-title">Legal</div>
            <a href="#" class="gl-footer-link">Privacy Policy</a>
            <a href="#" class="gl-footer-link">Terms of Use</a>
            <a href="#" class="gl-footer-link">Cookie Policy</a>
        </div>
        <div>
            <div class="gl-footer-brand">
                <div class="gl-footer-logo" aria-hidden="true">CP</div>
                <span class="gl-footer-wordmark">Cloud<em>Phoria</em></span>
            </div>
            <p class="gl-footer-desc">A gamified cloud computing learning platform — free to start, with structured pathways, XP rewards, boss battles, and professional certifications.</p>
            <div class="gl-footer-socials" aria-label="Social links">
                <div class="gl-footer-social" title="Website" aria-hidden="true">&#x1F310;</div>
                <div class="gl-footer-social" title="Discord" aria-hidden="true">&#x1F4AC;</div>
                <div class="gl-footer-social" title="Email"   aria-hidden="true">&#x1F4E7;</div>
            </div>
        </div>
    </div>
    <div class="gl-footer-bottom">
        <span>&copy; <%: DateTime.Now.Year %> CloudPhoria. All rights reserved.</span>
        <span>CT050-3-2-WAPP &mdash; Group 14</span>
    </div>
</footer>

</div><%-- end flex wrapper --%>
</form>
<script src="../Scripts/bootstrap.bundle.js"></script>
</body>
</html>
