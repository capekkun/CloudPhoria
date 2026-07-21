<%@ Page Title="Boss Fights" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="BossFights.aspx.cs"
    Inherits="CloudPhoria.Student.BossFights" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    .boss-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(280px,1fr)); gap:18px; }
    .boss-card {
        background:#111827;
        border:1px solid rgba(255,255,255,0.08);
        border-radius:14px;
        padding:20px;
        color:#fff;
        position:relative;
        overflow:hidden;
        transition:border-color 0.15s, transform 0.15s;
    }
    .boss-card:hover { border-color:rgba(220,38,38,0.4); transform:translateY(-2px); }
    .boss-card-glow {
        position:absolute; top:-30px; right:-30px;
        width:100px; height:100px; border-radius:50%;
        background:radial-gradient(circle, rgba(220,38,38,0.15) 0%, transparent 70%);
        pointer-events:none;
    }
    .boss-diff-easy       { color:#22C55E; }
    .boss-diff-medium     { color:#F59E0B; }
    .boss-diff-hard       { color:#EF4444; }
    .boss-diff-legendary  { color:#A855F7; }
    .boss-hp-bar-wrap { background:rgba(255,255,255,0.08); border-radius:4px; height:6px; margin:10px 0; }
    .boss-hp-bar      { height:100%; border-radius:4px; background:linear-gradient(90deg,#EF4444,#F97316); }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <h2>Boss Fights</h2>
        <p>Battle cloud knowledge bosses in timed quiz rooms. Survive their attacks and deal damage with correct answers to win XP.</p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <%-- Rooms grid --%>
    <asp:Panel ID="pnlRooms" runat="server" Visible="false">
        <div class="boss-grid">
            <asp:Repeater ID="rptRooms" runat="server">
                <ItemTemplate>
                    <div class="boss-card">
                        <div class="boss-card-glow" aria-hidden="true"></div>
                        <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:10px;">
                            <h3 style="font-size:15px;font-weight:700;margin:0;color:#fff;">
                                <%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %>
                            </h3>
                            <span style="font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:0.05em;"
                                  class="boss-diff-<%# Eval("DifficultyLevel").ToString().ToLower() %>">
                                <%# HttpUtility.HtmlEncode(Eval("DifficultyLevel").ToString()) %>
                            </span>
                        </div>
                        <div style="font-size:12px;color:rgba(255,255,255,0.5);margin-bottom:8px;">
                            Boss: <strong style="color:#fff;"><%# HttpUtility.HtmlEncode(Eval("BossName").ToString()) %></strong>
                        </div>
                        <div style="font-size:12px;color:rgba(255,255,255,0.4);margin-bottom:4px;">
                            Boss HP: <%# Eval("MaxHP") %>
                        </div>
                        <div class="boss-hp-bar-wrap">
                            <div class="boss-hp-bar" style="width:100%;"></div>
                        </div>
                        <div style="display:flex;align-items:center;justify-content:space-between;margin-top:14px;">
                            <span class="cp-xp-chip">+<%# Eval("XPReward") %> XP on win</span>
                            <%# Convert.ToBoolean(Eval("HasWon"))
                                ? "<span class='cp-badge cp-badge-green'>&#x2713; Defeated</span>"
                                : "<a href='BossFights.aspx?roomID=" + Eval("RoomID") + "' class='cp-btn cp-btn-danger cp-btn-sm'>Enter Battle</a>" %>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F480;</span>
            <h3>No boss fights available</h3>
            <p>Admins publish new boss fight rooms regularly. Check back soon.</p>
        </div>
    </asp:Panel>

    <%-- Battle history --%>
    <asp:Panel ID="pnlHistory" runat="server" Visible="false">
        <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:28px 0 12px;">
            Battle History
        </h3>
        <div class="cp-table-wrap">
            <table class="cp-table">
                <thead>
                    <tr><th>Room</th><th>Result</th><th>XP</th><th>Date</th></tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptHistory" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %></td>
                                <td>
                                    <%# Eval("Status").ToString() == "Won"
                                        ? "<span class='cp-badge cp-badge-green'>Won</span>"
                                        : Eval("Status").ToString() == "Lost"
                                            ? "<span class='cp-badge cp-badge-red'>Lost</span>"
                                            : "<span class='cp-badge cp-badge-grey'>" + HttpUtility.HtmlEncode(Eval("Status").ToString()) + "</span>" %>
                                </td>
                                <td><%# Convert.ToInt32(Eval("XPAwarded")) > 0 ? "+" + Eval("XPAwarded") : "—" %></td>
                                <td><%# Convert.ToDateTime(Eval("StartedAt")).ToString("dd MMM yyyy") %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>

</asp:Content>
