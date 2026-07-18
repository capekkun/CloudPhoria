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
                <h2>&#x1F4C4; Subtopics</h2>
                <p>
                    <asp:Literal ID="litModuleContext" runat="server" Text="Manage lesson subtopics for your modules." />
                </p>
            </div>
            <div style="display:flex;gap:8px;flex-wrap:wrap;">
                <a href="Modules.aspx" class="cp-btn cp-btn-ghost">&#x2190; Modules</a>
                <asp:Panel ID="pnlAddBtn" runat="server" Visible="false">
                    <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('createModal')">
                        + New Subtopic
                    </button>
                </asp:Panel>
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

    <%-- Subtopic list --%>
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
                    <asp:Repeater ID="rptSubTopics" runat="server"
                                  OnItemCommand="rptSubTopics_ItemCommand">
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
                                    <asp:LinkButton runat="server"
                                        CommandName="TogglePublish"
                                        CommandArgument='<%# Eval("SubTopicID") + "|" + Eval("IsPublished") %>'
                                        CssClass="cp-btn cp-btn-ghost cp-btn-sm"
                                        OnClientClick="return confirm('Toggle publish status?');">
                                        <%# Convert.ToBoolean(Eval("IsPublished")) ? "Unpublish" : "Publish" %>
                                    </asp:LinkButton>
                                    <a href='Questions.aspx?subTopicID=<%# Eval("SubTopicID") %>'
                                       class="cp-btn cp-btn-outline cp-btn-sm">Questions</a>
                                    <a href='Materials.aspx?subTopicID=<%# Eval("SubTopicID") %>'
                                       class="cp-btn cp-btn-ghost cp-btn-sm">Materials</a>
                                    <asp:LinkButton runat="server"
                                        CommandName="Delete"
                                        CommandArgument='<%# Eval("SubTopicID") %>'
                                        CssClass="cp-btn cp-btn-danger cp-btn-sm"
                                        OnClientClick="return confirm('Delete this subtopic?');">
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
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F4C4;</span>
            <h3>No subtopics yet</h3>
            <p>Select a module above and add subtopics to build lesson content.</p>
        </div>
    </asp:Panel>

    <%-- Create Subtopic Modal --%>
    <div id="createModal" class="cp-modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="createModalTitle">
        <div class="cp-modal" style="max-width:560px;">
            <button class="cp-modal-close" type="button" onclick="hideModal('createModal')"
                    aria-label="Close">&#x2715;</button>
            <h2 class="cp-modal-title" id="createModalTitle">New Subtopic</h2>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= ddlModuleCreate.ClientID %>">
                    Module <span class="required">*</span>
                </label>
                <asp:DropDownList ID="ddlModuleCreate" runat="server" CssClass="cp-select" />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtSubTopicName.ClientID %>">
                    Subtopic Name <span class="required">*</span>
                </label>
                <asp:TextBox ID="txtSubTopicName" runat="server" CssClass="cp-input"
                             MaxLength="150" placeholder="e.g. What is Cloud Computing?" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtSubTopicName"
                    Display="Dynamic" CssClass="cp-form-error"
                    ValidationGroup="CreateST"
                    ErrorMessage="Subtopic name is required." />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtContent.ClientID %>">Content / Lesson Body</label>
                <asp:TextBox ID="txtContent" runat="server" CssClass="cp-textarea"
                             TextMode="MultiLine" Rows="5"
                             placeholder="Write the lesson content here..." />
            </div>

            <div class="cp-grid-2" style="gap:12px;">
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtOrderIndex.ClientID %>">Order Index</label>
                    <asp:TextBox ID="txtOrderIndex" runat="server" CssClass="cp-input"
                                 TextMode="Number" Text="0" />
                </div>
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtSTXP.ClientID %>">XP Reward</label>
                    <asp:TextBox ID="txtSTXP" runat="server" CssClass="cp-input"
                                 TextMode="Number" Text="10" />
                </div>
            </div>

            <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:8px;">
                <button type="button" class="cp-btn cp-btn-ghost"
                        onclick="hideModal('createModal')">Cancel</button>
                <asp:Button ID="btnCreate" runat="server" Text="Create Subtopic"
                            CssClass="cp-btn cp-btn-primary"
                            ValidationGroup="CreateST"
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
document.querySelectorAll('.cp-modal-backdrop').forEach(function(el) {
    el.addEventListener('click', function(e) {
        if (e.target === el) hideModal(el.id);
    });
});
</script>
</asp:Content>
