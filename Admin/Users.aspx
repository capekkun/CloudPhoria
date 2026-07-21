<%@ Page Title="Manage Users" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Users.aspx.cs"
    Inherits="CloudPhoria.Admin.Users" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.ad-badge-banned{background:rgba(239,68,68,0.12);color:#DC2626;padding:3px 10px;border-radius:12px;font-size:11px;font-weight:600;}
.ad-badge-inactive{background:rgba(148,163,184,0.15);color:#64748B;padding:3px 10px;border-radius:12px;font-size:11px;font-weight:600;}
.ad-badge-active{background:rgba(34,197,94,0.12);color:#16A34A;padding:3px 10px;border-radius:12px;font-size:11px;font-weight:600;}
.ad-row-actions{display:flex;gap:6px;flex-wrap:wrap;}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

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

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
<script>
function showModal(id) { document.getElementById(id).classList.add('open'); document.body.style.overflow='hidden'; }
function hideModal(id) { document.getElementById(id).classList.remove('open'); document.body.style.overflow=''; }
document.querySelectorAll('.cp-modal-backdrop').forEach(function(el){
    el.addEventListener('click', function(e){ if (e.target === el) hideModal(el.id); });
});
</script>
</asp:Content>
