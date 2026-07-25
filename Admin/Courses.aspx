<%@ Page Title="Manage Courses" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Courses.aspx.cs"
    Inherits="CloudPhoria.Admin.Courses" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

<div class="cp-page-header">
    <h2>Manage Courses</h2>
    <p>Create modules, subtopics and questions, assign instructors, and moderate published content. Only Admin can create or edit learning content — Instructors manage the classroom side (materials, assignments, challenges) for whatever is assigned to them.</p>
</div>

<asp:Panel ID="pnlSuccess" runat="server" Visible="false">
    <div class="cp-alert cp-alert-success cp-mb-md"><asp:Literal ID="litSuccess" runat="server" /></div>
</asp:Panel>
<asp:Panel ID="pnlError" runat="server" Visible="false">
    <div class="cp-alert cp-alert-danger cp-mb-md"><asp:Literal ID="litError" runat="server" /></div>
</asp:Panel>

<%-- ============== TOP-LEVEL: Pathways + Modules (default view) ============== --%>
<asp:Panel ID="pnlModulesSection" runat="server" Visible="true">

<h3 style="font-size:15px;font-weight:600;margin:0 0 12px;">Pathways</h3>
<div class="cp-grid-3 cp-mb-lg">
    <asp:Repeater ID="rptPathwaysAdmin" runat="server">
        <ItemTemplate>
            <div class="cp-card">
                <div style="font-size:14px;font-weight:700;color:var(--cp-text);">
                    <%# HttpUtility.HtmlEncode(Eval("PathwayName").ToString()) %>
                </div>
                <div style="font-size:12px;color:var(--cp-text-muted);margin-top:4px;">
                    <%# Eval("ModuleCount") %> modules
                    <%# Convert.ToBoolean(Eval("IsFoundation")) ? " &bull; Foundation (Free)" : "" %>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
</div>

<div class="cp-card cp-mb-lg" style="max-width:640px;">
    <h3 style="font-size:14px;font-weight:600;margin:0 0 12px;">Create a New Module</h3>

    <div class="cp-form-group">
        <label class="cp-label" for="<%= ddlModulePathway.ClientID %>">Pathway <span class="required">*</span></label>
        <asp:DropDownList ID="ddlModulePathway" runat="server" CssClass="cp-select" />
    </div>

    <div class="cp-form-group">
        <label class="cp-label" for="<%= txtModuleName.ClientID %>">Module Name <span class="required">*</span></label>
        <asp:TextBox ID="txtModuleName" runat="server" CssClass="cp-input" MaxLength="150"
                     placeholder="e.g. Introduction to Cloud Computing" />
        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtModuleName"
            Display="Dynamic" CssClass="cp-form-error"
            ValidationGroup="CreateModule" ErrorMessage="Module name is required." />
    </div>

    <div class="cp-form-group">
        <label class="cp-label" for="<%= txtModuleDesc.ClientID %>">Description</label>
        <asp:TextBox ID="txtModuleDesc" runat="server" CssClass="cp-textarea" TextMode="MultiLine" Rows="2"
                     placeholder="Brief description of this module..." />
    </div>

    <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
        <div class="cp-form-group">
            <label class="cp-label" for="<%= ddlModuleDifficulty.ClientID %>">Difficulty</label>
            <asp:DropDownList ID="ddlModuleDifficulty" runat="server" CssClass="cp-select">
                <asp:ListItem Value="Easy">Easy</asp:ListItem>
                <asp:ListItem Value="Medium" Selected="True">Medium</asp:ListItem>
                <asp:ListItem Value="Hard">Hard</asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="cp-form-group">
            <label class="cp-label" for="<%= txtModuleXP.ClientID %>">XP Reward</label>
            <asp:TextBox ID="txtModuleXP" runat="server" CssClass="cp-input" TextMode="Number" Text="100" />
        </div>
    </div>

    <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
        <div class="cp-form-group">
            <label class="cp-label" for="<%= txtModuleExamDuration.ClientID %>">Exam Duration (min)</label>
            <asp:TextBox ID="txtModuleExamDuration" runat="server" CssClass="cp-input" TextMode="Number" Text="60" />
        </div>
        <div class="cp-form-group">
            <label class="cp-label" for="<%= txtModulePassMark.ClientID %>">Pass Mark (%)</label>
            <asp:TextBox ID="txtModulePassMark" runat="server" CssClass="cp-input" TextMode="Number" Text="70" />
        </div>
    </div>

    <asp:Button ID="btnCreateModule" runat="server" Text="+ Create Module"
                CssClass="cp-btn cp-btn-primary" style="margin-top:4px;"
                ValidationGroup="CreateModule" OnClick="btnCreateModule_Click" />
</div>

<h3 style="font-size:15px;font-weight:600;margin:0 0 12px;">Modules — Manage Content, Assign Instructor &amp; Moderate</h3>
<div class="cp-table-wrap">
    <table class="cp-table">
        <thead><tr><th>Module</th><th>Pathway</th><th>Subtopics</th><th>Instructor</th><th>Status</th><th>Actions</th></tr></thead>
        <tbody>
            <asp:Repeater ID="rptModulesAdmin" runat="server" OnItemCommand="rptModulesAdmin_ItemCommand" OnItemDataBound="rptModulesAdmin_ItemDataBound">
                <ItemTemplate>
                    <tr>
                        <td><%# HttpUtility.HtmlEncode(Eval("ModuleName").ToString()) %></td>
                        <td style="font-size:12px;color:var(--cp-text-muted);"><%# HttpUtility.HtmlEncode(Eval("PathwayName").ToString()) %></td>
                        <td><span class="cp-badge cp-badge-blue"><%# Eval("SubTopicCount") %></span></td>
                        <td>
                            <asp:DropDownList runat="server" ID="ddlAssignInstructor" CssClass="cp-select" style="font-size:12px;padding:4px 8px;">
                            </asp:DropDownList>
                        </td>
                        <td>
                            <%# Convert.ToBoolean(Eval("IsPublished")) ? "<span class='cp-badge cp-badge-green'>Published</span>"
                                : "<span class='cp-badge cp-badge-grey'>Draft</span>" %>
                        </td>
                        <td>
                            <div style="display:flex;gap:6px;flex-wrap:wrap;">
                                <a href='Courses.aspx?moduleID=<%# Eval("ModuleID") %>' class="cp-btn cp-btn-outline cp-btn-sm">Subtopics</a>
                                <asp:LinkButton runat="server" CommandName="Assign" CommandArgument='<%# Eval("ModuleID") %>'
                                    CssClass="cp-btn cp-btn-outline cp-btn-sm">Assign</asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="TogglePublish" CommandArgument='<%# Eval("ModuleID") %>'
                                    CssClass="cp-btn cp-btn-outline cp-btn-sm">
                                    <%# Convert.ToBoolean(Eval("IsPublished")) ? "Unpublish" : "Publish" %>
                                </asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="DeleteModule" CommandArgument='<%# Eval("ModuleID") %>'
                                    CssClass="cp-btn cp-btn-danger cp-btn-sm"
                                    OnClientClick="return confirm('Delete this module and all its content?');">Delete</asp:LinkButton>
                            </div>
                        </td>
                    </tr>
                </ItemTemplate>
            </asp:Repeater>
        </tbody>
    </table>
</div>

</asp:Panel>

<%-- ============== DRILL-DOWN: Manage SubTopics (?moduleID=) ============== --%>
<asp:Panel ID="pnlManageSubTopics" runat="server" Visible="false">
    <div class="cp-page-header-row" style="margin-bottom:16px;">
        <div>
            <h2>Subtopics &mdash; <asp:Literal ID="litManageModuleTitle" runat="server" /></h2>
            <p>Create and manage lesson subtopics for this module.</p>
        </div>
        <a href="Courses.aspx" class="cp-btn cp-btn-ghost">&#x2190; Back to Courses</a>
    </div>

    <div class="cp-card cp-mb-md" style="max-width:640px;">
        <h3 style="font-size:14px;font-weight:600;margin:0 0 12px;">Add a Subtopic</h3>

        <div class="cp-form-group">
            <label class="cp-label" for="<%= txtSTName.ClientID %>">Subtopic Name <span class="required">*</span></label>
            <asp:TextBox ID="txtSTName" runat="server" CssClass="cp-input" MaxLength="150"
                         placeholder="e.g. What is Cloud Computing?" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtSTName"
                Display="Dynamic" CssClass="cp-form-error"
                ValidationGroup="AddST" ErrorMessage="Subtopic name is required." />
        </div>

        <div class="cp-form-group">
            <label class="cp-label" for="<%= txtSTContent.ClientID %>">Content / Lesson Body</label>
            <asp:TextBox ID="txtSTContent" runat="server" CssClass="cp-textarea" TextMode="MultiLine" Rows="4"
                         placeholder="Write the lesson content here..." />
        </div>

        <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtSTOrder.ClientID %>">Order Index</label>
                <asp:TextBox ID="txtSTOrder" runat="server" CssClass="cp-input" TextMode="Number" Text="0" />
            </div>
            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtSTXPReward.ClientID %>">XP Reward</label>
                <asp:TextBox ID="txtSTXPReward" runat="server" CssClass="cp-input" TextMode="Number" Text="10" />
            </div>
        </div>

        <asp:Button ID="btnAddSubTopic" runat="server" Text="+ Add Subtopic"
                    CssClass="cp-btn cp-btn-primary" style="margin-top:4px;"
                    ValidationGroup="AddST" OnClick="btnAddSubTopic_Click" />
    </div>

    <h3 style="font-size:14px;font-weight:600;margin:0 0 12px;">Existing Subtopics</h3>
    <asp:Panel ID="pnlSubTopicsList" runat="server" Visible="false">
        <asp:Repeater ID="rptManageSubTopics" runat="server" OnItemCommand="rptManageSubTopics_ItemCommand">
            <ItemTemplate>
                <div class="cp-card" style="margin-bottom:10px;">
                    <div class="cp-flex-between" style="flex-wrap:wrap;gap:10px;">
                        <div>
                            <div style="font-size:13px;font-weight:600;color:var(--cp-text);">
                                <%# HttpUtility.HtmlEncode(Eval("SubTopicName").ToString()) %>
                            </div>
                            <div style="font-size:12px;color:var(--cp-text-muted);margin-top:4px;">
                                Order <%# Eval("OrderIndex") %> &bull; <%# Eval("XPReward") %> XP &bull;
                                <%# Eval("QuestionCount") %> question(s) &bull;
                                <%# Convert.ToBoolean(Eval("IsPublished"))
                                    ? "<span class='cp-badge cp-badge-green'>Published</span>"
                                    : "<span class='cp-badge cp-badge-grey'>Draft</span>" %>
                            </div>
                        </div>
                        <div style="display:flex;gap:6px;flex-wrap:wrap;">
                            <a href='Courses.aspx?subTopicID=<%# Eval("SubTopicID") %>' class="cp-btn cp-btn-outline cp-btn-sm">Questions</a>
                            <asp:LinkButton runat="server" CommandName="TogglePublishST" CommandArgument='<%# Eval("SubTopicID") %>'
                                CssClass="cp-btn cp-btn-outline cp-btn-sm">
                                <%# Convert.ToBoolean(Eval("IsPublished")) ? "Unpublish" : "Publish" %>
                            </asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="DeleteSubTopic" CommandArgument='<%# Eval("SubTopicID") %>'
                                CssClass="cp-btn cp-btn-danger cp-btn-sm"
                                OnClientClick="return confirm('Delete this subtopic?');">Delete</asp:LinkButton>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>
    <asp:Panel ID="pnlNoSubTopics" runat="server" Visible="false">
        <div class="cp-card" style="text-align:center;padding:20px;color:var(--cp-text-muted);font-size:13px;">
            No subtopics yet. Add one above.
        </div>
    </asp:Panel>
</asp:Panel>

<%-- ============== DRILL-DOWN: Manage Questions (?subTopicID=) ============== --%>
<asp:Panel ID="pnlManageQuestions" runat="server" Visible="false">
    <div class="cp-page-header-row" style="margin-bottom:16px;">
        <div>
            <h2>Questions &mdash; <asp:Literal ID="litManageSubTopicTitle" runat="server" /></h2>
            <p>Manage inline questions (MCQ, Regex, StringMatch) for this subtopic.</p>
        </div>
        <a href="Courses.aspx" class="cp-btn cp-btn-ghost">&#x2190; Back to Courses</a>
    </div>

    <div class="cp-card cp-mb-md" style="max-width:640px;">
        <h3 style="font-size:14px;font-weight:600;margin:0 0 12px;">Add a Question</h3>

        <div class="cp-form-group">
            <label class="cp-label" for="<%= txtQText.ClientID %>">Question Text <span class="required">*</span></label>
            <asp:TextBox ID="txtQText" runat="server" CssClass="cp-textarea" TextMode="MultiLine" Rows="3"
                         placeholder="Enter the question..." />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtQText"
                Display="Dynamic" CssClass="cp-form-error"
                ValidationGroup="AddQ" ErrorMessage="Question text is required." />
        </div>

        <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
            <div class="cp-form-group">
                <label class="cp-label" for="<%= ddlQuestionType.ClientID %>">Type</label>
                <asp:DropDownList ID="ddlQuestionType" runat="server" CssClass="cp-select"
                                  AutoPostBack="true" OnSelectedIndexChanged="ddlQuestionType_Changed">
                    <asp:ListItem Value="MCQ" Selected="True">MCQ</asp:ListItem>
                    <asp:ListItem Value="Regex">Regex</asp:ListItem>
                    <asp:ListItem Value="StringMatch">StringMatch</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtQXPReward.ClientID %>">XP Reward</label>
                <asp:TextBox ID="txtQXPReward" runat="server" CssClass="cp-input" TextMode="Number" Text="5" />
            </div>
        </div>

        <div class="cp-form-group">
            <label class="cp-label" for="<%= txtQOrder.ClientID %>">Order Index</label>
            <asp:TextBox ID="txtQOrder" runat="server" CssClass="cp-input" TextMode="Number" Text="0" />
        </div>

        <div class="cp-form-group">
            <label class="cp-label" for="<%= txtQCorrectAnswer.ClientID %>">
                Correct Answer <span class="required">*</span>
                <span style="font-weight:400;color:var(--cp-text-muted);font-size:11px;">
                    (pattern for Regex; exact string for StringMatch; also required for MCQ)
                </span>
            </label>
            <asp:TextBox ID="txtQCorrectAnswer" runat="server" CssClass="cp-input"
                         placeholder="e.g. ^[Cc]loud$ or exact answer text" />
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtQCorrectAnswer"
                Display="Dynamic" CssClass="cp-form-error"
                ValidationGroup="AddQ" ErrorMessage="Correct answer is required." />
        </div>

        <asp:Panel ID="pnlMCQOptionsAdmin" runat="server">
            <div class="cp-alert cp-alert-info" style="margin-bottom:12px;">
                <span>&#x2139;</span>
                <span>Enter up to 4 options. Check the correct one.</span>
            </div>
            <asp:Repeater ID="rptQOptions" runat="server">
                <ItemTemplate>
                    <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px;">
                        <asp:CheckBox ID="chkQCorrect" runat="server" />
                        <asp:TextBox ID="txtQOption" runat="server" CssClass="cp-input"
                                     placeholder='<%# "Option " + Container.DataItem %>' style="flex:1;" />
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>

        <asp:Button ID="btnAddQuestion" runat="server" Text="+ Add Question"
                    CssClass="cp-btn cp-btn-primary" style="margin-top:4px;"
                    ValidationGroup="AddQ" OnClick="btnAddQuestion_Click" />
    </div>

    <h3 style="font-size:14px;font-weight:600;margin:0 0 12px;">Existing Questions</h3>
    <asp:Panel ID="pnlQuestionsList" runat="server" Visible="false">
        <asp:Repeater ID="rptManageQuestions" runat="server" OnItemCommand="rptManageQuestions_ItemCommand">
            <ItemTemplate>
                <div class="cp-card" style="margin-bottom:10px;">
                    <div class="cp-flex-between" style="flex-wrap:wrap;gap:10px;">
                        <div>
                            <div style="font-size:13px;font-weight:600;color:var(--cp-text);max-width:420px;word-break:break-word;">
                                <%# HttpUtility.HtmlEncode(Eval("QuestionText").ToString()) %>
                            </div>
                            <div style="font-size:12px;color:var(--cp-text-muted);margin-top:4px;">
                                <span class='cp-badge <%# GetQTypeBadge(Eval("QuestionType").ToString()) %>'>
                                    <%# HttpUtility.HtmlEncode(Eval("QuestionType").ToString()) %>
                                </span>
                                &bull; <%# Eval("XPReward") %> XP &bull; order <%# Eval("OrderIndex") %>
                            </div>
                        </div>
                        <asp:LinkButton runat="server" CommandName="DeleteQuestion" CommandArgument='<%# Eval("QuestionID") %>'
                            CssClass="cp-btn cp-btn-danger cp-btn-sm"
                            OnClientClick="return confirm('Delete this question?');">Delete</asp:LinkButton>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>
    <asp:Panel ID="pnlNoQuestions" runat="server" Visible="false">
        <div class="cp-card" style="text-align:center;padding:20px;color:var(--cp-text-muted);font-size:13px;">
            No questions yet. Add one above.
        </div>
    </asp:Panel>
</asp:Panel>

</asp:Content>
