<%@ Page Title="Discussion" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="DiscussionThread.aspx.cs"
    Inherits="CloudPhoria.Student.DiscussionThread" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="cp-page-header">
        <h2>&#x1F4AC; <asp:Literal ID="litTitle" runat="server" Text="Discussion" /></h2>
        <p>Posted by <asp:Literal ID="litAuthor" runat="server" /> on <asp:Literal ID="litDate" runat="server" /></p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md"><asp:Literal ID="litError" runat="server" /></div>
    </asp:Panel>

    <asp:Panel ID="pnlThread" runat="server" Visible="false">
        <div class="cp-card cp-mb-lg">
            <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                <div><asp:Literal ID="litBody" runat="server" /></div>
                <asp:Panel ID="pnlDeleteThread" runat="server" Visible="false">
                    <asp:LinkButton ID="btnDeleteThread" runat="server"
                        CssClass="cp-btn cp-btn-danger cp-btn-sm"
                        OnClick="btnDeleteThread_Click"
                        OnClientClick="return confirm('Delete this thread? This cannot be undone.');">
                        Delete Thread
                    </asp:LinkButton>
                </asp:Panel>
            </div>
        </div>

        <h3>Replies</h3>
        <asp:Panel ID="pnlReplies" runat="server" Visible="false">
            <asp:Repeater ID="rptReplies" runat="server" OnItemCommand="rptReplies_ItemCommand">
                <ItemTemplate>
                    <div class="cp-card" style="border-left:3px solid var(--cp-primary);">
                        <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                            <div>
                                <div style="font-size:12px;color:#64748B;margin-bottom:8px;">
                                    <strong><%# HttpUtility.HtmlEncode(Eval("FullName").ToString()) %></strong>
                                    &mdash; <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy HH:mm") %>
                                </div>
                                <div style="font-size:14px;color:#172033;">
                                    <%# HttpUtility.HtmlEncode(Eval("Body").ToString()) %>
                                </div>
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
        <asp:Panel ID="pnlNoReplies" runat="server" Visible="false">
            <div class="cp-card" style="text-align:center;padding:20px;color:#64748B;font-size:13px;">
                No replies yet. Be the first to respond!
            </div>
        </asp:Panel>

        <%-- Reply form --%>
        <div class="cp-card" style="margin-top:20px;">
            <h3 style="margin-top:0;">Post a Reply</h3>
            <asp:Panel ID="pnlReplySuccess" runat="server" Visible="false">
                <div class="cp-alert cp-alert-success cp-mb-md">Reply posted successfully!</div>
            </asp:Panel>
            <div class="cp-form-group">
                <asp:TextBox ID="txtReply" runat="server" TextMode="MultiLine" Rows="4"
                    CssClass="cp-input" placeholder="Write your reply..." style="width:100%;max-width:100%;" />
                <asp:RequiredFieldValidator ID="rfvReply" runat="server"
                    ControlToValidate="txtReply" ValidationGroup="Reply"
                    CssClass="cp-form-error" ErrorMessage="Reply cannot be empty." Display="Dynamic" />
            </div>
            <asp:Button ID="btnPostReply" runat="server" Text="Post Reply"
                CssClass="cp-btn cp-btn-primary" OnClick="btnPostReply_Click" ValidationGroup="Reply" />
        </div>
    </asp:Panel>

    <div style="margin-top:16px;">
        <a href="Discussions.aspx" style="font-size:13px;color:#0EA5E9;">&#x2190; Back to Discussions</a>
    </div>
</asp:Content>
