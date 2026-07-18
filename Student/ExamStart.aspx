<%@ Page Title="Start Exam" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="ExamStart.aspx.cs"
    Inherits="CloudPhoria.Student.ExamStart" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <h2>&#x1F4CB; Module Exam</h2>
        <p>Module: <asp:Literal ID="litModuleName" runat="server" Text="Loading..." /></p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlExamInfo" runat="server" Visible="false">
        <div class="cp-card" style="border-top:3px solid var(--cp-indigo);max-width:600px;">
            <div style="text-align:center;font-size:48px;margin-bottom:16px;" aria-hidden="true">&#x23F1;</div>
            <h3 class="cp-card-title" style="text-align:center;">Ready to start your exam?</h3>
            <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;margin:20px 0;text-align:center;">
                <div>
                    <div style="font-size:22px;font-weight:700;color:var(--cp-text);">
                        <asp:Literal ID="litDuration" runat="server" /> min
                    </div>
                    <div style="font-size:12px;color:var(--cp-text-muted);">Duration</div>
                </div>
                <div>
                    <div style="font-size:22px;font-weight:700;color:var(--cp-text);">
                        <asp:Literal ID="litPassMark" runat="server" />%
                    </div>
                    <div style="font-size:12px;color:var(--cp-text-muted);">Pass Mark</div>
                </div>
                <div>
                    <div style="font-size:22px;font-weight:700;color:var(--cp-warning);">
                        +<asp:Literal ID="litXPReward" runat="server" /> XP
                    </div>
                    <div style="font-size:12px;color:var(--cp-text-muted);">Reward</div>
                </div>
            </div>
            <div class="cp-alert cp-alert-warning" style="margin-top:16px;">
                <span>&#x26A0;</span>
                <span>Once you start, the timer begins. Make sure you have enough time.</span>
            </div>
            <div style="text-align:center;margin-top:20px;">
                <a href="Exams.aspx" class="cp-btn cp-btn-ghost" style="margin-right:10px;">&#x2190; Back</a>
                <asp:Button ID="btnStartExam" runat="server" Text="Start Exam"
                            CssClass="cp-btn cp-btn-primary"
                            OnClick="btnStartExam_Click"
                            OnClientClick="return confirm('Start the timed exam now?');" />
            </div>
        </div>
    </asp:Panel>

</asp:Content>
