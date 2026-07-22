<%@ Page Title="Manage Users" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Users.aspx.cs"
    Inherits="CloudPhoria.Admin.Users" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<<<<<<< HEAD
=======
<style>
.ad-badge-banned{background:rgba(239,68,68,0.12);color:#DC2626;padding:3px 10px;border-radius:12px;font-size:11px;font-weight:600;}
.ad-badge-inactive{background:rgba(148,163,184,0.15);color:#64748B;padding:3px 10px;border-radius:12px;font-size:11px;font-weight:600;}
.ad-badge-active{background:rgba(34,197,94,0.12);color:#16A34A;padding:3px 10px;border-radius:12px;font-size:11px;font-weight:600;}
.ad-row-actions{display:flex;gap:6px;flex-wrap:wrap;}
</style>
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<<<<<<< HEAD
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
=======
<div class="cp-page-header">
    <div class="cp-page-header-row">
        <div>
            <h2>&#x1F465; Manage Users</h2>
            <p>Create, edit, ban, deactivate, or delete Student, Instructor, and Admin accounts.</p>
        </div>
        <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('createUserModal')">+ New User</button>
    </div>
</div>

<asp:Panel ID="pnlSuccess" runat="server" Visible="false">
    <div class="cp-alert cp-alert-success cp-mb-md"><asp:Literal ID="litSuccess" runat="server" /></div>
</asp:Panel>
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="cp-alert cp-alert-danger cp-mb-md"><asp:Literal ID="litError" runat="server" /></div>
</asp:Panel>

<div class="ad-inline-form cp-mb-md">
    <asp:TextBox ID="txtSearch" runat="server" CssClass="cp-input" placeholder="Search by name or email..." style="max-width:280px;" />
    <asp:DropDownList ID="ddlRoleFilter" runat="server" CssClass="cp-select" AutoPostBack="true" OnSelectedIndexChanged="ddlRoleFilter_Changed">
        <asp:ListItem Value="" Text="All Roles" />
        <asp:ListItem Value="Student" Text="Student" />
        <asp:ListItem Value="Instructor" Text="Instructor" />
        <asp:ListItem Value="Admin" Text="Admin" />
    </asp:DropDownList>
    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="cp-btn cp-btn-outline" OnClick="btnSearch_Click" />
</div>

<div class="cp-table-wrap">
    <table class="cp-table">
        <thead>
            <tr><th>Name</th><th>Email</th><th>Role</th><th>Status</th><th>Joined</th><th>Actions</th></tr>
        </thead>
        <tbody>
            <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                <ItemTemplate>
                    <tr>
                        <td><%# HttpUtility.HtmlEncode(Eval("FullName").ToString()) %></td>
                        <td><%# HttpUtility.HtmlEncode(Eval("Email").ToString()) %></td>
                        <td><span class="cp-badge cp-badge-indigo"><%# HttpUtility.HtmlEncode(Eval("Role").ToString()) %></span></td>
                        <td>
                            <%# Convert.ToBoolean(Eval("IsBanned")) ? "<span class='ad-badge-banned'>Banned</span>"
                                : !Convert.ToBoolean(Eval("IsActive")) ? "<span class='ad-badge-inactive'>Inactive</span>"
                                : "<span class='ad-badge-active'>Active</span>" %>
                        </td>
                        <td style="font-size:12px;color:var(--cp-text-muted);"><%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %></td>
                        <td>
                            <div class="ad-row-actions">
                                <asp:LinkButton runat="server" CommandName="ToggleBan" CommandArgument='<%# Eval("UserID") %>'
                                    CssClass="cp-btn cp-btn-outline cp-btn-sm"
                                    OnClientClick='<%# "return confirm(\"" + (Convert.ToBoolean(Eval("IsBanned")) ? "Unban" : "Ban") + " this user?\");" %>'>
                                    <%# Convert.ToBoolean(Eval("IsBanned")) ? "Unban" : "Ban" %>
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="ToggleActive" CommandArgument='<%# Eval("UserID") %>'
                                    CssClass="cp-btn cp-btn-outline cp-btn-sm">
                                    <%# Convert.ToBoolean(Eval("IsActive")) ? "Deactivate" : "Activate" %>
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="DeleteUser" CommandArgument='<%# Eval("UserID") %>'
                                    CssClass="cp-btn cp-btn-danger cp-btn-sm"
                                    OnClientClick="return confirm('Delete this user permanently? This cannot be undone.');">
                                    Delete
                                </asp:LinkButton>
                            </div>
                        </td>
                    </tr>
                </ItemTemplate>
            </asp:Repeater>
        </tbody>
    </table>
</div>

<%-- ===================== CREATE USER MODAL ===================== --%>
<div id="createUserModal" class="cp-modal-backdrop" role="dialog" aria-modal="true">
    <div class="cp-modal">
        <button class="cp-modal-close" type="button" onclick="hideModal('createUserModal')" aria-label="Close">&#x2715;</button>
        <h2 class="cp-modal-title">Create New User</h2>

        <div class="cp-form-group">
            <label class="cp-label">Role <span class="required">*</span></label>
            <asp:DropDownList ID="ddlNewUserRole" runat="server" CssClass="cp-select">
                <asp:ListItem Value="Student" Text="Student" />
                <asp:ListItem Value="Instructor" Text="Instructor" />
                <asp:ListItem Value="Admin" Text="Admin" />
            </asp:DropDownList>
        </div>
        <div class="cp-form-group">
            <label class="cp-label">Full Name <span class="required">*</span></label>
            <asp:TextBox ID="txtNewUserName" runat="server" CssClass="cp-input" MaxLength="100" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtNewUserName" Display="Dynamic"
                CssClass="cp-form-error" ValidationGroup="NewUser" ErrorMessage="Full name is required." />
        </div>
        <div class="cp-form-group">
            <label class="cp-label">Email <span class="required">*</span></label>
            <asp:TextBox ID="txtNewUserEmail" runat="server" CssClass="cp-input" TextMode="Email" MaxLength="100" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtNewUserEmail" Display="Dynamic"
                CssClass="cp-form-error" ValidationGroup="NewUser" ErrorMessage="Email is required." />
        </div>
        <div class="cp-form-group">
            <label class="cp-label">Temporary Password <span class="required">*</span></label>
            <asp:TextBox ID="txtNewUserPassword" runat="server" CssClass="cp-input" TextMode="Password" MaxLength="256" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtNewUserPassword" Display="Dynamic"
                CssClass="cp-form-error" ValidationGroup="NewUser" ErrorMessage="Password is required." />
        </div>
        <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:12px;">
            <button type="button" class="cp-btn cp-btn-ghost" onclick="hideModal('createUserModal')">Cancel</button>
            <asp:Button ID="btnCreateUser" runat="server" Text="Create User" CssClass="cp-btn cp-btn-primary"
                ValidationGroup="NewUser" OnClick="btnCreateUser_Click" />
        </div>
    </div>
</div>
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
<<<<<<< HEAD
=======
<script>
function showModal(id) { document.getElementById(id).classList.add('open'); document.body.style.overflow='hidden'; }
function hideModal(id) { document.getElementById(id).classList.remove('open'); document.body.style.overflow=''; }
document.querySelectorAll('.cp-modal-backdrop').forEach(function(el){
    el.addEventListener('click', function(e){ if (e.target === el) hideModal(el.id); });
});
</script>
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
</asp:Content>
