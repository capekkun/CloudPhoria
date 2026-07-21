<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Modules.aspx.cs" Inherits="CloudPhoria.Guest.Modules" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Modules – CloudPhoria</title>
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
.gl-brand-name{font-size:17px;font-weight:700;color:#fff;letter-spacing:-0.3px;}
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
/* page styles */
.gm-hero{background:linear-gradient(135deg,#0F172A,#1A2744);border-bottom:1px solid rgba(255,255,255,0.07);padding:48px 40px 44px;}
.gm-hero-in{max-width:1280px;margin:0 auto;}
.gm-hero-in h1{font-size:36px;font-weight:800;color:#fff;margin:0 0 10px;}
.gm-hero-in p{font-size:15px;color:rgba(255,255,255,0.55);max-width:580px;line-height:1.7;margin:0;}
.gm-filters{background:#111827;border-bottom:1px solid rgba(255,255,255,0.07);}
.gm-filters-in{max-width:1280px;margin:0 auto;padding:14px 40px;display:flex;gap:12px;align-items:center;flex-wrap:wrap;}
.gm-filter-btn{padding:6px 16px;border-radius:20px;font-size:12.5px;font-weight:500;cursor:pointer;border:1px solid rgba(255,255,255,0.15);background:transparent;color:rgba(255,255,255,0.55);transition:all 0.15s;}
.gm-filter-btn.active, .gm-filter-btn:hover{background:#0EA5E9;border-color:#0EA5E9;color:#fff;}
.gm-filter-btn:focus-visible{outline:2px solid #0EA5E9;outline-offset:2px;}
.gm-main{flex:1;background:#0B1120;}
.gm-wrap{max-width:1280px;margin:0 auto;padding:32px 40px 60px;}
.gm-group-title{font-size:13px;font-weight:700;color:rgba(255,255,255,0.35);text-transform:uppercase;letter-spacing:0.07em;margin:28px 0 12px;}
.gm-group-title:first-child{margin-top:0;}
.gm-list{display:flex;flex-direction:column;gap:10px;}
.gm-row{background:#162032;border:1px solid rgba(255,255,255,0.08);border-radius:10px;padding:14px 18px;display:flex;align-items:center;gap:16px;transition:border-color 0.15s;}
.gm-row:hover{border-color:rgba(14,165,233,0.25);}
.gm-ico{font-size:24px;flex-shrink:0;}
.gm-name{font-size:14px;font-weight:600;color:#fff;}
.gm-sub{font-size:12px;color:rgba(255,255,255,0.4);margin-top:3px;}
.gm-badges{display:flex;gap:7px;margin-left:auto;align-items:center;flex-shrink:0;}
.gm-diff{border-radius:20px;font-size:11px;font-weight:700;padding:3px 10px;}
.gm-diff-easy{background:rgba(34,197,94,0.12);color:#22C55E;border:1px solid rgba(34,197,94,0.25);}
.gm-diff-medium{background:rgba(245,158,11,0.12);color:#F59E0B;border:1px solid rgba(245,158,11,0.25);}
.gm-diff-hard{background:rgba(239,68,68,0.12);color:#EF4444;border:1px solid rgba(239,68,68,0.25);}
.gm-tag-free{background:rgba(34,197,94,0.1);color:#22C55E;border:1px solid rgba(34,197,94,0.2);border-radius:20px;font-size:11px;font-weight:700;padding:3px 10px;}
.gm-tag-lock{background:rgba(100,116,139,0.08);color:rgba(255,255,255,0.3);border:1px solid rgba(100,116,139,0.15);border-radius:20px;font-size:11px;padding:3px 10px;}
.gm-xp{font-size:11px;color:#F59E0B;font-weight:700;white-space:nowrap;}
@media(max-width:768px){.gm-hero{padding:32px 20px 28px;}.gm-hero-in h1{font-size:26px;}.gm-wrap{padding:20px 16px 40px;}.gm-filters-in{padding:12px 16px;}}
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
            <li><a href="Modules.aspx" class="active">&#x1F4D6; Modules</a></li>
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

<section class="gm-hero" aria-label="Modules page header">
    <div class="gm-hero-in">
        <h1>&#x1F4D6; Modules</h1>
        <p>All published cloud computing modules, grouped by pathway. Filter by difficulty or access level.</p>
    </div>
</section>

<nav class="gm-filters" aria-label="Module filters">
    <div class="gm-filters-in">
        <span style="font-size:12px;color:rgba(255,255,255,0.4);font-weight:600;margin-right:4px;">FILTER:</span>
        <button class="gm-filter-btn active" type="button" onclick="gmFilter('all',this)">All</button>
        <button class="gm-filter-btn" type="button" onclick="gmFilter('free',this)">Free</button>
        <button class="gm-filter-btn" type="button" onclick="gmFilter('easy',this)">Easy</button>
        <button class="gm-filter-btn" type="button" onclick="gmFilter('medium',this)">Medium</button>
        <button class="gm-filter-btn" type="button" onclick="gmFilter('hard',this)">Hard</button>
        <asp:Panel ID="pnlPathwayFilter" runat="server" style="display:flex;gap:8px;flex-wrap:wrap;" />
    </div>
</nav>

<main class="gm-main" role="main" id="gmMain">
    <div class="gm-wrap">
        <asp:Panel ID="pnlError" runat="server" Visible="false">
            <div style="background:rgba(239,68,68,0.1);border:1px solid rgba(239,68,68,0.25);border-radius:10px;padding:14px 18px;color:#FCA5A5;font-size:13px;margin-bottom:20px;" role="alert">
                <asp:Literal ID="litError" runat="server" />
            </div>
        </asp:Panel>
        <asp:Panel ID="pnlModuleList" runat="server" />
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
@media(max-width:768px){.gl-footer-inner{grid-template-columns:1fr 1fr;gap:20px;padding:28px 20px;}.gl-footer-bottom{padding:12px 20px;}}
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
// Client-side filter — toggles visibility of .gm-row by data attributes
function gmFilter(type, btn) {
    document.querySelectorAll('.gm-filter-btn').forEach(function(b){ b.classList.remove('active'); });
    btn.classList.add('active');
    var rows = document.querySelectorAll('.gm-row');
    rows.forEach(function(row){
        var show = true;
        if (type === 'free')   show = row.dataset.free === '1';
        else if (type === 'easy')   show = row.dataset.diff === 'Easy';
        else if (type === 'medium') show = row.dataset.diff === 'Medium';
        else if (type === 'hard')   show = row.dataset.diff === 'Hard';
        else if (type.startsWith('pw-')) show = row.dataset.pathway === type.substring(3);
        row.style.display = show ? '' : 'none';
    });
    // hide group headers that have no visible rows
    document.querySelectorAll('.gm-group-section').forEach(function(sec){
        var hasVisible = Array.from(sec.querySelectorAll('.gm-row')).some(function(r){ return r.style.display !== 'none'; });
        sec.style.display = hasVisible ? '' : 'none';
    });
}
</script>
</body>
</html>
