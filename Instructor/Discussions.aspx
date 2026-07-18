<%@ Page Title="Discussions" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Discussions.aspx.cs"
    Inherits="CloudPhoria.Instructor.Discussions" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x1F4AC; Discussions</h2>
                <p>Browse forum threads and participate in student conversations.</p>
            </div>
            <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('createModal')">
                + New Thread
            </button>
        </div>
    </div>

    <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
        <div class="cp-alert cp-alert-success"><span>&#x2714;</span>
            <asp:Literal ID="litSuccess" runat="server" /></div>
    </asp:Panel>
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger"><span>&#x26A0;</span>
            <asp:Literal ID="litError" runat="server" /></div>
    </asp:Panel>

    <%-- Thread list --%>
    <asp:Panel ID="pnlThreads" runat="server" Visible="false">
        <asp:Repeater ID="rptThreads" runat="server"
                      OnItemCommand="rptThreads_ItemCommand">
            <ItemTemplate>
                <div class="cp-card" style="margin-bottom:12px;">
                    <div class="cp-flex-between" style="flex-wrap:wrap;gap:8px;">
                        <div style="flex:1;min-width:0;">
                            <div style="font-size:15px;font-weight:700;color:var(--cp-text);margin-bottom:4px;">
                                <%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %>
                            </div>
                            <div style="font-size:12px;color:var(--cp-text-muted);">
                                By <%# HttpUtility.HtmlEncode(Eval("AuthorName").ToString()) %>
                                &bull; <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy HH:mm") %>
                                &bull; <span class="cp-badge cp-badge-blue"><%# Eval("ReplyCount") %> reply(s)</span>
                            </div>
                        </div>
                        <div style="display:flex;gap:8px;align-items:center;">
                            <a href='Discussions.aspx?threadID=<%# Eval("ThreadID") %>'
                               class="cp-btn cp-btn-outline cp-btn-sm">View</a>
                            <%# Convert.ToInt32(Eval("CreatedByUserID")) == Convert.ToInt32(Session["UserID"])
                                ? "<asp:LinkButton runat='server' CommandName='Delete' CommandArgument='" + Eval("ThreadID") + "' CssClass='cp-btn cp-btn-danger cp-btn-sm'>Delete</asp:LinkButton>"
                                : "" %>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F4AC;</span>
            <h3>No discussion threads</h3>
            <p>Start a thread to engage with your students.</p>
            <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('createModal')">
                + New Thread
            </button>
        </div>
    </asp:Panel>

    <%-- Thread detail + replies --%>
    <asp:Panel ID="pnlThread" runat="server" Visible="false">
        <div class="cp-card" style="margin-bottom:16px;">
            <h3 style="font-size:17px;font-weight:700;color:var(--cp-text);margin:0 0 8px;">
                <asp:Literal ID="litThreadTitle" runat="server" />
            </h3>
            <div style="font-size:13px;color:var(--cp-text);margin-bottom:8px;">
                <asp:Literal ID="litThreadBody" runat="server" />
            </div>
            <div style="font-size:11px;color:var(--cp-text-muted);">
                <asp:Literal ID="litThreadMeta" runat="server" />
            </div>
        </div>

        <h3 style="font-size:14px;font-weight:600;margin:0 0 12px;">Replies</h3>

        <asp:Panel ID="pnlReplies" runat="server" Visible="false">
            <asp:Repeater ID="rptReplies" runat="server"
                          OnItemCommand="rptReplies_ItemCommand">
                <ItemTemplate>
                    <div class="cp-card" style="margin-bottom:8px;padding:12px 16px;">
                        <div style="font-size:13px;color:var(--cp-text);margin-bottom:6px;">
                            <%# HttpUtility.HtmlEncode(Eval("Body").ToString()) %>
                        </div>
                        <div class="cp-flex-between">
                            <div style="font-size:11px;color:var(--cp-text-muted);">
                                <%# HttpUtility.HtmlEncode(Eval("AuthorName").ToString()) %>
                                &bull; <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy HH:mm") %>
                            </div>
                            <asp:LinkButton runat="server"
                                CommandName="DeleteReply"
                                CommandArgument='<%# Eval("ReplyID") %>'
                                CssClass="cp-btn cp-btn-danger cp-btn-sm"
                                Visible='<%# Convert.ToInt32(Eval("CreatedByUserID")) == Convert.ToInt32(Session["UserID"]) %>'
                                OnClientClick="return confirm('Delete this reply?');">
                                Delete
                            </asp:LinkButton>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>

        <%-- Post reply form --%>
        <div class="cp-card" style="margin-top:16px;">
            <h3 style="font-size:14px;font-weight:600;margin:0 0 12px;">Post a Reply</h3>
            <asp:HiddenField ID="hfThreadID" runat="server" />
            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtReply.ClientID %>">Your reply <span class="required">*</span></label>
                <asp:TextBox ID="txtReply" runat="server" CssClass="cp-textarea"
                             TextMode="MultiLine" Rows="3" placeholder="Write your reply..." />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtReply"
                    Display="Dynamic" CssClass="cp-form-error"
                    ValidationGroup="PostReply" ErrorMessage="Reply cannot be empty." />
            </div>
            <asp:Button ID="btnReply" runat="server" Text="Post Reply"
                        CssClass="cp-btn cp-btn-primary"
                        ValidationGroup="PostReply"
                        OnClick="btnReply_Click" />
        </div>
    </asp:Panel>

    <%-- Create Thread Modal --%>
    <div id="createModal" class="cp-modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="createTTitle">
        <div class="cp-modal" style="max-width:560px;">
            <button class="cp-modal-close" type="button" onclick="hideModal('createModal')" aria-label="Close">&#x2715;</button>
            <h2 class="cp-modal-title" id="createTTitle">New Thread</h2>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtThreadTitle.ClientID %>">Title <span class="required">*</span></label>
                <asp:TextBox ID="txtThreadTitle" runat="server" CssClass="cp-input"
                             MaxLength="200" placeholder="Thread title" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtThreadTitle"
                    Display="Dynamic" CssClass="cp-form-error"
                    ValidationGroup="CreateThread" ErrorMessage="Title is required." />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtThreadBody.ClientID %>">Body <span class="required">*</span></label>
                <asp:TextBox ID="txtThreadBody" runat="server" CssClass="cp-textarea"
                             TextMode="MultiLine" Rows="5" placeholder="Write your post..." />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtThreadBody"
                    Display="Dynamic" CssClass="cp-form-error"
                    ValidationGroup="CreateThread" ErrorMessage="Body is required." />
            </div>

            <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:12px;">
                <button type="button" class="cp-btn cp-btn-ghost" onclick="hideModal('createModal')">Cancel</button>
                <asp:Button ID="btnCreateThread" runat="server" Text="Post Thread"
                            CssClass="cp-btn cp-btn-primary"
                            ValidationGroup="CreateThread"
                            OnClick="btnCreateThread_Click" />
            </div>
        </div>
    </div>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
<script>
function showModal(id) { document.getElementById(id).classList.add('open'); document.body.style.overflow='hidden'; }
function hideModal(id) { document.getElementById(id).classList.remove('open'); document.body.style.overflow=''; }
document.querySelectorAll('.cp-modal-backdrop').forEach(function(el){
    el.addEventListener('click',function(e){ if(e.target===el) hideModal(el.id); });
});
</script>
</asp:Content>
