<%@ Page Title="Module Exams" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Exams.aspx.cs"
    Inherits="CloudPhoria.Student.Exams" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <h2>Module Exams</h2>
        <p>Take timed module exams to earn XP and badges. Pass mark and duration vary by module.</p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <%-- Available exams --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">
        Available Exams
    </h3>
    <asp:Panel ID="pnlAvailable" runat="server" Visible="false">
        <asp:Repeater ID="rptAvailable" runat="server">
            <ItemTemplate>
                <div class="cp-module-card">
                    <div class="cp-flex-between">
                        <div>
                            <div style="font-size:14px;font-weight:600;color:var(--cp-text);">
                                <%# HttpUtility.HtmlEncode(Eval("ModuleName").ToString()) %>
                            </div>
                            <div style="font-size:12px;color:var(--cp-text-muted);margin-top:4px;">
                                &#x23F1; <%# Eval("ExamDurationMinutes") %> min
                                &bull; Pass: <%# Eval("ExamPassMarkPercent") %>%
                                &bull; Reward: <span class="cp-xp-chip" style="font-size:11px;">+<%# Eval("XPReward") %> XP</span>
                            </div>
                        </div>
                        <a href="ExamStart.aspx?moduleID=<%# Eval("ModuleID") %>"
                           class="cp-btn cp-btn-primary cp-btn-sm">
                            Start Exam
                        </a>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>
    <asp:Panel ID="pnlNoAvailable" runat="server" Visible="false">
        <div class="cp-card" style="text-align:center;padding:20px;font-size:13px;color:var(--cp-text-muted);">
            No exams available. Complete modules to unlock their exams.
        </div>
    </asp:Panel>

    <%-- Past attempts --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:24px 0 12px;">
        Past Attempts
    </h3>
    <asp:Panel ID="pnlHistory" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table">
                <thead>
                    <tr>
                        <th>Module</th>
                        <th>Date</th>
                        <th>Score</th>
                        <th>Result</th>
                        <th>XP Awarded</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptHistory" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><%# HttpUtility.HtmlEncode(Eval("ModuleName").ToString()) %></td>
                                <td><%# Convert.ToDateTime(Eval("SubmittedAt")).ToString("dd MMM yyyy") %></td>
                                <td><%# Eval("ScorePercent") %>%</td>
                                <td>
                                    <%# Convert.ToBoolean(Eval("IsPassed"))
                                        ? "<span class='cp-badge cp-badge-green'>Passed</span>"
                                        : "<span class='cp-badge cp-badge-red'>Failed</span>" %>
                                </td>
                                <td>
                                    <%# Convert.ToInt32(Eval("XPAwarded")) > 0
                                        ? "<span class='cp-xp-chip'>+" + Eval("XPAwarded") + " XP</span>"
                                        : "—" %>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlNoHistory" runat="server" Visible="false">
        <div class="cp-card" style="text-align:center;padding:20px;font-size:13px;color:var(--cp-text-muted);">
            No exam attempts yet.
        </div>
    </asp:Panel>

</asp:Content>
