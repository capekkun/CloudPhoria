<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs"
    Inherits="CloudPhoria.Admin.Dashboard" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Page Header --%>
    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x1F6E1; Admin Control Centre</h2>
                <p>Platform overview and pending actions for CloudPhoria.</p>
            </div>
            <div style="display:flex;align-items:center;gap:8px;">
                <a href="/Admin/Users.aspx" class="cp-btn cp-btn-primary">&#x1F465; Manage Users</a>
                <a href="/Admin/Reports.aspx" class="cp-btn cp-btn-outline">&#x1F4CA; Reports</a>
            </div>
        </div>
    </div>

    <%-- Alert for pending actions --%>
    <asp:Panel ID="pnlPendingAlert" runat="server" Visible="false">
        <div class="cp-alert cp-alert-warning" style="margin-bottom:20px;">
            <span style="font-size:16px;">&#x26A0;</span>
            <div>
                <strong>Pending actions require your attention.</strong>
                <asp:Literal ID="litPendingAlertText" runat="server" />
            </div>
        </div>
    </asp:Panel>

    <%-- Stat Cards Row --%>
    <div class="cp-grid-4 cp-mb-lg">
        <div class="cp-stat-card">
            <div class="cp-stat-icon blue" aria-hidden="true">&#x1F465;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litTotalUsers" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Total Users</div>
            </div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon amber" aria-hidden="true">&#x23F3;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litPendingApprovals" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Pending Approvals</div>
            </div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon red" aria-hidden="true">&#x1F6A8;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litOpenReports" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Open Reports</div>
            </div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon green" aria-hidden="true">&#x1F4D6;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litPublishedModules" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Published Modules</div>
            </div>
        </div>
    </div>

    <%-- Second stats row --%>
    <div class="cp-grid-4 cp-mb-lg">
        <div class="cp-stat-card">
            <div class="cp-stat-icon indigo" aria-hidden="true">&#x1F3AE;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litPendingFunRooms" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Pending Fun Rooms</div>
            </div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon blue" aria-hidden="true">&#x26A1;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litActiveChallenges" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Active Challenges</div>
            </div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon green" aria-hidden="true">&#x1F480;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litBossFightRooms" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Boss Fight Rooms</div>
            </div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon amber" aria-hidden="true">&#x1F4CB;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litTotalStudents" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Registered Students</div>
            </div>
        </div>
    </div>

    <%-- Two-column: Pending Instructor Approvals + Recent Reports --%>
    <div class="cp-grid-2 cp-mb-lg">

        <%-- Pending Instructor Approvals --%>
        <div>
            <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">
                &#x2714; Pending Instructor Approvals
            </h3>

            <asp:Panel ID="pnlPendingInstructors" runat="server" Visible="false">
                <div class="cp-card" style="padding:0;overflow:hidden;">
                    <asp:Repeater ID="rptPendingInstructors" runat="server">
                        <ItemTemplate>
                            <div style="display:flex;align-items:center;justify-content:space-between;
                                        padding:12px 16px;border-bottom:1px solid var(--cp-border);">
                                <div>
                                    <div style="font-size:13px;font-weight:600;color:var(--cp-text);">
                                        <%# HttpUtility.HtmlEncode(Eval("FullName").ToString()) %>
                                    </div>
                                    <div style="font-size:11px;color:var(--cp-text-muted);margin-top:2px;">
                                        <%# HttpUtility.HtmlEncode(Eval("Email").ToString()) %>
                                        &nbsp;&mdash;&nbsp;
                                        <%# Eval("Qualification") != DBNull.Value ? HttpUtility.HtmlEncode(Eval("Qualification").ToString()) : "No qualification listed" %>
                                    </div>
                                </div>
                                <span class="cp-status cp-status-pending">Pending</span>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <div style="text-align:right;margin-top:8px;">
                    <a href="/Admin/InstructorApprovals.aspx" style="font-size:13px;color:var(--cp-primary);">
                        Review all approvals &#x2192;
                    </a>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlNoPendingInstructors" runat="server" Visible="false">
                <div class="cp-empty-state" style="padding:24px;">
                    <span class="cp-empty-state-icon" aria-hidden="true">&#x2714;</span>
                    <h3>All caught up</h3>
                    <p>No pending instructor approvals.</p>
                </div>
            </asp:Panel>
        </div>

        <%-- Recent Open Reports --%>
        <div>
            <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">
                &#x1F6A8; Recent Open Reports
            </h3>

            <asp:Panel ID="pnlRecentReports" runat="server" Visible="false">
                <div class="cp-card" style="padding:0;overflow:hidden;">
                    <asp:Repeater ID="rptRecentReports" runat="server">
                        <ItemTemplate>
                            <div style="display:flex;align-items:flex-start;gap:12px;
                                        padding:12px 16px;border-bottom:1px solid var(--cp-border);">
                                <div style="flex:1;min-width:0;">
                                    <div style="font-size:12px;font-weight:600;color:var(--cp-text);">
                                        Reported by: <%# HttpUtility.HtmlEncode(Eval("ReporterName").ToString()) %>
                                    </div>
                                    <div style="font-size:11px;color:var(--cp-text-muted);margin-top:2px;
                                                white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:220px;">
                                        <%# HttpUtility.HtmlEncode(Eval("Reason").ToString()) %>
                                    </div>
                                    <div style="font-size:10px;color:var(--cp-text-muted);margin-top:2px;">
                                        <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %>
                                    </div>
                                </div>
                                <span class="cp-badge cp-badge-red">Open</span>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <div style="text-align:right;margin-top:8px;">
                    <a href="/Admin/Reports.aspx" style="font-size:13px;color:var(--cp-primary);">
                        View all reports &#x2192;
                    </a>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlNoReports" runat="server" Visible="false">
                <div class="cp-empty-state" style="padding:24px;">
                    <span class="cp-empty-state-icon" aria-hidden="true">&#x1F4CA;</span>
                    <h3>No open reports</h3>
                    <p>There are no unresolved reports at this time.</p>
                </div>
            </asp:Panel>
        </div>

    </div>

    <%-- Pending Fun Rooms --%>
    <asp:Panel ID="pnlFunRoomsSection" runat="server" Visible="false">
        <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">
            &#x1F3AE; Pending Fun Room Reviews
        </h3>
        <div class="cp-card" style="padding:0;overflow:hidden;">
            <asp:Repeater ID="rptPendingFunRooms" runat="server">
                <ItemTemplate>
                    <div style="display:flex;align-items:center;justify-content:space-between;
                                padding:12px 16px;border-bottom:1px solid var(--cp-border);">
                        <div>
                            <div style="font-size:13px;font-weight:600;color:var(--cp-text);">
                                <%# HttpUtility.HtmlEncode(Eval("RoomTitle").ToString()) %>
                            </div>
                            <div style="font-size:11px;color:var(--cp-text-muted);margin-top:2px;">
                                By: <%# HttpUtility.HtmlEncode(Eval("CreatorName").ToString()) %>
                                &nbsp;&mdash;&nbsp;
                                <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %>
                            </div>
                        </div>
                        <span class="cp-status cp-status-pending">Pending</span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <div style="text-align:right;margin-top:8px;">
            <a href="/Admin/FunRoomReviews.aspx" style="font-size:13px;color:var(--cp-primary);">
                Review all fun rooms &#x2192;
            </a>
        </div>
    </asp:Panel>

    <%-- Recent Audit Log --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:24px 0 12px;">
        &#x1F4CB; Recent Audit Activity
    </h3>

    <asp:Panel ID="pnlAuditLog" runat="server" Visible="false">
        <div class="cp-card" style="padding:0;overflow:hidden;">
            <asp:Repeater ID="rptAuditLog" runat="server">
                <ItemTemplate>
                    <div style="display:flex;align-items:center;gap:12px;
                                padding:10px 16px;border-bottom:1px solid var(--cp-border);">
                        <span style="font-size:15px;" aria-hidden="true">&#x1F4CB;</span>
                        <div style="flex:1;min-width:0;">
                            <div style="font-size:12px;font-weight:600;color:var(--cp-text);">
                                <%# HttpUtility.HtmlEncode(Eval("ActionType").ToString()) %>
                            </div>
                            <div style="font-size:11px;color:var(--cp-text-muted);margin-top:1px;">
                                By <%# HttpUtility.HtmlEncode(Eval("PerformedBy").ToString()) %>
                                &mdash;
                                <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy HH:mm") %>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <div style="text-align:right;margin-top:8px;">
            <a href="/Admin/AuditLogs.aspx" style="font-size:13px;color:var(--cp-primary);">
                View full audit log &#x2192;
            </a>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlNoAudit" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F4CB;</span>
            <h3>No audit activity yet</h3>
            <p>Admin actions will appear here as you use the platform.</p>
        </div>
    </asp:Panel>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
</asp:Content>
