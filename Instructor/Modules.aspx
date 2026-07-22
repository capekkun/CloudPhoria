<%@ Page Title="Modules" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Modules.aspx.cs"
    Inherits="CloudPhoria.Instructor.Modules" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Page header --%>
    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x1F4D6; Modules</h2>
                <p>Modules assigned to you by an Admin. Only Admin can create, edit, or publish modules — contact your Admin if a module needs changes.</p>
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger">
            <span>&#x26A0;</span>
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <%-- Module list (read-only) --%>
    <asp:Panel ID="pnlModules" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table" role="grid" aria-label="Modules">
                <thead>
                    <tr>
                        <th scope="col">Module Name</th>
                        <th scope="col">Pathway</th>
                        <th scope="col">Difficulty</th>
                        <th scope="col">XP Reward</th>
                        <th scope="col">Status</th>
                        <th scope="col">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptModules" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td style="font-weight:600;">
                                    <%# HttpUtility.HtmlEncode(Eval("ModuleName").ToString()) %>
                                </td>
                                <td style="color:var(--cp-text-muted);">
                                    <%# HttpUtility.HtmlEncode(Eval("PathwayName").ToString()) %>
                                </td>
                                <td>
                                    <span class='cp-badge <%# GetDifficultyBadge(Eval("DifficultyLevel").ToString()) %>'>
                                        <%# HttpUtility.HtmlEncode(Eval("DifficultyLevel").ToString()) %>
                                    </span>
                                </td>
                                <td>
                                    <span class="cp-xp-chip"><%# Eval("XPReward") %> XP</span>
                                </td>
                                <td>
                                    <%# Convert.ToBoolean(Eval("IsPublished"))
                                        ? "<span class='cp-badge cp-badge-green'>Published</span>"
                                        : "<span class='cp-badge cp-badge-grey'>Draft</span>" %>
                                </td>
                                <td>
                                    <a href='SubTopics.aspx?moduleID=<%# Eval("ModuleID") %>'
                                       class="cp-btn cp-btn-outline cp-btn-sm">View Subtopics</a>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F4D6;</span>
            <h3>No modules assigned yet</h3>
            <p>Ask an Admin to assign you a module from Manage Courses.</p>
        </div>
    </asp:Panel>

</asp:Content>
