<%@ Page Title="Assignments" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Assignments.aspx.cs"
    Inherits="CloudPhoria.Instructor.Assignments" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* Section separator */
.cp-section-divider {
    border: none;
    border-top: 2px solid var(--cp-border);
    margin: 32px 0 24px;
}
/* Detail header info strip */
.cp-detail-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 24px;
    background: var(--cp-surface);
    border: 1px solid var(--cp-border);
    border-radius: 10px;
    padding: 14px 20px;
    margin-bottom: 16px;
    font-size: 13px;
}
.cp-detail-meta span { color: var(--cp-text-muted); }
.cp-detail-meta strong { color: var(--cp-text); }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ═══════════════════════════════════════════════════════════
         PAGE HEADER
    ═══════════════════════════════════════════════════════════ --%>
    <div class="cp-page-header">
        <div class="cp-page-header-row">
            <div>
                <h2>Assignments</h2>
                <p>Create and manage assignments. Review student submissions below.</p>
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
            <label class="cp-label" style="margin:0;white-space:nowrap;"
                   for="<%= ddlClassroom.ClientID %>">Filter by Classroom:</label>
            <asp:DropDownList ID="ddlClassroom" runat="server" CssClass="cp-select"
                              AutoPostBack="true" OnSelectedIndexChanged="ddlClassroom_Changed"
                              style="max-width:360px;" />
        </div>
    </div>

    <%-- Feedback banners --%>
    <asp:Panel ID="pnlSuccess" runat="server" Visible="false">
        <div class="cp-alert cp-alert-success"><span></span>
            <asp:Literal ID="litSuccess" runat="server" /></div>
    </asp:Panel>
    <asp:Panel ID="pnlError" runat="server" Visible="false">
        <div class="cp-alert cp-alert-danger"><span></span>
            <asp:Literal ID="litError" runat="server" /></div>
    </asp:Panel>

    <%-- ═══════════════════════════════════════════════════════════
         SECTION 1 — ASSIGNMENT LIST
    ═══════════════════════════════════════════════════════════ --%>
    <asp:Panel ID="pnlAssignments" runat="server" Visible="false">
        <asp:Repeater ID="rptAssignments" runat="server"
                      OnItemCommand="rptAssignments_ItemCommand">
            <ItemTemplate>
                <div class="cp-card" style="margin-bottom:12px;">
                    <div class="cp-flex-between" style="flex-wrap:wrap;gap:10px;">
                        <div>
                            <div style="font-size:16px;font-weight:700;color:var(--cp-text);">
                                <%# HttpUtility.HtmlEncode(Eval("Title").ToString()) %>
                            </div>
                            <div style="font-size:12px;color:var(--cp-text-muted);margin-top:4px;">
                                <span class="cp-badge cp-badge-indigo">
                                    <%# HttpUtility.HtmlEncode(Eval("ClassroomName").ToString()) %>
                                </span>
                                &bull; Created <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %>
                                <%# Eval("DueDate") != DBNull.Value
                                    ? " &bull; Due " + Convert.ToDateTime(Eval("DueDate")).ToString("dd MMM yyyy")
                                    : "" %>
                            </div>
                        </div>
                        <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
                            <span class="cp-badge cp-badge-amber">
                                <%# Eval("SubmissionCount") %> submission(s)
                            </span>
                            <%-- PostBack command so Section 2 loads on the same page --%>
                            <asp:LinkButton runat="server"
                                CommandName="ViewStudents"
                                CommandArgument='<%# Eval("AssignmentID") + "|" + Eval("Title") %>'
                                CssClass="cp-btn cp-btn-outline cp-btn-sm">
                                View Submissions
                            </asp:LinkButton>
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
            <h3>No assignments yet</h3>
            <p>Create an assignment to start receiving student submissions.</p>
        </div>
    </asp:Panel>

    <%-- ═══════════════════════════════════════════════════════════
         SECTION 2 — SUBMITTED STUDENTS
    ═══════════════════════════════════════════════════════════ --%>
    <asp:Panel ID="pnlSection2" runat="server" Visible="false">
        <hr class="cp-section-divider" />

        <div style="display:flex;align-items:center;justify-content:space-between;
                    flex-wrap:wrap;gap:10px;margin-bottom:14px;">
            <div>
                <h3 style="font-size:16px;font-weight:700;margin:0 0 4px;">
                    Submitted Students
                </h3>
                <div style="font-size:13px;color:var(--cp-text-muted);">
                    Assignment: <strong><asp:Literal ID="litSection2Title" runat="server" /></strong>
                </div>
            </div>
            <asp:LinkButton ID="btnBackToAssignments" runat="server"
                CssClass="cp-btn cp-btn-ghost cp-btn-sm"
                OnClick="btnBackToAssignments_Click">
                &#x2190; Back
            </asp:LinkButton>
        </div>

        <%-- Hidden field carries the selected assignment ID across postbacks --%>
        <asp:HiddenField ID="hfSelectedAssignmentID" runat="server" />
        <asp:HiddenField ID="hfSelectedAssignmentTitle" runat="server" />

        <asp:Panel ID="pnlStudentList" runat="server" Visible="false">
            <div class="cp-table-wrap">
                <table class="cp-table" role="grid" aria-label="Submitted students">
                    <thead>
                        <tr>
                            <th scope="col">Student Name</th>
                            <th scope="col">Assignment</th>
                            <th scope="col">Submitted Date</th>
                            <th scope="col">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptStudents" runat="server"
                                      OnItemCommand="rptStudents_ItemCommand">
                            <ItemTemplate>
                                <tr>
                                    <td style="font-weight:600;">
                                        <%# HttpUtility.HtmlEncode(Eval("StudentName").ToString()) %>
                                    </td>
                                    <td style="color:var(--cp-text-muted);">
                                        <%# HttpUtility.HtmlEncode(Eval("AssignmentTitle").ToString()) %>
                                    </td>
                                    <td style="color:var(--cp-text-muted);">
                                        <%# Convert.ToDateTime(Eval("SubmittedAt")).ToString("dd MMM yyyy HH:mm") %>
                                    </td>
                                    <td>
                                        <asp:LinkButton runat="server"
                                            CommandName="ViewDetail"
                                            CommandArgument='<%# Eval("StudentID") + "|" + Eval("StudentName") + "|" + Eval("SubmittedAt") %>'
                                            CssClass="cp-btn cp-btn-outline cp-btn-sm">
                                            View
                                        </asp:LinkButton>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlNoStudents" runat="server" Visible="false">
            <div class="cp-empty-state" style="padding:24px 16px;">
                <h3>No submissions yet</h3>
                <p>No students have submitted this assignment.</p>
            </div>
        </asp:Panel>
    </asp:Panel>

    <%-- ═══════════════════════════════════════════════════════════
         SECTION 3 — STUDENT SUBMISSION DETAIL
    ═══════════════════════════════════════════════════════════ --%>
    <asp:Panel ID="pnlSection3" runat="server" Visible="false">
        <hr class="cp-section-divider" />

        <div style="display:flex;align-items:center;justify-content:space-between;
                    flex-wrap:wrap;gap:10px;margin-bottom:14px;">
            <h3 style="font-size:16px;font-weight:700;margin:0;">
                Student Submission Detail
            </h3>
            <asp:LinkButton ID="btnBackToStudents" runat="server"
                CssClass="cp-btn cp-btn-ghost cp-btn-sm"
                OnClick="btnBackToStudents_Click">
                &#x2190; Back to Students
            </asp:LinkButton>
        </div>

        <%-- Hidden fields for Section 3 context --%>
        <asp:HiddenField ID="hfDetailStudentID"    runat="server" />
        <asp:HiddenField ID="hfDetailStudentName"  runat="server" />
        <asp:HiddenField ID="hfDetailSubmittedAt"  runat="server" />
        <%-- Feedback modal state --%>
        <asp:HiddenField ID="hfSubmissionID"       runat="server" />
        <asp:HiddenField ID="hfAssignmentIDFb"     runat="server" />
        <asp:HiddenField ID="hfExistingFeedback"   runat="server" />
        <asp:HiddenField ID="hfExistingGrade"      runat="server" />

        <%-- Info strip --%>
        <div class="cp-detail-meta">
            <div>
                <span>Student Name:&nbsp;</span>
                <strong><asp:Literal ID="litDetailStudentName" runat="server" /></strong>
            </div>
            <div>
                <span>Assignment:&nbsp;</span>
                <strong><asp:Literal ID="litDetailAssignmentTitle" runat="server" /></strong>
            </div>
            <div>
                <span>Submitted Date:&nbsp;</span>
                <strong><asp:Literal ID="litDetailSubmittedAt" runat="server" /></strong>
            </div>
        </div>

        <%-- Question/Answer detail table --%>
        <div class="cp-table-wrap">
            <table class="cp-table" role="grid" aria-label="Submission detail">
                <thead>
                    <tr>
                        <th scope="col" style="width:28%;">Question</th>
                        <th scope="col" style="width:22%;">Answer</th>
                        <th scope="col" style="width:10%;">Feedback Status</th>
                        <th scope="col" style="width:22%;">Feedback Comment</th>
                        <th scope="col" style="width:8%;">Grade</th>
                        <th scope="col" style="width:10%;">Mark</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptDetail" runat="server"
                                  OnItemCommand="rptDetail_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td style="font-size:13px;word-break:break-word;vertical-align:top;">
                                    <%# HttpUtility.HtmlEncode(Eval("QuestionText").ToString()) %>
                                    <div style="margin-top:4px;">
                                        <span class="cp-badge cp-badge-grey" style="font-size:10px;">
                                            <%# HttpUtility.HtmlEncode(Eval("QuestionType").ToString()) %>
                                        </span>
                                    </div>
                                </td>
                                <td style="font-size:13px;word-break:break-word;vertical-align:top;">
                                    <%# Eval("AnswerText") != DBNull.Value && !string.IsNullOrEmpty(Eval("AnswerText").ToString())
                                        ? HttpUtility.HtmlEncode(Eval("AnswerText").ToString())
                                        : "<em style='color:var(--cp-text-muted);'>No answer</em>" %>
                                </td>
                                <td style="vertical-align:top;">
                                    <%# Eval("FeedbackText") != DBNull.Value
                                        ? "<span class='cp-badge cp-badge-green'>Given</span>"
                                        : "<span class='cp-badge cp-badge-amber'>Pending</span>" %>
                                </td>
                                <td style="font-size:12px;word-break:break-word;vertical-align:top;
                                           color:var(--cp-text-muted);">
                                    <%# Eval("FeedbackText") != DBNull.Value
                                        ? HttpUtility.HtmlEncode(Eval("FeedbackText").ToString())
                                        : "<em>—</em>" %>
                                </td>
                                <td style="vertical-align:top;font-weight:600;">
                                    <%# Eval("Grade") != DBNull.Value && !string.IsNullOrEmpty(Eval("Grade").ToString())
                                        ? HttpUtility.HtmlEncode(Eval("Grade").ToString())
                                        : "<span style='color:var(--cp-text-muted);font-weight:400;'>—</span>" %>
                                </td>
                                <td style="vertical-align:top;">
                                    <asp:LinkButton runat="server"
                                        CommandName="OpenMark"
                                        CommandArgument='<%# Eval("SubmissionID") + "|" + (Eval("FeedbackText") != DBNull.Value ? HttpUtility.UrlEncode(Eval("FeedbackText").ToString()) : "") + "|" + (Eval("Grade") != DBNull.Value ? HttpUtility.UrlEncode(Eval("Grade").ToString()) : "") %>'
                                        CssClass="cp-btn cp-btn-primary cp-btn-sm">
                                        <%# Eval("FeedbackText") != DBNull.Value ? "Edit" : "Mark" %>
                                    </asp:LinkButton>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </asp:Panel>

    <%-- ═══════════════════════════════════════════════════════════
         MARK / FEEDBACK MODAL
    ═══════════════════════════════════════════════════════════ --%>
    <div id="feedbackModal" class="cp-modal-backdrop" role="dialog"
         aria-modal="true" aria-labelledby="fbTitle">
        <div class="cp-modal">
            <button class="cp-modal-close" type="button"
                    onclick="hideModal('feedbackModal')" aria-label="Close"></button>
            <h2 class="cp-modal-title" id="fbTitle">Mark Submission</h2>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtFeedback.ClientID %>">
                    Feedback Comment <span class="required">*</span>
                </label>
                <asp:TextBox ID="txtFeedback" runat="server" CssClass="cp-textarea"
                             TextMode="MultiLine" Rows="4"
                             placeholder="Write your feedback..." />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtFeedback"
                    Display="Dynamic" CssClass="cp-form-error"
                    ValidationGroup="GiveFB" ErrorMessage="Feedback comment is required." />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtGrade.ClientID %>">
                    Grade <span style="font-weight:400;color:var(--cp-text-muted);font-size:11px;">(optional — e.g. A, B+, 85)</span>
                </label>
                <asp:TextBox ID="txtGrade" runat="server" CssClass="cp-input"
                             MaxLength="10" placeholder="e.g. A, B+, 85" />
            </div>

            <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:16px;">
                <button type="button" class="cp-btn cp-btn-ghost"
                        onclick="hideModal('feedbackModal')">Cancel</button>
                <asp:Button ID="btnSaveFeedback" runat="server"
                            Text="Save"
                            CssClass="cp-btn cp-btn-primary"
                            ValidationGroup="GiveFB"
                            OnClick="btnSaveFeedback_Click" />
            </div>
        </div>
    </div>

    <%-- ═══════════════════════════════════════════════════════════
         CREATE ASSIGNMENT MODAL
    ═══════════════════════════════════════════════════════════ --%>
    <div id="createModal" class="cp-modal-backdrop" role="dialog"
         aria-modal="true" aria-labelledby="createATitle">
        <div class="cp-modal" style="max-width:580px;">
            <button class="cp-modal-close" type="button"
                    onclick="hideModal('createModal')" aria-label="Close"></button>
            <h2 class="cp-modal-title" id="createATitle">New Assignment</h2>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= ddlClassroomCreate.ClientID %>">
                    Classroom <span class="required">*</span>
                </label>
                <asp:DropDownList ID="ddlClassroomCreate" runat="server" CssClass="cp-select" />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtTitle.ClientID %>">
                    Title <span class="required">*</span>
                </label>
                <asp:TextBox ID="txtTitle" runat="server" CssClass="cp-input"
                             MaxLength="150" placeholder="Assignment title" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtTitle"
                    Display="Dynamic" CssClass="cp-form-error"
                    ValidationGroup="CreateA" ErrorMessage="Title is required." />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtADesc.ClientID %>">Description</label>
                <asp:TextBox ID="txtADesc" runat="server" CssClass="cp-textarea"
                             TextMode="MultiLine" Rows="3"
                             placeholder="Instructions for students..." />
            </div>

            <div class="cp-form-group">
                <label class="cp-label" for="<%= txtDueDate.ClientID %>">Due Date (optional)</label>
                <asp:TextBox ID="txtDueDate" runat="server" CssClass="cp-input"
                             TextMode="DateTime" />
            </div>

            <h4 style="margin:20px 0 10px;font-size:14px;font-weight:600;">Questions</h4>
            <p style="font-size:12px;color:var(--cp-text-muted);margin:0 0 12px;">
                Objective questions need 4 options (first option = correct answer).
            </p>

            <div style="background:var(--cp-surface);border:1px solid var(--cp-border);
                        border-radius:8px;padding:14px;margin-bottom:10px;">
                <label class="cp-label">Question 1 — Objective</label>
                <asp:TextBox ID="txtAQ1" runat="server" CssClass="cp-input"
                             placeholder="Question text" MaxLength="500" />
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:6px;margin-top:8px;">
                    <asp:TextBox ID="txtAQ1O1" runat="server" CssClass="cp-input"
                                 placeholder="Option A (correct)" MaxLength="300" />
                    <asp:TextBox ID="txtAQ1O2" runat="server" CssClass="cp-input"
                                 placeholder="Option B" MaxLength="300" />
                    <asp:TextBox ID="txtAQ1O3" runat="server" CssClass="cp-input"
                                 placeholder="Option C" MaxLength="300" />
                    <asp:TextBox ID="txtAQ1O4" runat="server" CssClass="cp-input"
                                 placeholder="Option D" MaxLength="300" />
                </div>
            </div>

            <div style="background:var(--cp-surface);border:1px solid var(--cp-border);
                        border-radius:8px;padding:14px;margin-bottom:10px;">
                <label class="cp-label">Question 2 — Objective (optional)</label>
                <asp:TextBox ID="txtAQ2" runat="server" CssClass="cp-input"
                             placeholder="Question text" MaxLength="500" />
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:6px;margin-top:8px;">
                    <asp:TextBox ID="txtAQ2O1" runat="server" CssClass="cp-input"
                                 placeholder="Option A (correct)" MaxLength="300" />
                    <asp:TextBox ID="txtAQ2O2" runat="server" CssClass="cp-input"
                                 placeholder="Option B" MaxLength="300" />
                    <asp:TextBox ID="txtAQ2O3" runat="server" CssClass="cp-input"
                                 placeholder="Option C" MaxLength="300" />
                    <asp:TextBox ID="txtAQ2O4" runat="server" CssClass="cp-input"
                                 placeholder="Option D" MaxLength="300" />
                </div>
            </div>

            <div style="background:var(--cp-surface);border:1px solid var(--cp-border);
                        border-radius:8px;padding:14px;margin-bottom:16px;">
                <label class="cp-label">Question 3 — Subjective (optional)</label>
                <asp:TextBox ID="txtAQ3" runat="server" CssClass="cp-input"
                             placeholder="Open-ended question (students type their answer)"
                             MaxLength="500" />
            </div>

            <div style="display:flex;gap:8px;justify-content:flex-end;">
                <button type="button" class="cp-btn cp-btn-ghost"
                        onclick="hideModal('createModal')">Cancel</button>
                <asp:Button ID="btnCreate" runat="server"
                            Text="Create Assignment"
                            CssClass="cp-btn cp-btn-primary"
                            ValidationGroup="CreateA"
                            OnClick="btnCreate_Click" />
            </div>
        </div>
    </div>

</asp:Content>

<asp:Content ID="PageScripts" ContentPlaceHolderID="PageScripts" runat="server">
<script>
function showModal(id) {
    document.getElementById(id).classList.add('open');
    document.body.style.overflow = 'hidden';
}
function hideModal(id) {
    document.getElementById(id).classList.remove('open');
    document.body.style.overflow = '';
}
document.querySelectorAll('.cp-modal-backdrop').forEach(function(el) {
    el.addEventListener('click', function(e) { if (e.target === el) hideModal(el.id); });
});

// Pre-fill feedback modal when server triggers it.
function openFeedbackModal(existingFeedback, existingGrade) {
    var fb = document.getElementById('<%= txtFeedback.ClientID %>');
    var gr = document.getElementById('<%= txtGrade.ClientID %>');
    if (fb) fb.value = decodeURIComponent(existingFeedback || '');
    if (gr) gr.value = decodeURIComponent(existingGrade || '');
    showModal('feedbackModal');
}
</script>
</asp:Content>
