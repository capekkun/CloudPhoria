<%@ Page Title="Upgrade to Pro" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Upgrade.aspx.cs"
    Inherits="CloudPhoria.Student.Upgrade" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.up-page{background:linear-gradient(180deg,#0F172A 0%,#1E293B 100%);
    margin:-24px -32px;padding:60px 32px;min-height:calc(100vh - 72px);}
.up-title{text-align:center;color:#fff;margin-bottom:48px;}
.up-title h1{font-size:32px;font-weight:800;margin:0 0 8px;}
.up-title p{font-size:15px;color:rgba(255,255,255,0.5);margin:0;}

/* Plan cards */
.up-cards{display:grid;grid-template-columns:1fr 1fr;gap:24px;max-width:800px;margin:0 auto;}
.up-card{background:#1E293B;border:1px solid rgba(255,255,255,0.08);border-radius:16px;
    padding:36px 32px;position:relative;transition:transform 0.2s,border-color 0.2s;}
.up-card:hover{transform:translateY(-4px);}
.up-card-pro{border-color:#6366F1;background:linear-gradient(135deg,#1E293B,#312E81 120%);}
.up-card-pro::before{content:'RECOMMENDED';position:absolute;top:-12px;left:50%;
    transform:translateX(-50%);background:linear-gradient(90deg,#6366F1,#8B5CF6);
    color:#fff;font-size:10px;font-weight:700;letter-spacing:0.1em;
    padding:4px 16px;border-radius:12px;}

.up-plan-name{font-size:14px;font-weight:600;color:rgba(255,255,255,0.6);margin:0 0 4px;
    text-transform:uppercase;letter-spacing:0.05em;}
.up-plan-desc{font-size:13px;color:rgba(255,255,255,0.4);margin:0 0 20px;}
.up-price{margin-bottom:24px;}
.up-price-amount{font-size:42px;font-weight:800;color:#fff;}
.up-price-period{font-size:14px;color:rgba(255,255,255,0.4);}
.up-price-free{font-size:42px;font-weight:800;color:#22C55E;}

/* Features list */
.up-features{list-style:none;padding:0;margin:0 0 28px;}
.up-features li{display:flex;align-items:flex-start;gap:10px;font-size:13px;
    color:rgba(255,255,255,0.7);padding:8px 0;border-bottom:1px solid rgba(255,255,255,0.04);}
.up-features li:last-child{border-bottom:none;}
.up-check{color:#22C55E;font-size:14px;flex-shrink:0;}
.up-cross{color:#64748B;font-size:14px;flex-shrink:0;}

/* Buttons */
.up-btn{display:block;width:100%;padding:14px;text-align:center;border-radius:10px;
    font-size:15px;font-weight:700;cursor:pointer;transition:all 0.15s;
    text-decoration:none;border:none;font-family:inherit;}
.up-btn-free{background:rgba(255,255,255,0.06);color:rgba(255,255,255,0.5);
    border:1px solid rgba(255,255,255,0.1);}
.up-btn-pro{background:linear-gradient(90deg,#6366F1,#8B5CF6);color:#fff;
    box-shadow:0 8px 24px rgba(99,102,241,0.3);}
.up-btn-pro:hover{transform:translateY(-2px);box-shadow:0 12px 32px rgba(99,102,241,0.4);color:#fff;text-decoration:none;}
.up-btn-current{background:rgba(34,197,94,0.15);color:#22C55E;border:1px solid rgba(34,197,94,0.3);
    cursor:default;}

/* Payment modal */
.up-modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,0.7);
    z-index:10000;align-items:center;justify-content:center;padding:24px;}
.up-modal-overlay.show{display:flex;}
.up-modal{background:#fff;border-radius:16px;max-width:480px;width:100%;padding:36px;
    position:relative;box-shadow:0 20px 60px rgba(0,0,0,0.5);}
.up-modal-close{position:absolute;top:16px;right:16px;background:none;border:none;
    font-size:20px;color:#64748B;cursor:pointer;}
.up-modal h2{font-size:22px;font-weight:700;color:#172033;margin:0 0 8px;}
.up-modal p{font-size:14px;color:#64748B;margin:0 0 24px;}
.up-modal-price{font-size:28px;font-weight:800;color:#6366F1;margin-bottom:24px;text-align:center;}
.up-modal-field{margin-bottom:16px;}
.up-modal-label{display:block;font-size:13px;font-weight:500;color:#172033;margin-bottom:6px;}
.up-modal-input{display:block;width:100%;padding:12px 14px;font-size:14px;
    border:1.5px solid #E2E8F0;border-radius:8px;font-family:inherit;box-sizing:border-box;}
.up-modal-input:focus{outline:none;border-color:#6366F1;box-shadow:0 0 0 3px rgba(99,102,241,0.1);}
.up-modal-row{display:grid;grid-template-columns:1fr 1fr;gap:12px;}
.up-modal-btn{display:block;width:100%;padding:14px;background:#6366F1;color:#fff;
    border:none;border-radius:10px;font-size:15px;font-weight:700;cursor:pointer;
    margin-top:20px;font-family:inherit;transition:background 0.15s;}
.up-modal-btn:hover{background:#4F46E5;}
.up-modal-secure{text-align:center;font-size:12px;color:#94A3B8;margin-top:12px;}

@media(max-width:700px){
    .up-cards{grid-template-columns:1fr;}
    .up-page{padding:32px 16px;}
}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<div class="up-page">
    <div class="up-title">
        <h1>Unlock Your Full Potential</h1>
        <p>Choose the plan that works best for your learning journey</p>
    </div>

    <div class="up-cards">
        <%-- Free Plan --%>
        <div class="up-card">
            <div class="up-plan-name">Free</div>
            <div class="up-plan-desc">Get started with the basics</div>
            <div class="up-price">
                <span class="up-price-free">$0</span>
                <span class="up-price-period">/ forever</span>
            </div>
            <ul class="up-features">
                <li><span class="up-check">&#x2713;</span> Foundation pathway access</li>
                <li><span class="up-check">&#x2713;</span> Practice quizzes</li>
                <li><span class="up-check">&#x2713;</span> Community discussions</li>
                <li><span class="up-check">&#x2713;</span> Fun rooms</li>
                <li><span class="up-cross">&#x2717;</span> Specialisation pathways</li>
                <li><span class="up-cross">&#x2717;</span> Boss fights</li>
                <li><span class="up-cross">&#x2717;</span> Certifications</li>
                <li><span class="up-cross">&#x2717;</span> Priority support</li>
            </ul>
            <asp:Panel ID="pnlFreeCurrent" runat="server" Visible="false">
                <div class="up-btn up-btn-current">&#x2713; Current Plan</div>
            </asp:Panel>
            <asp:Panel ID="pnlFreeNotCurrent" runat="server" Visible="false">
                <a href="/Register.aspx" class="up-btn up-btn-free" style="text-decoration:none;text-align:center;">Register for Free</a>
            </asp:Panel>
        </div>

        <%-- Pro Plan --%>
        <div class="up-card up-card-pro">
            <div class="up-plan-name">Pro</div>
            <div class="up-plan-desc">Best for serious learners</div>
            <div class="up-price">
                <span class="up-price-amount">$9.99</span>
                <span class="up-price-period">/ month</span>
            </div>
            <ul class="up-features">
                <li><span class="up-check">&#x2713;</span> Everything in Free</li>
                <li><span class="up-check">&#x2713;</span> All specialisation pathways</li>
                <li><span class="up-check">&#x2713;</span> Module exams &amp; certifications</li>
                <li><span class="up-check">&#x2713;</span> Boss fights &amp; challenges</li>
                <li><span class="up-check">&#x2713;</span> Unlimited practice quizzes</li>
                <li><span class="up-check">&#x2713;</span> Certificate of completion</li>
                <li><span class="up-check">&#x2713;</span> Priority support</li>
                <li><span class="up-check">&#x2713;</span> Full access to all content</li>
            </ul>
            <asp:Panel ID="pnlProCurrent" runat="server" Visible="false">
                <div class="up-btn up-btn-current">&#x2713; Current Plan</div>
            </asp:Panel>
            <asp:Panel ID="pnlProUpgrade" runat="server" Visible="false">
                <% if (Session["UserID"] != null) { %>
                <a href="javascript:void(0)" class="up-btn up-btn-pro" onclick="openPaymentModal();">
                    Upgrade to Pro &#x1F680;
                </a>
                <% } else { %>
                <a href="/Register.aspx" class="up-btn up-btn-pro">
                    Register to Get Pro &#x1F680;
                </a>
                <% } %>
            </asp:Panel>
        </div>
    </div>
</div>

<%-- Payment Modal --%>
<div class="up-modal-overlay" id="paymentModal">
    <div class="up-modal">
        <button class="up-modal-close" onclick="closePaymentModal();" type="button">&times;</button>
        <h2>Upgrade to Pro</h2>
        <p>Enter your payment details to unlock all features</p>
        <div class="up-modal-price">$9.99 / month</div>

        <div class="up-modal-field">
            <label class="up-modal-label">Cardholder Name</label>
            <asp:TextBox ID="txtCardName" runat="server" CssClass="up-modal-input"
                placeholder="John Doe" MaxLength="100" />
        </div>
        <div class="up-modal-field">
            <label class="up-modal-label">Card Number</label>
            <asp:TextBox ID="txtCardNumber" runat="server" CssClass="up-modal-input"
                placeholder="4242 4242 4242 4242" MaxLength="19" />
        </div>
        <div class="up-modal-row">
            <div class="up-modal-field">
                <label class="up-modal-label">Expiry Date</label>
                <asp:TextBox ID="txtExpiry" runat="server" CssClass="up-modal-input"
                    placeholder="MM/YY" MaxLength="5" />
            </div>
            <div class="up-modal-field">
                <label class="up-modal-label">CVV</label>
                <asp:TextBox ID="txtCVV" runat="server" CssClass="up-modal-input"
                    placeholder="123" MaxLength="4" TextMode="Password" />
            </div>
        </div>

        <asp:Button ID="btnPay" runat="server" Text="Pay $9.99 & Upgrade"
            CssClass="up-modal-btn" OnClick="btnPay_Click" />
        <div class="up-modal-secure">&#x1F512; Secure payment. Cancel anytime.</div>
    </div>
</div>

<asp:Panel ID="pnlSuccessOverlay" runat="server" Visible="false">
<div class="up-modal-overlay show">
    <div class="up-modal" style="text-align:center;">
        <div style="font-size:64px;margin-bottom:16px;">&#x1F389;</div>
        <h2 style="color:#22C55E;">Welcome to Pro!</h2>
        <p style="margin-bottom:24px;">Your account has been upgraded. You now have full access to all pathways, certifications, and features.</p>
        <a href="/Student/Dashboard.aspx" class="up-btn up-btn-pro" style="display:inline-block;width:auto;padding:14px 32px;">
            Go to Dashboard &#x2192;
        </a>
    </div>
</div>
</asp:Panel>

<script>
function openPaymentModal() {
    document.getElementById('paymentModal').classList.add('show');
}
function closePaymentModal() {
    document.getElementById('paymentModal').classList.remove('show');
}
// Close on overlay click
document.getElementById('paymentModal').addEventListener('click', function(e) {
    if (e.target === this) closePaymentModal();
});
</script>

</asp:Content>
