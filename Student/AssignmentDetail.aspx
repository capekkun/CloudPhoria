<%@ Page Title="Assignment" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="AssignmentDetail.aspx.cs"
    Inherits="CloudPhoria.Student.AssignmentDetail" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.asgn-hero{background:linear-gradient(135deg,#0F172A,#1E293B);padding:28px 32px;color:#fff;
    border-radius:0;margin:-24px -32px 24px;position:relative;}
.asgn-hero a{color:#38BDF8;font-size:13px;text-decoration:none;}
.asgn-hero h1{font-size:24px;font-weight:800;margin:10px 0 6px;}
.asgn-hero p{font-size:13px;color:rgba(255,255,255,0.5);margin:0;}
.asgn-meta{display:flex;gap:16px;margin-top:10px;font-size:12px;color:rgba(255,255,255,0.4);}
.asgn-q{background:#fff;border:1px solid #E2E8F0;border-radius:12px;padding:20px;margin-bottom:14px;}
.asgn-q-num{font-size:11px;font-weight:700;color:#6366F1;text-transform:uppercase;margin-bottom:6px;}
.asgn-q-text{font-size:15px;font-weight:600;color:#172033;margin-bottom:14px;line-height:1.5;}
.asgn-q-type{font-size:11px;color:#64748B;margin-bottom:10px;}
.asgn-opt{display:block;padding:10px 14px;background:#F8FAFC;border:1.5px solid #E2E8F0;
    border-radius:8px;margin-bottom:8px;font-size:13px;cursor:pointer;transition:all 0.12s;}
.asgn-opt:hover{border-color:#6366F1;background:#EEF2FF;}
.asgn-opt.selected{border-color:#6366F1;background:#EEF2FF;font-weight:600;}
.asgn-submitted{background:#F0FDF4;border-color:#22C55E;}
.asgn-submitted .asgn-q-num{color:#16A34A;}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<div class="asgn-hero">
    <a href="ClassroomDetail.aspx?classroomID=<%= Request.QueryString["classroomID"] %>">&#x2190; Back to Classroom</a>
    <h1><asp:Literal ID="litTitle" runat="server" /></h1>
    <p><asp:Literal ID="litDesc" runat="server" /></p>
    <div class="asgn-meta">
        <span><asp:Literal ID="litClassroom" runat="server" /></span>
        <span><asp:Literal ID="litInstructor" runat="server" /></span>
        <asp:Literal ID="litDue" runat="server" />
    </div>
</div>

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="cp-alert cp-alert-danger cp-mb-md"><asp:Literal ID="litError" runat="server" /></div>
</asp:Panel>

<asp:Panel ID="pnlSuccess" runat="server" Visible="false">
    <div class="cp-alert cp-alert-success cp-mb-md"><asp:Literal ID="litSuccess" runat="server" /></div>
</asp:Panel>

<asp:Panel ID="pnlQuestions" runat="server" Visible="false">
    <asp:Literal ID="litQuestions" runat="server" />

    <asp:Panel ID="pnlSubmitBtn" runat="server" Visible="false">
        <div style="text-align:center;margin-top:20px;">
            <asp:Button ID="btnSubmit" runat="server" Text="Submit Assignment"
                CssClass="cp-btn cp-btn-primary" OnClick="btnSubmit_Click"
                OnClientClick="return confirm('Submit your answers? You cannot change them after submission.');" />
        </div>
    </asp:Panel>
</asp:Panel>

<asp:Panel ID="pnlNoQuestions" runat="server" Visible="false">
    <div class="cp-card" style="text-align:center;padding:40px;color:#64748B;">
        <span style="font-size:40px;display:block;margin-bottom:10px;"></span>
        No questions have been added to this assignment yet.
    </div>
</asp:Panel>

<script>
function selectOption(el, qid) {
    var container = el.parentElement;
    var opts = container.querySelectorAll('.asgn-opt');
    for (var i = 0; i < opts.length; i++) opts[i].classList.remove('selected');
    el.classList.add('selected');
    var hdn = document.getElementById('hdn_' + qid);
    if (hdn) hdn.value = el.getAttribute('data-val');
}
</script>

</asp:Content>
