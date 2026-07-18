<%@ Page Title="Assignments" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Assignments.aspx.cs"
    Inherits="CloudPhoria.Instructor.Assignments" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>&#x1F4DD; Assignments</h2>
                <p>Create and manage assignments for your classrooms. Review student submissions.</p>
            </div>
            <asp:Panel ID="pnlCreateBtn" runat="server" Visible="false">
                <button type="button" class="cp-btn cp-btn-primary" onclick="showModal('createModal')">
                    + New Assignment
                </button>
            </asp:Panel>
        </div>
    </div>

    <%-- Classroom filter --%>
    <div class="cp-card cp-mb-md" style="padding:16px 20px;">
        <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
            <label class="cp-label" style="margin:0;white-space:nowrap;" for="<%= ddlClassroom.ClientID %>">Filter by Classroom:</label>
            <asp:DropDownList ID="ddlClassroom" runat="server" CssClass="cp-select"
                              AutoPostBack="true" OnSelectedIndexChanged="ddlClassroom_Changed"
                              style="max-width:360px;" />
        </div>
    </div>

    <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
        <div class="cp-alert cp-alert-success"><span>&#x2714;</span>
            <asp:Literal ID="litSuccess" runat="server" /></div>
    </asp:Panel>
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger"><span>&#x26A0;</span>
            <asp:Literal ID="litError" runat="server" /></div>
    </asp:Panel>

    <asp:Panel ID="pnlAssignments" runat="server" Visible="false">
        <asp:Repeater ID="rptAssignments" runat="server"
                      OnItemCommand="rptAssignments_ItemCommand">
            <ItemTemplate>
                <div class="cp-card" style="margin-bottom:16px;">
                    <div class="cp-flex-between" style="flex-wrap:wrap;gap:10px;">
                        <div>
                            <div style="font-size:16px;font-weight:700;color:var(--cp-text);">
                                <%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %>
                            </div>
                            <div style="font-size:12px;color:var(--cp-text-muted);margin-top:4px;">
                                <span class="cp-badge cp-badge-indigo"><%# HttpUtility.HtmlEncode(Eval("ClassroomName").ToString()) %></span>
                                &bull; Created <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %>
                                <%# Eval("DueDate") != DBNull.Value
                                    ? " &bull; Due " + Convert.ToDateTime(Eval("DueDate")).ToString("dd MMM yyyy")
                                    : "" %>
                            </div>
                        </div>
                        <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
                            <span class="cp-badge cp-badge-amber"><%# Eval("SubmissionCount") %> submission(s)</span>
                            <a href='Assignments.aspx?assignmentID=<%# Eval("AssignmentID") %>'
                               class="cp-btn cp-btn-outline cp-btn-sm">View Submissions</a>
                            <asp:LinkButton runat="server"
                                CommandName="Delete"
                                CommandArgument='<%# Eval("AssignmentID") %>'
                                CssClass="cp-btn cp-btn-danger cp-btn-sm"
                                OnClientClick="return confirm('Delete this assignment?');">
                                Delete
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="cp-empty-state">
            <span class="cp-empty-state-icon" aria-hidden="true">&#x1F4DD;</span>
            <h3>No assignments yet</h3>
            <p>Create an assignment to start receiving student submissions.</p>
        </div>
    </asp:Panel>

    <%-- Submissions panel (when ?assignmentID= provided) --%>
    <asp:Panel ID="pnlSubmissions" runat="server" Visible="false">
        <h3 style="font-size:15px;font-weight:600;margin:24px 0 12px;">
            Submissions &mdash;
            <asp:Literal ID="litAssignmentTitle" runat="server" />
        </h3>
        <div class="cp-table-wrap">
            <table class="cp-table" role="grid">
                <thead>
                    <tr>
                        <th>Student</th>
                        <th>Question</th>
                        <th>Answer</th>
                        <th>Submitted</th>
                        <th>Feedback</th>
                        <th>Grade</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptSubmissions" runat="server"
                                  OnItemCommand="rptSubmissions_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td><%# HttpUtility.HtmlEncode(Eval("StudentName").ToString()) %></td>
                                <td style="max-width:200px;word-break:break-word;font-size:12px;">
                                    <%# HttpUtility.HtmlEncode(Eval("QuestionText").ToString()) %>
                                </td>
                                <td style="max-width:200px;word-break:break-word;">
                                    <%# HttpUtility.HtmlEncode(Eval("AnswerText") != DBNull.Value ? Eval("AnswerText").ToString() : "-") %>
                                </td>
                                <td style="color:var(--cp-text-muted);font-size:12px;">
                                    <%# Convert.ToDateTime(Eval("SubmittedAt")).ToString("dd MMM yyyy") %>
                                </td>
                                <td>
                                    <%# Eval("FeedbackText") != DBNull.Value
                                        ? "<span class='cp-badge cp-badge-green'>Given</span>"
                                        : "<span class='cp-badge cp-badge-grey'>Pending</span>" %>
                                </td>
                                <td>
                                    <%# Eval("Grade") != DBNull.Value
                                        ? "<strong>" + HttpUtility.HtmlEncode(Eval("Grade").ToString()) + "</strong>"
                                        : "<span style='color:var(--cp-text-muted)'>-</span>" %>
                                    <asp:LinkButton runat="server"
                                        CommandName="GiveFeedback"
                                        CommandArgument='<%# Eval("SubmissionID") %>'
                                        CssClass="cp-btn cp-btn-outline cp-btn-sm"
                                        style="margin-left:6px;">
                                        <%# Eval("FeedbackText") != DBNull.Value ? "Edit" : "Grade" %>
                                    </asp:LinkButton>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>

    <%-- Feedback / Grade modal --%>
    <div id="feedbackModal" class="cp-modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="fbTitle">
        <div class="cp-modal">
            <button class="cp-modal-close" type="button" onclick="hideModal('feedbackModal')" aria-label="Close">&#x2715;</button>
            <h2 class="cp-modal-title" id="fbTitle">Give Feedback</h2>
            <asp:HiddenField ID="hfSubmissionID" runat="server" />
            <asp:HiddenField ID="hfAssignmentIDFb" runat="server" />
            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtFeedback.ClientID %>">Feedback <span class="required">*</span></label>
                <asp:TextBox ID="txtFeedback" runat="server" CssClass="cp-textarea"
                             TextMode="MultiLine" Rows="4" placeholder="Write your feedback..." />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtFeedback"
                    Display="Dynamic" CssClass="cp-form-error"
                    ValidationGroup="GiveFB" ErrorMessage="Feedback text is required." />
            </div>
            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtGrade.ClientID %>">Grade (optional)</label>
                <asp:TextBox ID="txtGrade" runat="server" CssClass="cp-input"
                             MaxLength="10" placeholder="e.g. A, B+, 85" />
            </div>
            <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:12px;">
                <button type="button" class="cp-btn cp-btn-ghost" onclick="hideModal('feedbackModal')">Cancel</button>
                <asp:Button ID="btnSaveFeedback" runat="server" Text="Save Feedback"
                            CssClass="cp-btn cp-btn-primary"
                            ValidationGroup="GiveFB"
                            OnClick="btnSaveFeedback_Click" />
            </div>
        </div>
    </div>

    <%-- Create Assignment Modal --%>
    <div id="createModal" class="cp-modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="createATitle">
        <div class="cp-modal" style="max-width:560px;">
            <button class="cp-modal-close" type="button" onclick="hideModal('createModal')" aria-label="Close">&#x2715;</button>
            <h2 class="cp-modal-title" id="createATitle">New Assignment</h2>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= ddlClassroomCreate.ClientID %>">Classroom <span class="required">*</span></label>
                <asp:DropDownList ID="ddlClassroomCreate" runat="server" CssClass="cp-select" />
            </div>
            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtTitle.ClientID %>">Title <span class="required">*</span></label>
                <asp:TextBox ID="txtTitle" runat="server" CssClass="cp-input"
                             MaxLength="150" placeholder="Assignment title" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtTitle"
                    Display="Dynamic" CssClass="cp-form-error"
                    ValidationGroup="CreateA" ErrorMessage="Title is required." />
            </div>
            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtADesc.ClientID %>">Description</label>
                <asp:TextBox ID="txtADesc" runat="server" CssClass="cp-textarea"
                             TextMode="MultiLine" Rows="3" placeholder="Instructions for students..." />
            </div>
            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtDueDate.ClientID %>">Due Date (optional)</label>
                <asp:TextBox ID="txtDueDate" runat="server" CssClass="cp-input" TextMode="DateTime" />
            </div>
            <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:12px;">
                <button type="button" class="cp-btn cp-btn-ghost" onclick="hideModal('createModal')">Cancel</button>
                <asp:Button ID="btnCreate" runat="server" Text="Create Assignment"
                            CssClass="cp-btn cp-btn-primary"
                            ValidationGroup="CreateA"
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
