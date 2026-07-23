<%@ Page Title="Manage Users" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Users.aspx.cs"
    Inherits="CloudPhoria.Admin.Users" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Page Header --%>
    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x1F465; Manage Users</h2>
                <p>Search, filter, and manage all CloudPhoria accounts.</p>
            </div>
        </div>
    </div>

    <%-- Feedback message --%>
    <asp:Panel ID="pnlMessage" runat="server" Visible="false" style="margin-bottom:16px;">
        <asp:Literal ID="litMessage" runat="server" />
    </asp:Panel>

    <%-- Search and filter bar --%>
    <div class="cp-card cp-mb-md">
        <div style="display:flex;align-items:flex-end;gap:12px;flex-wrap:wrap;">
            <div style="flex:1;min-width:180px;">
                <label class="cp-label">Search</label>
                <div class="cp-search-wrap">
                    <span class="cp-search-icon" aria-hidden="true">&#x1F50D;</span>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="cp-input"
                        placeholder="Name or email…" MaxLength="100" />
                </div>
            </div>
            <div style="min-width:130px;">
                <label class="cp-label">Role</label>
                <asp:DropDownList ID="ddlRole" runat="server" CssClass="cp-select">
                    <asp:ListItem Value="">All Roles</asp:ListItem>
                    <asp:ListItem Value="Student">Student</asp:ListItem>
                    <asp:ListItem Value="Instructor">Instructor</asp:ListItem>
                    <asp:ListItem Value="Admin">Admin</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div style="min-width:130px;">
                <label class="cp-label">Status</label>
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="cp-select">
                    <asp:ListItem Value="">All Statuses</asp:ListItem>
                    <asp:ListItem Value="active">Active</asp:ListItem>
                    <asp:ListItem Value="banned">Banned</asp:ListItem>
                    <asp:ListItem Value="inactive">Inactive</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div>
                <asp:Button ID="btnSearch" runat="server" Text="Search"
                    CssClass="cp-btn cp-btn-primary" OnClick="btnSearch_Click" />
                <asp:Button ID="btnClear" runat="server" Text="Clear"
                    CssClass="cp-btn cp-btn-ghost" style="margin-left:6px;"
                    OnClick="btnClear_Click" />
            </div>
        </div>
    </div>

    <%-- Results count --%>
    <div style="font-size:13px;color:var(--cp-text-muted);margin-bottom:10px;">
        Showing <strong><asp:Literal ID="litResultCount" runat="server" Text="0" /></strong> user(s)
    </div>

    <%-- Users table --%>
    <asp:Panel ID="pnlUsers" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table" role="table" aria-label="Users list">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Status</th>
                        <th>Joined</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td style="font-weight:600;">
                                    <%# HttpUtility.HtmlEncode(Eval("FullName").ToString()) %>
                                </td>
                                <td style="color:var(--cp-text-muted);font-size:12px;">
                                    <%# HttpUtility.HtmlEncode(Eval("Email").ToString()) %>
                                </td>
                                <td>
                                    <%# GetRoleBadge(Eval("Role").ToString()) %>
                                </td>
                                <td>
                                    <%# GetStatusBadge(Convert.ToBoolean(Eval("IsActive")), Convert.ToBoolean(Eval("IsBanned"))) %>
                                </td>
                                <td style="color:var(--cp-text-muted);font-size:12px;">
                                    <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %>
                                </td>
                                <td>
                                    <div style="display:flex;gap:4px;flex-wrap:wrap;">
                                        <%-- Ban / Unban --%>
                                        <asp:LinkButton runat="server"
                                            Visible='<%# !Convert.ToBoolean(Eval("IsBanned")) && !IsSelf(Eval("UserID")) %>'
                                            CommandName="Ban"
                                            CommandArgument='<%# Eval("UserID") %>'
                                            CssClass="cp-btn cp-btn-sm cp-btn-danger"
                                            OnClientClick="return confirm('Ban this user? They will not be able to log in.');">
                                            Ban
                                        </asp:LinkButton>
                                        <asp:LinkButton runat="server"
                                            Visible='<%# Convert.ToBoolean(Eval("IsBanned")) && !IsSelf(Eval("UserID")) %>'
                                            CommandName="Unban"
                                            CommandArgument='<%# Eval("UserID") %>'
                                            CssClass="cp-btn cp-btn-sm cp-btn-success">
                                            Unban
                                        </asp:LinkButton>
                                        <%-- Activate / Deactivate --%>
                                        <asp:LinkButton runat="server"
                                            Visible='<%# Convert.ToBoolean(Eval("IsActive")) && !Convert.ToBoolean(Eval("IsBanned")) && !IsSelf(Eval("UserID")) %>'
                                            CommandName="Deactivate"
                                            CommandArgument='<%# Eval("UserID") %>'
                                            CssClass="cp-btn cp-btn-sm cp-btn-ghost"
                                            OnClientClick="return confirm('Deactivate this user?');">
                                            Deactivate
                                        </asp:LinkButton>
                                        <asp:LinkButton runat="server"
                                            Visible='<%# !Convert.ToBoolean(Eval("IsActive")) && !IsSelf(Eval("UserID")) %>'
                                            CommandName="Activate"
                                            CommandArgument='<%# Eval("UserID") %>'
                                            CssClass="cp-btn cp-btn-sm cp-btn-outline">
                                            Activate
                                        </asp:LinkButton>
                                        <%-- Self label --%>
                                        <%# IsSelf(Eval("UserID")) ? "<span style='font-size:11px;color:var(--cp-text-muted);'>You</span>" : "" %>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlNoUsers" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F465;</span>
            <h3>No users found</h3>
            <p>Try adjusting your search or filter criteria.</p>
        </div>
    </asp:Panel>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
</asp:Content>
