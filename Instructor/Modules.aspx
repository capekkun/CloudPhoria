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
                <p>Create and manage your learning modules across pathways.</p>
            </div>
            <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('createModal')">
                + New Module
            </button>
        </div>
    </div>

    <%-- Feedback messages --%>
    <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
        <div class="cp-alert cp-alert-success">
            <span>&#x2714;</span>
            <asp:Literal ID="litSuccess" runat="server" />
        </div>
    </asp:Panel>
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger">
            <span>&#x26A0;</span>
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <%-- Module list --%>
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
                    <asp:Repeater ID="rptModules" runat="server"
                                  OnItemCommand="rptModules_ItemCommand">
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
                                    <asp:LinkButton runat="server"
                                        CommandName="TogglePublish"
                                        CommandArgument='<%# Eval("ModuleID") + "|" + Eval("IsPublished") %>'
                                        CssClass="cp-btn cp-btn-ghost cp-btn-sm"
                                        OnClientClick="return confirm('Toggle publish status?');">
                                        <%# Convert.ToBoolean(Eval("IsPublished")) ? "Unpublish" : "Publish" %>
                                    </asp:LinkButton>
                                    <a href='SubTopics.aspx?moduleID=<%# Eval("ModuleID") %>'
                                       class="cp-btn cp-btn-outline cp-btn-sm">Subtopics</a>
                                    <asp:LinkButton runat="server"
                                        CommandName="Delete"
                                        CommandArgument='<%# Eval("ModuleID") %>'
                                        CssClass="cp-btn cp-btn-danger cp-btn-sm"
                                        OnClientClick="return confirm('Delete this module and all its content?');">
                                        Delete
                                    </asp:LinkButton>
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
            <h3>No modules yet</h3>
            <p>Create your first module to start building learning content.</p>
            <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('createModal')">
                + New Module
            </button>
        </div>
    </asp:Panel>

    <%-- Create Module Modal --%>
    <div id="createModal" class="cp-modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="createModalTitle">
        <div class="cp-modal">
            <button class="cp-modal-close" type="button" onclick="hideModal('createModal')"
                    aria-label="Close">&#x2715;</button>
            <h2 class="cp-modal-title" id="createModalTitle">New Module</h2>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= ddlPathway.ClientID %>">
                    Pathway <span class="required">*</span>
                </label>
                <asp:DropDownList ID="ddlPathway" runat="server" CssClass="cp-select" />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtModuleName.ClientID %>">
                    Module Name <span class="required">*</span>
                </label>
                <asp:TextBox ID="txtModuleName" runat="server" CssClass="cp-input"
                             MaxLength="150" placeholder="e.g. Introduction to Cloud Computing" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtModuleName"
                    Display="Dynamic" CssClass="cp-form-error"
                    ValidationGroup="CreateModule"
                    ErrorMessage="Module name is required." />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtDescription.ClientID %>">Description</label>
                <asp:TextBox ID="txtDescription" runat="server" CssClass="cp-textarea"
                             TextMode="MultiLine" Rows="3"
                             placeholder="Brief description of this module..." />
            </div>

            <div class="cp-grid-2" style="gap:12px;">
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= ddlDifficulty.ClientID %>">
                        Difficulty <span class="required">*</span>
                    </label>
                    <asp:DropDownList ID="ddlDifficulty" runat="server" CssClass="cp-select">
                        <asp:ListItem Value="Easy">Easy</asp:ListItem>
                        <asp:ListItem Value="Medium" Selected="True">Medium</asp:ListItem>
                        <asp:ListItem Value="Hard">Hard</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtXPReward.ClientID %>">XP Reward</label>
                    <asp:TextBox ID="txtXPReward" runat="server" CssClass="cp-input"
                                 TextMode="Number" Text="100" />
                </div>
            </div>

            <div class="cp-grid-2" style="gap:12px;">
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtExamDuration.ClientID %>">Exam Duration (min)</label>
                    <asp:TextBox ID="txtExamDuration" runat="server" CssClass="cp-input"
                                 TextMode="Number" Text="60" />
                </div>
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtPassMark.ClientID %>">Pass Mark (%)</label>
                    <asp:TextBox ID="txtPassMark" runat="server" CssClass="cp-input"
                                 TextMode="Number" Text="70" />
                </div>
            </div>

            <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:8px;">
                <button type="button" class="cp-btn cp-btn-ghost"
                        onclick="hideModal('createModal')">Cancel</button>
                <asp:Button ID="btnCreate" runat="server" Text="Create Module"
                            CssClass="cp-btn cp-btn-primary"
                            ValidationGroup="CreateModule"
                            OnClick="btnCreate_Click" />
            </div>
        </div>
    </div>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
<script>
function showModal(id) {
    document.getElementById(id).classList.add('open');
    document.body.style.overflow = 'hidden';
}
function hideModal(id) {
    document.getElementById(id).classList.remove('open');
    document.body.style.overflow = '';
}
// Close on backdrop click.
document.querySelectorAll('.cp-modal-backdrop').forEach(function(el) {
    el.addEventListener('click', function(e) {
        if (e.target === el) hideModal(el.id);
    });
});
</script>
</asp:Content>
