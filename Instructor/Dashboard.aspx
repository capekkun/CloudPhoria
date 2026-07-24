<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs"
    Inherits="CloudPhoria.Instructor.Dashboard" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
a.cp-stat-card-link {
    text-decoration: none;
    color: inherit;
    display: flex;
    cursor: pointer;
    transition: transform 0.15s, box-shadow 0.15s;
}
a.cp-stat-card-link:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 24px rgba(0,0,0,0.10);
    text-decoration: none;
    color: inherit;
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Page header --%>
    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>Welcome back, <asp:Literal ID="litWelcomeName" runat="server" />!</h2>
                <p>Here's your teaching overview for today.</p>
            </div>
            <asp:Panel ID="pnlHeaderActions" runat="server" Visible="false">
                <a href="Classrooms.aspx" class="cp-btn cp-btn-primary">
                    My Classrooms
                </a>
            </asp:Panel>
        </div>
    </div>

    <%-- Pending approval notice --%>
    <asp:Panel ID="pnlPendingNotice" runat="server" Visible="false">
        <div class="cp-alert cp-alert-warning" style="margin-bottom:24px;">
            <span style="font-size:18px;">&#x23F3;</span>
            <div>
                <strong>Licence Pending Approval</strong><br />
                Your instructor account is awaiting admin approval. Full teaching features will unlock once your licence is approved.
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlRejectedNotice" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger" style="margin-bottom:24px;">
            <span style="font-size:18px;"></span>
            <div>
                <strong>Licence Rejected</strong><br />
                Your instructor application was not approved. Please contact an administrator for further guidance.
            </div>
        </div>
    </asp:Panel>

    <%-- Stat cards — only shown when approved --%>
    <asp:Panel ID="pnlStats" runat="server" Visible="false">
        <div class="cp-grid-4 cp-mb-lg">
            <a href="Classrooms.aspx" class="cp-stat-card cp-stat-card-link" aria-label="Go to My Classrooms">
                <div class="cp-stat-icon indigo" aria-hidden="true"></div>
                <div>
                    <div class="cp-stat-value"><asp:Literal ID="litClassroomCount" runat="server" Text="0" /></div>
                    <div class="cp-stat-label">My Classrooms</div>
                </div>
            </a>
            <a href="Modules.aspx" class="cp-stat-card cp-stat-card-link" aria-label="Go to Modules">
                <div class="cp-stat-icon blue" aria-hidden="true"></div>
                <div>
                    <div class="cp-stat-value"><asp:Literal ID="litModuleCount" runat="server" Text="0" /></div>
                    <div class="cp-stat-label">Modules Created</div>
                </div>
            </a>
            <a href="Classrooms.aspx" class="cp-stat-card cp-stat-card-link" aria-label="Go to Classrooms to see students">
                <div class="cp-stat-icon green" aria-hidden="true"></div>
                <div>
                    <div class="cp-stat-value"><asp:Literal ID="litStudentCount" runat="server" Text="0" /></div>
                    <div class="cp-stat-label">Total Students</div>
                </div>
            </a>
            <a href="Assignments.aspx" class="cp-stat-card cp-stat-card-link" aria-label="Go to Assignments">
                <div class="cp-stat-icon amber" aria-hidden="true"></div>
                <div>
                    <div class="cp-stat-value"><asp:Literal ID="litPendingAssignments" runat="server" Text="0" /></div>
                    <div class="cp-stat-label">Pending Submissions</div>
                </div>
            </a>
        </div>

        <%-- Two-column layout --%>
        <div class="cp-grid-2">

            <%-- My Classrooms summary --%>
            <div>
                <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">
                    My Classrooms
                </h3>

                <asp:Panel ID="pnlClassroomList" runat="server" Visible="false">
                    <asp:Repeater ID="rptClassrooms" runat="server">
                        <ItemTemplate>
                            <div class="cp-module-card">
                                <div class="cp-flex-between">
                                    <div>
                                        <div style="font-size:14px;font-weight:600;color:var(--cp-text);">
                                            <%# HttpUtility.HtmlEncode(Eval("ClassroomName").ToString()) %>
                                        </div>
                                        <div style="font-size:12px;color:var(--cp-text-muted);margin-top:3px;">
                                            <%# Eval("StudentCount") %> student(s) &bull; Code: <strong><%# HttpUtility.HtmlEncode(Eval("InviteCode").ToString()) %></strong>
                                        </div>
                                    </div>
                                    <a href='Classrooms.aspx?id=<%# Eval("ClassroomID") %>'
                                       class="cp-btn cp-btn-ghost cp-btn-sm">View</a>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </asp:Panel>

                <asp:Panel ID="pnlNoClassrooms" runat="server" Visible="false">
                    <div class="cp-empty-state">
                        <h3>No classrooms yet</h3>
                        <p>Create your first classroom to get started.</p>
                        <a href="Classrooms.aspx" class="cp-btn cp-btn-primary">Create Classroom</a>
                    </div>
                </asp:Panel>
            </div>

            <%-- Recent submissions --%>
            <div>
                <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">
                    Recent Submissions
                </h3>

                <asp:Panel ID="pnlSubmissions" runat="server" Visible="false">
                    <div class="cp-card" style="padding:0;overflow:hidden;">
                        <asp:Repeater ID="rptSubmissions" runat="server">
                            <ItemTemplate>
                                <div style="display:flex;align-items:center;justify-content:space-between;
                                            padding:12px 16px;border-bottom:1px solid var(--cp-border);">
                                    <div>
                                        <div style="font-size:13px;font-weight:500;color:var(--cp-text);">
                                            <%# HttpUtility.HtmlEncode(Eval("StudentName").ToString()) %>
                                        </div>
                                        <div style="font-size:11px;color:var(--cp-text-muted);margin-top:2px;">
                                            <%# HttpUtility.HtmlEncode(Eval("AssignmentTitle").ToString()) %>
                                            &bull; <%# Convert.ToDateTime(Eval("SubmittedAt")).ToString("dd MMM yyyy HH:mm") %>
                                        </div>
                                    </div>
                                    <span class="cp-badge cp-badge-amber">Pending</span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlNoSubmissions" runat="server" Visible="false">
                    <div class="cp-empty-state">
                        <h3>No pending submissions</h3>
                        <p>All assignment submissions have been reviewed.</p>
                    </div>
                </asp:Panel>
            </div>

        </div>

        <%-- Recent notifications --%>
        <asp:Panel ID="pnlRecentNotif" runat="server" Visible="false">
            <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:24px 0 12px;">
                Recent Notifications
            </h3>
            <div class="cp-card" style="padding:0;overflow:hidden;">
                <asp:Repeater ID="rptNotifications" runat="server">
                    <ItemTemplate>
                        <div style="display:flex;align-items:center;gap:12px;
                                    padding:12px 16px;border-bottom:1px solid var(--cp-border);">
                            <span style="font-size:16px;" aria-hidden="true"></span>
                            <div style="flex:1;min-width:0;">
                                <div style="font-size:13px;color:var(--cp-text);">
                                    <%# HttpUtility.HtmlEncode(Eval("Message").ToString()) %>
                                </div>
                                <div style="font-size:11px;color:var(--cp-text-muted);margin-top:2px;">
                                    <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy HH:mm") %>
                                </div>
                            </div>
                            <%# Convert.ToBoolean(Eval("IsRead")) ? "" :
                                "<span class='cp-badge cp-badge-blue'>New</span>" %>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
            <div style="text-align:right;margin-top:8px;">
                <a href="Notifications.aspx" style="font-size:13px;color:var(--cp-primary);">
                    View all notifications &#x2192;
                </a>
            </div>
        </asp:Panel>

    </asp:Panel><%-- end pnlStats --%>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
</asp:Content>
