<%@ Page Title="Subtopic" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="SubTopicView.aspx.cs"
    Inherits="CloudPhoria.Student.SubTopicView" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
.sub-hero{background:#0F172A;padding:24px 32px;color:#fff;margin:-24px -32px 24px;}
.sub-hero a{color:#38BDF8;font-size:13px;text-decoration:none;}
.sub-hero h1{font-size:26px;font-weight:700;margin:10px 0 6px;color:#fff;}
.sub-hero-meta{font-size:13px;color:rgba(255,255,255,0.5);display:flex;gap:16px;flex-wrap:wrap;}
.sub-content{background:#fff;border:1px solid #E2E8F0;border-radius:12px;padding:28px 32px;
    font-size:14px;line-height:1.8;color:#172033;margin-bottom:24px;}
.sub-content h2,.sub-content h3{color:#172033;margin-top:24px;}
.sub-materials{margin-bottom:24px;}
.sub-mat-item{display:flex;align-items:center;gap:12px;padding:12px 16px;
    background:#F8FAFC;border:1px solid #E2E8F0;border-radius:8px;margin-bottom:8px;}
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<div class="sub-hero">
    <a href="ModuleDetail.aspx?moduleID=<%= ViewState["ModuleID"] %>">&#x2190; Back to module</a>
    <h1><asp:Literal ID="litSubName" runat="server" /></h1>
    <div class="sub-hero-meta">
        <span>&#x1F4DA; <asp:Literal ID="litModuleName" runat="server" /></span>
        <span>&#x26A1; +<asp:Literal ID="litXP" runat="server" /> XP</span>
        <span><asp:Literal ID="litStatus" runat="server" /></span>
    </div>
</div>

<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="cp-alert cp-alert-danger cp-mb-md"><asp:Literal ID="litError" runat="server" /></div>
</asp:Panel>

<%-- Lesson content --%>
<asp:Panel ID="pnlContent" runat="server" Visible="false">
    <div class="sub-content">
        <asp:Literal ID="litContent" runat="server" />
    </div>
</asp:Panel>

<%-- Learning materials --%>
<asp:Panel ID="pnlMaterials" runat="server" Visible="false">
    <div class="sub-materials">
        <h3 style="font-size:15px;font-weight:600;margin:0 0 12px;">&#x1F4CE; Learning Materials</h3>
        <asp:Repeater ID="rptMaterials" runat="server">
            <ItemTemplate>
                <div class="sub-mat-item">
                    <span style="font-size:18px;">&#x1F4C4;</span>
                    <div style="flex:1;">
                        <div style="font-size:13px;font-weight:600;color:#172033;">
                            <%# HttpUtility.HtmlEncode(Eval("FileName").ToString()) %>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<%-- Mark complete button --%>
<asp:Panel ID="pnlComplete" runat="server" Visible="false">
    <div class="cp-card" style="text-align:center;">
        <p style="font-size:14px;color:#64748B;margin:0 0 16px;">
            Review the content and answer all questions, then mark this subtopic as complete to earn XP.
        </p>
        <asp:Button ID="btnComplete" runat="server" Text="&#x2713; Mark as Complete"
            CssClass="cp-btn cp-btn-primary"
            OnClick="btnComplete_Click"
            OnClientClick="return confirm('Mark this subtopic as complete?');" />
    </div>
</asp:Panel>

<%-- Questions section --%>
<asp:Panel ID="pnlQuestions" runat="server" Visible="false">
    <h3 style="font-size:16px;font-weight:700;margin:24px 0 16px;">&#x2753; Questions</h3>
    <asp:Repeater ID="rptQuestions" runat="server">
        <ItemTemplate>
            <div class="cp-card" style="border-left:3px solid var(--cp-indigo);margin-bottom:16px;">
                <div style="font-size:14px;font-weight:600;color:#172033;margin-bottom:12px;">
                    Q<%# Container.ItemIndex + 1 %>: <%# HttpUtility.HtmlEncode(Eval("QuestionText").ToString()) %>
                </div>
                <div style="font-size:11px;color:#64748B;margin-bottom:8px;">
                    Type: <%# Eval("QuestionType") %> &bull; +<%# Eval("XPReward") %> XP
                </div>
                <%# Eval("QuestionType").ToString() == "MCQ"
                    ? "<div class='bf-options' style='grid-template-columns:1fr;gap:8px;max-width:100%;'>"
                      + GetMCQOptions(Convert.ToInt32(Eval("QuestionID"))) + "</div>"
                    : "<div style='margin-top:8px;'><input type='text' class='cp-input' placeholder='Type your answer...' "
                      + "style='max-width:400px;' disabled /><br/><small style=\"color:#94A3B8;\">Answer submission coming soon</small></div>" %>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</asp:Panel>

<asp:Panel ID="pnlAlreadyDone" runat="server" Visible="false">
    <div class="cp-alert cp-alert-success">
        &#x2713; You have completed this subtopic!
    </div>
</asp:Panel>

<script>
function selectAnswer(el, result) {
    // Disable all options in the same question card
    var card = el.closest('.cp-card');
    var opts = card.querySelectorAll('.st-opt');
    for (var i = 0; i < opts.length; i++) {
        opts[i].style.pointerEvents = 'none';
        opts[i].style.opacity = '0.6';
    }
    // Highlight selected
    if (result === 'correct') {
        el.style.background = 'rgba(34,197,94,0.15)';
        el.style.borderColor = '#22C55E';
        el.style.color = '#16A34A';
        el.innerHTML = '&#x2713; ' + el.textContent.substring(2);
    } else {
        el.style.background = 'rgba(239,68,68,0.15)';
        el.style.borderColor = '#EF4444';
        el.style.color = '#DC2626';
        el.innerHTML = '&#x2717; ' + el.textContent.substring(2);
    }
    el.style.opacity = '1';
    el.style.fontWeight = '600';
}
</script>

</asp:Content>
