<%@ Page Title="My Profile" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Profile.aspx.cs"
    Inherits="CloudPhoria.Admin.Profile" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>My Profile</h2>
                <p>View and update your admin account details.</p>
            </div>
        </div>
    </div>

    <%-- Feedback --%>
    <asp:Panel ID="pnlMessage" runat="server" Visible="false" style="margin-bottom:16px;">
        <asp:Literal ID="litMessage" runat="server" />
    </asp:Panel>

    <div class="cp-grid-2" style="align-items:start;gap:20px;">

        <%-- Left: Profile summary card --%>
        <div>
            <div class="cp-card" style="text-align:center;padding:32px 24px;">
                <%-- Avatar --%>
                <div style="width:72px;height:72px;border-radius:50%;
                            background:linear-gradient(135deg,var(--cp-indigo),var(--cp-primary));
                            display:flex;align-items:center;justify-content:center;
                            font-size:26px;font-weight:700;color:#fff;
                            margin:0 auto 16px;border:3px solid var(--cp-border);">
                    <asp:Literal ID="litInitials" runat="server" />
                </div>
                <div style="font-size:18px;font-weight:700;color:var(--cp-text);">
                    <asp:Literal ID="litFullName" runat="server" />
                </div>
                <div style="margin-top:8px;">
                    <span class="cp-badge cp-badge-red" style="font-size:12px;padding:4px 12px;">
                        Administrator
                    </span>
                </div>
                <div style="font-size:13px;color:var(--cp-text-muted);margin-top:12px;">
                    <asp:Literal ID="litEmail" runat="server" />
                </div>
                <div style="font-size:12px;color:var(--cp-text-muted);margin-top:6px;">
                    Member since <asp:Literal ID="litJoined" runat="server" />
                </div>
            </div>

            <%-- Quick stats --%>
            <div class="cp-card cp-mt-md">
                <h3 style="font-size:14px;font-weight:600;margin:0 0 12px;">
                    Platform Activity
                </h3>
                <div style="display:flex;flex-direction:column;gap:10px;">
                    <div style="display:flex;justify-content:space-between;align-items:center;">
                        <span style="font-size:13px;color:var(--cp-text-muted);">Actions Logged</span>
                        <span style="font-weight:600;"><asp:Literal ID="litActionsCount" runat="server" Text="0" /></span>
                    </div>
                    <div style="display:flex;justify-content:space-between;align-items:center;">
                        <span style="font-size:13px;color:var(--cp-text-muted);">Instructors Approved</span>
                        <span style="font-weight:600;"><asp:Literal ID="litApprovedCount" runat="server" Text="0" /></span>
                    </div>
                    <div style="display:flex;justify-content:space-between;align-items:center;">
                        <span style="font-size:13px;color:var(--cp-text-muted);">Reports Reviewed</span>
                        <span style="font-weight:600;"><asp:Literal ID="litReportsReviewed" runat="server" Text="0" /></span>
                    </div>
                    <div style="display:flex;justify-content:space-between;align-items:center;">
                        <span style="font-size:13px;color:var(--cp-text-muted);">Boss Fights Created</span>
                        <span style="font-weight:600;"><asp:Literal ID="litBossCreated" runat="server" Text="0" /></span>
                    </div>
                </div>
            </div>
        </div>

        <%-- Right: Edit form --%>
        <div>
            <div class="cp-card">
                <h3 style="font-size:15px;font-weight:700;margin:0 0 18px;">Update Details</h3>

                <div class="cp-form-group">
                    <label class="cp-label">Full Name <span class="required">*</span></label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="cp-input"
                        MaxLength="100" />
                    <asp:RequiredFieldValidator ID="rfvName" runat="server"
                        ControlToValidate="txtFullName" ValidationGroup="Profile"
                        CssClass="cp-form-error" ErrorMessage="Full name is required." Display="Dynamic" />
                </div>

                <div class="cp-form-group">
                    <label class="cp-label">Email Address <span class="required">*</span></label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="cp-input"
                        TextMode="Email" MaxLength="100" />
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                        ControlToValidate="txtEmail" ValidationGroup="Profile"
                        CssClass="cp-form-error" ErrorMessage="Email is required." Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server"
                        ControlToValidate="txtEmail" ValidationGroup="Profile"
                        ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                        CssClass="cp-form-error" ErrorMessage="Enter a valid email address." Display="Dynamic" />
                </div>

                <div style="margin-bottom:16px;">
                    <asp:Button ID="btnUpdate" runat="server" Text="Save Changes"
                        CssClass="cp-btn cp-btn-primary" ValidationGroup="Profile"
                        OnClick="btnUpdate_Click" />
                </div>
            </div>

            <%-- Change password --%>
            <div class="cp-card cp-mt-md">
                <h3 style="font-size:15px;font-weight:700;margin:0 0 18px;">Change Password</h3>

                <div class="cp-form-group">
                    <label class="cp-label">Current Password <span class="required">*</span></label>
                    <asp:TextBox ID="txtCurrentPwd" runat="server" CssClass="cp-input"
                        TextMode="Password" MaxLength="100" />
                    <asp:RequiredFieldValidator ID="rfvCurrentPwd" runat="server"
                        ControlToValidate="txtCurrentPwd" ValidationGroup="Password"
                        CssClass="cp-form-error" ErrorMessage="Current password is required." Display="Dynamic" />
                </div>

                <div class="cp-form-group">
                    <label class="cp-label">New Password <span class="required">*</span></label>
                    <asp:TextBox ID="txtNewPwd" runat="server" CssClass="cp-input"
                        TextMode="Password" MaxLength="100" />
                    <asp:RequiredFieldValidator ID="rfvNewPwd" runat="server"
                        ControlToValidate="txtNewPwd" ValidationGroup="Password"
                        CssClass="cp-form-error" ErrorMessage="New password is required." Display="Dynamic" />
                    <div class="cp-form-hint">Minimum 8 characters.</div>
                </div>

                <div class="cp-form-group">
                    <label class="cp-label">Confirm New Password <span class="required">*</span></label>
                    <asp:TextBox ID="txtConfirmPwd" runat="server" CssClass="cp-input"
                        TextMode="Password" MaxLength="100" />
                    <asp:RequiredFieldValidator ID="rfvConfirmPwd" runat="server"
                        ControlToValidate="txtConfirmPwd" ValidationGroup="Password"
                        CssClass="cp-form-error" ErrorMessage="Please confirm your new password." Display="Dynamic" />
                    <asp:CompareValidator ID="cvPasswords" runat="server"
                        ControlToValidate="txtConfirmPwd"
                        ControlToCompare="txtNewPwd"
                        ValidationGroup="Password"
                        CssClass="cp-form-error" ErrorMessage="Passwords do not match." Display="Dynamic" />
                </div>

                <asp:Button ID="btnChangePassword" runat="server" Text="Change Password"
                    CssClass="cp-btn cp-btn-secondary" ValidationGroup="Password"
                    OnClick="btnChangePassword_Click" />
            </div>
        </div>

    </div>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
</asp:Content>
