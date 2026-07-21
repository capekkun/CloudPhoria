<%@ Page Title="Challenges" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Challenges.aspx.cs"
    Inherits="CloudPhoria.Student.Challenges" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <h2>Challenges</h2>
        <p>Time-limited challenges to test your cloud knowledge and earn XP.</p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <%-- Active challenges --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">
        Active Challenges
    </h3>
    <asp:Panel ID="pnlActive" runat="server" Visible="false">
        <div class="cp-grid-2">
            <asp:Repeater ID="rptActive" runat="server">
                <ItemTemplate>
                    <div class="cp-card">
                        <div class="cp-flex-between cp-mb-sm">
                            <h3 class="cp-card-title" style="margin:0;">
                                <%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %>
                            </h3>
                            <span class="cp-xp-chip">+<%# Eval("XPReward") %> XP</span>
                        </div>
                        <p class="cp-card-subtitle">
                            <%# HttpUtility.HtmlEncode(Eval("Description") != null ? Eval("Description").ToString() : "") %>
                        </p>
                        <div style="font-size:12px;color:var(--cp-text-muted);margin-bottom:12px;">
                            Ends: <%# Convert.ToDateTime(Eval("EndDate")).ToString("dd MMM yyyy HH:mm") %>
                        </div>
                        <%# Convert.ToBoolean(Eval("HasParticipated"))
                            ? "<span class='cp-badge cp-badge-green'>&#x2713; Participated</span>"
                            : "<a href='Challenges.aspx?challengeID=" + Eval("ChallengeID") + "' class='cp-btn cp-btn-primary cp-btn-sm'>Join Challenge</a>" %>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoActive" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x26A1;</span>
            <h3>No active challenges</h3>
            <p>Check back soon — new challenges are added regularly.</p>
        </div>
    </asp:Panel>

    <%-- Past participation --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:24px 0 12px;">
        My Participation
    </h3>
    <asp:Panel ID="pnlPast" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table">
                <thead>
                    <tr>
                        <th>Challenge</th>
                        <th>Score</th>
                        <th>Completed</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptPast" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %></td>
                                <td><%# Eval("Score") %></td>
                                <td><%# Eval("CompletedAt") != DBNull.Value
                                        ? Convert.ToDateTime(Eval("CompletedAt")).ToString("dd MMM yyyy")
                                        : "—" %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoPast" runat="server" Visible="false">
        <div class="cp-card" style="text-align:center;padding:20px;font-size:13px;color:var(--cp-text-muted);">
            You haven't participated in any challenges yet.
        </div>
    </asp:Panel>

</asp:Content>
