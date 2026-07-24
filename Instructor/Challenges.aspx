<%@ Page Title="Challenges" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Challenges.aspx.cs"
    Inherits="CloudPhoria.Instructor.Challenges" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>Challenges</h2>
                <p>Create time-boxed challenges for your students to earn XP.</p>
            </div>
            <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('createModal')">
                + New Challenge
            </button>
        </div>
    </div>

    <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
        <div class="cp-alert cp-alert-success"><span></span>
            <asp:Literal ID="litSuccess" runat="server" /></div>
    </asp:Panel>
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger"><span></span>
            <asp:Literal ID="litError" runat="server" /></div>
    </asp:Panel>

    <asp:Panel ID="pnlChallenges" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table" role="grid" aria-label="Challenges">
                <thead>
                    <tr>
                        <th scope="col">Title</th>
                        <th scope="col">XP Reward</th>
                        <th scope="col">Start Date</th>
                        <th scope="col">End Date</th>
                        <th scope="col">Participants</th>
                        <th scope="col">Status</th>
                        <th scope="col">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptChallenges" runat="server"
                                  OnItemCommand="rptChallenges_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td style="font-weight:600;"><%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %></td>
                                <td><span class="cp-xp-chip"><%# Eval("XPReward") %> XP</span></td>
                                <td style="color:var(--cp-text-muted);"><%# Convert.ToDateTime(Eval("StartDate")).ToString("dd MMM yyyy") %></td>
                                <td style="color:var(--cp-text-muted);"><%# Convert.ToDateTime(Eval("EndDate")).ToString("dd MMM yyyy") %></td>
                                <td><span class="cp-badge cp-badge-blue"><%# Eval("ParticipantCount") %></span></td>
                                <td>
                                    <%# GetChallengeStatus(Eval("StartDate"), Eval("EndDate")) %>
                                </td>
                                <td style="display:flex;gap:6px;">
                                    <a href='Challenges.aspx?manageQuestions=<%# Eval("ChallengeID") %>' class="cp-btn cp-btn-outline cp-btn-sm">Questions</a>
                                    <asp:LinkButton runat="server"
                                        CommandName="Delete"
                                        CommandArgument='<%# Eval("ChallengeID") %>'
                                        CssClass="cp-btn cp-btn-danger cp-btn-sm"
                                        OnClientClick="return confirm('Delete this challenge?');">
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
            <h3>No challenges yet</h3>
            <p>Create a challenge to motivate your students with bonus XP.</p>
            <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('createModal')">
                + New Challenge
            </button>
        </div>
    </asp:Panel>

    <%-- Manage Questions view (?manageQuestions=) --%>
    <asp:Panel ID="pnlManageQuestions" runat="server" Visible="false">
        <div class="cp-page-header-row" style="margin-bottom:16px;">
            <div>
                <h2>Questions &mdash; <asp:Literal ID="litManageChTitle" runat="server" /></h2>
                <p>Add multiple-choice questions students will answer when they join this challenge.</p>
            </div>
            <a href="Challenges.aspx" class="cp-btn cp-btn-ghost">&#x2190; Back to Challenges</a>
        </div>

        <div class="cp-card cp-mb-md">
            <h3 style="font-size:14px;font-weight:600;margin:0 0 12px;">Add a Question</h3>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtChQText.ClientID %>">Question Text <span class="required">*</span></label>
                <asp:TextBox ID="txtChQText" runat="server" CssClass="cp-textarea" TextMode="MultiLine" Rows="2"
                             placeholder="Enter the question..." />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtChQText"
                    Display="Dynamic" CssClass="cp-form-error"
                    ValidationGroup="AddChQ" ErrorMessage="Question text is required." />
            </div>

            <div class="cp-grid-2" style="gap:12px;">
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtChQPoints.ClientID %>">Points for Correct Answer</label>
                    <asp:TextBox ID="txtChQPoints" runat="server" CssClass="cp-input" TextMode="Number" Text="10" />
                </div>
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtChQTime.ClientID %>">Time Limit (seconds)</label>
                    <asp:TextBox ID="txtChQTime" runat="server" CssClass="cp-input" TextMode="Number" Text="30" />
                </div>
            </div>

            <label class="cp-label">Answer Options <span class="required">*</span> (at least 2, select the correct one)</label>
            <asp:Repeater ID="rptChOptions" runat="server">
                <ItemTemplate>
                    <div style="display:flex;gap:8px;align-items:center;margin-bottom:8px;">
                        <asp:RadioButton ID="rbChCorrect" runat="server" GroupName="ChCorrectOption" />
                        <asp:TextBox ID="txtChOption" runat="server" CssClass="cp-input"
                                     MaxLength="300" placeholder='<%# "Option " + Container.DataItem %>' />
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Button ID="btnAddChQuestion" runat="server" Text="+ Add Question"
                        CssClass="cp-btn cp-btn-primary" style="margin-top:8px;"
                        ValidationGroup="AddChQ" OnClick="btnAddChQuestion_Click" />
        </div>

        <h3 style="font-size:14px;font-weight:600;margin:0 0 12px;">Existing Questions</h3>
        <asp:Panel ID="pnlChQuestionsList" runat="server" Visible="false">
            <asp:Repeater ID="rptChQuestions" runat="server" OnItemCommand="rptChQuestions_ItemCommand">
                <ItemTemplate>
                    <div class="cp-card" style="margin-bottom:10px;">
                        <div class="cp-flex-between" style="flex-wrap:wrap;gap:10px;">
                            <div>
                                <div style="font-size:13px;font-weight:600;color:var(--cp-text);">
                                    <%# HttpUtility.HtmlEncode(Eval("QuestionText").ToString()) %>
                                </div>
                                <div style="font-size:12px;color:var(--cp-text-muted);margin-top:4px;">
                                    <%# Eval("Points") %> pts &bull; <%# Eval("TimeLimitSeconds") %>s &bull;
                                    <%# Eval("OptionCount") %> option(s)
                                </div>
                            </div>
                            <asp:LinkButton runat="server" CommandName="DeleteQuestion"
                                CommandArgument='<%# Eval("ChallengeQuestionID") %>'
                                CssClass="cp-btn cp-btn-danger cp-btn-sm"
                                OnClientClick="return confirm('Remove this question?');">
                                Remove
                            </asp:LinkButton>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>
        <asp:Panel ID="pnlNoChQuestions" runat="server" Visible="false">
            <div class="cp-card" style="text-align:center;padding:20px;color:var(--cp-text-muted);font-size:13px;">
                No questions yet. Add at least one so students can join this challenge.
            </div>
        </asp:Panel>
    </asp:Panel>

    <%-- Create Challenge Modal --%>
    <div id="createModal" class="cp-modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="createChTitle">
        <div class="cp-modal">
            <button class="cp-modal-close" type="button" onclick="hideModal('createModal')" aria-label="Close"></button>
            <h2 class="cp-modal-title" id="createChTitle">New Challenge</h2>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtChTitle.ClientID %>">Title <span class="required">*</span></label>
                <asp:TextBox ID="txtChTitle" runat="server" CssClass="cp-input"
                             MaxLength="150" placeholder="Challenge title" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtChTitle"
                    Display="Dynamic" CssClass="cp-form-error"
                    ValidationGroup="CreateCh" ErrorMessage="Title is required." />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtChDesc.ClientID %>">Description</label>
                <asp:TextBox ID="txtChDesc" runat="server" CssClass="cp-textarea"
                             TextMode="MultiLine" Rows="3" placeholder="What is this challenge about?" />
            </div>

            <div class="cp-grid-2" style="gap:12px;">
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtChXP.ClientID %>">XP Reward</label>
                    <asp:TextBox ID="txtChXP" runat="server" CssClass="cp-input" TextMode="Number" Text="50" />
                </div>
                <div class="cp-form-group"><%-- spacer --%></div>
            </div>

            <div class="cp-grid-2" style="gap:12px;">
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtChStart.ClientID %>">Start Date <span class="required">*</span></label>
                    <asp:TextBox ID="txtChStart" runat="server" CssClass="cp-input" TextMode="Date" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtChStart"
                        Display="Dynamic" CssClass="cp-form-error"
                        ValidationGroup="CreateCh" ErrorMessage="Start date is required." />
                </div>
                <div class="cp-form-group">
                    <label class="cp-label" for="<%= txtChEnd.ClientID %>">End Date <span class="required">*</span></label>
                    <asp:TextBox ID="txtChEnd" runat="server" CssClass="cp-input" TextMode="Date" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtChEnd"
                        Display="Dynamic" CssClass="cp-form-error"
                        ValidationGroup="CreateCh" ErrorMessage="End date is required." />
                </div>
            </div>

            <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:12px;">
                <button type="button" class="cp-btn cp-btn-ghost" onclick="hideModal('createModal')">Cancel</button>
                <asp:Button ID="btnCreateCh" runat="server" Text="Create Challenge"
                            CssClass="cp-btn cp-btn-primary"
                            ValidationGroup="CreateCh"
                            OnClick="btnCreateCh_Click" />
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
