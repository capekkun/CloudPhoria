<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Certifications.aspx.cs" Inherits="CloudPhoria.Guest.Certifications" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Certifications – CloudPhoria</title>
<link href="../Content/bootstrap.css" rel="stylesheet" type="text/css" />
<style>
*, *::before, *::after { box-sizing:border-box; }
html, body { margin:0; padding:0; min-height:100vh; background:#0B1120;
    font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Arial,sans-serif;
    color:#fff; overflow-x:hidden; }
a { text-decoration:none; }
.gl-hdr{background:#0F172A;border-bottom:1px solid rgba(255,255,255,0.07);position:sticky;top:0;z-index:300;}
.gl-hdr-in{display:flex;align-items:center;padding:0 40px;height:58px;gap:28px;}
.gl-brand{display:flex;align-items:center;gap:9px;}
.gl-brand-logo{width:34px;height:34px;background:linear-gradient(135deg,#0EA5E9,#6366F1);border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:900;color:#fff;}
.gl-brand-name{font-size:17px;font-weight:700;color:#fff;}
.gl-brand-name em{font-style:normal;color:#0EA5E9;}
.gl-nav-links{display:flex;align-items:center;gap:2px;flex:1;list-style:none;margin:0;padding:0;}
.gl-nav-links a{display:flex;align-items:center;gap:6px;padding:6px 13px;color:rgba(255,255,255,0.65);font-size:13px;font-weight:500;border-radius:7px;transition:background 0.15s,color 0.15s;}
.gl-nav-links a:hover{background:rgba(255,255,255,0.07);color:#fff;}
.gl-nav-links a.active{color:#0EA5E9;font-weight:600;}
.gl-nav-acts{display:flex;gap:10px;align-items:center;flex-shrink:0;}
.gl-btn-login{padding:6px 18px;border:1.5px solid rgba(255,255,255,0.22);border-radius:7px;color:rgba(255,255,255,0.85);font-size:13px;font-weight:500;}
.gl-btn-login:hover{border-color:#0EA5E9;color:#0EA5E9;}
.gl-btn-join{padding:6px 18px;background:#0EA5E9;border-radius:7px;color:#fff;font-size:13px;font-weight:700;}
.gl-btn-join:hover{background:#0284C7;color:#fff;}
@media(max-width:768px){.gl-nav-links{display:none;}.gl-hdr-in{padding:0 16px;}}
/* cert page */
.gc-hero{background:linear-gradient(135deg,#0F172A,#1A1F5E);border-bottom:1px solid rgba(99,102,241,0.2);padding:60px 40px 56px;text-align:center;}
.gc-hero h1{font-size:40px;font-weight:800;color:#fff;margin:0 0 14px;}
.gc-hero p{font-size:15px;color:rgba(255,255,255,0.55);max-width:560px;margin:0 auto;line-height:1.7;}
.gc-main{flex:1;background:#0B1120;}
.gc-wrap{max-width:1100px;margin:0 auto;padding:52px 40px 64px;}
.gc-how{background:rgba(99,102,241,0.07);border:1px solid rgba(99,102,241,0.18);border-radius:12px;padding:28px 32px;margin-bottom:40px;display:grid;grid-template-columns:repeat(3,1fr);gap:24px;}
.gc-step{display:flex;align-items:flex-start;gap:12px;}
.gc-step-num{width:32px;height:32px;border-radius:50%;background:rgba(99,102,241,0.2);border:1.5px solid rgba(99,102,241,0.4);display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:800;color:#A5B4FC;flex-shrink:0;}
.gc-step h4{font-size:13.5px;font-weight:700;color:#fff;margin:0 0 5px;}
.gc-step p{font-size:12.5px;color:rgba(255,255,255,0.5);margin:0;line-height:1.55;}
.gc-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:20px;}
.gc-card{background:linear-gradient(135deg,#1A1A3A,#162040);border:1px solid rgba(99,102,241,0.2);border-radius:14px;padding:28px;display:flex;flex-direction:column;gap:14px;transition:border-color 0.15s,transform 0.15s;}
.gc-card:hover{border-color:rgba(99,102,241,0.5);transform:translateY(-2px);}
.gc-cert-badge{width:60px;height:60px;border-radius:14px;display:flex;align-items:center;justify-content:center;font-size:28px;}
.gc-cert-name{font-size:16px;font-weight:700;color:#fff;margin:0;}
.gc-cert-pathway{font-size:12.5px;color:rgba(255,255,255,0.45);margin:0;}
.gc-cert-meta{display:flex;align-items:center;gap:8px;font-size:12px;color:rgba(255,255,255,0.35);}
.gc-lock-note{font-size:12px;color:rgba(99,102,241,0.8);background:rgba(99,102,241,0.1);border:1px solid rgba(99,102,241,0.2);border-radius:20px;padding:4px 12px;display:inline-block;}
.gc-unlock-btn{display:inline-block;padding:10px 22px;background:#6366F1;border-radius:8px;color:#fff;font-size:13.5px;font-weight:700;align-self:flex-start;transition:background 0.15s;}
.gc-unlock-btn:hover{background:#4F46E5;color:#fff;}
.gc-cta{background:linear-gradient(135deg,rgba(99,102,241,0.12),rgba(14,165,233,0.08));border:1px solid rgba(99,102,241,0.25);border-radius:14px;padding:40px;text-align:center;margin-top:44px;}
.gc-cta h3{font-size:24px;font-weight:700;color:#fff;margin:0 0 12px;}
.gc-cta p{font-size:14px;color:rgba(255,255,255,0.55);margin:0 0 24px;line-height:1.7;}
.gc-cta a{display:inline-block;padding:13px 32px;background:#6366F1;border-radius:9px;color:#fff;font-size:15px;font-weight:700;transition:background 0.15s;}
.gc-cta a:hover{background:#4F46E5;color:#fff;}
@media(max-width:768px){.gc-hero{padding:40px 20px 36px;}.gc-hero h1{font-size:28px;}.gc-wrap{padding:32px 20px 48px;}.gc-how{grid-template-columns:1fr;gap:16px;}}
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
            <li><a href="Dashboard.aspx">&#x1F3E0; Home</a></li>
            <li><a href="Learn.aspx">&#x1F4DA; Learn</a></li>
            <li><a href="Pathways.aspx">&#x25B6; Pathways</a></li>
            <li><a href="Modules.aspx">&#x1F4D6; Modules</a></li>
            <li><a href="Practice.aspx">&#x270F; Practice</a></li>
            <li><a href="Pricing.aspx">&#x1F4B0; Pricing</a></li>
            <li><a href="Certifications.aspx" class="active">&#x1F3C5; Certifications</a></li>
        </ul>
        <div class="gl-nav-acts">
            <a class="gl-btn-login" href="../LogIn.aspx">Log In</a>
            <a class="gl-btn-join"  href="../LogIn.aspx">Join for Free</a>
        </div>
    </div>
</header>

<section class="gc-hero" aria-label="Certifications page header">
    <h1>&#x1F3C5; CloudPhoria Certifications</h1>
    <p>Earn professional certifications by completing a full specialisation pathway. Each certificate demonstrates real-world cloud computing expertise.</p>
</section>

<main class="gc-main" role="main">
    <div class="gc-wrap">

        <%-- How to earn --%>
        <div class="gc-how" aria-label="How to earn certifications">
            <div class="gc-step">
                <div class="gc-step-num">1</div>
                <div><h4>Create a free account</h4><p>Sign up in under a minute — no credit card needed. Foundation pathway access is included.</p></div>
            </div>
            <div class="gc-step">
                <div class="gc-step-num">2</div>
                <div><h4>Complete all pathway modules</h4><p>Work through every module in your chosen specialisation pathway, passing each exam.</p></div>
            </div>
            <div class="gc-step">
                <div class="gc-step-num">3</div>
                <div><h4>Receive your certificate</h4><p>Your certificate is automatically issued once all modules are completed and exams passed.</p></div>
            </div>
        </div>

        <asp:Panel ID="pnlError" runat="server" Visible="false">
            <div style="background:rgba(239,68,68,0.1);border:1px solid rgba(239,68,68,0.25);border-radius:10px;padding:14px 18px;color:#FCA5A5;font-size:13px;margin-bottom:24px;" role="alert">
                <asp:Literal ID="litError" runat="server" />
            </div>
        </asp:Panel>

        <div class="gc-grid">
            <asp:Panel ID="pnlCertCards" runat="server" />
        </div>

        <div class="gc-cta">
            <h3>Start earning your certifications today</h3>
            <p>Create a free account to access all specialisation pathways, take module exams, earn XP and badges, and collect your professional CloudPhoria certificates.</p>
            <a href="../LogIn.aspx">&#x1F680; Create Free Account</a>
        </div>
    </div>
</main>

<%-- FOOTER --%>
<style>
.gl-footer{background:#070D1A;border-top:1px solid rgba(255,255,255,0.06);}
.gl-footer-inner{max-width:1280px;margin:0 auto;padding:48px 40px 36px;display:grid;grid-template-columns:1fr 1fr 1fr 1.8fr;gap:36px;}
.gl-footer-col-title{font-size:12px;font-weight:700;color:#fff;letter-spacing:0.06em;text-transform:uppercase;margin-bottom:16px;}
.gl-footer-link{display:block;font-size:13px;color:rgba(255,255,255,0.45);margin-bottom:10px;transition:color 0.15s;}
.gl-footer-link:hover{color:#0EA5E9;}
.gl-footer-brand{display:flex;align-items:center;gap:10px;margin-bottom:14px;}
.gl-footer-logo{width:36px;height:36px;background:linear-gradient(135deg,#0EA5E9,#6366F1);border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:900;color:#fff;flex-shrink:0;}
.gl-footer-wordmark{font-size:17px;font-weight:700;color:#fff;}
.gl-footer-wordmark em{font-style:normal;color:#0EA5E9;}
.gl-footer-desc{font-size:12.5px;color:rgba(255,255,255,0.4);line-height:1.7;margin:0;}
.gl-footer-bottom{max-width:1280px;margin:0 auto;padding:16px 40px;border-top:1px solid rgba(255,255,255,0.06);display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;}
.gl-footer-bottom span{font-size:12px;color:rgba(255,255,255,0.28);}
@media(max-width:768px){.gl-footer-inner{grid-template-columns:1fr 1fr;}.gl-footer-bottom{padding:12px 20px;}}
</style>
<footer class="gl-footer">
    <div class="gl-footer-inner">
        <div>
            <div class="gl-footer-col-title">Learning</div>
            <a href="Learn.aspx"          class="gl-footer-link">Roadmap</a>
            <a href="Pathways.aspx"       class="gl-footer-link">Pathways</a>
            <a href="Modules.aspx"        class="gl-footer-link">Modules</a>
            <a href="Practice.aspx"       class="gl-footer-link">Practice</a>
            <a href="Certifications.aspx" class="gl-footer-link">Certifications</a>
        </div>
        <div>
            <div class="gl-footer-col-title">Platform</div>
            <a href="../LogIn.aspx" class="gl-footer-link">Log In</a>
            <a href="../LogIn.aspx" class="gl-footer-link">Join for Free</a>
            <a href="Pricing.aspx"  class="gl-footer-link">Pricing</a>
        </div>
        <div>
            <div class="gl-footer-col-title">Legal</div>
            <a href="#" class="gl-footer-link">Privacy Policy</a>
            <a href="#" class="gl-footer-link">Terms of Use</a>
        </div>
        <div>
            <div class="gl-footer-brand">
                <div class="gl-footer-logo" aria-hidden="true">CP</div>
                <span class="gl-footer-wordmark">Cloud<em>Phoria</em></span>
            </div>
            <p class="gl-footer-desc">Gamified cloud learning — free to start, structured pathways, real certifications.</p>
        </div>
    </div>
    <div class="gl-footer-bottom">
        <span>&copy; <%: DateTime.Now.Year %> CloudPhoria. All rights reserved.</span>
        <span>CT050-3-2-WAPP &mdash; Group 14</span>
    </div>
</footer>

</div>
</form>
<script src="../Scripts/bootstrap.bundle.js"></script>
</body>
</html>
