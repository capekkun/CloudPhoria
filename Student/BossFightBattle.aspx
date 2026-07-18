<%@ Page Title="Boss Battle" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="BossFightBattle.aspx.cs"
    Inherits="CloudPhoria.Student.BossFightBattle" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* Override master page light background — DARK BATTLE THEME */
.cp-page { background: #0B0F1A !important; background-image: none !important; padding: 16px !important; }
.cp-page::before, .cp-page::after { display: none !important; }

/* ================================================================
   BOSS FIGHT BATTLE ARENA — Dramatic, dark, gamified
   ================================================================ */
.bf { background: linear-gradient(180deg, #0B0F1A 0%, #1A0A2E 40%, #0B0F1A 100%);
    border-radius:18px; padding:0; color:#fff;
    position:relative; overflow:hidden; border:1px solid rgba(220,38,38,0.15); }

/* Animated background */
.bf::before { content:''; position:absolute; inset:0; z-index:0;
    background:
        radial-gradient(ellipse at 30% 20%, rgba(124,58,237,0.12) 0%, transparent 50%),
        radial-gradient(ellipse at 70% 80%, rgba(220,38,38,0.08) 0%, transparent 50%),
        linear-gradient(rgba(220,38,38,0.02) 1px, transparent 1px),
        linear-gradient(90deg, rgba(220,38,38,0.02) 1px, transparent 1px);
    background-size:100% 100%,100% 100%,28px 28px,28px 28px;
    animation:bgPulse 4s ease-in-out infinite; pointer-events:none; }
@keyframes bgPulse { 0%,100%{opacity:1;} 50%{opacity:0.7;} }

.bf-inner { position:relative; z-index:1; padding:36px 32px; }

/* Boss area */
.bf-boss { text-align:center; margin-bottom:28px; }
.bf-boss-ring { width:140px; height:140px; margin:0 auto 18px; border-radius:50%;
    background:conic-gradient(from 0deg, #DC2626, #7C3AED, #F97316, #DC2626);
    padding:4px; animation:ringRotate 6s linear infinite;
    box-shadow:0 0 50px rgba(220,38,38,0.3), 0 0 100px rgba(124,58,237,0.15); }
@keyframes ringRotate { 0%{transform:rotate(0deg);} 100%{transform:rotate(360deg);} }
.bf-boss-inner { width:100%; height:100%; border-radius:50%;
    background:#1A1F2E; display:flex; align-items:center; justify-content:center;
    font-size:56px; overflow:hidden; }
.bf-boss-inner img { width:100%; height:100%; object-fit:cover; border-radius:50%; }
.bf-boss-name { font-size:24px; font-weight:800; color:#fff; margin:0 0 4px;
    text-shadow:0 0 20px rgba(220,38,38,0.4); letter-spacing:-0.3px; }
.bf-boss-diff { font-size:11px; font-weight:700; text-transform:uppercase;
    letter-spacing:0.1em; padding:3px 12px; border-radius:20px; display:inline-block; }
.bf-diff-easy { background:rgba(34,197,94,0.15); color:#22C55E; border:1px solid rgba(34,197,94,0.3); }
.bf-diff-medium { background:rgba(245,158,11,0.15); color:#F59E0B; border:1px solid rgba(245,158,11,0.3); }
.bf-diff-hard { background:rgba(239,68,68,0.15); color:#EF4444; border:1px solid rgba(239,68,68,0.3); }
.bf-diff-legendary { background:rgba(168,85,247,0.15); color:#A855F7; border:1px solid rgba(168,85,247,0.3); }

/* HP bars */
.bf-hp-row { display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:28px; }
.bf-hp-box { background:rgba(255,255,255,0.03); border:1px solid rgba(255,255,255,0.07);
    border-radius:14px; padding:18px 20px; }
.bf-hp-lbl { font-size:11px; font-weight:700; color:rgba(255,255,255,0.45);
    text-transform:uppercase; letter-spacing:0.08em; margin-bottom:8px;
    display:flex; align-items:center; gap:6px; }
.bf-hp-val { font-size:22px; font-weight:800; margin-bottom:10px; }
.bf-hp-bar { height:12px; border-radius:6px; background:rgba(255,255,255,0.08);
    overflow:hidden; position:relative; }
.bf-hp-fill { height:100%; border-radius:6px; transition:width 0.6s ease; position:relative; }
.bf-hp-fill-boss { background:linear-gradient(90deg,#EF4444,#F97316); }
.bf-hp-fill-player { background:linear-gradient(90deg,#0EA5E9,#22C55E); }
.bf-hp-fill::after { content:''; position:absolute; top:0; left:0; right:0; bottom:0;
    background:linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
    animation:hpShimmer 2s linear infinite; }
@keyframes hpShimmer { 0%{transform:translateX(-100%);} 100%{transform:translateX(100%);} }

/* XP reward */
.bf-reward { text-align:center; margin-bottom:24px; }
.bf-reward-chip { display:inline-flex; align-items:center; gap:8px;
    background:rgba(245,158,11,0.12); border:1px solid rgba(245,158,11,0.3);
    color:#F59E0B; padding:10px 24px; border-radius:28px;
    font-size:15px; font-weight:700;
    box-shadow:0 0 20px rgba(245,158,11,0.1);
    animation:rewardGlow 2s ease-in-out infinite; }
@keyframes rewardGlow { 0%,100%{box-shadow:0 0 20px rgba(245,158,11,0.1);}
    50%{box-shadow:0 0 30px rgba(245,158,11,0.25);} }

/* Question area */
.bf-question { background:rgba(255,255,255,0.04); border:1px solid rgba(255,255,255,0.08);
    border-radius:16px; padding:28px 24px; text-align:center; }
.bf-q-number { font-size:12px; color:rgba(255,255,255,0.35); text-transform:uppercase;
    letter-spacing:0.08em; margin-bottom:8px; }
.bf-q-text { font-size:17px; font-weight:600; color:#fff; margin:0 0 24px;
    line-height:1.6; max-width:600px; margin-left:auto; margin-right:auto; }
.bf-q-timer { display:inline-flex; align-items:center; gap:6px;
    background:rgba(239,68,68,0.1); border:1px solid rgba(239,68,68,0.2);
    color:#FCA5A5; padding:6px 16px; border-radius:20px;
    font-size:13px; font-weight:600; margin-bottom:20px; }

/* Answer options */
.bf-options { display:grid; grid-template-columns:1fr 1fr; gap:12px;
    max-width:600px; margin:0 auto; }
.bf-opt-btn { display:block; width:100%; padding:14px 18px; text-align:left;
    background:rgba(255,255,255,0.04); border:1.5px solid rgba(255,255,255,0.1);
    border-radius:10px; color:#fff; font-size:14px; font-weight:500;
    cursor:pointer; transition:all 0.15s; font-family:inherit; }
.bf-opt-btn:hover { background:rgba(14,165,233,0.1); border-color:rgba(14,165,233,0.4);
    transform:translateY(-1px); }
.bf-opt-btn:focus-visible { outline:2px solid #0EA5E9; outline-offset:2px; }
.bf-opt-correct { background:rgba(34,197,94,0.15) !important;
    border-color:#22C55E !important; color:#22C55E !important; }
.bf-opt-wrong { background:rgba(239,68,68,0.15) !important;
    border-color:#EF4444 !important; color:#EF4444 !important; }

/* Battle result overlay */
.bf-result { text-align:center; padding:40px 24px; }
.bf-result-icon { font-size:64px; margin-bottom:16px; display:block;
    animation:resultBounce 0.5s ease; }
@keyframes resultBounce { 0%{transform:scale(0);} 50%{transform:scale(1.2);} 100%{transform:scale(1);} }
.bf-result-title { font-size:28px; font-weight:800; margin:0 0 8px; }
.bf-result-sub { font-size:14px; color:rgba(255,255,255,0.5); margin:0 0 24px; }
.bf-result-xp { font-size:22px; font-weight:700; color:#F59E0B; margin-bottom:24px; }

/* Damage flash */
.bf-flash { animation:damageFlash 0.3s ease; }
@keyframes damageFlash { 0%,100%{opacity:1;} 50%{opacity:0.5;} }

/* Floating particles */
.bf-p { position:absolute; border-radius:50%; pointer-events:none; opacity:0.4;
    animation:bfFloat 5s ease-in-out infinite; }
@keyframes bfFloat { 0%,100%{transform:translateY(0) scale(1);}
    50%{transform:translateY(-25px) scale(1.2);} }

/* Start screen */
.bf-start-screen { text-align:center; padding:40px 24px; }
.bf-start-btn { display:inline-block; padding:16px 48px;
    background:linear-gradient(135deg,#DC2626,#7C3AED); color:#fff;
    border-radius:12px; font-size:18px; font-weight:800; border:none; cursor:pointer;
    box-shadow:0 8px 30px rgba(220,38,38,0.3); transition:all 0.2s;
    text-transform:uppercase; letter-spacing:0.05em; }
.bf-start-btn:hover { transform:translateY(-3px) scale(1.02);
    box-shadow:0 12px 40px rgba(220,38,38,0.4); }

/* Responsive */
@media(max-width:600px) {
    .bf-inner { padding:20px 16px; }
    .bf-hp-row { grid-template-columns:1fr; }
    .bf-options { grid-template-columns:1fr; }
    .bf-boss-ring { width:100px; height:100px; }
    .bf-boss-inner { font-size:40px; }
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <div class="bf">
        <%-- Floating particles --%>
        <div class="bf-p" style="width:8px;height:8px;background:#DC2626;top:12%;left:8%;animation-delay:0s;"></div>
        <div class="bf-p" style="width:6px;height:6px;background:#7C3AED;top:20%;right:12%;animation-delay:1.2s;"></div>
        <div class="bf-p" style="width:10px;height:10px;background:#F97316;bottom:25%;left:15%;animation-delay:0.6s;"></div>
        <div class="bf-p" style="width:5px;height:5px;background:#0EA5E9;top:50%;right:20%;animation-delay:2s;"></div>
        <div class="bf-p" style="width:7px;height:7px;background:#EF4444;bottom:15%;right:8%;animation-delay:3s;"></div>
        <div class="bf-p" style="width:4px;height:4px;background:#A855F7;top:35%;left:25%;animation-delay:1.8s;"></div>

        <div class="bf-inner">
            <%-- Boss display --%>
            <div class="bf-boss">
                <div class="bf-boss-ring">
                    <div class="bf-boss-inner">
                        <asp:Literal ID="litBossVisual" runat="server" Text="&#x1F480;" />
                    </div>
                </div>
                <h2 class="bf-boss-name"><asp:Literal ID="litBossName" runat="server" /></h2>
                <span class="bf-boss-diff" id="spanDiff" runat="server">
                    <asp:Literal ID="litDifficulty" runat="server" />
                </span>
            </div>

            <%-- HP bars --%>
            <div class="bf-hp-row">
                <div class="bf-hp-box">
                    <div class="bf-hp-lbl">&#x1F480; Boss HP</div>
                    <div class="bf-hp-val" style="color:#EF4444;">
                        <asp:Literal ID="litBossHP" runat="server" /> / <asp:Literal ID="litBossMaxHP" runat="server" />
                    </div>
                    <div class="bf-hp-bar">
                        <div class="bf-hp-fill bf-hp-fill-boss" id="bossHPBar" runat="server" style="width:100%;"></div>
                    </div>
                </div>
                <div class="bf-hp-box">
                    <div class="bf-hp-lbl">&#x1F6E1; Your HP</div>
                    <div class="bf-hp-val" style="color:#0EA5E9;">
                        <asp:Literal ID="litPlayerHP" runat="server" /> / <asp:Literal ID="litPlayerMaxHP" runat="server" />
                    </div>
                    <div class="bf-hp-bar">
                        <div class="bf-hp-fill bf-hp-fill-player" id="playerHPBar" runat="server" style="width:100%;"></div>
                    </div>
                </div>
            </div>

            <%-- XP Reward --%>
            <div class="bf-reward">
                <span class="bf-reward-chip">&#x26A1; +<asp:Literal ID="litXPReward" runat="server" /> XP on victory</span>
            </div>

            <%-- BATTLE STATE: Start screen --%>
            <asp:Panel ID="pnlStart" runat="server" Visible="false">
                <div class="bf-start-screen">
                    <p style="font-size:15px;color:rgba(255,255,255,0.6);margin:0 0 12px;">
                        Answer questions to deal damage. Wrong answers let the boss attack you.
                    </p>
                    <p style="font-size:13px;color:rgba(255,255,255,0.35);margin:0 0 28px;">
                        Each question has a time limit. If time runs out, the boss attacks!
                    </p>
                    <asp:Button ID="btnStartBattle" runat="server" Text="ENTER BATTLE"
                                CssClass="bf-start-btn" OnClick="btnStartBattle_Click" />
                </div>
            </asp:Panel>

            <%-- BATTLE STATE: Active question --%>
            <asp:Panel ID="pnlQuestion" runat="server" Visible="false">
                <div class="bf-question">
                    <div class="bf-q-number">
                        Turn <asp:Literal ID="litTurnNumber" runat="server" />
                    </div>
                    <div class="bf-q-timer">
                        &#x23F1; <asp:Literal ID="litTimeLimit" runat="server" />s per question
                    </div>
                    <div class="bf-q-text">
                        <asp:Literal ID="litQuestionText" runat="server" />
                    </div>
                    <div class="bf-options">
                        <asp:LinkButton ID="btnOpt1" runat="server" CssClass="bf-opt-btn" OnClick="btnAnswer_Click" />
                        <asp:LinkButton ID="btnOpt2" runat="server" CssClass="bf-opt-btn" OnClick="btnAnswer_Click" />
                        <asp:LinkButton ID="btnOpt3" runat="server" CssClass="bf-opt-btn" OnClick="btnAnswer_Click" />
                        <asp:LinkButton ID="btnOpt4" runat="server" CssClass="bf-opt-btn" OnClick="btnAnswer_Click" />
                    </div>
                </div>
            </asp:Panel>

            <%-- BATTLE STATE: Turn result --%>
            <asp:Panel ID="pnlTurnResult" runat="server" Visible="false">
                <div class="bf-question">
                    <div style="font-size:36px;margin-bottom:12px;">
                        <asp:Literal ID="litTurnIcon" runat="server" />
                    </div>
                    <div style="font-size:16px;font-weight:700;color:#fff;margin-bottom:8px;">
                        <asp:Literal ID="litTurnTitle" runat="server" />
                    </div>
                    <div style="font-size:14px;color:rgba(255,255,255,0.5);margin-bottom:20px;">
                        <asp:Literal ID="litTurnDesc" runat="server" />
                    </div>
                    <asp:Button ID="btnNextTurn" runat="server" Text="Next Question &#x2192;"
                                CssClass="bf-start-btn" style="font-size:14px;padding:12px 32px;"
                                OnClick="btnNextTurn_Click" />
                </div>
            </asp:Panel>

            <%-- BATTLE STATE: Battle over --%>
            <asp:Panel ID="pnlResult" runat="server" Visible="false">
                <div class="bf-result">
                    <span class="bf-result-icon"><asp:Literal ID="litResultIcon" runat="server" /></span>
                    <h2 class="bf-result-title"><asp:Literal ID="litResultTitle" runat="server" /></h2>
                    <p class="bf-result-sub"><asp:Literal ID="litResultSub" runat="server" /></p>
                    <asp:Panel ID="pnlResultXP" runat="server" Visible="false">
                        <div class="bf-result-xp">+<asp:Literal ID="litResultXP" runat="server" /> XP Earned!</div>
                    </asp:Panel>
                    <a href="BossFights.aspx" class="bf-start-btn" style="font-size:14px;padding:12px 32px;text-decoration:none;">
                        Back to Boss Fights
                    </a>
                </div>
            </asp:Panel>

        </div><%-- end bf-inner --%>
    </div><%-- end bf --%>

    <div style="text-align:center;margin-top:16px;">
        <a href="BossFights.aspx" style="font-size:13px;color:var(--cp-primary);">&#x2190; Back to Boss Fights</a>
    </div>

</asp:Content>
