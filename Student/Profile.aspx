<%@ Page Title="Profile" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Profile.aspx.cs"
    Inherits="CloudPhoria.Student.Profile" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <h2>My Profile</h2>
        <p>Your account information and learning statistics.</p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <div class="cp-grid-2">

        <%-- Account info --%>
        <div class="cp-card">
            <h3 class="cp-card-title">Account Information</h3>
            <div style="display:flex;align-items:center;gap:16px;margin-bottom:20px;">
                <div style="width:60px;height:60px;border-radius:50%;
                            background:linear-gradient(135deg,var(--cp-indigo),var(--cp-primary));
                            display:flex;align-items:center;justify-content:center;
                            font-size:20px;font-weight:700;color:#fff;">
                    <asp:Literal ID="litInitials" runat="server" />
                </div>
                <div>
                    <div style="font-size:16px;font-weight:700;color:var(--cp-text);">
                        <asp:Literal ID="litFullName" runat="server" />
                    </div>
                    <div style="font-size:13px;color:var(--cp-text-muted);margin-top:2px;">
                        <asp:Literal ID="litEmail" runat="server" />
                    </div>
                </div>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
                <div>
                    <div style="font-size:11px;color:var(--cp-text-muted);text-transform:uppercase;
                                letter-spacing:0.05em;margin-bottom:4px;">TP Number</div>
                    <div style="font-size:14px;font-weight:600;color:var(--cp-text);">
                        <asp:Literal ID="litTPNumber" runat="server" Text="—" />
                    </div>
                </div>
                <div>
                    <div style="font-size:11px;color:var(--cp-text-muted);text-transform:uppercase;
                                letter-spacing:0.05em;margin-bottom:4px;">Role</div>
                    <div style="font-size:14px;font-weight:600;color:var(--cp-text);">
                        <span class="cp-badge cp-badge-blue">Student</span>
                    </div>
                </div>
                <div>
                    <div style="font-size:11px;color:var(--cp-text-muted);text-transform:uppercase;
                                letter-spacing:0.05em;margin-bottom:4px;">Account Created</div>
                    <div style="font-size:14px;color:var(--cp-text);">
                        <asp:Literal ID="litCreatedAt" runat="server" Text="—" />
                    </div>
                </div>
                <div>
                    <div style="font-size:11px;color:var(--cp-text-muted);text-transform:uppercase;
                                letter-spacing:0.05em;margin-bottom:4px;">Subscription</div>
                    <div style="font-size:14px;color:var(--cp-text);">
                        <asp:Literal ID="litPlan" runat="server" Text="—" />
                    </div>
                </div>
            </div>
        </div>

        <%-- Stats summary --%>
        <div class="cp-card">
            <h3 class="cp-card-title">Learning Stats</h3>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-top:12px;">
                <div style="text-align:center;">
                    <div style="font-size:28px;font-weight:800;color:var(--cp-warning);">
                        <asp:Literal ID="litXP" runat="server" Text="0" />
                    </div>
                    <div style="font-size:12px;color:var(--cp-text-muted);margin-top:4px;">Total XP</div>
                </div>
                <div style="text-align:center;">
                    <div style="font-size:28px;font-weight:800;color:var(--cp-primary);">
                        <asp:Literal ID="litModules" runat="server" Text="0" />
                    </div>
                    <div style="font-size:12px;color:var(--cp-text-muted);margin-top:4px;">Modules Done</div>
                </div>
                <div style="text-align:center;">
                    <div style="font-size:28px;font-weight:800;color:var(--cp-success);">
                        <asp:Literal ID="litBadges" runat="server" Text="0" />
                    </div>
                    <div style="font-size:12px;color:var(--cp-text-muted);margin-top:4px;">Badges</div>
                </div>
                <div style="text-align:center;">
                    <div style="font-size:28px;font-weight:800;color:var(--cp-indigo);">
                        <asp:Literal ID="litCerts" runat="server" Text="0" />
                    </div>
                    <div style="font-size:12px;color:var(--cp-text-muted);margin-top:4px;">Certifications</div>
                </div>
            </div>
        </div>

    </div>

    <%-- Report an Issue --%>
    <div class="cp-card cp-mb-md" style="margin-top:16px;">
        <h3 class="cp-card-title">&#x26A0; Report an Issue</h3>
        <p style="font-size:13px;color:var(--cp-text-muted);margin:0 0 16px;">
            Report inappropriate content, a bug, or a policy violation. Admin will review it.
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
                <asp:ListItem Text="A user (harassment, cheating, etc.)" Value="User" />
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
