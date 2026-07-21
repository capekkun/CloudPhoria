<%@ Page Title="Profile" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Profile.aspx.cs"
    Inherits="CloudPhoria.Instructor.Profile" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x1F464; My Profile</h2>
                <p>View and update your instructor account information.</p>
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
        <div class="cp-alert cp-alert-success"><span>&#x2714;</span>
            <asp:Literal ID="litSuccess" runat="server" /></div>
    </asp:Panel>
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger"><span>&#x26A0;</span>
            <asp:Literal ID="litError" runat="server" /></div>
    </asp:Panel>

    <div class="cp-grid-2" style="align-items:start;">

        <%-- Left: account summary card --%>
        <div>
            <div class="cp-card" style="text-align:center;padding:32px 24px;">
                <div style="width:72px;height:72px;border-radius:50%;
                            background:linear-gradient(135deg,var(--cp-indigo),var(--cp-primary));
                            display:flex;align-items:center;justify-content:center;
                            font-size:26px;font-weight:800;color:#fff;
                            margin:0 auto 16px;">
                    <asp:Literal ID="litInitials" runat="server" />
                </div>
                <div style="font-size:18px;font-weight:700;color:var(--cp-text);">
                    <asp:Literal ID="litFullName" runat="server" />
                </div>
                <div style="font-size:13px;color:var(--cp-text-muted);margin-top:4px;">
                    <asp:Literal ID="litEmail" runat="server" />
                </div>
                <div style="margin-top:12px;">
                    <asp:Literal ID="litLicenseBadge" runat="server" />
                </div>
            </div>

            <%-- Licence info --%>
            <div class="cp-card" style="margin-top:0;">
                <h3 style="font-size:14px;font-weight:600;margin:0 0 12px;">Licence Information</h3>
                <div style="display:flex;flex-direction:column;gap:8px;font-size:13px;">
                    <div class="cp-flex-between">
                        <span style="color:var(--cp-text-muted);">Qualification</span>
                        <span style="font-weight:500;"><asp:Literal ID="litQualification" runat="server" Text="—" /></span>
                    </div>
                    <div class="cp-flex-between">
                        <span style="color:var(--cp-text-muted);">Licence Status</span>
                        <asp:Literal ID="litLicenseStatus" runat="server" />
                    </div>
                    <div class="cp-flex-between">
                        <span style="color:var(--cp-text-muted);">Approved At</span>
                        <span><asp:Literal ID="litApprovedAt" runat="server" Text="—" /></span>
                    </div>
                    <div class="cp-flex-between">
                        <span style="color:var(--cp-text-muted);">Member Since</span>
                        <span><asp:Literal ID="litMemberSince" runat="server" /></span>
                    </div>
                </div>
            </div>
        </div>

        <%-- Right: edit form --%>
        <div>
            <div class="cp-card">
                <h3 style="font-size:15px;font-weight:600;margin:0 0 16px;">Edit Profile</h3>

                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtFullName.ClientID %>">
                        Full Name <span class="required">*</span>
                    </label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="cp-input" MaxLength="100" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtFullName"
                        Display="Dynamic" CssClass="cp-form-error"
                        ValidationGroup="EditProfile" ErrorMessage="Full name is required." />
                </div>

                <div class="cp-form-group">
                    <label class="cp-label">Email</label>
                    <asp:Literal ID="litEmailReadonly" runat="server" />
                    <div class="cp-form-hint">Email cannot be changed here. Contact an administrator.</div>
                </div>

                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtQualification.ClientID %>">Qualification</label>
                    <asp:TextBox ID="txtQualification" runat="server" CssClass="cp-input"
                                 MaxLength="100" placeholder="e.g. MSc Cloud Computing" />
                </div>

                <asp:Button ID="btnSaveProfile" runat="server" Text="Save Changes"
                            CssClass="cp-btn cp-btn-primary"
                            ValidationGroup="EditProfile"
                            OnClick="btnSaveProfile_Click" />
            </div>

            <%-- Change password --%>
            <div class="cp-card" style="margin-top:0;">
                <h3 style="font-size:15px;font-weight:600;margin:0 0 16px;">Change Password</h3>

                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtCurrentPassword.ClientID %>">
                        Current Password <span class="required">*</span>
                    </label>
                    <asp:TextBox ID="txtCurrentPassword" runat="server" CssClass="cp-input"
                                 TextMode="Password" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtCurrentPassword"
                        Display="Dynamic" CssClass="cp-form-error"
                        ValidationGroup="ChangePwd" ErrorMessage="Current password is required." />
                </div>

                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtNewPassword.ClientID %>">
                        New Password <span class="required">*</span>
                    </label>
                    <asp:TextBox ID="txtNewPassword" runat="server" CssClass="cp-input"
                                 TextMode="Password" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtNewPassword"
                        Display="Dynamic" CssClass="cp-form-error"
                        ValidationGroup="ChangePwd" ErrorMessage="New password is required." />
                </div>

                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtConfirmPassword.ClientID %>">
                        Confirm New Password <span class="required">*</span>
                    </label>
                    <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="cp-input"
                                 TextMode="Password" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtConfirmPassword"
                        Display="Dynamic" CssClass="cp-form-error"
                        ValidationGroup="ChangePwd" ErrorMessage="Please confirm your new password." />
                    <asp:CompareValidator runat="server"
                        ControlToValidate="txtConfirmPassword"
                        ControlToCompare="txtNewPassword"
                        Display="Dynamic" CssClass="cp-form-error"
                        ValidationGroup="ChangePwd"
                        ErrorMessage="Passwords do not match." />
                </div>

                <asp:Button ID="btnChangePassword" runat="server" Text="Change Password"
                            CssClass="cp-btn cp-btn-secondary"
                            ValidationGroup="ChangePwd"
                            OnClick="btnChangePassword_Click" />
            </div>
        </div>

    </div>

    <%-- Report an Issue --%>
    <div class="cp-card" style="margin-top:0;">
        <h3 style="font-size:15px;font-weight:600;margin:0 0 8px;">&#x26A0; Report an Issue</h3>
        <p style="font-size:13px;color:var(--cp-text-muted);margin:0 0 16px;">
            Report a student, classroom content, or a platform bug. Admin will review it.
        </p>

        <asp:Panel ID="pnlReportSuccess" runat="server" Visible="false">
            <div class="cp-alert cp-alert-success"><span>&#x2714;</span>
                <asp:Literal ID="litReportSuccess" runat="server" /></div>
        </asp:Panel>
        <asp:Panel ID="pnlReportError" runat="server" Visible="false">
            <div class="cp-alert cp-alert-danger"><span>&#x26A0;</span>
                <asp:Literal ID="litReportError" runat="server" /></div>
        </asp:Panel>

        <div class="cp-form-group">
            <label class="cp-label" for="<%= ddlReportType.ClientID %>">What are you reporting?</label>
            <asp:DropDownList ID="ddlReportType" runat="server" CssClass="cp-select">
                <asp:ListItem Text="A student (cheating, abuse, etc.)" Value="User" />
                <asp:ListItem Text="Classroom content" Value="Classroom" />
                <asp:ListItem Text="A challenge or boss fight" Value="Challenge" />
                <asp:ListItem Text="Something else / a bug" Value="Other" />
            </asp:DropDownList>
        </div>

        <div class="cp-form-group">
            <label class="cp-label" for="<%= txtReportReason.ClientID %>">Details <span class="required">*</span></label>
            <asp:TextBox ID="txtReportReason" runat="server" CssClass="cp-textarea"
                         TextMode="MultiLine" Rows="4" MaxLength="1000"
                         placeholder="Describe what happened..." />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtReportReason"
                Display="Dynamic" CssClass="cp-form-error"
                ValidationGroup="Report" ErrorMessage="Please describe the issue before submitting." />
        </div>

        <asp:Button ID="btnSubmitReport" runat="server" Text="Submit Report"
                    CssClass="cp-btn cp-btn-danger"
                    ValidationGroup="Report"
                    OnClick="btnSubmitReport_Click" />
    </div>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
</asp:Content>
