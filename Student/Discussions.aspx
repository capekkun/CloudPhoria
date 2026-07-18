<%@ Page Title="Discussions" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Discussions.aspx.cs"
    Inherits="CloudPhoria.Student.Discussions" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="TopbarActions" ContentPlaceHolderID="TopbarActions" runat="server">
    <a href="DiscussionCreate.aspx" class="cp-btn cp-btn-primary cp-btn-sm">+ New Thread</a>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <h2>Discussions</h2>
        <p>Ask questions, share insights, and connect with fellow students and instructors.</p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlThreads" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table">
                <thead>
                    <tr>
                        <th>Thread</th>
                        <th>Topic</th>
                        <th>Posted by</th>
                        <th>Date</th>
                        <th>Replies</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptThreads" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <a href="DiscussionThread.aspx?threadID=<%# Eval("ThreadID") %>"
                                       style="color:var(--cp-primary);font-weight:500;">
                                        <%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %>
                                    </a>
                                </td>
                                <td>
                                    <%# Eval("ModuleName") != DBNull.Value
                                        ? HttpUtility.HtmlEncode(Eval("ModuleName").ToString())
                                        : Eval("SubTopicName") != DBNull.Value
                                            ? HttpUtility.HtmlEncode(Eval("SubTopicName").ToString())
                                            : "<span style='color:var(--cp-text-muted)'>General</span>" %>
                                </td>
                                <td><%# HttpUtility.HtmlEncode(Eval("FullName").ToString()) %></td>
                                <td><%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %></td>
                                <td><%# Eval("ReplyCount") %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F4AC;</span>
            <h3>No discussions yet</h3>
            <p>Start the first thread to get the conversation going.</p>
            <a href="DiscussionCreate.aspx" class="cp-btn cp-btn-primary">Start a Discussion</a>
        </div>
    </asp:Panel>

</asp:Content>
