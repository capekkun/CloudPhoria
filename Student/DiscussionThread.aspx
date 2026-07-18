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
            <asp:Literal ID="litBody" runat="server" />
        </div>

        <h3>Replies</h3>
        <asp:Panel ID="pnlReplies" runat="server" Visible="false">
            <asp:Repeater ID="rptReplies" runat="server">
                <ItemTemplate>
                    <div class="cp-card" style="border-left:3px solid var(--cp-primary);">
                        <div style="font-size:12px;color:#64748B;margin-bottom:8px;">
                            <strong><%# HttpUtility.HtmlEncode(Eval("FullName").ToString()) %></strong>
                            &mdash; <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy HH:mm") %>
                        </div>
                        <div style="font-size:14px;color:#172033;">
                            <%# HttpUtility.HtmlEncode(Eval("Body").ToString()) %>
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
    </asp:Panel>

    <div style="margin-top:16px;">
        <a href="Discussions.aspx" style="font-size:13px;color:#0EA5E9;">&#x2190; Back to Discussions</a>
    </div>
</asp:Content>
