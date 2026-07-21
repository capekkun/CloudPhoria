<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Pricing.aspx.cs" Inherits="CloudPhoria.Guest.Pricing" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Pricing – CloudPhoria</title>
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
/* pricing */
.gpi-hero{background:linear-gradient(135deg,#0F172A,#1A2744);border-bottom:1px solid rgba(255,255,255,0.07);padding:60px 40px 56px;text-align:center;}
.gpi-hero h1{font-size:40px;font-weight:800;color:#fff;margin:0 0 14px;}
.gpi-hero p{font-size:15px;color:rgba(255,255,255,0.55);max-width:520px;margin:0 auto;line-height:1.7;}
.gpi-main{flex:1;background:#0B1120;}
.gpi-wrap{max-width:1100px;margin:0 auto;padding:52px 40px 64px;}
.gpi-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:20px;}
.gpi-card{background:#162032;border:1px solid rgba(255,255,255,0.08);border-radius:16px;overflow:hidden;display:flex;flex-direction:column;position:relative;}
.gpi-card.featured{border-color:rgba(14,165,233,0.4);box-shadow:0 0 36px rgba(14,165,233,0.08);}
.gpi-card-badge{position:absolute;top:16px;right:16px;background:#0EA5E9;color:#fff;font-size:11px;font-weight:700;padding:3px 10px;border-radius:20px;}
.gpi-card-top{padding:28px 28px 22px;}
.gpi-plan-name{font-size:13px;font-weight:700;color:rgba(255,255,255,0.5);text-transform:uppercase;letter-spacing:0.07em;margin-bottom:10px;}
.gpi-price{font-size:40px;font-weight:800;color:#fff;line-height:1;}
.gpi-price sup{font-size:18px;vertical-align:top;margin-top:8px;margin-right:2px;}
.gpi-price sub{font-size:13px;color:rgba(255,255,255,0.4);font-weight:500;}
.gpi-desc{font-size:13px;color:rgba(255,255,255,0.5);margin:12px 0 0;line-height:1.65;}
.gpi-divider{height:1px;background:rgba(255,255,255,0.07);margin:0 28px;}
.gpi-features{padding:22px 28px;flex:1;}
.gpi-feat-item{display:flex;align-items:flex-start;gap:10px;margin-bottom:12px;font-size:13.5px;color:rgba(255,255,255,0.7);}
.gpi-feat-icon{flex-shrink:0;font-size:14px;margin-top:1px;}
.gpi-feat-item.muted{color:rgba(255,255,255,0.3);}
.gpi-card-cta{padding:20px 28px;}
.gpi-cta-btn{display:block;width:100%;padding:12px;border-radius:9px;font-size:14px;font-weight:700;text-align:center;transition:all 0.15s;}
.gpi-cta-btn.primary{background:#0EA5E9;color:#fff;border:2px solid #0EA5E9;}
.gpi-cta-btn.primary:hover{background:#0284C7;border-color:#0284C7;}
.gpi-cta-btn.outline{background:transparent;color:#fff;border:2px solid rgba(255,255,255,0.18);}
.gpi-cta-btn.outline:hover{border-color:#0EA5E9;color:#0EA5E9;}
.gpi-faq{max-width:760px;margin:56px auto 0;}
.gpi-faq h2{font-size:22px;font-weight:700;color:#fff;margin:0 0 24px;text-align:center;}
.gpi-faq-item{background:#162032;border:1px solid rgba(255,255,255,0.08);border-radius:10px;margin-bottom:10px;overflow:hidden;}
.gpi-faq-q{display:flex;align-items:center;justify-content:space-between;padding:16px 20px;cursor:pointer;font-size:14px;font-weight:600;color:#fff;}
.gpi-faq-q:hover{background:rgba(255,255,255,0.04);}
.gpi-faq-a{padding:0 20px;max-height:0;overflow:hidden;transition:max-height 0.3s,padding 0.3s;font-size:13.5px;color:rgba(255,255,255,0.55);line-height:1.7;}
.gpi-faq-a.open{max-height:200px;padding:0 20px 16px;}
@media(max-width:900px){.gpi-grid{grid-template-columns:1fr;}.gpi-wrap{padding:36px 20px 48px;}.gpi-hero{padding:40px 20px 36px;}.gpi-hero h1{font-size:28px;}}
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
            <li><a href="Pricing.aspx" class="active">&#x1F4B0; Pricing</a></li>
            <li><a href="Certifications.aspx">&#x1F3C5; Certifications</a></li>
        </ul>
        <div class="gl-nav-acts">
            <a class="gl-btn-login" href="../LogIn.aspx">Log In</a>
            <a class="gl-btn-join"  href="../LogIn.aspx">Join for Free</a>
        </div>
    </div>
</header>

<section class="gpi-hero" aria-label="Pricing page header">
    <h1>&#x1F4B0; Simple Pricing</h1>
    <p>Choose the plan that fits your goals. The Foundation pathway is free forever — no credit card needed.</p>
</section>

<main class="gpi-main" role="main">
    <div class="gpi-wrap">
        <asp:Panel ID="pnlError" runat="server" Visible="false">
            <div style="background:rgba(239,68,68,0.1);border:1px solid rgba(239,68,68,0.25);border-radius:10px;padding:14px 18px;color:#FCA5A5;font-size:13px;margin-bottom:24px;" role="alert">
                <asp:Literal ID="litError" runat="server" />
            </div>
        </asp:Panel>

        <div class="gpi-grid">
            <asp:Panel ID="pnlPlanCards" runat="server" />
        </div>

        <%-- FAQ --%>
        <div class="gpi-faq">
            <h2>Frequently Asked Questions</h2>
            <div class="gpi-faq-item">
                <div class="gpi-faq-q" onclick="gpiToggle(this)">Is the Free plan really free forever? <span>&#x25BC;</span></div>
                <div class="gpi-faq-a">Yes. The Free plan gives you permanent access to the entire Cloud Foundation pathway — no expiry date and no credit card required.</div>
            </div>
            <div class="gpi-faq-item">
                <div class="gpi-faq-q" onclick="gpiToggle(this)">What is included in the Pro plan? <span>&#x25BC;</span></div>
                <div class="gpi-faq-a">The Pro plan unlocks all specialisation pathways, certifications, challenge rooms, boss fights, instructor consultations and community fun rooms.</div>
            </div>
            <div class="gpi-faq-item">
                <div class="gpi-faq-q" onclick="gpiToggle(this)">Is there a student discount? <span>&#x25BC;</span></div>
                <div class="gpi-faq-a">Yes — the Student plan offers full access at a reduced price. Verify your student status at sign-up.</div>
            </div>
            <div class="gpi-faq-item">
                <div class="gpi-faq-q" onclick="gpiToggle(this)">Can I cancel at any time? <span>&#x25BC;</span></div>
                <div class="gpi-faq-a">Yes, you can cancel your subscription at any time. Your access continues until the end of your current billing period.</div>
            </div>
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
<script>
function gpiToggle(el) {
    var ans = el.nextElementSibling;
    ans.classList.toggle('open');
    el.querySelector('span').textContent = ans.classList.contains('open') ? '▲' : '▼';
}
</script>
</body>
</html>
