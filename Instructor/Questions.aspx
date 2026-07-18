<%@ Page Title="Questions" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Questions.aspx.cs"
    Inherits="CloudPhoria.Instructor.Questions" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x2753; Subtopic Questions</h2>
                <p>Manage inline questions (MCQ, Regex, StringMatch) attached to subtopics.</p>
            </div>
            <div style="display:flex;gap:8px;flex-wrap:wrap;">
                <a href="SubTopics.aspx" class="cp-btn cp-btn-ghost">&#x2190; Subtopics</a>
                <asp:Panel ID="pnlAddBtn" runat="server" Visible="false">
                    <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('createModal')">
                        + New Question
                    </button>
                </asp:Panel>
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
    <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
        <div class="cp-alert cp-alert-success"><span>&#x2714;</span>
            <asp:Literal ID="litSuccess" runat="server" /></div>
    </asp:Panel>
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger"><span>&#x26A0;</span>
            <asp:Literal ID="litError" runat="server" /></div>
    </asp:Panel>

    <%-- Question list --%>
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
                        <th scope="col">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptQuestions" runat="server"
                                  OnItemCommand="rptQuestions_ItemCommand">
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
                                <td>
                                    <asp:LinkButton runat="server"
                                        CommandName="Delete"
                                        CommandArgument='<%# Eval("QuestionID") %>'
                                        CssClass="cp-btn cp-btn-danger cp-btn-sm"
                                        OnClientClick="return confirm('Delete this question?');">
                                        Delete
                                    </asp:LinkButton>
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
            <span class="cp-empty-state-icon" aria-hidden="true">&#x2753;</span>
            <h3>No questions yet</h3>
            <p>Select a subtopic and add questions to make lessons interactive.</p>
        </div>
    </asp:Panel>

    <%-- Create Question Modal --%>
    <div id="createModal" class="cp-modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="createQTitle">
        <div class="cp-modal" style="max-width:580px;">
            <button class="cp-modal-close" type="button" onclick="hideModal('createModal')" aria-label="Close">&#x2715;</button>
            <h2 class="cp-modal-title" id="createQTitle">New Question</h2>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= ddlSubTopicCreate.ClientID %>">Subtopic <span class="required">*</span></label>
                <asp:DropDownList ID="ddlSubTopicCreate" runat="server" CssClass="cp-select" />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtQuestionText.ClientID %>">Question Text <span class="required">*</span></label>
                <asp:TextBox ID="txtQuestionText" runat="server" CssClass="cp-textarea"
                             TextMode="MultiLine" Rows="3" placeholder="Enter the question..." />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtQuestionText"
                    Display="Dynamic" CssClass="cp-form-error"
                    ValidationGroup="CreateQ" ErrorMessage="Question text is required." />
            </div>

            <div class="cp-grid-2" style="gap:12px;">
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= ddlQType.ClientID %>">Type <span class="required">*</span></label>
                    <asp:DropDownList ID="ddlQType" runat="server" CssClass="cp-select"
                                      AutoPostBack="true" OnSelectedIndexChanged="ddlQType_Changed">
                        <asp:ListItem Value="MCQ" Selected="True">MCQ</asp:ListItem>
                        <asp:ListItem Value="Regex">Regex</asp:ListItem>
                        <asp:ListItem Value="StringMatch">StringMatch</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtQXP.ClientID %>">XP Reward</label>
                    <asp:TextBox ID="txtQXP" runat="server" CssClass="cp-input" TextMode="Number" Text="5" />
                </div>
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtOrderIdx.ClientID %>">Order Index</label>
                <asp:TextBox ID="txtOrderIdx" runat="server" CssClass="cp-input" TextMode="Number" Text="0" />
            </div>

            <%-- Correct answer (for Regex / StringMatch) --%>
            <asp:Panel ID="pnlCorrectAnswer" runat="server">
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtCorrectAnswer.ClientID %>">
                        Correct Answer <span class="required">*</span>
                        <span style="font-weight:400;color:var(--cp-text-muted);font-size:11px;">
                            (pattern for Regex; exact string for StringMatch; also required for MCQ)
                        </span>
                    </label>
                    <asp:TextBox ID="txtCorrectAnswer" runat="server" CssClass="cp-input"
                                 placeholder="e.g. ^[Cc]loud$ or exact answer text" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtCorrectAnswer"
                        Display="Dynamic" CssClass="cp-form-error"
                        ValidationGroup="CreateQ" ErrorMessage="Correct answer is required." />
                </div>
            </asp:Panel>

            <%-- MCQ options --%>
            <asp:Panel ID="pnlMCQOptions" runat="server">
                <div class="cp-alert cp-alert-info" style="margin-bottom:12px;">
                    <span>&#x2139;</span>
                    <span>Enter up to 4 options. Mark the correct one with the checkbox.</span>
                </div>
                <asp:Repeater ID="rptOptions" runat="server">
                    <ItemTemplate>
                        <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px;">
                            <asp:CheckBox ID="chkCorrect" runat="server" />
                            <asp:TextBox ID="txtOption" runat="server" CssClass="cp-input"
                                         placeholder='<%# "Option " + Container.ItemIndex.ToString() %>'
                                         style="flex:1;" />
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>

            <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:12px;">
                <button type="button" class="cp-btn cp-btn-ghost" onclick="hideModal('createModal')">Cancel</button>
                <asp:Button ID="btnCreate" runat="server" Text="Create Question"
                            CssClass="cp-btn cp-btn-primary"
                            ValidationGroup="CreateQ"
                            OnClick="btnCreate_Click" />
            </div>
        </div>
    </div>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
<script>
function showModal(id) { document.getElementById(id).classList.add('open'); document.body.style.overflow='hidden'; }
function hideModal(id) { document.getElementById(id).classList.remove('open'); document.body.style.overflow=''; }
document.querySelectorAll('.cp-modal-backdrop').forEach(function(el){
    el.addEventListener('click',function(e){ if(e.target===el) hideModal(el.id); });
});
</script>
</asp:Content>
