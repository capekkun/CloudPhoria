<%@ Page Title="Achievements" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Achievements.aspx.cs"
    Inherits="CloudPhoria.Student.Achievements" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>Achievements</h2>
                <p>Your earned badges, certifications, and XP history.</p>
            </div>
            <div class="cp-xp-chip" style="font-size:14px;padding:6px 16px;">
                &#x26A1; <asp:Literal ID="litTotalXP" runat="server" Text="0" /> XP
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <%-- Badges --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">
        Badges (<asp:Literal ID="litBadgeCount" runat="server" Text="0" />)
    </h3>
    <asp:Panel ID="pnlBadges" runat="server" Visible="false">
        <div class="cp-grid-4 cp-mb-lg">
            <asp:Repeater ID="rptBadges" runat="server">
                <ItemTemplate>
                    <div class="cp-card" style="text-align:center;padding:20px;">
                        <div style="font-size:32px;margin-bottom:8px;" aria-hidden="true">&#x1F3C5;</div>
                        <div style="font-size:13px;font-weight:600;color:var(--cp-text);">
                            <%# HttpUtility.HtmlEncode(Eval("BadgeName").ToString()) %>
                        </div>
                        <div style="font-size:11px;color:var(--cp-text-muted);margin-top:4px;">
                            <%# Convert.ToDateTime(Eval("AwardedAt")).ToString("dd MMM yyyy") %>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoBadges" runat="server" Visible="false">
        <div class="cp-card cp-mb-lg" style="text-align:center;padding:24px;color:var(--cp-text-muted);font-size:13px;">
            No badges earned yet. Complete modules to earn badges.
        </div>
    </asp:Panel>

    <%-- Certifications --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">
        Certifications (<asp:Literal ID="litCertCount" runat="server" Text="0" />)
    </h3>
    <asp:Panel ID="pnlCerts" runat="server" Visible="false">
        <div class="cp-grid-3 cp-mb-lg">
            <asp:Repeater ID="rptCerts" runat="server">
                <ItemTemplate>
                    <div class="cp-card" style="border-left:3px solid var(--cp-indigo);padding:20px;">
                        <div style="font-size:15px;font-weight:700;color:var(--cp-text);">
                            <%# HttpUtility.HtmlEncode(Eval("CertificateName").ToString()) %>
                        </div>
                        <div style="font-size:12px;color:var(--cp-text-muted);margin-top:4px;">
                            Issued: <%# Convert.ToDateTime(Eval("IssuedAt")).ToString("dd MMM yyyy") %>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoCerts" runat="server" Visible="false">
        <div class="cp-card cp-mb-lg" style="text-align:center;padding:24px;color:var(--cp-text-muted);font-size:13px;">
            No certifications yet. Complete all modules in a pathway to earn one.
        </div>
    </asp:Panel>

    <%-- XP History --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">
        XP History
    </h3>
    <asp:Panel ID="pnlXPHistory" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table">
                <thead>
                    <tr><th>Source</th><th>XP</th><th>Date</th></tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptXP" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><%# HttpUtility.HtmlEncode(Eval("SourceType").ToString()) %></td>
                                <td><span class="cp-xp-chip">+<%# Eval("XPAmount") %></span></td>
                                <td><%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoXP" runat="server" Visible="false">
        <div class="cp-card" style="text-align:center;padding:20px;color:var(--cp-text-muted);font-size:13px;">
            No XP transactions yet.
        </div>
    </asp:Panel>

</asp:Content>
