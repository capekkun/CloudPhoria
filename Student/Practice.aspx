<%@ Page Title="Practice" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Practice.aspx.cs"
    Inherits="CloudPhoria.Student.Practice" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <h2>Practice</h2>
        <p>Practise module questions as many times as you like. No timer, no pressure.</p>
    </div>

    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger cp-mb-md">
            <asp:Literal ID="litError" runat="server" />
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlModules" runat="server" Visible="false">
        <asp:Repeater ID="rptModules" runat="server">
            <ItemTemplate>
                <div class="cp-module-card">
                    <div class="cp-flex-between">
                        <div>
                            <div style="font-size:14px;font-weight:600;color:var(--cp-text);">
                                <%# HttpUtility.HtmlEncode(Eval("ModuleName").ToString()) %>
                            </div>
                            <div style="font-size:12px;color:var(--cp-text-muted);margin-top:3px;">
                                <%# HttpUtility.HtmlEncode(Eval("PathwayName").ToString()) %>
                                &bull;
                                <span style="color:<%# Eval("DiffColour") %>;font-weight:600;">
                                    <%# HttpUtility.HtmlEncode(Eval("DifficultyLevel").ToString()) %>
                                </span>
                                &bull; <%# Eval("QuestionCount") %> practice question<%# Convert.ToInt32(Eval("QuestionCount")) == 1 ? "" : "s" %>
                            </div>
                        </div>
                        <a href="PracticeQuiz.aspx?moduleID=<%# Eval("ModuleID") %>"
                           class="cp-btn cp-btn-outline cp-btn-sm">
                            Start Practice
                        </a>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x270F;</span>
            <h3>No practice questions yet</h3>
            <p>Practice questions will appear here once instructors publish them.</p>
        </div>
    </asp:Panel>

</asp:Content>
