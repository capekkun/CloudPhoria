<%@ Page Title="Live Challenge" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="ChallengeDetail.aspx.cs"
    Inherits="CloudPhoria.Student.ChallengeDetail" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.ch-page{background:#0B0F1A !important;}
.ch-layout{display:grid;grid-template-columns:1fr 320px;gap:24px;max-width:1100px;margin:0 auto;}

/* Challenge card */
.ch-main{background:linear-gradient(135deg,#1E1B4B,#312E81);border-radius:16px;
    padding:32px;color:#fff;position:relative;overflow:hidden;}
.ch-main::before{content:'';position:absolute;inset:0;
    background:radial-gradient(circle at 30% 20%,rgba(99,102,241,0.1),transparent 50%);pointer-events:none;}

/* Timer bar */
.ch-timer{display:flex;align-items:center;justify-content:center;gap:10px;
    margin-bottom:24px;position:relative;z-index:1;}
.ch-timer-icon{font-size:24px;}
.ch-timer-text{font-size:28px;font-weight:800;color:#F59E0B;font-variant-numeric:tabular-nums;}
.ch-timer-label{font-size:12px;color:rgba(255,255,255,0.4);}
.ch-timer-bar{width:100%;height:6px;background:rgba(255,255,255,0.1);border-radius:3px;
    margin-top:8px;overflow:hidden;}
.ch-timer-fill{height:100%;background:linear-gradient(90deg,#22C55E,#F59E0B,#EF4444);
    border-radius:3px;transition:width 1s linear;}

/* Question */
.ch-q{position:relative;z-index:1;}
.ch-q-progress{font-size:12px;color:rgba(255,255,255,0.4);margin-bottom:8px;}
.ch-q-text{font-size:18px;font-weight:700;color:#fff;margin:0 0 24px;line-height:1.5;}
.ch-q-opts{display:flex;flex-direction:column;gap:10px;}
.ch-opt{display:block;padding:14px 18px;background:rgba(255,255,255,0.05);
    border:1.5px solid rgba(255,255,255,0.12);border-radius:10px;color:#fff;
    font-size:14px;cursor:pointer;transition:all 0.15s;text-decoration:none;}
.ch-opt:hover{background:rgba(99,102,241,0.15);border-color:#6366F1;text-decoration:none;color:#fff;}
.ch-opt-correct{background:rgba(34,197,94,0.2)!important;border-color:#22C55E!important;}
.ch-opt-wrong{background:rgba(239,68,68,0.2)!important;border-color:#EF4444!important;}
.ch-opt-disabled{pointer-events:none;opacity:0.6;}

/* Score display */
.ch-score{text-align:center;margin-bottom:20px;position:relative;z-index:1;}
.ch-score-num{font-size:36px;font-weight:800;color:#fff;}
.ch-score-label{font-size:12px;color:rgba(255,255,255,0.4);}

/* Start screen */
.ch-start{text-align:center;padding:40px 0;position:relative;z-index:1;}
.ch-start h2{font-size:24px;font-weight:800;margin:0 0 8px;}
.ch-start p{font-size:14px;color:rgba(255,255,255,0.5);margin:0 0 24px;}
.ch-start-btn{display:inline-block;padding:16px 40px;background:linear-gradient(90deg,#6366F1,#8B5CF6);
    color:#fff;font-size:16px;font-weight:700;border-radius:10px;border:none;cursor:pointer;
    box-shadow:0 8px 24px rgba(99,102,241,0.4);transition:all 0.15s;text-decoration:none;}
.ch-start-btn:hover{transform:translateY(-2px);box-shadow:0 12px 32px rgba(99,102,241,0.5);color:#fff;text-decoration:none;}

/* Leaderboard */
.ch-lb{background:#1E293B;border:1px solid rgba(255,255,255,0.06);border-radius:16px;
    padding:24px;color:#fff;height:fit-content;}
.ch-lb h3{font-size:16px;font-weight:700;margin:0 0 16px;display:flex;align-items:center;gap:8px;}
.ch-lb-item{display:flex;align-items:center;gap:12px;padding:10px 0;
    border-bottom:1px solid rgba(255,255,255,0.05);}
.ch-lb-item:last-child{border-bottom:none;}
.ch-lb-rank{width:28px;height:28px;border-radius:50%;background:rgba(255,255,255,0.05);
    display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;flex-shrink:0;}
.ch-lb-rank-1{background:linear-gradient(135deg,#F59E0B,#EF4444);color:#fff;}
.ch-lb-rank-2{background:linear-gradient(135deg,#94A3B8,#64748B);color:#fff;}
.ch-lb-rank-3{background:linear-gradient(135deg,#D97706,#92400E);color:#fff;}
.ch-lb-name{flex:1;font-size:13px;font-weight:500;color:rgba(255,255,255,0.8);}
.ch-lb-score{font-size:14px;font-weight:700;color:#F59E0B;}
.ch-lb-empty{text-align:center;padding:20px;color:rgba(255,255,255,0.3);font-size:13px;}

/* Result */
.ch-result{text-align:center;padding:40px 0;position:relative;z-index:1;}
.ch-result-icon{font-size:64px;margin-bottom:16px;display:block;}
.ch-result h2{font-size:26px;font-weight:800;margin:0 0 8px;}
.ch-result p{font-size:14px;color:rgba(255,255,255,0.5);margin:0 0 24px;}
.ch-result-score{font-size:36px;font-weight:800;color:#F59E0B;margin-bottom:24px;}

@media(max-width:768px){
    .ch-layout{grid-template-columns:1fr;}
    .ch-main{padding:24px 20px;}
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="cp-alert cp-alert-danger cp-mb-md"><asp:Literal ID="litError" runat="server" /></div>
</asp:Panel>

<asp:Panel ID="pnlChallenge" runat="server" Visible="false">
<div class="ch-layout">
    <%-- Main area --%>
    <div class="ch-main">
        <div class="ch-score">
            <div class="ch-score-num"><asp:Literal ID="litScore" runat="server" Text="0" /></div>
            <div class="ch-score-label">points</div>
        </div>

        <%-- Start screen --%>
        <asp:Panel ID="pnlStart" runat="server" style="display:block;">
            <div class="ch-start">
                <h2><asp:Literal ID="litTitle" runat="server" /></h2>
                <p><asp:Literal ID="litDescription" runat="server" /></p>
                <p style="font-size:13px;color:rgba(255,255,255,0.4);margin-bottom:20px;">
                    <asp:Literal ID="litQuestionCount" runat="server" /> questions &bull;
                    +<asp:Literal ID="litXPReward" runat="server" /> XP &bull;
                    Ends: <asp:Literal ID="litEndDate" runat="server" />
                </p>
                <asp:Button ID="btnStart" runat="server" Text="Start Challenge &#x1F680;"
                    CssClass="ch-start-btn" OnClick="btnStart_Click" />
            </div>
        </asp:Panel>

        <%-- Question panel --%>
        <asp:Panel ID="pnlQuestion" runat="server" style="display:none;">
            <div class="ch-timer">
                <span class="ch-timer-icon">&#x23F1;</span>
                <span class="ch-timer-text" id="timerDisplay">30</span>
                <span class="ch-timer-label">seconds</span>
            </div>
            <div class="ch-timer-bar">
                <div class="ch-timer-fill" id="timerBar" style="width:100%;"></div>
            </div>
            <div class="ch-q" style="margin-top:24px;">
                <div class="ch-q-progress">Question <asp:Literal ID="litQNum" runat="server" /> of <asp:Literal ID="litQTotal" runat="server" /></div>
                <div class="ch-q-text"><asp:Literal ID="litQText" runat="server" /></div>
                <div class="ch-q-opts">
                    <asp:Literal ID="litQOpts" runat="server" />
                </div>
            </div>
            <asp:HiddenField ID="hdnAnswer" runat="server" />
            <asp:Button ID="btnSubmitAnswer" runat="server" style="display:none;" OnClick="btnSubmitAnswer_Click" />
        </asp:Panel>

        <%-- Result panel --%>
        <asp:Panel ID="pnlResult" runat="server" style="display:none;">
            <div class="ch-result">
                <span class="ch-result-icon">&#x1F3C6;</span>
                <h2>Challenge Complete!</h2>
                <p>Here's how you did</p>
                <div class="ch-result-score"><asp:Literal ID="litFinalScore" runat="server" /> pts</div>
                <p style="font-size:13px;color:rgba(255,255,255,0.4);">
                    +<asp:Literal ID="litXPEarned" runat="server" /> XP earned
                </p>
                <a href="Challenges.aspx" class="ch-start-btn" style="font-size:14px;padding:12px 28px;">
                    Back to Challenges
                </a>
            </div>
        </asp:Panel>
    </div>

    <%-- Leaderboard --%>
    <div class="ch-lb">
        <h3>&#x1F3C6; Leaderboard</h3>
        <asp:Literal ID="litLeaderboard" runat="server" />
    </div>
</div>
</asp:Panel>

<asp:HiddenField ID="hdnTimeLimit" runat="server" Value="30" />
<script>
var chTimerInterval = null;
function startChTimer(seconds) {
    var display = document.getElementById('timerDisplay');
    var bar = document.getElementById('timerBar');
    var totalSeconds = seconds;
    var remaining = seconds;
    if (chTimerInterval) clearInterval(chTimerInterval);

    display.textContent = remaining;
    bar.style.width = '100%';

    chTimerInterval = setInterval(function() {
        remaining--;
        display.textContent = remaining;
        bar.style.width = ((remaining / totalSeconds) * 100) + '%';

        if (remaining <= 5) display.style.color = '#EF4444';
        else display.style.color = '#F59E0B';

        if (remaining <= 0) {
            clearInterval(chTimerInterval);
            display.textContent = '0';
            // Auto-submit timeout
            var hdn = document.getElementById('<%= hdnAnswer.ClientID %>');
            var btn = document.getElementById('<%= btnSubmitAnswer.ClientID %>');
            if (hdn && btn) { hdn.value = '0'; btn.click(); }
        }
    }, 1000);
}

function selectChAnswer(el, optionID) {
    var hdn = document.getElementById('<%= hdnAnswer.ClientID %>');
    var btn = document.getElementById('<%= btnSubmitAnswer.ClientID %>');
    if (hdn && btn) {
        hdn.value = optionID;
        // Disable all options
        var opts = document.querySelectorAll('.ch-opt');
        for (var i = 0; i < opts.length; i++) opts[i].classList.add('ch-opt-disabled');
        el.style.borderColor = '#6366F1';
        el.style.background = 'rgba(99,102,241,0.2)';
        clearInterval(chTimerInterval);
        btn.click();
    }
}
</script>

</asp:Content>
