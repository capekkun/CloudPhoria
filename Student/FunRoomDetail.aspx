<%@ Page Title="Fun Room" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="FunRoomDetail.aspx.cs"
    Inherits="CloudPhoria.Student.FunRoomDetail" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.fr-hero{background:linear-gradient(135deg,#1E1B4B 0%,#312E81 60%,#1E1B4B 100%);
    padding:32px;color:#fff;border-radius:0;margin:-24px -32px 24px;position:relative;overflow:hidden;}
.fr-hero::before{content:'';position:absolute;inset:0;
    background:radial-gradient(ellipse at 50% 0%,rgba(168,85,247,0.1),transparent 60%);pointer-events:none;}
.fr-hero a{color:#A78BFA;font-size:13px;text-decoration:none;position:relative;z-index:1;}
.fr-hero h1{font-size:28px;font-weight:800;margin:12px 0 8px;position:relative;z-index:1;}
.fr-hero p{font-size:14px;color:rgba(255,255,255,0.6);margin:0;position:relative;z-index:1;}
.fr-hero-meta{display:flex;gap:16px;margin-top:12px;font-size:13px;color:rgba(255,255,255,0.5);position:relative;z-index:1;}

/* Quiz cards */
.fr-quiz{max-width:700px;}
.fr-q-card{background:#fff;border:1px solid #E2E8F0;border-radius:14px;padding:24px;
    margin-bottom:16px;transition:border-color 0.15s;}
.fr-q-card.answered-correct{border-color:#22C55E;background:#F0FDF4;}
.fr-q-card.answered-wrong{border-color:#EF4444;background:#FEF2F2;}
.fr-q-number{font-size:12px;font-weight:700;color:#6366F1;text-transform:uppercase;
    letter-spacing:0.05em;margin-bottom:8px;}
.fr-q-text{font-size:15px;font-weight:600;color:#172033;margin:0 0 16px;line-height:1.5;}
.fr-q-opts{display:flex;flex-direction:column;gap:8px;}
.fr-opt{display:block;padding:12px 16px;background:#F8FAFC;border:1.5px solid #E2E8F0;
    border-radius:10px;font-size:13px;color:#172033;cursor:pointer;transition:all 0.15s;
    text-decoration:none;}
.fr-opt:hover{border-color:#6366F1;background:#EEF2FF;text-decoration:none;color:#172033;}
.fr-opt-correct{border-color:#22C55E!important;background:#DCFCE7!important;color:#166534!important;font-weight:600;}
.fr-opt-wrong{border-color:#EF4444!important;background:#FEE2E2!important;color:#991B1B!important;}
.fr-opt-disabled{pointer-events:none;opacity:0.7;}

/* Score */
.fr-score{background:linear-gradient(135deg,#EEF2FF,#E0E7FF);border:2px solid #6366F1;
    border-radius:14px;padding:28px;text-align:center;margin-top:24px;}
.fr-score h2{font-size:22px;font-weight:800;color:#312E81;margin:0 0 8px;}
.fr-score p{font-size:14px;color:#4338CA;margin:0;}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<%-- Hero --%>
<div class="fr-hero">
    <a href="FunRooms.aspx">&#x2190; Back to Fun Rooms</a>
    <h1>&#x1F3AE; <asp:Literal ID="litRoomTitle" runat="server" /></h1>
    <p><asp:Literal ID="litDescription" runat="server" /></p>
    <div class="fr-hero-meta">
        <span>&#x1F464; Created by <asp:Literal ID="litCreator" runat="server" /></span>
        <span>&#x2753; <asp:Literal ID="litQuestionCount" runat="server" /> questions</span>
        <span>&#x26A1; <asp:Literal ID="litTotalXP" runat="server" /> XP available</span>
    </div>
</div>

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="cp-alert cp-alert-danger cp-mb-md"><asp:Literal ID="litError" runat="server" /></div>
</asp:Panel>

<asp:Panel ID="pnlContent" runat="server" Visible="false">
    <div class="fr-quiz">
        <asp:Literal ID="litQuestions" runat="server" />
    </div>
</asp:Panel>

<script>
function selectFROption(el, qCard, isCorrect) {
    // Prevent re-answering
    if (qCard.classList.contains('answered-correct') || qCard.classList.contains('answered-wrong')) return;

    // Mark all options as disabled
    var opts = qCard.querySelectorAll('.fr-opt');
    for (var i = 0; i < opts.length; i++) opts[i].classList.add('fr-opt-disabled');

    if (isCorrect) {
        el.classList.add('fr-opt-correct');
        qCard.classList.add('answered-correct');
        updateScore(1);
    } else {
        el.classList.add('fr-opt-wrong');
        qCard.classList.add('answered-wrong');
        // Show correct answer
        var correctOpt = qCard.querySelector('[data-correct="1"]');
        if (correctOpt) correctOpt.classList.add('fr-opt-correct');
        updateScore(0);
    }
}

var totalQ = 0, correctQ = 0;
function initScore(total) { totalQ = total; }
function updateScore(correct) {
    correctQ += correct;
    var scoreEl = document.getElementById('frScoreDisplay');
    if (scoreEl) scoreEl.textContent = correctQ + ' / ' + totalQ;
}
</script>

</asp:Content>
