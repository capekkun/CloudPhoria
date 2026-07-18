<%@ Page Title="Practice Quiz" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="PracticeQuiz.aspx.cs"
    Inherits="CloudPhoria.Student.PracticeQuiz" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <h2>&#x270F; Practice Quiz</h2>
        <p>Module: <asp:Literal ID="litModuleName" runat="server" Text="Loading..." /></p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlQuiz" runat="server" Visible="false">
        <div class="cp-card" style="border-top:3px solid var(--cp-primary);max-width:700px;">
            <div style="text-align:center;font-size:36px;margin-bottom:12px;" aria-hidden="true">&#x1F4DD;</div>
            <h3 class="cp-card-title" style="text-align:center;">Practice questions will appear here</h3>
            <p class="cp-card-subtitle" style="text-align:center;">
                This page will display interactive practice questions for the selected module.
                Answer at your own pace — no timer, unlimited attempts.
            </p>
            <div style="text-align:center;margin-top:20px;">
                <a href="Practice.aspx" class="cp-btn cp-btn-ghost">&#x2190; Back to Practice</a>
            </div>
        </div>
    </asp:Panel>

</asp:Content>
