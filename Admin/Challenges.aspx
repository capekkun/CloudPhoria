<<<<<<< HEAD
<%@ Page Title="Challenges" Language="C#" MasterPageFile="~/Site.Master"
=======
<%@ Page Title="Global Challenges" Language="C#" MasterPageFile="~/Site.Master"
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
    AutoEventWireup="true" CodeBehind="Challenges.aspx.cs"
    Inherits="CloudPhoria.Admin.Challenges" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<<<<<<< HEAD
    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x26A1; Challenges</h2>
                <p>Create and manage official admin challenges for the CloudPhoria platform.</p>
            </div>
            <div>
                <button type="button" class="cp-btn cp-btn-primary"
                    onclick="toggleCreatePanel();">
                    &#x2B; New Challenge
                </button>
            </div>
        </div>
    </div>

    <%-- Feedback --%>
    <asp:Panel ID="pnlMessage" runat="server" Visible="false" style="margin-bottom:16px;">
        <asp:Literal ID="litMessage" runat="server" />
    </asp:Panel>

    <%-- Create challenge form --%>
    <div id="createPanel" style="display:none;" class="cp-card cp-mb-lg">
        <h3 style="font-size:15px;font-weight:700;margin:0 0 16px;">Create New Challenge</h3>
        <div class="cp-form-group">
            <label class="cp-label">Challenge Title <span class="required">*</span></label>
            <asp:TextBox ID="txtTitle" runat="server" CssClass="cp-input"
                MaxLength="150" placeholder="e.g. Cloud Security Sprint" />
            <asp:RequiredFieldValidator ID="rfvTitle" runat="server"
                ControlToValidate="txtTitle" ValidationGroup="Create"
                CssClass="cp-form-error" ErrorMessage="Title is required." Display="Dynamic" />
        </div>
        <div class="cp-form-group">
            <label class="cp-label">Description</label>
            <asp:TextBox ID="txtDescription" runat="server" CssClass="cp-textarea"
                TextMode="MultiLine" Rows="3"
                placeholder="Describe this challenge…" MaxLength="4000" />
        </div>
        <div class="cp-grid-2" style="gap:12px;">
            <div class="cp-form-group">
                <label class="cp-label">XP Reward <span class="required">*</span></label>
                <asp:TextBox ID="txtXPReward" runat="server" CssClass="cp-input"
                    TextMode="Number" placeholder="e.g. 100" />
                <asp:RequiredFieldValidator ID="rfvXP" runat="server"
                    ControlToValidate="txtXPReward" ValidationGroup="Create"
                    CssClass="cp-form-error" ErrorMessage="XP Reward is required." Display="Dynamic" />
                <asp:RangeValidator ID="rvXP" runat="server"
                    ControlToValidate="txtXPReward" ValidationGroup="Create"
                    Type="Integer" MinimumValue="1" MaximumValue="9999"
                    CssClass="cp-form-error" ErrorMessage="Enter 1–9999." Display="Dynamic" />
            </div>
            <div></div><%-- spacer --%>
            <div class="cp-form-group">
                <label class="cp-label">Start Date &amp; Time <span class="required">*</span></label>
                <asp:TextBox ID="txtStartDate" runat="server" CssClass="cp-input"
                    TextMode="DateTimeLocal" />
                <asp:RequiredFieldValidator ID="rfvStart" runat="server"
                    ControlToValidate="txtStartDate" ValidationGroup="Create"
                    CssClass="cp-form-error" ErrorMessage="Start date is required." Display="Dynamic" />
            </div>
            <div class="cp-form-group">
                <label class="cp-label">End Date &amp; Time <span class="required">*</span></label>
                <asp:TextBox ID="txtEndDate" runat="server" CssClass="cp-input"
                    TextMode="DateTimeLocal" />
                <asp:RequiredFieldValidator ID="rfvEnd" runat="server"
                    ControlToValidate="txtEndDate" ValidationGroup="Create"
                    CssClass="cp-form-error" ErrorMessage="End date is required." Display="Dynamic" />
            </div>
        </div>
        <div style="display:flex;gap:8px;margin-top:4px;">
            <asp:Button ID="btnCreate" runat="server" Text="Create Challenge"
                CssClass="cp-btn cp-btn-primary" ValidationGroup="Create"
                OnClick="btnCreate_Click" />
            <button type="button" class="cp-btn cp-btn-ghost"
                onclick="document.getElementById('createPanel').style.display='none';">
                Cancel
            </button>
        </div>
    </div>

    <%-- Stats row --%>
    <div class="cp-grid-3 cp-mb-lg">
        <div class="cp-stat-card">
            <div class="cp-stat-icon amber" aria-hidden="true">&#x26A1;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litActiveCount" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Active Now</div>
            </div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon blue" aria-hidden="true">&#x23F3;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litUpcomingCount" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Upcoming</div>
            </div>
        </div>
        <div class="cp-stat-card">
            <div class="cp-stat-icon green" aria-hidden="true">&#x2714;</div>
            <div>
                <div class="cp-stat-value"><asp:Literal ID="litEndedCount" runat="server" Text="0" /></div>
                <div class="cp-stat-label">Ended</div>
            </div>
        </div>
    </div>

    <%-- Challenges table --%>
    <asp:Panel ID="pnlList" runat="server" Visible="false">
        <div class="cp-table-wrap">
            <table class="cp-table" role="table" aria-label="Challenges list">
                <thead>
                    <tr>
                        <th>Title</th>
                        <th>Created By</th>
                        <th>XP Reward</th>
                        <th>Start</th>
                        <th>End</th>
                        <th>Participants</th>
                        <th>State</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptChallenges" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <div style="font-weight:600;font-size:13px;">
                                        <%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %>
                                    </div>
                                    <div style="font-size:11px;color:var(--cp-text-muted);margin-top:2px;
                                                max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                                        <%# Eval("Description") != DBNull.Value
                                            ? HttpUtility.HtmlEncode(Eval("Description").ToString())
                                            : "" %>
                                    </div>
                                </td>
                                <td style="font-size:12px;">
                                    <%# Eval("CreatorName") != DBNull.Value
                                        ? HttpUtility.HtmlEncode(Eval("CreatorName").ToString())
                                        : "<span style='color:var(--cp-text-muted);'>—</span>" %>
                                    <br/>
                                    <span class="cp-badge cp-badge-red" style="font-size:10px;">Admin</span>
                                </td>
                                <td>
                                    <span class="cp-xp-chip">&#x26A1; <%# Eval("XPReward") %> XP</span>
                                </td>
                                <td style="font-size:12px;color:var(--cp-text-muted);">
                                    <%# Convert.ToDateTime(Eval("StartDate")).ToString("dd MMM yyyy HH:mm") %>
                                </td>
                                <td style="font-size:12px;color:var(--cp-text-muted);">
                                    <%# Convert.ToDateTime(Eval("EndDate")).ToString("dd MMM yyyy HH:mm") %>
                                </td>
                                <td style="text-align:center;">
                                    <span class="cp-badge cp-badge-blue"><%# Eval("ParticipantCount") %></span>
                                </td>
                                <td>
                                    <%# GetChallengeStateBadge(
                                            Convert.ToDateTime(Eval("StartDate")),
                                            Convert.ToDateTime(Eval("EndDate"))) %>
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
            <span class="cp-empty-state-icon" aria-hidden="true">&#x26A1;</span>
            <h3>No challenges yet</h3>
            <p>Create a challenge using the button above.</p>
        </div>
    </asp:Panel>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
<script>
function toggleCreatePanel() {
    var p = document.getElementById('createPanel');
    p.style.display = (p.style.display === 'none' || p.style.display === '') ? 'block' : 'none';
}
</script>
</asp:Content>
=======
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
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
