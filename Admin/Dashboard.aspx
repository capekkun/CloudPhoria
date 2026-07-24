<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs"
    Inherits="CloudPhoria.Admin.Dashboard" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>Admin Control Centre</h2>
                <p>Platform overview and pending actions for CloudPhoria.</p>
            </div>
            <div style="display:flex;align-items:center;gap:8px;">
                <a href="/Admin/Users.aspx" class="cp-btn cp-btn-primary">Manage Users</a>
                <a href="/Admin/Reports.aspx" class="cp-btn cp-btn-outline">Reports</a>
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlPendingAlert" runat="server" Visible="false">
        <div class="cp-alert cp-alert-warning" style="margin-bottom:20px;">
            <span style="font-size:16px;"></span>
            <div>
                <strong>Pending actions require your attention.</strong>
                <asp:Literal ID="litPendingAlertText" runat="server" />
            </div>
        </div>
    </asp:Panel>

    <div class="cp-grid-4 cp-mb-lg">
        <div class="cp-stat-card">
            <div class="cp-stat-icon blue"></div>
            <div><div class="cp-stat-value"><asp:Literal ID="litTotalUsers" runat="server" Text="0" /></div><div class="cp-stat-label">Total Users</div></div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon amber">&#x23F3;</div>
            <div><div class="cp-stat-value"><asp:Literal ID="litPendingApprovals" runat="server" Text="0" /></div><div class="cp-stat-label">Pending Approvals</div></div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon red"></div>
            <div><div class="cp-stat-value"><asp:Literal ID="litOpenReports" runat="server" Text="0" /></div><div class="cp-stat-label">Open Reports</div></div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon green"></div>
            <div><div class="cp-stat-value"><asp:Literal ID="litPublishedModules" runat="server" Text="0" /></div><div class="cp-stat-label">Published Modules</div></div>
        </div>
    </div>

    <div class="cp-grid-4 cp-mb-lg">
        <div class="cp-stat-card">
            <div class="cp-stat-icon indigo"></div>
            <div><div class="cp-stat-value"><asp:Literal ID="litPendingFunRooms" runat="server" Text="0" /></div><div class="cp-stat-label">Pending Fun Rooms</div></div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon blue"></div>
            <div><div class="cp-stat-value"><asp:Literal ID="litActiveChallenges" runat="server" Text="0" /></div><div class="cp-stat-label">Active Challenges</div></div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon green"></div>
            <div><div class="cp-stat-value"><asp:Literal ID="litBossFightRooms" runat="server" Text="0" /></div><div class="cp-stat-label">Boss Fight Rooms</div></div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon amber"></div>
            <div><div class="cp-stat-value"><asp:Literal ID="litTotalStudents" runat="server" Text="0" /></div><div class="cp-stat-label">Registered Students</div></div>
        </div>
    </div>

    <div class="cp-grid-2 cp-mb-lg">
        <div>
            <h3 style="font-size:15px;font-weight:600;margin:0 0 12px;">Pending Instructor Approvals</h3>
            <asp:Panel ID="pnlPendingInstructors" runat="server" Visible="false">
                <div class="cp-card" style="padding:0;overflow:hidden;">
                    <asp:Repeater ID="rptPendingInstructors" runat="server">
                        <ItemTemplate>
                            <div style="display:flex;align-items:center;justify-content:space-between;padding:12px 16px;border-bottom:1px solid var(--cp-border);">
                                <div>
                                    <div style="font-size:13px;font-weight:600;"><%# HttpUtility.HtmlEncode(Eval("FullName").ToString()) %></div>
                                    <div style="font-size:11px;color:var(--cp-text-muted);"><%# HttpUtility.HtmlEncode(Eval("Email").ToString()) %></div>
                                </div>
                                <span class="cp-status cp-status-pending">Pending</span>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <div style="text-align:right;margin-top:8px;"><a href="/Admin/InstructorApprovals.aspx" style="font-size:13px;color:var(--cp-primary);">Review all &#x2192;</a></div>
            </asp:Panel>
            <asp:Panel ID="pnlNoPendingInstructors" runat="server" Visible="false">
                <div class="cp-empty-state" style="padding:24px;"><h3>All caught up</h3><p>No pending instructor approvals.</p></div>
            </asp:Panel>
        </div>
        <div>
            <h3 style="font-size:15px;font-weight:600;margin:0 0 12px;">Recent Open Reports</h3>
            <asp:Panel ID="pnlRecentReports" runat="server" Visible="false">
                <div class="cp-card" style="padding:0;overflow:hidden;">
                    <asp:Repeater ID="rptRecentReports" runat="server">
                        <ItemTemplate>
                            <div style="display:flex;align-items:flex-start;gap:12px;padding:12px 16px;border-bottom:1px solid var(--cp-border);">
                                <div style="flex:1;">
                                    <div style="font-size:12px;font-weight:600;">Reported by: <%# HttpUtility.HtmlEncode(Eval("ReporterName").ToString()) %></div>
                                    <div style="font-size:11px;color:var(--cp-text-muted);margin-top:2px;"><%# HttpUtility.HtmlEncode(Eval("Reason").ToString()) %></div>
                                </div>
                                <span class="cp-badge cp-badge-red">Open</span>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <div style="text-align:right;margin-top:8px;"><a href="/Admin/Reports.aspx" style="font-size:13px;color:var(--cp-primary);">View all &#x2192;</a></div>
            </asp:Panel>
            <asp:Panel ID="pnlNoReports" runat="server" Visible="false">
                <div class="cp-empty-state" style="padding:24px;"><h3>No open reports</h3><p>There are no unresolved reports.</p></div>
            </asp:Panel>
        </div>
    </div>

    <asp:Panel ID="pnlFunRoomsSection" runat="server" Visible="false">
        <h3 style="font-size:15px;font-weight:600;margin:0 0 12px;">Pending Fun Room Reviews</h3>
        <div class="cp-card" style="padding:0;overflow:hidden;">
            <asp:Repeater ID="rptPendingFunRooms" runat="server">
                <ItemTemplate>
                    <div style="display:flex;align-items:center;justify-content:space-between;padding:12px 16px;border-bottom:1px solid var(--cp-border);">
                        <div>
                            <div style="font-size:13px;font-weight:600;"><%# HttpUtility.HtmlEncode(Eval("RoomTitle").ToString()) %></div>
                            <div style="font-size:11px;color:var(--cp-text-muted);">By: <%# HttpUtility.HtmlEncode(Eval("CreatorName").ToString()) %></div>
                        </div>
                        <span class="cp-status cp-status-pending">Pending</span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>

    <h3 style="font-size:15px;font-weight:600;margin:24px 0 12px;">Recent Audit Activity</h3>
    <asp:Panel ID="pnlAuditLog" runat="server" Visible="false">
        <div class="cp-card" style="padding:0;overflow:hidden;">
            <asp:Repeater ID="rptAuditLog" runat="server">
                <ItemTemplate>
                    <div style="display:flex;align-items:center;gap:12px;padding:10px 16px;border-bottom:1px solid var(--cp-border);">
                        <div style="flex:1;">
                            <div style="font-size:12px;font-weight:600;"><%# HttpUtility.HtmlEncode(Eval("ActionType").ToString()) %></div>
                            <div style="font-size:11px;color:var(--cp-text-muted);">By <%# HttpUtility.HtmlEncode(Eval("PerformedBy").ToString()) %> &mdash; <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy HH:mm") %></div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <div style="text-align:right;margin-top:8px;"><a href="/Admin/AuditLogs.aspx" style="font-size:13px;color:var(--cp-primary);">View full log &#x2192;</a></div>
    </asp:Panel>
    <asp:Panel ID="pnlNoAudit" runat="server" Visible="false">
        <div class="cp-empty-state"><h3>No audit activity yet</h3><p>Actions will appear here as you use the platform.</p></div>
    </asp:Panel>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
</asp:Content>
