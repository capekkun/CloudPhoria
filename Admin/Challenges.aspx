<%@ Page Title="Global Challenges" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Challenges.aspx.cs"
    Inherits="CloudPhoria.Admin.Challenges" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<div class="cp-page-header">
    <h2>&#x26A1; Global Challenges</h2>
    <p>Design and publish platform-wide challenges with high XP rewards for all students.</p>
</div>

<asp:Panel ID="pnlSuccess" runat="server" Visible="false">
    <div class="cp-alert cp-alert-success cp-mb-md"><asp:Literal ID="litSuccess" runat="server" /></div>
</asp:Panel>
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="cp-alert cp-alert-danger cp-mb-md"><asp:Literal ID="litError" runat="server" /></div>
</asp:Panel>

<h3 style="font-size:15px;font-weight:600;margin:0 0 16px;">Create a Global Challenge</h3>
<div class="cp-card" style="max-width:640px;margin-bottom:24px;">
    <div class="cp-form-group">
        <label class="cp-label">Title <span class="required">*</span></label>
        <asp:TextBox ID="txtGCTitle" runat="server" CssClass="cp-input" MaxLength="150" placeholder="e.g. Cloud Master Weekend Sprint" />
    </div>
    <div class="cp-form-group">
        <label class="cp-label">Description</label>
        <asp:TextBox ID="txtGCDesc" runat="server" CssClass="cp-textarea" TextMode="MultiLine" Rows="2" placeholder="Describe the challenge..." />
    </div>
    <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;">
        <div class="cp-form-group">
            <label class="cp-label">XP Reward</label>
            <asp:TextBox ID="txtGCXP" runat="server" CssClass="cp-input" Text="100" />
        </div>
        <div class="cp-form-group">
            <label class="cp-label">Start Date</label>
            <asp:TextBox ID="txtGCStart" runat="server" CssClass="cp-input" TextMode="DateTime" />
        </div>
        <div class="cp-form-group">
            <label class="cp-label">End Date</label>
            <asp:TextBox ID="txtGCEnd" runat="server" CssClass="cp-input" TextMode="DateTime" />
        </div>
    </div>
    <asp:Button ID="btnCreateGlobalChallenge" runat="server" Text="Create Global Challenge"
        CssClass="cp-btn cp-btn-primary" OnClick="btnCreateGlobalChallenge_Click" style="margin-top:8px;" />
</div>

<h3 style="font-size:15px;font-weight:600;margin:0 0 12px;">Existing Global Challenges</h3>
<asp:Panel ID="pnlGlobalChallenges" runat="server" Visible="false">
    <asp:Repeater ID="rptGlobalChallenges" runat="server" OnItemCommand="rptGlobalChallenges_ItemCommand">
        <ItemTemplate>
            <div class="cp-card" style="margin-bottom:10px;">
                <div class="cp-flex-between" style="flex-wrap:wrap;gap:10px;">
                    <div>
                        <div style="font-size:14px;font-weight:700;color:var(--cp-text);">
                            <%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %>
                        </div>
                        <div style="font-size:12px;color:var(--cp-text-muted);margin-top:3px;">
                            +<%# Eval("XPReward") %> XP &bull; <%# Convert.ToDateTime(Eval("StartDate")).ToString("dd MMM") %> - <%# Convert.ToDateTime(Eval("EndDate")).ToString("dd MMM yyyy") %>
                            &bull; <%# Eval("ParticipantCount") %> participant(s)
                        </div>
                    </div>
                    <div style="display:flex;gap:6px;">
                        <a href='Challenges.aspx?manageQuestions=<%# Eval("ChallengeID") %>' class="cp-btn cp-btn-outline cp-btn-sm">Questions</a>
                        <asp:LinkButton runat="server" CommandName="Delete" CommandArgument='<%# Eval("ChallengeID") %>'
                            CssClass="cp-btn cp-btn-danger cp-btn-sm" OnClientClick="return confirm('Delete this challenge?');">
                            Delete
                        </asp:LinkButton>
                    </div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</asp:Panel>
<asp:Panel ID="pnlNoGlobalChallenges" runat="server" Visible="false">
    <div class="cp-card" style="text-align:center;padding:20px;color:var(--cp-text-muted);font-size:13px;">
        No global challenges yet.
    </div>
</asp:Panel>

<%-- Manage Questions view (?manageQuestions=) --%>
<asp:Panel ID="pnlManageQuestions" runat="server" Visible="false">
    <div class="cp-page-header-row" style="margin-bottom:16px;">
        <div>
            <h2>&#x2753; Questions &mdash; <asp:Literal ID="litManageGCTitle" runat="server" /></h2>
            <p>Add multiple-choice questions students will answer when they join this challenge.</p>
        </div>
        <a href="Challenges.aspx" class="cp-btn cp-btn-ghost">&#x2190; Back to Global Challenges</a>
    </div>

    <div class="cp-card cp-mb-md" style="max-width:640px;">
        <h3 style="font-size:14px;font-weight:600;margin:0 0 12px;">Add a Question</h3>

        <div class="cp-form-group">
            <label class="cp-label" for="<%= txtGCQText.ClientID %>">Question Text <span class="required">*</span></label>
            <asp:TextBox ID="txtGCQText" runat="server" CssClass="cp-textarea" TextMode="MultiLine" Rows="2"
                         placeholder="Enter the question..." />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtGCQText"
                Display="Dynamic" CssClass="cp-form-error"
                ValidationGroup="AddGCQ" ErrorMessage="Question text is required." />
        </div>

        <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtGCQPoints.ClientID %>">Points for Correct Answer</label>
                <asp:TextBox ID="txtGCQPoints" runat="server" CssClass="cp-input" TextMode="Number" Text="10" />
            </div>
            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtGCQTime.ClientID %>">Time Limit (seconds)</label>
                <asp:TextBox ID="txtGCQTime" runat="server" CssClass="cp-input" TextMode="Number" Text="30" />
            </div>
        </div>

        <label class="cp-label">Answer Options <span class="required">*</span> (at least 2, select the correct one)</label>
        <asp:Repeater ID="rptGCOptions" runat="server">
            <ItemTemplate>
                <div style="display:flex;gap:8px;align-items:center;margin-bottom:8px;">
                    <asp:RadioButton ID="rbGCCorrect" runat="server" GroupName="GCCorrectOption" />
                    <asp:TextBox ID="txtGCOption" runat="server" CssClass="cp-input"
                                 MaxLength="300" placeholder='<%# "Option " + Container.DataItem %>' />
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Button ID="btnAddGCQuestion" runat="server" Text="+ Add Question"
                    CssClass="cp-btn cp-btn-primary" style="margin-top:8px;"
                    ValidationGroup="AddGCQ" OnClick="btnAddGCQuestion_Click" />
    </div>

    <h3 style="font-size:14px;font-weight:600;margin:0 0 12px;">Existing Questions</h3>
    <asp:Panel ID="pnlGCQuestionsList" runat="server" Visible="false">
        <asp:Repeater ID="rptGCQuestions" runat="server" OnItemCommand="rptGCQuestions_ItemCommand">
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
    <asp:Panel ID="pnlNoGCQuestions" runat="server" Visible="false">
        <div class="cp-card" style="text-align:center;padding:20px;color:var(--cp-text-muted);font-size:13px;">
            No questions yet. Add at least one so students can join this challenge.
        </div>
    </asp:Panel>
</asp:Panel>

</asp:Content>
