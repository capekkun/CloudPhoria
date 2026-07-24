<%@ Page Title="My Learning" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="MyLearning.aspx.cs"
    Inherits="CloudPhoria.Student.MyLearning" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <h2>My Learning</h2>
        <p>Track your progress across all modules and subtopics.</p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <%-- In Progress --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">
        In Progress
    </h3>
    <asp:Panel ID="pnlInProgress" runat="server" Visible="false">
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
                                &bull;
                                <span style="color:<%# Eval("DiffColour") %>;font-weight:600;">
                                    <%# HttpUtility.HtmlEncode(Eval("DifficultyLevel").ToString()) %>
                                </span>
                            </div>
                        </div>
                        <span class="cp-badge cp-badge-blue">In Progress</span>
                    </div>
                    <div class="cp-progress-label cp-mt-sm">
                        <span><%# Eval("CompletedSubs") %> / <%# Eval("TotalSubs") %> subtopics</span>
                        <span><%# Eval("ProgressPct") %>%</span>
                    </div>
                    <div class="cp-progress-wrap">
                        <div class="cp-progress-bar" style="width:<%# Eval("ProgressPct") %>%;"></div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>
    <asp:Panel ID="pnlNoInProgress" runat="server" Visible="false">
        <div class="cp-card" style="text-align:center;padding:24px;color:var(--cp-text-muted);font-size:13px;">
            No modules in progress. <a href="Pathways.aspx" style="color:var(--cp-primary);">Browse pathways</a> to get started.
        </div>
    </asp:Panel>

    <%-- Completed --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:24px 0 12px;">
        Completed
    </h3>
    <asp:Panel ID="pnlCompleted" runat="server" Visible="false">
        <asp:Repeater ID="rptCompleted" runat="server">
            <ItemTemplate>
                <div class="cp-module-card">
                    <div class="cp-flex-between">
                        <div>
                            <div style="font-size:14px;font-weight:600;color:var(--cp-text);">
                                <%# HttpUtility.HtmlEncode(Eval("ModuleName").ToString()) %>
                            </div>
                            <div style="font-size:12px;color:var(--cp-text-muted);margin-top:3px;">
                                <%# HttpUtility.HtmlEncode(Eval("PathwayName").ToString()) %>
                                &bull; Completed <%# Convert.ToDateTime(Eval("CompletedAt")).ToString("dd MMM yyyy") %>
                            </div>
                        </div>
                        <div class="cp-flex-row">
                            <span class="cp-xp-chip">+<%# Eval("XPEarned") %> XP</span>
                            <span class="cp-badge cp-badge-green">Done</span>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>
    <asp:Panel ID="pnlNoCompleted" runat="server" Visible="false">
        <div class="cp-card" style="text-align:center;padding:24px;color:var(--cp-text-muted);font-size:13px;">
            No completed modules yet. Keep learning!
        </div>
    </asp:Panel>

</asp:Content>
