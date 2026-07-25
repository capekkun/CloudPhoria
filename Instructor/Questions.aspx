<%@ Page Title="Questions" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Questions.aspx.cs"
    Inherits="CloudPhoria.Instructor.Questions" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>Subtopic Questions</h2>
                <p>Questions for subtopics assigned to you. Only Admin can create, edit, or delete questions.</p>
            </div>
            <div style="display:flex;gap:8px;flex-wrap:wrap;">
                <a href="SubTopics.aspx" class="cp-btn cp-btn-ghost">&#x2190; Subtopics</a>
            </div>
        </div>
    </div>

    <%-- Subtopic filter --%>
    <div class="cp-card cp-mb-md" style="padding:16px 20px;">
        <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
            <label class="cp-label" style="margin:0;white-space:nowrap;" for="<%= ddlSubTopic.ClientID %>">Filter by Subtopic:</label>
            <asp:DropDownList ID="ddlSubTopic" runat="server" CssClass="cp-select"
                              AutoPostBack="true" OnSelectedIndexChanged="ddlSubTopic_Changed"
                              style="max-width:400px;" />
        </div>
    </div>

    <%-- Feedback --%>
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger"><span></span>
            <asp:Literal ID="litError" runat="server" /></div>
    </asp:Panel>

    <%-- Question list (read-only) --%>
    <asp:Panel ID="pnlQuestions" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table" role="grid" aria-label="Questions">
                <thead>
                    <tr>
                        <th scope="col">#</th>
                        <th scope="col">Question</th>
                        <th scope="col">Type</th>
                        <th scope="col">XP</th>
                        <th scope="col">Subtopic</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptQuestions" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td style="color:var(--cp-text-muted);"><%# Eval("OrderIndex") %></td>
                                <td style="max-width:320px;word-break:break-word;">
                                    <%# HttpUtility.HtmlEncode(Eval("QuestionText").ToString()) %>
                                </td>
                                <td>
                                    <span class='cp-badge <%# GetTypeBadge(Eval("QuestionType").ToString()) %>'>
                                        <%# HttpUtility.HtmlEncode(Eval("QuestionType").ToString()) %>
                                    </span>
                                </td>
                                <td><span class="cp-xp-chip"><%# Eval("XPReward") %> XP</span></td>
                                <td style="color:var(--cp-text-muted);font-size:12px;">
                                    <%# HttpUtility.HtmlEncode(Eval("SubTopicName").ToString()) %>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <h3>No questions yet</h3>
            <p>Ask an Admin to add questions to your assigned subtopics.</p>
        </div>
    </asp:Panel>

</asp:Content>
