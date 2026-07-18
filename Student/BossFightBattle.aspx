<%@ Page Title="Boss Battle" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="BossFightBattle.aspx.cs"
    Inherits="CloudPhoria.Student.BossFightBattle" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* Boss Fight Battle Arena */
.bf-arena { background:#111827; border-radius:16px; padding:32px; color:#fff;
    position:relative; overflow:hidden; min-height:500px; }
.bf-arena::before { content:''; position:absolute; inset:0;
    background-image:linear-gradient(rgba(220,38,38,0.03) 1px,transparent 1px),
    linear-gradient(90deg,rgba(220,38,38,0.03) 1px,transparent 1px);
    background-size:32px 32px; pointer-events:none; }
.bf-arena::after { content:''; position:absolute; bottom:-80px; left:50%;
    transform:translateX(-50%); width:600px; height:300px;
    background:radial-gradient(ellipse,rgba(124,58,237,0.15) 0%,transparent 70%);
    pointer-events:none; }

/* Boss display */
.bf-boss-area { text-align:center; margin-bottom:24px; position:relative; z-index:1; }
.bf-boss-icon { width:120px; height:120px; border-radius:50%;
    background:linear-gradient(135deg,#DC2626,#7C3AED);
    display:flex; align-items:center; justify-content:center;
    margin:0 auto 16px; font-size:56px;
    box-shadow:0 0 40px rgba(220,38,38,0.3), 0 0 80px rgba(124,58,237,0.15);
    animation:bossPulse 2s ease-in-out infinite; border:3px solid rgba(255,255,255,0.1); }
@keyframes bossPulse {
    0%,100% { box-shadow:0 0 40px rgba(220,38,38,0.3),0 0 80px rgba(124,58,237,0.15); }
    50%      { box-shadow:0 0 60px rgba(220,38,38,0.5),0 0 100px rgba(124,58,237,0.25); }
}
.bf-boss-name { font-size:22px; font-weight:800; color:#fff; margin:0 0 4px; letter-spacing:-0.3px; }
.bf-boss-diff { font-size:12px; font-weight:700; text-transform:uppercase; letter-spacing:0.08em; }
.bf-diff-easy { color:#22C55E; } .bf-diff-medium { color:#F59E0B; }
.bf-diff-hard { color:#EF4444; } .bf-diff-legendary { color:#A855F7; }

/* HP Bars */
.bf-hp-section { display:grid; grid-template-columns:1fr 1fr; gap:24px;
    margin-bottom:28px; position:relative; z-index:1; }
.bf-hp-box { background:rgba(255,255,255,0.04); border:1px solid rgba(255,255,255,0.08);
    border-radius:12px; padding:16px; }
.bf-hp-label { font-size:12px; font-weight:600; color:rgba(255,255,255,0.5);
    text-transform:uppercase; letter-spacing:0.06em; margin-bottom:8px; }
.bf-hp-value { font-size:20px; font-weight:800; margin-bottom:8px; }
.bf-hp-bar { height:10px; border-radius:5px; background:rgba(255,255,255,0.1); overflow:hidden; }
.bf-hp-fill-boss { height:100%; border-radius:5px;
    background:linear-gradient(90deg,#EF4444,#F97316); transition:width 0.5s; }
.bf-hp-fill-player { height:100%; border-radius:5px;
    background:linear-gradient(90deg,#0EA5E9,#22C55E); transition:width 0.5s; }

/* Battle info */
.bf-info { text-align:center; position:relative; z-index:1; }
.bf-xp-reward { display:inline-flex; align-items:center; gap:6px;
    background:rgba(245,158,11,0.15); border:1px solid rgba(245,158,11,0.3);
    color:#F59E0B; padding:8px 20px; border-radius:24px;
    font-size:14px; font-weight:700; margin-bottom:20px; }
.bf-question-area { background:rgba(255,255,255,0.05); border:1px solid rgba(255,255,255,0.1);
    border-radius:12px; padding:24px; margin-top:20px; text-align:center; }
.bf-question-area h3 { font-size:16px; font-weight:600; color:#fff; margin:0 0 12px; }
.bf-question-area p { font-size:14px; color:rgba(255,255,255,0.6); margin:0 0 20px; }
.bf-start-btn { display:inline-block; padding:14px 36px; background:linear-gradient(135deg,#DC2626,#7C3AED);
    color:#fff; border-radius:10px; font-size:16px; font-weight:700; text-decoration:none;
    border:none; cursor:pointer; transition:transform 0.15s,box-shadow 0.15s;
    box-shadow:0 4px 20px rgba(220,38,38,0.3); }
.bf-start-btn:hover { transform:translateY(-2px); box-shadow:0 8px 30px rgba(220,38,38,0.4); color:#fff; }

/* Floating particles */
.bf-particle { position:absolute; border-radius:50%; pointer-events:none; animation:particleFloat 4s ease-in-out infinite; }
@keyframes particleFloat { 0%,100%{transform:translateY(0);opacity:0.4;} 50%{transform:translateY(-20px);opacity:0.8;} }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlBattle" runat="server" Visible="false">
        <div class="bf-arena">
            <%-- Floating particles --%>
            <div class="bf-particle" style="width:8px;height:8px;background:#DC2626;top:15%;left:10%;animation-delay:0s;"></div>
            <div class="bf-particle" style="width:6px;height:6px;background:#7C3AED;top:25%;right:15%;animation-delay:1s;"></div>
            <div class="bf-particle" style="width:10px;height:10px;background:#F97316;bottom:30%;left:20%;animation-delay:0.5s;"></div>
            <div class="bf-particle" style="width:5px;height:5px;background:#0EA5E9;top:40%;right:25%;animation-delay:1.5s;"></div>
            <div class="bf-particle" style="width:7px;height:7px;background:#EF4444;bottom:20%;right:10%;animation-delay:2s;"></div>

            <%-- Boss display --%>
            <div class="bf-boss-area">
                <div class="bf-boss-icon">
                    <asp:Literal ID="litBossEmoji" runat="server" Text="&#x1F480;" />
                </div>
                <h2 class="bf-boss-name"><asp:Literal ID="litBossName" runat="server" /></h2>
                <span class="bf-boss-diff">
                    <asp:Literal ID="litDifficulty" runat="server" />
                </span>
            </div>

            <%-- HP Bars --%>
            <div class="bf-hp-section">
                <div class="bf-hp-box">
                    <div class="bf-hp-label">&#x1F480; Boss HP</div>
                    <div class="bf-hp-value" style="color:#EF4444;">
                        <asp:Literal ID="litBossHP" runat="server" /> / <asp:Literal ID="litBossMaxHP" runat="server" />
                    </div>
                    <div class="bf-hp-bar">
                        <div class="bf-hp-fill-boss" style="width:100%;"></div>
                    </div>
                </div>
                <div class="bf-hp-box">
                    <div class="bf-hp-label">&#x1F6E1; Your HP</div>
                    <div class="bf-hp-value" style="color:#0EA5E9;">
                        <asp:Literal ID="litPlayerHP" runat="server" /> / <asp:Literal ID="litPlayerMaxHP" runat="server" />
                    </div>
                    <div class="bf-hp-bar">
                        <div class="bf-hp-fill-player" style="width:100%;"></div>
                    </div>
                </div>
            </div>

            <%-- Battle info + start --%>
            <div class="bf-info">
                <div class="bf-xp-reward">&#x26A1; +<asp:Literal ID="litXPReward" runat="server" /> XP on victory</div>

                <div class="bf-question-area">
                    <h3>&#x2694; Ready to fight?</h3>
                    <p>Answer questions correctly to deal damage. Wrong answers let the boss attack you. Survive and defeat the boss to earn XP!</p>
                    <asp:Button ID="btnStartBattle" runat="server" Text="Begin Battle"
                                CssClass="bf-start-btn"
                                OnClick="btnStartBattle_Click" />
                </div>
            </div>
        </div>
    </asp:Panel>

    <div style="text-align:center;margin-top:16px;">
        <a href="BossFights.aspx" class="cp-btn cp-btn-ghost">&#x2190; Back to Boss Fights</a>
    </div>

</asp:Content>
