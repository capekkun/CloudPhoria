<%@ Page Title="Subtopics" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="SubTopics.aspx.cs"
    Inherits="CloudPhoria.Instructor.SubTopics" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Page header --%>
    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>Subtopics</h2>
                <p>
                    <asp:Literal ID="litModuleContext" runat="server" Text="Subtopics for modules assigned to you. Only Admin can create, edit, or publish subtopics." />
                </p>
            </div>
            <div style="display:flex;gap:8px;flex-wrap:wrap;">
                <a href="Modules.aspx" class="cp-btn cp-btn-ghost">&#x2190; Modules</a>
            </div>
        </div>
    </div>

    <%-- Module filter --%>
    <div class="cp-card cp-mb-md" style="padding:16px 20px;">
        <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
            <label class="cp-label" style="margin:0;white-space:nowrap;" for="<%= ddlModule.ClientID %>">Filter by Module:</label>
            <asp:DropDownList ID="ddlModule" runat="server" CssClass="cp-select"
                              AutoPostBack="true" OnSelectedIndexChanged="ddlModule_Changed"
                              style="max-width:360px;" />
        </div>
    </div>

    <%-- Feedback --%>
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger">
            <span></span>
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <%-- Subtopic list (read-only) --%>
    <asp:Panel ID="pnlSubTopics" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table" role="grid" aria-label="Subtopics">
                <thead>
                    <tr>
                        <th scope="col">Order</th>
                        <th scope="col">Subtopic Name</th>
                        <th scope="col">Module</th>
                        <th scope="col">XP Reward</th>
                        <th scope="col">Status</th>
                        <th scope="col">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptSubTopics" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td style="color:var(--cp-text-muted);"><%# Eval("OrderIndex") %></td>
                                <td style="font-weight:600;">
                                    <%# HttpUtility.HtmlEncode(Eval("SubTopicName").ToString()) %>
                                </td>
                                <td style="color:var(--cp-text-muted);">
                                    <%# HttpUtility.HtmlEncode(Eval("ModuleName").ToString()) %>
                                </td>
                                <td><span class="cp-xp-chip"><%# Eval("XPReward") %> XP</span></td>
                                <td>
                                    <%# Convert.ToBoolean(Eval("IsPublished"))
                                        ? "<span class='cp-badge cp-badge-green'>Published</span>"
                                        : "<span class='cp-badge cp-badge-grey'>Draft</span>" %>
                                </td>
                                <td>
                                    <a href='Questions.aspx?subTopicID=<%# Eval("SubTopicID") %>'
                                       class="cp-btn cp-btn-outline cp-btn-sm">View Questions</a>
                                    <a href='Materials.aspx?subTopicID=<%# Eval("SubTopicID") %>'
                                       class="cp-btn cp-btn-ghost cp-btn-sm">Materials</a>
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
            <h3>No subtopics yet</h3>
            <p>Ask an Admin to add subtopics to your assigned modules.</p>
        </div>
    </asp:Panel>

</asp:Content>
