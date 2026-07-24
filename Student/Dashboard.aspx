<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs"
    Inherits="CloudPhoria.Student.Dashboard" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Page header with CloudPhoria mascot --%>
    <div class="cp-page-header" style="display:flex;align-items:center;justify-content:space-between;gap:20px;">
        <div>
            <h2>Welcome back, <asp:Literal ID="litWelcomeName" runat="server" />!</h2>
            <p>Here's your learning summary for today.</p>
        </div>
        <div style="display:flex;align-items:center;gap:16px;">
            <a href="Pathways.aspx" class="cp-btn cp-btn-primary">
                Browse Pathways
            </a>
            <img src="/uploads/studentdashboard/robot-icon.png" alt="" width="56" height="56" style="border-radius:50%;object-fit:cover;" />
        </div>
    </div>

    <%-- Stat cards row --%>
    <div class="cp-grid-4 cp-mb-lg">
        <div class="cp-stat-card">
            <div class="cp-stat-icon" style="background-image:url('/uploads/studentdashboard/total-xp-icon.png');background-size:cover;background-position:center;" aria-hidden="true"></div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litTotalXP" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Total XP</div>
            </div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon" style="background-image:url('/uploads/studentdashboard/modules-completed-icon.png');background-size:cover;background-position:center;" aria-hidden="true"></div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litModulesCompleted" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Modules Completed</div>
            </div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon" style="background-image:url('/uploads/studentdashboard/badges-earned-icon.png');background-size:cover;background-position:center;" aria-hidden="true"></div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litBadgesEarned" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Badges Earned</div>
            </div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon" style="background-image:url('/uploads/studentdashboard/classrooms-joined-icon.png');background-size:cover;background-position:center;" aria-hidden="true"></div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litClassroomsJoined" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Classrooms Joined</div>
            </div>
        </div>
    </div>

    <%-- Two-column layout: continue learning + recent activity --%>
    <div class="cp-grid-2">

        <%-- Continue learning --%>
        <div>
            <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">
                Continue Learning
            </h3>

            <asp:Panel ID="pnlContinueLearning" runat="server" Visible="false">
                <asp:Repeater ID="rptInProgress" runat="server">
                    <ItemTemplate>
                        <div class="cp-module-card">
                            <div class="cp-flex-between">
                                <div>
                                    <div style="font-size:14px;font-weight:600;color:var(--cp-text);">
                                        <%# HttpUtility.HtmlEncode(Eval("ModuleName").ToString()) %>
                                    </div>
                                    <div style="font-size:12px;color:var(--cp-text-muted);margin-top:3px;">
                                        <%# HttpUtility.HtmlEncode(Eval("PathwayName").ToString()) %>
                                    </div>
                                </div>
                                <span class="cp-badge cp-badge-blue">In Progress</span>
                            </div>
                            <div class="cp-progress-label cp-mt-sm">
                                <span>Progress</span>
                                <span><%# Eval("ProgressPct") %>%</span>
                            </div>
                            <div class="cp-progress-wrap">
                                <div class="cp-progress-bar" style="width:<%# Eval("ProgressPct") %>%;"></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>

            <asp:Panel ID="pnlNoContinue" runat="server" Visible="false">
                <div class="cp-empty-state">
                    <h3>No modules in progress</h3>
                    <p>Start your first module to see your progress here.</p>
                    <a href="Pathways.aspx" class="cp-btn cp-btn-primary">Browse Pathways</a>
                </div>
            </asp:Panel>
        </div>

        <%-- Recent XP activity --%>
        <div>
            <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">
                Recent XP Activity
            </h3>

            <asp:Panel ID="pnlRecentXP" runat="server" Visible="false">
                <div class="cp-card" style="padding:0;overflow:hidden;">
                    <asp:Repeater ID="rptRecentXP" runat="server">
                        <ItemTemplate>
                            <div style="display:flex;align-items:center;justify-content:space-between;
                                        padding:12px 16px;border-bottom:1px solid var(--cp-border);">
                                <div>
                                    <div style="font-size:13px;font-weight:500;color:var(--cp-text);">
                                        <%# HttpUtility.HtmlEncode(Eval("SourceType").ToString()) %>
                                    </div>
                                    <div style="font-size:11px;color:var(--cp-text-muted);margin-top:2px;">
                                        <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %>
                                    </div>
                                </div>
                                <span class="cp-xp-chip">+<%# Eval("XPAmount") %> XP</span>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlNoXP" runat="server" Visible="false">
                <div class="cp-empty-state">
                    <h3>No XP earned yet</h3>
                    <p>Complete subtopics and exams to earn XP.</p>
                </div>
            </asp:Panel>
        </div>

    </div>

    <%-- Recent notifications strip --%>
    <asp:Panel ID="pnlRecentNotif" runat="server" Visible="false">
        <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:24px 0 12px;">
            Recent Notifications
        </h3>
        <div class="cp-card" style="padding:0;overflow:hidden;">
            <asp:Repeater ID="rptNotifications" runat="server">
                <ItemTemplate>
                    <div style="display:flex;align-items:center;gap:12px;
                                padding:12px 16px;border-bottom:1px solid var(--cp-border);">
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
                View all notifications
            </a>
        </div>
    </asp:Panel>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
</asp:Content>
