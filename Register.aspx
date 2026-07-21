<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="CloudPhoria.Register" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Join CloudPhoria</title>
    <link href="Content/bootstrap.css" rel="stylesheet" type="text/css" />
    <link href="Content/Site.css" rel="stylesheet" type="text/css" />
    <style>
        html, body { height:100%; margin:0; padding:0; background:#0F172A;
            font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Arial,sans-serif; }
        .cp-reg-wrapper { min-height:100vh; display:flex; align-items:center; justify-content:center;
            padding:24px 16px; background:linear-gradient(135deg,#0F172A 0%,#172033 60%,#0F172A 100%); }
        .cp-reg-box { background:#fff; border-radius:18px; box-shadow:0 20px 60px rgba(0,0,0,0.35);
            width:100%; max-width:520px; overflow:hidden; }
        .cp-reg-accent { height:4px; background:linear-gradient(90deg,#0EA5E9,#6366F1); }
        .cp-reg-body { padding:36px 36px 32px; }
        .cp-reg-brand { display:flex; align-items:center; gap:10px; margin-bottom:24px; text-decoration:none; }
        .cp-reg-logo { width:38px; height:38px; background:linear-gradient(135deg,#0EA5E9,#6366F1);
            border-radius:10px; display:flex; align-items:center; justify-content:center;
            font-size:16px; font-weight:800; color:#fff; }
        .cp-reg-heading { font-size:22px; font-weight:700; color:#172033; margin:0 0 4px; }
        .cp-reg-sub { font-size:14px; color:#64748B; margin:0 0 24px; }
        .cp-reg-field { margin-bottom:16px; }
        .cp-reg-label { display:block; font-size:13px; font-weight:500; color:#172033; margin-bottom:5px; }
        .cp-reg-input { display:block; width:100%; padding:10px 14px; font-size:14px; color:#172033;
            background:#F4F7FB; border:1.5px solid #E2E8F0; border-radius:9px;
            transition:border-color 0.15s; font-family:inherit; box-sizing:border-box; }
        .cp-reg-input:focus { outline:none; border-color:#0EA5E9; background:#fff;
            box-shadow:0 0 0 3px rgba(14,165,233,0.12); }
        .cp-reg-select { display:block; width:100%; padding:10px 14px; font-size:14px;
            background:#F4F7FB; border:1.5px solid #E2E8F0; border-radius:9px; font-family:inherit; box-sizing:border-box; }
        .cp-reg-btn { display:block; width:100%; padding:12px; background:#0EA5E9; color:#fff;
            border:none; border-radius:9px; font-size:15px; font-weight:600; cursor:pointer;
            transition:background 0.15s; font-family:inherit; margin-top:8px; }
        .cp-reg-btn:hover { background:#0284C7; }
        .cp-reg-footer { text-align:center; margin-top:18px; font-size:13px; color:#64748B; }
        .cp-reg-footer a { color:#0EA5E9; text-decoration:none; font-weight:500; }
        .cp-reg-alert { background:rgba(239,68,68,0.08); border:1px solid rgba(239,68,68,0.25);
            border-radius:9px; padding:11px 14px; font-size:13px; color:#DC2626; margin-bottom:16px; }
        .cp-reg-alert-success { background:rgba(34,197,94,0.08); border-color:rgba(34,197,94,0.25); color:#16A34A; }
        .cp-reg-error { font-size:12px; color:#EF4444; margin-top:4px; display:block; }
        .cp-reg-note { font-size:12px; color:#64748B; margin-top:6px; font-style:italic; }
        .cp-reg-row { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
        #instructorFields { display:none; }
        @media(max-width:480px) { .cp-reg-body{padding:24px 20px;} .cp-reg-row{grid-template-columns:1fr;} }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="cp-reg-wrapper">
    <div class="cp-reg-box">
        <div class="cp-reg-accent"></div>
        <div class="cp-reg-body">

            <a class="cp-reg-brand" href="Default.aspx">
                <img src="Images/LogoCloudPhoriaBlack.png" alt="CloudPhoria" style="height:48px;width:auto;" onerror="this.style.display='none';this.nextElementSibling.style.display='flex';" />
                <div class="cp-reg-logo" style="display:none;">CP</div>
            </a>

            <h1 class="cp-reg-heading">Join CloudPhoria</h1>
            <p class="cp-reg-sub">Create your free account and start learning cloud computing</p>

            <asp:Panel ID="pnlError" runat="server" Visible="false">
                <div class="cp-reg-alert"><asp:Literal ID="litError" runat="server" /></div>
            </asp:Panel>
            <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
                <div class="cp-reg-alert cp-reg-alert-success"><asp:Literal ID="litSuccess" runat="server" /></div>
            </asp:Panel>

            <asp:Panel ID="pnlForm" runat="server">

            <div class="cp-reg-field">
                <label class="cp-reg-label">Full Name <span style="color:#EF4444;">*</span></label>
                <asp:TextBox ID="txtFullName" runat="server" CssClass="cp-reg-input"
                    placeholder="Your full name" MaxLength="100" />
                <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtFullName"
                    CssClass="cp-reg-error" ErrorMessage="Name is required." Display="Dynamic" />
            </div>

            <div class="cp-reg-field">
                <label class="cp-reg-label">Email Address <span style="color:#EF4444;">*</span></label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="cp-reg-input" TextMode="Email"
                    placeholder="you@example.com" MaxLength="100" />
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                    CssClass="cp-reg-error" ErrorMessage="Email is required." Display="Dynamic" />
            </div>

            <div class="cp-reg-row">
                <div class="cp-reg-field">
                    <label class="cp-reg-label">Password <span style="color:#EF4444;">*</span></label>
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="cp-reg-input" TextMode="Password"
                        placeholder="Min 6 characters" MaxLength="256" />
                    <asp:RequiredFieldValidator ID="rfvPass" runat="server" ControlToValidate="txtPassword"
                        CssClass="cp-reg-error" ErrorMessage="Password is required." Display="Dynamic" />
                </div>
                <div class="cp-reg-field">
                    <label class="cp-reg-label">Confirm Password <span style="color:#EF4444;">*</span></label>
                    <asp:TextBox ID="txtConfirm" runat="server" CssClass="cp-reg-input" TextMode="Password"
                        placeholder="Repeat password" MaxLength="256" />
                    <asp:CompareValidator ID="cvPass" runat="server" ControlToValidate="txtConfirm"
                        ControlToCompare="txtPassword" CssClass="cp-reg-error"
                        ErrorMessage="Passwords do not match." Display="Dynamic" />
                </div>
            </div>

            <div class="cp-reg-field">
                <label class="cp-reg-label">I want to join as <span style="color:#EF4444;">*</span></label>
                <asp:DropDownList ID="ddlRole" runat="server" CssClass="cp-reg-select"
                    onchange="toggleInstructorFields(this);">
                    <asp:ListItem Value="Student" Text="Student — I want to learn" />
                    <asp:ListItem Value="Instructor" Text="Instructor — I want to teach" />
                </asp:DropDownList>
            </div>

            <%-- Instructor-specific fields --%>
            <div id="instructorFields">
                <div class="cp-reg-field">
                    <label class="cp-reg-label">Qualification / Specialisation <span style="color:#EF4444;">*</span></label>
                    <asp:TextBox ID="txtQualification" runat="server" CssClass="cp-reg-input"
                        placeholder="e.g. BSc Computer Science, AWS Certified" MaxLength="200" />
                    <p class="cp-reg-note">Describe your teaching qualification or cloud certification.</p>
                </div>
                <div class="cp-reg-field">
                    <label class="cp-reg-label">Teaching Permit / Certificate (describe) <span style="color:#EF4444;">*</span></label>
                    <asp:TextBox ID="txtPermit" runat="server" CssClass="cp-reg-input" TextMode="MultiLine"
                        Rows="3" placeholder="Describe your permit or attach a reference number. Admin will verify before approving your account." MaxLength="1000" />
                    <p class="cp-reg-note">Your account will be reviewed by admin. You cannot create content until approved.</p>
                </div>
            </div>

            <%-- Student-specific field --%>
            <div class="cp-reg-field" id="studentFields">
                <label class="cp-reg-label">TP Number (optional)</label>
                <asp:TextBox ID="txtTPNumber" runat="server" CssClass="cp-reg-input"
                    placeholder="e.g. TP012345" MaxLength="20" />
            </div>

            <asp:Button ID="btnRegister" runat="server" Text="Create Account"
                CssClass="cp-reg-btn" OnClick="btnRegister_Click" />

            </asp:Panel>

            <div class="cp-reg-footer">
                Already have an account? <a href="LogIn.aspx">Sign In</a>
            </div>

        </div>
    </div>
</div>
</form>

<script>
function toggleInstructorFields(sel) {
    var instFields = document.getElementById('instructorFields');
    var stuFields = document.getElementById('studentFields');
    if (sel.value === 'Instructor') {
        instFields.style.display = 'block';
        stuFields.style.display = 'none';
    } else {
        instFields.style.display = 'none';
        stuFields.style.display = 'block';
    }
}
// Init on load
document.addEventListener('DOMContentLoaded', function() {
    var sel = document.getElementById('<%= ddlRole.ClientID %>');
    if (sel) toggleInstructorFields(sel);
});
</script>
</body>
</html>
