<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs"
    Inherits="CloudPhoria.Admin.Dashboard" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<div class="cp-page-header">
    <h2>&#x2699;&#xFE0F; Admin Dashboard</h2>
    <p>Platform overview and quick links to management tools.</p>
</div>

<div class="cp-grid-4 cp-mb-lg">
    <div class="cp-stat-card">
        <div class="cp-stat-icon blue" aria-hidden="true">&#x1F393;</div>
        <div><div class="cp-stat-value"><asp:Literal ID="litTotalStudents" runat="server" Text="0" /></div>
            <div class="cp-stat-label">Students</div></div>
    </div>
    <div class="cp-stat-card">
        <div class="cp-stat-icon indigo" aria-hidden="true">&#x1F468;&#x200D;&#x1F3EB;</div>
        <div><div class="cp-stat-value"><asp:Literal ID="litTotalInstructors" runat="server" Text="0" /></div>
            <div class="cp-stat-label">Instructors</div></div>
    </div>
    <div class="cp-stat-card">
        <div class="cp-stat-icon amber" aria-hidden="true">&#x23F3;</div>
        <div><div class="cp-stat-value"><asp:Literal ID="litPendingCount" runat="server" Text="0" /></div>
            <div class="cp-stat-label">Pending Approvals</div></div>
    </div>
    <div class="cp-stat-card">
        <div class="cp-stat-icon green" aria-hidden="true">&#x1F4D6;</div>
        <div><div class="cp-stat-value"><asp:Literal ID="litTotalModules" runat="server" Text="0" /></div>
            <div class="cp-stat-label">Published Modules</div></div>
    </div>
</div>

<div class="cp-grid-4 cp-mb-lg">
    <div class="cp-stat-card">
        <div class="cp-stat-icon red" aria-hidden="true">&#x1F6A8;</div>
        <div><div class="cp-stat-value"><asp:Literal ID="litOpenReports" runat="server" Text="0" /></div>
            <div class="cp-stat-label">Open Reports</div></div>
    </div>
    <div class="cp-stat-card">
        <div class="cp-stat-icon grey" aria-hidden="true">&#x1F6AB;</div>
        <div><div class="cp-stat-value"><asp:Literal ID="litBannedCount" runat="server" Text="0" /></div>
            <div class="cp-stat-label">Banned Users</div></div>
    </div>
    <div class="cp-stat-card">
        <div class="cp-stat-icon amber" aria-hidden="true">&#x26A1;</div>
        <div><div class="cp-stat-value"><asp:Literal ID="litGlobalChallengeCount" runat="server" Text="0" /></div>
            <div class="cp-stat-label">Global Challenges</div></div>
    </div>
    <div class="cp-stat-card">
        <div class="cp-stat-icon blue" aria-hidden="true">&#x1F3EB;</div>
        <div><div class="cp-stat-value"><asp:Literal ID="litTotalClassrooms" runat="server" Text="0" /></div>
            <div class="cp-stat-label">Classrooms</div></div>
    </div>
</div>

<div class="cp-grid-2">
    <div>
        <h3 style="font-size:15px;font-weight:600;margin:0 0 12px;">Quick Actions</h3>
        <div style="display:flex;flex-direction:column;gap:10px;">
            <a href="InstructorApprovals.aspx" class="cp-card" style="display:flex;align-items:center;gap:12px;text-decoration:none;color:inherit;">
                <span style="font-size:22px;">&#x2714;</span>
                <div><div style="font-weight:600;font-size:14px;">Review Instructor Applications</div>
                    <div style="font-size:12px;color:var(--cp-text-muted);"><asp:Literal ID="litPendingCount2" runat="server" Text="0" /> pending approval</div></div>
            </a>
            <a href="Reports.aspx" class="cp-card" style="display:flex;align-items:center;gap:12px;text-decoration:none;color:inherit;">
                <span style="font-size:22px;">&#x1F6A8;</span>
                <div><div style="font-weight:600;font-size:14px;">Review Reports</div>
                    <div style="font-size:12px;color:var(--cp-text-muted);"><asp:Literal ID="litOpenReports2" runat="server" Text="0" /> open reports</div></div>
            </a>
            <a href="Users.aspx" class="cp-card" style="display:flex;align-items:center;gap:12px;text-decoration:none;color:inherit;">
                <span style="font-size:22px;">&#x1F465;</span>
                <div><div style="font-weight:600;font-size:14px;">Manage Users</div>
                    <div style="font-size:12px;color:var(--cp-text-muted);">Create, ban, or remove accounts</div></div>
            </a>
        </div>
    </div>

    <div>
        <h3 style="font-size:15px;font-weight:600;margin:0 0 12px;">Recent Activity</h3>
        <asp:Panel ID="pnlRecentActivity" runat="server" Visible="false">
            <div class="cp-card" style="padding:0;overflow:hidden;">
                <asp:Repeater ID="rptRecentActivity" runat="server">
                    <ItemTemplate>
                        <div style="display:flex;align-items:center;gap:12px;padding:12px 16px;border-bottom:1px solid var(--cp-border);">
                            <span style="font-size:16px;">&#x1F4CB;</span>
                            <div style="flex:1;">
                                <div style="font-size:13px;color:var(--cp-text);">
                                    <strong><%# HttpUtility.HtmlEncode(Eval("PerformedByName").ToString()) %></strong>
                                    &mdash; <%# HttpUtility.HtmlEncode(Eval("ActionType").ToString()) %>
                                </div>
                                <div style="font-size:11px;color:var(--cp-text-muted);margin-top:2px;">
                                    <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy HH:mm") %>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
            <div style="text-align:right;margin-top:8px;">
                <a href="AuditLogs.aspx" style="font-size:13px;color:var(--cp-primary);">View full audit log &#x2192;</a>
            </div>
        </asp:Panel>
        <asp:Panel ID="pnlNoActivity" runat="server" Visible="false">
            <div class="cp-card" style="text-align:center;padding:20px;color:var(--cp-text-muted);font-size:13px;">
                No activity recorded yet.
            </div>
        </asp:Panel>
    </div>
</div>

</asp:Content>
