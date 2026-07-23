using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Instructor
{
    public partial class Assignments : System.Web.UI.Page
    {
        // ── Page lifecycle ───────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Instructor")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            string licenseStatus = Session["LicenseStatus"] != null
                                   ? Session["LicenseStatus"].ToString() : "Pending";
            if (licenseStatus != "Approved")
            {
                Response.Redirect("~/Instructor/Dashboard.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Assignments";

            if (!IsPostBack)
            {
                LoadClassroomDropdowns();
                LoadAssignments();
            }
        }

        // ── Dropdowns ────────────────────────────────────────────────────────
        private void LoadClassroomDropdowns()
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT ClassroomID, ClassroomName FROM Classrooms WHERE InstructorID=@ID ORDER BY ClassroomName", conn))
                {
                    cmd.Parameters.Add("@ID", SqlDbType.Int).Value = instructorID;
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                }
            }

            ddlClassroom.DataSource       = dt;
            ddlClassroom.DataTextField    = "ClassroomName";
            ddlClassroom.DataValueField   = "ClassroomID";
            ddlClassroom.DataBind();
            ddlClassroom.Items.Insert(0, new ListItem("-- All Classrooms --", "0"));

            ddlClassroomCreate.DataSource     = dt;
            ddlClassroomCreate.DataTextField  = "ClassroomName";
            ddlClassroomCreate.DataValueField = "ClassroomID";
            ddlClassroomCreate.DataBind();
            ddlClassroomCreate.Items.Insert(0, new ListItem("-- Select Classroom --", "0"));

            pnlCreateBtn.Visible = dt.Rows.Count > 0;
        }

        // ── Section 1: assignment list ────────────────────────────────────────
        private void LoadAssignments()
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            int filterID; int.TryParse(ddlClassroom.SelectedValue, out filterID);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            string sql = @"
                SELECT ca.AssignmentID, ca.Title, ca.DueDate, ca.CreatedAt,
                       c.ClassroomName,
                       COUNT(DISTINCT asub.SubmissionID) AS SubmissionCount
                FROM   ClassroomAssignments ca
                INNER JOIN Classrooms c ON c.ClassroomID = ca.ClassroomID
                LEFT  JOIN AssignmentSubmissions asub ON asub.AssignmentID = ca.AssignmentID
                WHERE  ca.InstructorID = @IID
                       AND (@Filter = 0 OR ca.ClassroomID = @Filter)
                GROUP BY ca.AssignmentID, ca.Title, ca.DueDate, ca.CreatedAt, c.ClassroomName
                ORDER BY ca.CreatedAt DESC";

            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@IID",    SqlDbType.Int).Value = instructorID;
                        cmd.Parameters.Add("@Filter", SqlDbType.Int).Value = filterID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }
                }
                if (dt.Rows.Count > 0)
                {
                    rptAssignments.DataSource = dt;
                    rptAssignments.DataBind();
                    pnlAssignments.Visible = true;
                    pnlEmpty.Visible       = false;
                }
                else
                {
                    pnlAssignments.Visible = false;
                    pnlEmpty.Visible       = true;
                }
            }
            catch (SqlException) { ShowError("Could not load assignments. Please try again."); }
        }

        protected void ddlClassroom_Changed(object sender, EventArgs e)
        {
            pnlAssignments.Visible = false;
            pnlEmpty.Visible       = false;
            LoadAssignments();
        }

        // ── Section 1 item commands ───────────────────────────────────────────
        protected void rptAssignments_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ViewStudents")
            {
                // CommandArgument is "AssignmentID|Title"
                string[] parts     = e.CommandArgument.ToString().Split(new char[]{'|'}, 2);
                int assignmentID   = Convert.ToInt32(parts[0]);
                string assignTitle = parts.Length > 1 ? parts[1] : string.Empty;

                hfSelectedAssignmentID.Value    = assignmentID.ToString();
                hfSelectedAssignmentTitle.Value = assignTitle;
                litSection2Title.Text           = HttpUtility.HtmlEncode(assignTitle);
                hfAssignmentIDFb.Value          = assignmentID.ToString();

                LoadStudentList(assignmentID);

                // Keep Section 1 visible, show Section 2, hide Section 3.
                pnlSection2.Visible = true;
                pnlSection3.Visible = false;
            }
            else if (e.CommandName == "Delete")
            {
                DeleteAssignment(Convert.ToInt32(e.CommandArgument));
            }
        }

        // ── Section 2: per-student submission summary ─────────────────────────
        private void LoadStudentList(int assignmentID)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            // One row per student — pick their earliest submission date.
            string sql = @"
                SELECT   s.StudentID,
                         u.FullName  AS StudentName,
                         ca.Title    AS AssignmentTitle,
                         MIN(asub.SubmittedAt) AS SubmittedAt
                FROM     AssignmentSubmissions asub
                INNER JOIN ClassroomAssignments ca ON ca.AssignmentID = asub.AssignmentID
                INNER JOIN Students             s  ON s.StudentID     = asub.StudentID
                INNER JOIN Users                u  ON u.UserID        = s.StudentID
                WHERE    asub.AssignmentID = @AID
                GROUP BY s.StudentID, u.FullName, ca.Title
                ORDER BY u.FullName";

            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@AID", SqlDbType.Int).Value = assignmentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }
                }
                if (dt.Rows.Count > 0)
                {
                    rptStudents.DataSource = dt;
                    rptStudents.DataBind();
                    pnlStudentList.Visible = true;
                    pnlNoStudents.Visible  = false;
                }
                else
                {
                    pnlStudentList.Visible = false;
                    pnlNoStudents.Visible  = true;
                }
            }
            catch (SqlException) { ShowError("Could not load student list. Please try again."); }
        }

        // Section 2 item command — "View" button opens Section 3
        protected void rptStudents_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ViewDetail") return;

            // CommandArgument: "StudentID|StudentName|SubmittedAt"
            string[] parts    = e.CommandArgument.ToString().Split(new char[]{'|'}, 3);
            int      studentID    = Convert.ToInt32(parts[0]);
            string   studentName  = parts.Length > 1 ? parts[1] : string.Empty;
            string   submittedAt  = parts.Length > 2 ? parts[2] : string.Empty;

            int assignmentID;
            int.TryParse(hfSelectedAssignmentID.Value, out assignmentID);

            // Store context for the detail header and feedback save.
            hfDetailStudentID.Value   = studentID.ToString();
            hfDetailStudentName.Value = studentName;
            hfDetailSubmittedAt.Value = submittedAt;
            hfAssignmentIDFb.Value    = assignmentID.ToString();

            // Populate info strip literals.
            litDetailStudentName.Text     = HttpUtility.HtmlEncode(studentName);
            litDetailAssignmentTitle.Text = HttpUtility.HtmlEncode(hfSelectedAssignmentTitle.Value);

            DateTime dt2;
            litDetailSubmittedAt.Text = DateTime.TryParse(submittedAt, out dt2)
                                        ? dt2.ToString("dd MMM yyyy HH:mm")
                                        : HttpUtility.HtmlEncode(submittedAt);

            LoadDetail(assignmentID, studentID);

            pnlSection3.Visible = true;
        }

        // ── Section 3: per-question detail for one student ────────────────────
        private void LoadDetail(int assignmentID, int studentID)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            // One row per question answered by this student.
            string sql = @"
                SELECT asub.SubmissionID,
                       aq.QuestionText,
                       aq.QuestionType,
                       asub.AnswerText,
                       asub.SubmittedAt,
                       fb.FeedbackText,
                       fb.Grade
                FROM   AssignmentSubmissions asub
                INNER JOIN AssignmentQuestions aq ON aq.AssignmentQuestionID = asub.AssignmentQuestionID
                LEFT  JOIN Feedback            fb ON fb.SubmissionID         = asub.SubmissionID
                WHERE  asub.AssignmentID = @AID
                  AND  asub.StudentID    = @SID
                ORDER BY aq.OrderIndex";

            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@AID", SqlDbType.Int).Value = assignmentID;
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }
                }
                rptDetail.DataSource = dt;
                rptDetail.DataBind();
            }
            catch (SqlException) { ShowError("Could not load submission detail. Please try again."); }
        }

        // Section 3 item command — "Mark/Edit" button opens feedback modal
        protected void rptDetail_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "OpenMark") return;

            // CommandArgument: "SubmissionID|urlEncodedFeedback|urlEncodedGrade"
            string[] parts     = e.CommandArgument.ToString().Split(new char[]{'|'}, 3);
            string submissionID      = parts[0];
            string existingFeedback  = parts.Length > 1 ? parts[1] : string.Empty;
            string existingGrade     = parts.Length > 2 ? parts[2] : string.Empty;

            hfSubmissionID.Value     = submissionID;
            hfExistingFeedback.Value = existingFeedback;
            hfExistingGrade.Value    = existingGrade;

            // Pre-fill the modal text boxes server-side so they render correctly.
            txtFeedback.Text = HttpUtility.UrlDecode(existingFeedback);
            txtGrade.Text    = HttpUtility.UrlDecode(existingGrade);

            // Open modal via JS after postback.
            ScriptManager.RegisterStartupScript(this, GetType(), "openFb",
                "openFeedbackModal(" +
                "'" + HttpUtility.JavaScriptStringEncode(existingFeedback) + "'," +
                "'" + HttpUtility.JavaScriptStringEncode(existingGrade) + "'" +
                ");", true);
        }

        // ── Back buttons ──────────────────────────────────────────────────────
        protected void btnBackToAssignments_Click(object sender, EventArgs e)
        {
            pnlSection2.Visible = false;
            pnlSection3.Visible = false;
            hfSelectedAssignmentID.Value    = string.Empty;
            hfSelectedAssignmentTitle.Value = string.Empty;
        }

        protected void btnBackToStudents_Click(object sender, EventArgs e)
        {
            pnlSection3.Visible = false;

            // Re-show Section 2 with the same student list.
            int assignmentID;
            if (int.TryParse(hfSelectedAssignmentID.Value, out assignmentID) && assignmentID > 0)
            {
                litSection2Title.Text = HttpUtility.HtmlEncode(hfSelectedAssignmentTitle.Value);
                LoadStudentList(assignmentID);
                pnlSection2.Visible = true;
            }
        }

        // ── Feedback save ─────────────────────────────────────────────────────
        protected void btnSaveFeedback_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int instructorID = Convert.ToInt32(Session["UserID"]);

            int submissionID;
            if (!int.TryParse(hfSubmissionID.Value, out submissionID) || submissionID == 0)
            {
                ShowError("Invalid submission reference.");
                return;
            }

            int assignmentID;
            int.TryParse(hfAssignmentIDFb.Value, out assignmentID);

            string feedback = txtFeedback.Text.Trim();
            string grade    = txtGrade.Text.Trim();
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Verify instructor owns this submission via the assignment.
                    int classroomID = 0;
                    using (SqlCommand get = new SqlCommand(
                        @"SELECT ca.ClassroomID
                          FROM   AssignmentSubmissions asub
                          INNER JOIN ClassroomAssignments ca ON ca.AssignmentID = asub.AssignmentID
                          WHERE  asub.SubmissionID = @SID AND ca.InstructorID = @IID", conn))
                    {
                        get.Parameters.Add("@SID", SqlDbType.Int).Value = submissionID;
                        get.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        object r = get.ExecuteScalar();
                        if (r == null || r == DBNull.Value)
                        {
                            ShowError("Submission not found or access denied.");
                            return;
                        }
                        classroomID = Convert.ToInt32(r);
                    }

                    // Get the student ID.
                    int studentID = 0;
                    using (SqlCommand get2 = new SqlCommand(
                        "SELECT StudentID FROM AssignmentSubmissions WHERE SubmissionID=@SID", conn))
                    {
                        get2.Parameters.Add("@SID", SqlDbType.Int).Value = submissionID;
                        studentID = Convert.ToInt32(get2.ExecuteScalar());
                    }

                    // Upsert feedback row.
                    bool exists;
                    using (SqlCommand chk = new SqlCommand(
                        "SELECT COUNT(*) FROM Feedback WHERE SubmissionID=@SID", conn))
                    {
                        chk.Parameters.Add("@SID", SqlDbType.Int).Value = submissionID;
                        exists = Convert.ToInt32(chk.ExecuteScalar()) > 0;
                    }

                    if (exists)
                    {
                        using (SqlCommand upd = new SqlCommand(
                            "UPDATE Feedback SET FeedbackText=@FB, Grade=@GR WHERE SubmissionID=@SID", conn))
                        {
                            upd.Parameters.Add("@FB",  SqlDbType.NVarChar, -1).Value = feedback;
                            upd.Parameters.Add("@GR",  SqlDbType.NVarChar, 10).Value =
                                string.IsNullOrEmpty(grade) ? (object)DBNull.Value : grade;
                            upd.Parameters.Add("@SID", SqlDbType.Int).Value           = submissionID;
                            upd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        using (SqlCommand ins = new SqlCommand(
                            @"INSERT INTO Feedback
                                (StudentID, InstructorID, ClassroomID, SubmissionID,
                                 FeedbackText, Grade, CreatedAt)
                              VALUES
                                (@StID, @IID, @CID, @SID, @FB, @GR, GETDATE())", conn))
                        {
                            ins.Parameters.Add("@StID", SqlDbType.Int).Value           = studentID;
                            ins.Parameters.Add("@IID",  SqlDbType.Int).Value           = instructorID;
                            ins.Parameters.Add("@CID",  SqlDbType.Int).Value           = classroomID;
                            ins.Parameters.Add("@SID",  SqlDbType.Int).Value           = submissionID;
                            ins.Parameters.Add("@FB",   SqlDbType.NVarChar, -1).Value  = feedback;
                            ins.Parameters.Add("@GR",   SqlDbType.NVarChar, 10).Value  =
                                string.IsNullOrEmpty(grade) ? (object)DBNull.Value : grade;
                            ins.ExecuteNonQuery();
                        }
                    }
                }

                // Clear modal fields.
                txtFeedback.Text     = string.Empty;
                txtGrade.Text        = string.Empty;
                hfSubmissionID.Value = string.Empty;

                ShowSuccess("Feedback saved successfully.");

                // Reload Section 3 so the table reflects the new feedback.
                int detailStudentID;
                if (int.TryParse(hfDetailStudentID.Value, out detailStudentID) && detailStudentID > 0 && assignmentID > 0)
                {
                    litDetailStudentName.Text     = HttpUtility.HtmlEncode(hfDetailStudentName.Value);
                    litDetailAssignmentTitle.Text = HttpUtility.HtmlEncode(hfSelectedAssignmentTitle.Value);
                    DateTime parsedDt;
                    litDetailSubmittedAt.Text = DateTime.TryParse(hfDetailSubmittedAt.Value, out parsedDt)
                                               ? parsedDt.ToString("dd MMM yyyy HH:mm")
                                               : HttpUtility.HtmlEncode(hfDetailSubmittedAt.Value);
                    LoadDetail(assignmentID, detailStudentID);
                    pnlSection3.Visible = true;
                }

                // Keep Section 2 visible too.
                litSection2Title.Text = HttpUtility.HtmlEncode(hfSelectedAssignmentTitle.Value);
                LoadStudentList(assignmentID);
                pnlSection2.Visible = true;
            }
            catch (SqlException)
            {
                ShowError("Could not save feedback. Please try again.");
            }
        }

        // ── Create assignment ─────────────────────────────────────────────────
        protected void btnCreate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int instructorID = Convert.ToInt32(Session["UserID"]);
            int classroomID;
            if (!int.TryParse(ddlClassroomCreate.SelectedValue, out classroomID) || classroomID == 0)
            {
                ShowError("Please select a classroom.");
                return;
            }

            string title   = txtTitle.Text.Trim();
            string desc    = txtADesc.Text.Trim();
            DateTime? due  = null;
            if (!string.IsNullOrWhiteSpace(txtDueDate.Text))
            {
                DateTime p;
                if (DateTime.TryParse(txtDueDate.Text.Trim(), out p)) due = p;
            }

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Ownership check.
                    using (SqlCommand chk = new SqlCommand(
                        "SELECT COUNT(*) FROM Classrooms WHERE ClassroomID=@CID AND InstructorID=@IID", conn))
                    {
                        chk.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        chk.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        if (Convert.ToInt32(chk.ExecuteScalar()) == 0)
                        {
                            ShowError("You do not own the selected classroom.");
                            return;
                        }
                    }

                    int assignmentID;
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO ClassroomAssignments
                            (ClassroomID, InstructorID, Title, Description, DueDate, CreatedAt)
                          VALUES (@CID, @IID, @Title, @Desc, @Due, GETDATE());
                          SELECT SCOPE_IDENTITY();", conn))
                    {
                        cmd.Parameters.Add("@CID",   SqlDbType.Int).Value           = classroomID;
                        cmd.Parameters.Add("@IID",   SqlDbType.Int).Value           = instructorID;
                        cmd.Parameters.Add("@Title", SqlDbType.NVarChar, 150).Value = title;
                        cmd.Parameters.Add("@Desc",  SqlDbType.NVarChar, -1).Value  =
                            string.IsNullOrEmpty(desc) ? (object)DBNull.Value : desc;
                        cmd.Parameters.Add("@Due",   SqlDbType.DateTime2).Value     =
                            due.HasValue ? (object)due.Value : DBNull.Value;
                        assignmentID = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    InsertObjectiveQuestion(conn, assignmentID, txtAQ1, txtAQ1O1, txtAQ1O2, txtAQ1O3, txtAQ1O4, 1);
                    InsertObjectiveQuestion(conn, assignmentID, txtAQ2, txtAQ2O1, txtAQ2O2, txtAQ2O3, txtAQ2O4, 2);
                    InsertSubjectiveQuestion(conn, assignmentID, txtAQ3, 3);

                    Utils.SendNotification(conn, instructorID,
                        "Assignment \"" + title + "\" created successfully.", "Assignment");
                }

                txtTitle.Text = txtADesc.Text = txtDueDate.Text = string.Empty;
                ShowSuccess("Assignment created successfully.");
                pnlAssignments.Visible = false;
                pnlEmpty.Visible       = false;
                LoadAssignments();
            }
            catch (SqlException) { ShowError("Could not create assignment. Please try again."); }
        }

        // ── Delete assignment ─────────────────────────────────────────────────
        private void DeleteAssignment(int assignmentID)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    string assignTitle = string.Empty;
                    using (SqlCommand getT = new SqlCommand(
                        "SELECT Title FROM ClassroomAssignments WHERE AssignmentID=@AID AND InstructorID=@IID", conn))
                    {
                        getT.Parameters.Add("@AID", SqlDbType.Int).Value = assignmentID;
                        getT.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        object r = getT.ExecuteScalar();
                        assignTitle = (r != null && r != DBNull.Value) ? r.ToString() : "assignment";
                    }

                    using (SqlCommand del = new SqlCommand(
                        "DELETE FROM ClassroomAssignments WHERE AssignmentID=@AID AND InstructorID=@IID", conn))
                    {
                        del.Parameters.Add("@AID", SqlDbType.Int).Value = assignmentID;
                        del.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        del.ExecuteNonQuery();
                    }

                    Utils.SendNotification(conn, instructorID,
                        "Assignment \"" + assignTitle + "\" was deleted.", "Assignment");
                }

                ShowSuccess("Assignment deleted.");
                pnlSection2.Visible = false;
                pnlSection3.Visible = false;
                pnlAssignments.Visible = false;
                pnlEmpty.Visible       = false;
                LoadAssignments();
            }
            catch (SqlException) { ShowError("Could not delete assignment. Please try again."); }
        }

        // ── Question helpers ──────────────────────────────────────────────────
        private void InsertObjectiveQuestion(SqlConnection conn, int assignmentID,
            TextBox txtQ, TextBox o1, TextBox o2, TextBox o3, TextBox o4, int order)
        {
            string qText = txtQ.Text.Trim();
            string opt1  = o1.Text.Trim(), opt2 = o2.Text.Trim(),
                   opt3  = o3.Text.Trim(), opt4 = o4.Text.Trim();
            if (string.IsNullOrEmpty(qText) || string.IsNullOrEmpty(opt1) ||
                string.IsNullOrEmpty(opt2)  || string.IsNullOrEmpty(opt3) ||
                string.IsNullOrEmpty(opt4)) return;

            int qID;
            using (SqlCommand cmd = new SqlCommand(
                @"INSERT INTO AssignmentQuestions (AssignmentID, QuestionText, QuestionType, OrderIndex)
                  VALUES (@AID, @QT, 'Objective', @Ord); SELECT SCOPE_IDENTITY();", conn))
            {
                cmd.Parameters.Add("@AID", SqlDbType.Int).Value          = assignmentID;
                cmd.Parameters.Add("@QT",  SqlDbType.NVarChar, -1).Value = qText;
                cmd.Parameters.Add("@Ord", SqlDbType.Int).Value           = order;
                qID = Convert.ToInt32(cmd.ExecuteScalar());
            }

            string[] opts = { opt1, opt2, opt3, opt4 };
            for (int i = 0; i < opts.Length; i++)
            {
                using (SqlCommand cmd = new SqlCommand(
                    "INSERT INTO AssignmentQuestionOptions (AssignmentQuestionID, OptionText, IsCorrect) VALUES (@QID,@OT,@C)", conn))
                {
                    cmd.Parameters.Add("@QID", SqlDbType.Int).Value          = qID;
                    cmd.Parameters.Add("@OT",  SqlDbType.NVarChar, -1).Value = opts[i];
                    cmd.Parameters.Add("@C",   SqlDbType.Bit).Value          = (i == 0) ? 1 : 0;
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void InsertSubjectiveQuestion(SqlConnection conn, int assignmentID,
            TextBox txtQ, int order)
        {
            string qText = txtQ.Text.Trim();
            if (string.IsNullOrEmpty(qText)) return;

            using (SqlCommand cmd = new SqlCommand(
                @"INSERT INTO AssignmentQuestions (AssignmentID, QuestionText, QuestionType, OrderIndex)
                  VALUES (@AID, @QT, 'Subjective', @Ord)", conn))
            {
                cmd.Parameters.Add("@AID", SqlDbType.Int).Value          = assignmentID;
                cmd.Parameters.Add("@QT",  SqlDbType.NVarChar, -1).Value = qText;
                cmd.Parameters.Add("@Ord", SqlDbType.Int).Value           = order;
                cmd.ExecuteNonQuery();
            }
        }

        // ── Helpers ───────────────────────────────────────────────────────────
        private void ShowSuccess(string msg)
        {
            litSuccess.Text    = HttpUtility.HtmlEncode(msg);
            pnlSuccess.Visible = true;
            pnlError.Visible   = false;
        }

        private void ShowError(string msg)
        {
            litError.Text      = HttpUtility.HtmlEncode(msg);
            pnlError.Visible   = true;
            pnlSuccess.Visible = false;
        }
    }
}
