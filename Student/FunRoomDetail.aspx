<%@ Page Title="Fun Room" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="FunRoomDetail.aspx.cs"
    Inherits="CloudPhoria.Student.FunRoomDetail" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="cp-page-header">
        <h2>&#x1F3AE; <asp:Literal ID="litRoomTitle" runat="server" Text="Fun Room" /></h2>
        <p>Created by: <asp:Literal ID="litCreator" runat="server" /></p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md"><asp:Literal ID="litError" runat="server" /></div>
    </asp:Panel>

    <asp:Panel ID="pnlContent" runat="server" Visible="false">
        <div class="cp-card">
            <asp:Literal ID="litContentBody" runat="server" />
        </div>
    </asp:Panel>

    <div style="margin-top:16px;">
        <a href="FunRooms.aspx" style="font-size:13px;color:var(--cp-primary);">&#x2190; Back to Fun Rooms</a>
    </div>
</asp:Content>
