<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LogIn.aspx.cs" Inherits="CloudPhoria.LogIn" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Log In – CloudPhoria</title>
    <link href="Content/bootstrap.css" rel="stylesheet" type="text/css" />
    <link href="Content/Site.css"      rel="stylesheet" type="text/css" />
    <style>
        /* -------------------------------------------------------
           Login page layout
           ------------------------------------------------------- */
        html, body {
            height: 100%;
            margin: 0;
            padding: 0;
            background: #0F172A;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
        }

        .cp-login-wrapper {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px 16px;
            background: linear-gradient(135deg, #0F172A 0%, #172033 60%, #0F172A 100%);
        }

        .cp-login-box {
            background: #FFFFFF;
            border-radius: 18px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.35);
            width: 100%;
            max-width: 420px;
            overflow: hidden;
        }

        /* Top accent stripe */
        .cp-login-accent {
            height: 4px;
            background: linear-gradient(90deg, #0EA5E9 0%, #6366F1 100%);
        }

        .cp-login-body {
            padding: 40px 36px 36px;
        }

        /* Brand */
        .cp-login-brand {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 28px;
            text-decoration: none;
        }
        .cp-login-logo {
            width: 38px;
            height: 38px;
            background: linear-gradient(135deg, #0EA5E9, #6366F1);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            font-weight: 800;
            color: #fff;
            flex-shrink: 0;
        }
        .cp-login-wordmark {
            font-size: 20px;
            font-weight: 700;
            color: #172033;
            letter-spacing: -0.3px;
        }
        .cp-login-wordmark span { color: #0EA5E9; }

        /* Heading */
        .cp-login-heading {
            font-size: 22px;
            font-weight: 700;
            color: #172033;
            margin: 0 0 4px 0;
        }
        .cp-login-subheading {
            font-size: 14px;
            color: #64748B;
            margin: 0 0 28px 0;
        }

        /* Form fields */
        .cp-login-field {
            margin-bottom: 18px;
        }
        .cp-login-label {
            display: block;
            font-size: 13px;
            font-weight: 500;
            color: #172033;
            margin-bottom: 6px;
        }
        .cp-login-input {
            display: block;
            width: 100%;
            max-width: 100%;
            padding: 10px 14px;
            font-size: 14px;
            color: #172033;
            background: #F4F7FB;
            border: 1.5px solid #E2E8F0;
            border-radius: 9px;
            transition: border-color 0.15s, box-shadow 0.15s;
            font-family: inherit;
            box-sizing: border-box;
        }
        .cp-login-input:focus {
            outline: none;
            border-color: #0EA5E9;
            box-shadow: 0 0 0 3px rgba(14,165,233,0.12);
            background: #FFFFFF;
        }
        .cp-login-input.input-error {
            border-color: #EF4444;
        }
        .cp-login-input.input-error:focus {
            box-shadow: 0 0 0 3px rgba(239,68,68,0.12);
        }

        /* Password wrapper for show/hide toggle */
        .cp-pw-wrap {
            position: relative;
        }
        .cp-pw-wrap .cp-login-input {
            padding-right: 44px;
        }
        .cp-pw-toggle {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: #64748B;
            font-size: 14px;
            padding: 4px;
            line-height: 1;
            border-radius: 4px;
        }
        .cp-pw-toggle:hover  { color: #172033; }
        .cp-pw-toggle:focus-visible {
            outline: 2px solid #0EA5E9;
            outline-offset: 2px;
        }

        /* Validation message under field */
        .cp-field-error {
            font-size: 12px;
            color: #EF4444;
            margin-top: 5px;
            display: block;
        }

        /* General error alert */
        .cp-login-alert {
            background: rgba(239,68,68,0.08);
            border: 1px solid rgba(239,68,68,0.25);
            border-radius: 9px;
            padding: 11px 14px;
            font-size: 13px;
            color: #DC2626;
            margin-bottom: 18px;
            display: flex;
            gap: 8px;
            align-items: flex-start;
        }
        .cp-login-alert-info {
            background: rgba(245,158,11,0.08);
            border-color: rgba(245,158,11,0.25);
            color: #B45309;
        }

        /* Submit button */
        .cp-login-btn {
            display: block;
            width: 100%;
            padding: 12px;
            background: #0EA5E9;
            color: #ffffff;
            border: none;
            border-radius: 9px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.15s;
            font-family: inherit;
            margin-top: 8px;
        }
        .cp-login-btn:hover    { background: #0284C7; }
        .cp-login-btn:focus-visible {
            outline: 2px solid #0EA5E9;
            outline-offset: 3px;
        }
        .cp-login-btn:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }

        /* Footer link row */
        .cp-login-footer {
            text-align: center;
            margin-top: 22px;
            font-size: 13px;
            color: #64748B;
        }
        .cp-login-footer a {
            color: #0EA5E9;
            text-decoration: none;
            font-weight: 500;
        }
        .cp-login-footer a:hover { text-decoration: underline; }

        @media (max-width: 480px) {
            .cp-login-body { padding: 28px 20px 24px; }
            .cp-login-heading { font-size: 20px; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="cp-login-wrapper">
    <div class="cp-login-box">

        <%-- Top gradient accent bar --%>
        <div class="cp-login-accent" aria-hidden="true"></div>

        <div class="cp-login-body">

            <%-- Brand --%>
            <a class="cp-login-brand" href="Default.aspx">
                <img src="Images/LogoCloudPhoriaBlack.png" alt="CloudPhoria" style="height:80px;width:auto;" onerror="this.style.display='none';this.nextElementSibling.style.display='flex';" />
                <div class="cp-login-logo" style="display:none;" aria-hidden="true">CP</div>
            </a>

            <%-- Heading --%>
            <h1 class="cp-login-heading">Welcome back</h1>
            <p class="cp-login-subheading">Sign in to continue to your account</p>

            <%-- General error message panel --%>
            <asp:Panel ID="pnlError" runat="server" Visible="false">
                <div class="cp-login-alert" role="alert">
                    <span aria-hidden="true"></span>
                    <asp:Literal ID="litError" runat="server" />
                </div>
            </asp:Panel>

            <%-- Account status message (inactive / banned / pending) --%>
            <asp:Panel ID="pnlStatus" runat="server" Visible="false">
                <div class="cp-login-alert cp-login-alert-info" role="alert">
                    <span aria-hidden="true">&#x2139;</span>
                    <asp:Literal ID="litStatus" runat="server" />
                </div>
            </asp:Panel>

            <%-- Email field --%>
            <div class="cp-login-field">
                <label class="cp-login-label" for="<%= txtEmail.ClientID %>">
                    Email address <span style="color:#EF4444;" aria-hidden="true">*</span>
                </label>
                <asp:TextBox ID="txtEmail"
                             runat="server"
                             TextMode="Email"
                             CssClass="cp-login-input"
                             placeholder="you@example.com"
                             MaxLength="100"
                             autocomplete="email" />
                <asp:RequiredFieldValidator
                    ID="rfvEmail"
                    runat="server"
                    ControlToValidate="txtEmail"
                    CssClass="cp-field-error"
                    ErrorMessage="Email is required."
                    Display="Dynamic"
                    EnableClientScript="true" />
                <asp:RegularExpressionValidator
                    ID="revEmail"
                    runat="server"
                    ControlToValidate="txtEmail"
                    CssClass="cp-field-error"
                    ErrorMessage="Please enter a valid email address."
                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    Display="Dynamic"
                    EnableClientScript="true" />
            </div>

            <%-- Password field --%>
            <div class="cp-login-field">
                <label class="cp-login-label" for="<%= txtPassword.ClientID %>">
                    Password <span style="color:#EF4444;" aria-hidden="true">*</span>
                </label>
                <div class="cp-pw-wrap">
                    <asp:TextBox ID="txtPassword"
                                 runat="server"
                                 TextMode="Password"
                                 CssClass="cp-login-input"
                                 placeholder="Enter your password"
                                 MaxLength="256"
                                 autocomplete="current-password" />
                    <button type="button"
                            class="cp-pw-toggle"
                            id="btnShowPassword"
                            aria-label="Show password"
                            aria-pressed="false"
                            onclick="togglePasswordVisibility()">
                        
                    </button>
                </div>
                <asp:RequiredFieldValidator
                    ID="rfvPassword"
                    runat="server"
                    ControlToValidate="txtPassword"
                    CssClass="cp-field-error"
                    ErrorMessage="Password is required."
                    Display="Dynamic"
                    EnableClientScript="true" />
            </div>

            <%-- Login button --%>
            <asp:Button ID="btnLogin"
                        runat="server"
                        Text="Sign In"
                        CssClass="cp-login-btn"
                        OnClick="btnLogin_Click"
                        UseSubmitBehavior="true" />

            <%-- Footer --%>
            <div class="cp-login-footer">
                Don't have an account? <a href="Register.aspx">Join for Free</a>
                <br />
                <a href="Default.aspx" style="margin-top:8px;display:inline-block;">&#x2190; Back to home</a>
            </div>

        </div><%-- end cp-login-body --%>
    </div><%-- end cp-login-box --%>
</div><%-- end cp-login-wrapper --%>
</form>

<script src="Scripts/bootstrap.bundle.js"></script>
<script>
    // Show/hide password toggle
    function togglePasswordVisibility() {
        var input  = document.getElementById('<%= txtPassword.ClientID %>');
        var btn    = document.getElementById('btnShowPassword');
        if (!input || !btn) { return; }

        if (input.type === 'password') {
            input.type = 'text';
            btn.setAttribute('aria-label', 'Hide password');
            btn.setAttribute('aria-pressed', 'true');
            btn.innerHTML = '';
        } else {
            input.type = 'password';
            btn.setAttribute('aria-label', 'Show password');
            btn.setAttribute('aria-pressed', 'false');
            btn.innerHTML = '';
        }
    }

    // Add error class to inputs that failed server-side validation
    (function () {
        var emailInput = document.getElementById('<%= txtEmail.ClientID %>');
        var pwInput    = document.getElementById('<%= txtPassword.ClientID %>');
        var errorPanel = document.getElementById('<%= pnlError.ClientID %>');

        if (errorPanel && errorPanel.style.display !== 'none' && emailInput) {
            emailInput.classList.add('input-error');
        }
    })();
</script>
</body>
</html>
