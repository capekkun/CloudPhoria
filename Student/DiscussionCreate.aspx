<%@ Page Title="New Discussion" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="DiscussionCreate.aspx.cs"
    Inherits="CloudPhoria.Student.DiscussionCreate" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="cp-page-header">
        <h2>&#x1F4AC; Start a New Discussion</h2>
        <p>Ask a question or share insights with the community.</p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md"><asp:Literal ID="litError" runat="server" /></div>
    </asp:Panel>

    <div class="cp-card" style="max-width:700px;">
        <div class="cp-form-group">
            <label class="cp-label">Title <span style="color:#EF4444;">*</span></label>
            <asp:TextBox ID="txtTitle" runat="server" CssClass="cp-input" MaxLength="200"
                placeholder="What's your discussion about?" />
            <asp:RequiredFieldValidator ID="rfvTitle" runat="server"
                ControlToValidate="txtTitle" ValidationGroup="Create"
                CssClass="cp-form-error" ErrorMessage="Title is required." Display="Dynamic" />
        </div>

        <div class="cp-form-group">
            <label class="cp-label">Body <span style="color:#EF4444;">*</span></label>
            <asp:TextBox ID="txtBody" runat="server" TextMode="MultiLine" Rows="6"
                CssClass="cp-input" placeholder="Describe your question or share your thoughts..."
                style="width:100%;max-width:100%;" />
            <asp:RequiredFieldValidator ID="rfvBody" runat="server"
                ControlToValidate="txtBody" ValidationGroup="Create"
                CssClass="cp-form-error" ErrorMessage="Body is required." Display="Dynamic" />
        </div>

        <div style="display:flex;gap:10px;align-items:center;">
            <asp:Button ID="btnCreate" runat="server" Text="Post Discussion"
                CssClass="cp-btn cp-btn-primary" OnClick="btnCreate_Click" ValidationGroup="Create" />
            <a href="Discussions.aspx" class="cp-btn cp-btn-ghost">Cancel</a>
        </div>
    </div>
</asp:Content>
