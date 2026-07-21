<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Practice.aspx.cs" Inherits="CloudPhoria.Guest.Practice" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Practice – CloudPhoria</title>
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
/* Practice page */
.gpr-hero{background:linear-gradient(135deg,#0F172A,#1A2744);border-bottom:1px solid rgba(255,255,255,0.07);padding:48px 40px 44px;}
.gpr-hero-in{max-width:1280px;margin:0 auto;}
.gpr-hero-in h1{font-size:36px;font-weight:800;color:#fff;margin:0 0 10px;}
.gpr-hero-in p{font-size:15px;color:rgba(255,255,255,0.55);max-width:580px;line-height:1.7;margin:0;}
.gpr-main{flex:1;background:#0B1120;}
.gpr-wrap{max-width:1000px;margin:0 auto;padding:40px 40px 60px;}
.gpr-info{background:rgba(14,165,233,0.08);border:1px solid rgba(14,165,233,0.2);border-radius:10px;padding:14px 18px;font-size:13px;color:rgba(255,255,255,0.65);margin-bottom:28px;}
.gpr-info strong{color:#0EA5E9;}
/* Module picker */
.gpr-pick-label{font-size:13px;font-weight:600;color:rgba(255,255,255,0.6);margin-bottom:8px;}
.gpr-select{width:100%;background:#162032;border:1px solid rgba(255,255,255,0.15);border-radius:8px;color:#fff;font-size:14px;padding:10px 14px;-webkit-appearance:none;cursor:pointer;}
.gpr-select:focus{outline:2px solid #0EA5E9;border-color:#0EA5E9;}
.gpr-btn{display:inline-block;padding:11px 26px;background:#6366F1;border-radius:8px;color:#fff;font-size:14px;font-weight:700;border:none;cursor:pointer;transition:background 0.15s;}
.gpr-btn:hover{background:#4F46E5;}
/* Quiz area */
.gpr-quiz{display:none;}
.gpr-progress{display:flex;align-items:center;justify-content:space-between;margin-bottom:20px;}
.gpr-prog-bar-wrap{flex:1;height:6px;background:rgba(255,255,255,0.1);border-radius:3px;margin:0 16px;}
.gpr-prog-bar{height:6px;background:#6366F1;border-radius:3px;transition:width 0.3s;}
.gpr-q-card{background:#162032;border:1px solid rgba(255,255,255,0.1);border-radius:12px;padding:28px;}
.gpr-q-text{font-size:16px;font-weight:600;color:#fff;margin:0 0 24px;line-height:1.6;}
.gpr-opt{display:flex;align-items:center;gap:12px;padding:12px 16px;background:#1A2840;border:1.5px solid rgba(255,255,255,0.1);border-radius:9px;margin-bottom:10px;cursor:pointer;transition:border-color 0.15s,background 0.15s;}
.gpr-opt:hover{border-color:#6366F1;background:#1F3050;}
.gpr-opt.selected{border-color:#6366F1;background:rgba(99,102,241,0.15);}
.gpr-opt.correct{border-color:#22C55E;background:rgba(34,197,94,0.1);}
.gpr-opt.wrong{border-color:#EF4444;background:rgba(239,68,68,0.1);}
.gpr-opt-letter{width:28px;height:28px;border-radius:6px;background:rgba(255,255,255,0.08);display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;flex-shrink:0;}
.gpr-opt-text{font-size:14px;color:#fff;}
.gpr-feedback{margin-top:14px;padding:12px 16px;border-radius:8px;font-size:13.5px;font-weight:500;display:none;}
.gpr-feedback.correct{background:rgba(34,197,94,0.1);color:#86EFAC;border:1px solid rgba(34,197,94,0.2);}
.gpr-feedback.wrong{background:rgba(239,68,68,0.1);color:#FCA5A5;border:1px solid rgba(239,68,68,0.2);}
.gpr-nav{display:flex;justify-content:flex-end;margin-top:20px;}
/* Result */
.gpr-result{display:none;text-align:center;padding:48px 24px;}
.gpr-result-score{font-size:64px;font-weight:800;color:#0EA5E9;}
.gpr-result h3{font-size:22px;font-weight:700;color:#fff;margin:12px 0 8px;}
.gpr-result p{font-size:14px;color:rgba(255,255,255,0.5);margin:0 0 28px;}
.gpr-result-btn{padding:12px 28px;border-radius:9px;font-size:14px;font-weight:700;border:none;cursor:pointer;margin:6px;}
.gpr-result-btn.primary{background:#6366F1;color:#fff;}
.gpr-result-btn.secondary{background:transparent;border:2px solid rgba(255,255,255,0.2);color:#fff;}
@media(max-width:768px){.gpr-hero{padding:32px 20px 28px;}.gpr-hero-in h1{font-size:26px;}.gpr-wrap{padding:24px 16px 40px;}}
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
            <li><a href="Practice.aspx" class="active">&#x270F; Practice</a></li>
            <li><a href="Pricing.aspx">&#x1F4B0; Pricing</a></li>
            <li><a href="Certifications.aspx">&#x1F3C5; Certifications</a></li>
        </ul>
        <div class="gl-nav-acts">
            <a class="gl-btn-login" href="../LogIn.aspx">Log In</a>
            <a class="gl-btn-join"  href="../LogIn.aspx">Join for Free</a>
        </div>
    </div>
</header>

<section class="gpr-hero">
    <div class="gpr-hero-in">
        <h1>&#x270F; Practice Quiz</h1>
        <p>Test your cloud knowledge with practice questions — no sign-in required. Pick a module and start practising.</p>
    </div>
</section>

<main class="gpr-main" role="main">
    <div class="gpr-wrap">
        <asp:Panel ID="pnlError" runat="server" Visible="false">
            <div style="background:rgba(239,68,68,0.1);border:1px solid rgba(239,68,68,0.25);border-radius:10px;padding:14px 18px;color:#FCA5A5;font-size:13px;margin-bottom:20px;" role="alert">
                <asp:Literal ID="litError" runat="server" />
            </div>
        </asp:Panel>

        <%-- MODULE PICKER (shown until a module is selected) --%>
        <div id="divPicker">
            <div class="gpr-info">
                <strong>Guest Practice Mode:</strong> You are practising as an anonymous guest. Your session is tracked via a temporary cookie so you can see results — but XP and badges are only available to signed-in students.
                <a href="../LogIn.aspx" style="color:#0EA5E9;font-weight:600;">Sign in for full access &#x2192;</a>
            </div>
            <div class="gpr-pick-label">Select a module to practise:</div>
            <asp:DropDownList ID="ddlModules" runat="server" CssClass="gpr-select" />
            <div style="margin-top:16px;">
                <asp:Button ID="btnStart" runat="server" Text="Start Practice &#x2192;"
                    CssClass="gpr-btn" OnClick="btnStart_Click" />
            </div>
            <asp:Panel ID="pnlNoQuestions" runat="server" Visible="false">
                <div style="margin-top:16px;padding:14px 18px;background:rgba(245,158,11,0.08);border:1px solid rgba(245,158,11,0.2);border-radius:9px;font-size:13px;color:#FCD34D;">
                    &#x26A0; This module has no practice questions yet. Please select another module.
                </div>
            </asp:Panel>
        </div>

        <%-- QUIZ (rendered server-side, driven by JS) --%>
        <asp:Panel ID="pnlQuiz" runat="server" Visible="false">
            <div class="gpr-progress">
                <span id="spanQNum" style="font-size:13px;color:rgba(255,255,255,0.5);white-space:nowrap;"></span>
                <div class="gpr-prog-bar-wrap"><div class="gpr-prog-bar" id="progBar"></div></div>
                <span id="spanScore" style="font-size:13px;color:#22C55E;font-weight:700;white-space:nowrap;"></span>
            </div>
            <asp:Panel ID="pnlQuizContent" runat="server" />
            <div class="gpr-result" id="quizResult">
                <div class="gpr-result-score" id="resultScore"></div>
                <h3 id="resultTitle"></h3>
                <p id="resultSub"></p>
                <button class="gpr-result-btn primary" type="button" onclick="location.reload()">&#x21BA; Try Again</button>
                <a class="gpr-result-btn secondary" href="../LogIn.aspx">&#x1F680; Sign in for XP &amp; Badges</a>
            </div>
        </asp:Panel>

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
            <a href="Learn.aspx"    class="gl-footer-link">Roadmap</a>
            <a href="Pathways.aspx" class="gl-footer-link">Pathways</a>
            <a href="Modules.aspx"  class="gl-footer-link">Modules</a>
            <a href="Practice.aspx" class="gl-footer-link">Practice</a>
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
// Quiz data injected by server
var gprQuestions = <%: QuizDataJson %>;
var gprAttemptID = <%: AttemptID %>;
var gprCurrent   = 0;
var gprScore     = 0;
var gprAnswered  = false;

function gprInit() {
    if (!gprQuestions || gprQuestions.length === 0) return;
    gprRender(gprCurrent);
}

function gprRender(idx) {
    if (idx >= gprQuestions.length) { gprShowResult(); return; }
    var q = gprQuestions[idx];
    gprAnswered = false;
    var letters = ['A','B','C','D','E'];
    var html = '<div class="gpr-q-card">' +
        '<p class="gpr-q-text">' + (idx+1) + '. ' + escHtml(q.text) + '</p>';
    q.options.forEach(function(opt, i) {
        html += '<div class="gpr-opt" id="opt_' + opt.id + '" onclick="gprPick(this,' + opt.id + ',' + q.correctID + ',' + opt.isCorrect + ')">' +
            '<span class="gpr-opt-letter">' + letters[i] + '</span>' +
            '<span class="gpr-opt-text">' + escHtml(opt.text) + '</span></div>';
    });
    html += '<div class="gpr-feedback" id="feedbackBox"></div>';
    html += '</div>';
    html += '<div class="gpr-nav"><button class="gpr-btn" type="button" id="btnNext" style="display:none" onclick="gprNext()">Next &#x2192;</button></div>';
    document.getElementById('pnlQuizContent').innerHTML = html;
    updateProgress(idx, gprQuestions.length, gprScore);
}

function gprPick(el, optID, correctID, isCorrect) {
    if (gprAnswered) return;
    gprAnswered = true;
    document.querySelectorAll('.gpr-opt').forEach(function(o){ o.style.pointerEvents='none'; });
    var fb = document.getElementById('feedbackBox');
    if (isCorrect) {
        el.classList.add('correct');
        fb.textContent = '✓ Correct!';
        fb.className = 'gpr-feedback correct';
        fb.style.display = 'block';
        gprScore++;
    } else {
        el.classList.add('wrong');
        fb.textContent = '✗ Incorrect.';
        fb.className = 'gpr-feedback wrong';
        fb.style.display = 'block';
        var correctEl = document.getElementById('opt_' + correctID);
        if (correctEl) correctEl.classList.add('correct');
    }
    gprSaveAnswer(optID, isCorrect);
    document.getElementById('btnNext').style.display = 'inline-block';
    updateProgress(gprCurrent, gprQuestions.length, gprScore);
}

function gprNext() {
    gprCurrent++;
    gprRender(gprCurrent);
}

function gprShowResult() {
    document.getElementById('pnlQuizContent').innerHTML = '';
    document.getElementById('btnNext') && (document.getElementById('btnNext').style.display='none');
    var pct = gprQuestions.length > 0 ? Math.round(gprScore / gprQuestions.length * 100) : 0;
    document.getElementById('resultScore').textContent = pct + '%';
    document.getElementById('resultTitle').textContent = pct >= 70 ? '🎉 Great work!' : '📖 Keep practising!';
    document.getElementById('resultSub').textContent   = gprScore + ' / ' + gprQuestions.length + ' correct.';
    var res = document.getElementById('quizResult');
    res.style.display = 'block';
}

function updateProgress(idx, total, score) {
    var pct = total > 0 ? Math.round(idx / total * 100) : 0;
    document.getElementById('progBar').style.width = pct + '%';
    document.getElementById('spanQNum').textContent = 'Question ' + (idx+1) + ' of ' + total;
    document.getElementById('spanScore').textContent = 'Score: ' + score;
}

function gprSaveAnswer(optID, isCorrect) {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'Practice.aspx/SaveAnswer', true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    var qID = gprQuestions[gprCurrent] ? gprQuestions[gprCurrent].id : 0;
    xhr.send(JSON.stringify({ attemptID: gprAttemptID, questionID: qID, optionID: optID, isCorrect: isCorrect }));
}

function escHtml(s) {
    var d = document.createElement('div');
    d.appendChild(document.createTextNode(s));
    return d.innerHTML;
}

if (typeof gprQuestions !== 'undefined' && gprQuestions.length > 0) {
    document.getElementById('divPicker').style.display = 'none';
    document.getElementById('pnlQuiz').style.display   = 'block';
    gprInit();
}
</script>
</body>
</html>
