<%@ Page Title="Fun Rooms" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="FunRooms.aspx.cs"
    Inherits="CloudPhoria.Student.FunRooms" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="TopbarActions" ContentPlaceHolderID="TopbarActions" runat="server">
    <a href="FunRoomCreate.aspx" class="cp-btn cp-btn-primary cp-btn-sm">+ Create Room</a>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <h2>Fun Rooms</h2>
        <p>Community-created learning rooms. Browse approved rooms or submit your own.</p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <%-- My submissions --%>
    <asp:Panel ID="pnlMyRooms" runat="server" Visible="false">
        <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:0 0 12px;">
            My Submissions
        </h3>
        <asp:Repeater ID="rptMyRooms" runat="server">
            <ItemTemplate>
                <div class="cp-module-card">
                    <div class="cp-flex-between">
                        <div style="font-size:14px;font-weight:600;color:var(--cp-text);">
                            <%# HttpUtility.HtmlEncode(Eval("RoomTitle").ToString()) %>
                        </div>
                        <%# GetStatusBadge(Eval("Status").ToString()) %>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>

    <%-- Approved rooms from all users --%>
    <h3 style="font-size:15px;font-weight:600;color:var(--cp-text);margin:20px 0 12px;">
        Approved Rooms
    </h3>
    <asp:Panel ID="pnlRooms" runat="server" Visible="false">
        <div class="cp-grid-3">
            <asp:Repeater ID="rptRooms" runat="server">
                <ItemTemplate>
                    <div class="cp-card">
                        <h3 class="cp-card-title">
                            <%# HttpUtility.HtmlEncode(Eval("RoomTitle").ToString()) %>
                        </h3>
                        <p class="cp-card-subtitle">
                            By <%# HttpUtility.HtmlEncode(Eval("CreatorName").ToString()) %>
                        </p>
                        <a href="FunRoomDetail.aspx?roomID=<%# Eval("FunRoomID") %>"
                           class="cp-btn cp-btn-outline cp-btn-sm">
                            Enter Room
                        </a>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F3AE;</span>
            <h3>No fun rooms yet</h3>
            <p>Be the first to create a community learning room!</p>
            <a href="FunRoomCreate.aspx" class="cp-btn cp-btn-primary">Create a Room</a>
        </div>
    </asp:Panel>

</asp:Content>
