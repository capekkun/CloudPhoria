<%@ Page Title="Practice Quiz" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="PracticeQuiz.aspx.cs"
    Inherits="CloudPhoria.Student.PracticeQuiz" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.pq-header{background:#0F172A;padding:24px 32px;color:#fff;margin:-24px -32px 24px;}
.pq-header h1{font-size:24px;font-weight:700;margin:0 0 4px;}
.pq-header p{font-size:13px;color:rgba(255,255,255,0.5);margin:0;}
.pq-card{background:#fff;border:1px solid #E2E8F0;border-radius:14px;padding:24px;margin-bottom:20px;}
.pq-q-num{font-size:11px;font-weight:700;color:#0EA5E9;text-transform:uppercase;letter-spacing:0.08em;margin-bottom:8px;}
.pq-q-text{font-size:16px;font-weight:600;color:#172033;margin-bottom:16px;line-height:1.6;}
.pq-opts{display:flex;flex-direction:column;gap:10px;}
.pq-opt{display:block;padding:12px 16px;background:#F8FAFC;border:1.5px solid #E2E8F0;border-radius:9px;
    font-size:14px;color:#172033;cursor:pointer;transition:all 0.15s;text-decoration:none;text-align:left;
    font-family:inherit;width:100%;}
.pq-opt:hover{border-color:#0EA5E9;background:rgba(14,165,233,0.04);}
.pq-correct{border-color:#22C55E !important;background:rgba(34,197,94,0.08) !important;color:#16A34A !important;}
.pq-wrong{border-color:#EF4444 !important;background:rgba(239,68,68,0.08) !important;color:#DC2626 !important;}
.pq-result{padding:12px 16px;border-radius:9px;margin-top:12px;font-size:13px;font-weight:600;}
.pq-result-correct{background:rgba(34,197,94,0.1);color:#16A34A;border:1px solid rgba(34,197,94,0.2);}
.pq-result-wrong{background:rgba(239,68,68,0.1);color:#DC2626;border:1px solid rgba(239,68,68,0.2);}
.pq-score{text-align:center;padding:32px;background:#fff;border:1px solid #E2E8F0;border-radius:14px;}
.pq-score h2{font-size:32px;font-weight:800;margin:0 0 8px;}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<div class="pq-header">
    <h1>&#x270F; Practice Quiz</h1>
    <p>Module: <asp:Literal ID="litModuleName" runat="server" /></p>
</div>

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="cp-alert cp-alert-danger cp-mb-md"><asp:Literal ID="litError" runat="server" /></div>
</asp:Panel>

<%-- Question display --%>
<asp:Panel ID="pnlQuestion" runat="server" Visible="false">
    <div class="pq-card">
        <div class="pq-q-num">
            Question <asp:Literal ID="litQNum" runat="server" /> of <asp:Literal ID="litQTotal" runat="server" />
        </div>
        <div class="pq-q-text">
            <asp:Literal ID="litQText" runat="server" />
        </div>
        <div class="pq-opts">
            <asp:Literal ID="litPQOpts" runat="server" />
        </div>
        <asp:HiddenField ID="hdnPQAnswer" runat="server" />
        <asp:Button ID="btnPQSubmit" runat="server" style="display:none;" OnClick="btnPQSubmit_Click" />
        <asp:Panel ID="pnlFeedback" runat="server" Visible="false">
            <div class="pq-result" id="feedbackDiv" runat="server">
                <asp:Literal ID="litFeedback" runat="server" />
            </div>
            <div style="text-align:right;margin-top:12px;">
                <asp:Button ID="btnNext" runat="server" Text="Next Question &#x2192;"
                    CssClass="cp-btn cp-btn-primary" OnClick="btnNext_Click" />
            </div>
        </asp:Panel>
    </div>
</asp:Panel>

<%-- Score at end --%>
<asp:Panel ID="pnlScore" runat="server" Visible="false">
    <div class="pq-score">
        <div style="font-size:48px;margin-bottom:12px;">&#x1F3C6;</div>
        <h2><asp:Literal ID="litScoreNum" runat="server" /> / <asp:Literal ID="litScoreTotal" runat="server" /></h2>
        <p style="color:#64748B;margin:0 0 20px;">Questions answered correctly</p>
        <a href="Practice.aspx" class="cp-btn cp-btn-primary">Back to Practice</a>
    </div>
</asp:Panel>

<%-- Empty state --%>
<asp:Panel ID="pnlEmpty" runat="server" Visible="false">
    <div class="cp-empty-state">
        <span class="cp-empty-state-icon">&#x270F;</span>
        <h3>No practice questions</h3>
        <p>This module doesn't have practice questions yet.</p>
        <a href="Practice.aspx" class="cp-btn cp-btn-ghost">Back to Practice</a>
    </div>
</asp:Panel>

</asp:Content>
