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

                int assignmentID;
                if (int.TryParse(Request.QueryString["assignmentID"], out assignmentID) && assignmentID > 0)
                    LoadSubmissions(assignmentID);
            }
        }

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
            catch (SqlException)
            {
                ShowError("Could not load assignments. Please try again.");
            }
        }

        private void LoadSubmissions(int assignmentID)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Verify ownership.
                    using (SqlCommand chk = new SqlCommand(
                        "SELECT Title FROM ClassroomAssignments WHERE AssignmentID=@AID AND InstructorID=@IID", conn))
                    {
                        chk.Parameters.Add("@AID", SqlDbType.Int).Value = assignmentID;
                        chk.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        object title = chk.ExecuteScalar();
                        if (title == null || title == DBNull.Value) return;
                        litAssignmentTitle.Text = HttpUtility.HtmlEncode(title.ToString());
                    }

                    string sql = @"
                        SELECT asub.SubmissionID, u.FullName AS StudentName,
                               aq.QuestionText, asub.AnswerText, asub.SubmittedAt,
                               fb.FeedbackText, fb.Grade
                        FROM   AssignmentSubmissions asub
                        INNER JOIN AssignmentQuestions aq ON aq.AssignmentQuestionID = asub.AssignmentQuestionID
                        INNER JOIN Students s  ON s.StudentID = asub.StudentID
                        INNER JOIN Users    u  ON u.UserID    = s.StudentID
                        LEFT  JOIN Feedback fb ON fb.SubmissionID = asub.SubmissionID
                        WHERE  asub.AssignmentID = @AID
                        ORDER BY u.FullName, aq.OrderIndex";

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@AID", SqlDbType.Int).Value = assignmentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }

                    rptSubmissions.DataSource = dt;
                    rptSubmissions.DataBind();
                    pnlSubmissions.Visible = true;

                    // Store assignment ID for feedback modal.
                    hfAssignmentIDFb.Value = assignmentID.ToString();
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load submissions. Please try again.");
            }
        }

        protected void ddlClassroom_Changed(object sender, EventArgs e)
        {
            pnlAssignments.Visible = false;
            pnlEmpty.Visible       = false;
            LoadAssignments();
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { return; }

            int instructorID = Convert.ToInt32(Session["UserID"]);
            int classroomID;
            if (!int.TryParse(ddlClassroomCreate.SelectedValue, out classroomID) || classroomID == 0)
            {
                ShowError("Please select a classroom.");
                return;
            }

            string title = txtTitle.Text.Trim();
            string desc  = txtADesc.Text.Trim();
            DateTime? dueDate = null;
            if (!string.IsNullOrWhiteSpace(txtDueDate.Text))
            {
                DateTime parsed;
                if (DateTime.TryParse(txtDueDate.Text.Trim(), out parsed))
                    dueDate = parsed;
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

                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO ClassroomAssignments
                            (ClassroomID, InstructorID, Title, Description, DueDate, CreatedAt)
                          VALUES (@CID, @IID, @Title, @Desc, @Due, GETDATE());
                          SELECT SCOPE_IDENTITY();", conn))
                    {
                        cmd.Parameters.Add("@CID",   SqlDbType.Int).Value           = classroomID;
                        cmd.Parameters.Add("@IID",   SqlDbType.Int).Value           = instructorID;
                        cmd.Parameters.Add("@Title", SqlDbType.NVarChar, 150).Value = title;
                        cmd.Parameters.Add("@Desc",  SqlDbType.NVarChar, -1).Value  = string.IsNullOrEmpty(desc) ? (object)DBNull.Value : desc;
                        cmd.Parameters.Add("@Due",   SqlDbType.DateTime2).Value     = dueDate.HasValue ? (object)dueDate.Value : DBNull.Value;
                        int assignmentID = Convert.ToInt32(cmd.ExecuteScalar());

                        // Insert questions
                        InsertObjectiveQuestion(conn, assignmentID, txtAQ1, txtAQ1O1, txtAQ1O2, txtAQ1O3, txtAQ1O4, 1);
                        InsertObjectiveQuestion(conn, assignmentID, txtAQ2, txtAQ2O1, txtAQ2O2, txtAQ2O3, txtAQ2O4, 2);
                        InsertSubjectiveQuestion(conn, assignmentID, txtAQ3, 3);
                    }

                    Utils.SendNotification(conn, instructorID,
                        "Assignment \"" + title + "\" created successfully.",
                        "Assignment");
                }

                txtTitle.Text   = string.Empty;
                txtADesc.Text   = string.Empty;
                txtDueDate.Text = string.Empty;

                ShowSuccess("Assignment created successfully.");
                pnlAssignments.Visible = false;
                pnlEmpty.Visible       = false;
                LoadAssignments();
            }
            catch (SqlException)
            {
                ShowError("Could not create assignment. Please try again.");
            }
        }

        protected void rptAssignments_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Delete")
                DeleteAssignment(Convert.ToInt32(e.CommandArgument));
        }

        private void DeleteAssignment(int assignmentID)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Get assignment title before deleting for notification.
                    string assignTitle = string.Empty;
                    using (SqlCommand getTitle = new SqlCommand(
                        "SELECT Title FROM ClassroomAssignments WHERE AssignmentID=@AID AND InstructorID=@IID", conn))
                    {
                        getTitle.Parameters.Add("@AID", SqlDbType.Int).Value = assignmentID;
                        getTitle.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        object r = getTitle.ExecuteScalar();
                        assignTitle = (r != null && r != DBNull.Value) ? r.ToString() : "assignment";
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        "DELETE FROM ClassroomAssignments WHERE AssignmentID=@AID AND InstructorID=@IID", conn))
                    {
                        cmd.Parameters.Add("@AID", SqlDbType.Int).Value = assignmentID;
                        cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        cmd.ExecuteNonQuery();
                    }

                    Utils.SendNotification(conn, instructorID,
                        "Assignment \"" + assignTitle + "\" was deleted.",
                        "Assignment");
                }
                ShowSuccess("Assignment deleted.");
                pnlAssignments.Visible = false;
                pnlEmpty.Visible       = false;
                pnlSubmissions.Visible = false;
                LoadAssignments();
            }
            catch (SqlException)
            {
                ShowError("Could not delete assignment. Please try again.");
            }
        }

        protected void rptSubmissions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "GiveFeedback")
            {
                hfSubmissionID.Value = e.CommandArgument.ToString();
                // Open feedback modal via JS.
                ScriptManager.RegisterStartupScript(this, GetType(), "openFb",
                    "showModal('feedbackModal');", true);
            }
        }

        protected void btnSaveFeedback_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { return; }

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

                    // Retrieve ClassroomID for the Feedback FK.
                    int classroomID = 0;
                    using (SqlCommand get = new SqlCommand(
                        @"SELECT ca.ClassroomID
                          FROM AssignmentSubmissions asub
                          INNER JOIN ClassroomAssignments ca ON ca.AssignmentID = asub.AssignmentID
                          WHERE asub.SubmissionID = @SID AND ca.InstructorID = @IID", conn))
                    {
                        get.Parameters.Add("@SID", SqlDbType.Int).Value = submissionID;
                        get.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        object r = get.ExecuteScalar();
                        if (r == null || r == DBNull.Value)
                        {
                            ShowError("Submission not found or not owned by you.");
                            return;
                        }
                        classroomID = Convert.ToInt32(r);
                    }

                    // Get StudentID from submission.
                    int studentID = 0;
                    using (SqlCommand get2 = new SqlCommand(
                        "SELECT StudentID FROM AssignmentSubmissions WHERE SubmissionID=@SID", conn))
                    {
                        get2.Parameters.Add("@SID", SqlDbType.Int).Value = submissionID;
                        studentID = Convert.ToInt32(get2.ExecuteScalar());
                    }

                    // Upsert feedback.
                    using (SqlCommand chk = new SqlCommand(
                        "SELECT COUNT(*) FROM Feedback WHERE SubmissionID=@SID", conn))
                    {
                        chk.Parameters.Add("@SID", SqlDbType.Int).Value = submissionID;
                        bool exists = Convert.ToInt32(chk.ExecuteScalar()) > 0;

                        if (exists)
                        {
                            using (SqlCommand upd = new SqlCommand(
                                "UPDATE Feedback SET FeedbackText=@FBText, Grade=@Grade WHERE SubmissionID=@SID", conn))
                            {
                                upd.Parameters.Add("@FBText", SqlDbType.NVarChar, -1).Value  = feedback;
                                upd.Parameters.Add("@Grade",  SqlDbType.NVarChar, 10).Value  = string.IsNullOrEmpty(grade) ? (object)DBNull.Value : grade;
                                upd.Parameters.Add("@SID",    SqlDbType.Int).Value           = submissionID;
                                upd.ExecuteNonQuery();
                            }
                        }
                        else
                        {
                            using (SqlCommand ins = new SqlCommand(
                                @"INSERT INTO Feedback
                                    (StudentID, InstructorID, ClassroomID, SubmissionID, FeedbackText, Grade, CreatedAt)
                                  VALUES (@StID, @IID, @CID, @SID, @FBText, @Grade, GETDATE())", conn))
                            {
                                ins.Parameters.Add("@StID",   SqlDbType.Int).Value           = studentID;
                                ins.Parameters.Add("@IID",    SqlDbType.Int).Value           = instructorID;
                                ins.Parameters.Add("@CID",    SqlDbType.Int).Value           = classroomID;
                                ins.Parameters.Add("@SID",    SqlDbType.Int).Value           = submissionID;
                                ins.Parameters.Add("@FBText", SqlDbType.NVarChar, -1).Value  = feedback;
                                ins.Parameters.Add("@Grade",  SqlDbType.NVarChar, 10).Value  = string.IsNullOrEmpty(grade) ? (object)DBNull.Value : grade;
                                ins.ExecuteNonQuery();
                            }
                        }
                    }
                }

                txtFeedback.Text     = string.Empty;
                txtGrade.Text        = string.Empty;
                hfSubmissionID.Value = string.Empty;

                ShowSuccess("Feedback saved.");
                if (assignmentID > 0) LoadSubmissions(assignmentID);
            }
            catch (SqlException)
            {
                ShowError("Could not save feedback. Please try again.");
            }
        }

        private void ShowSuccess(string msg)
        {
            litSuccess.Text = HttpUtility.HtmlEncode(msg);
            pnlSuccess.Visible = true;
            pnlError.Visible   = false;
        }

        private void ShowError(string msg)
        {
            litError.Text = HttpUtility.HtmlEncode(msg);
            pnlError.Visible   = true;
            pnlSuccess.Visible = false;
        }

        private void InsertObjectiveQuestion(SqlConnection conn, int assignmentID, TextBox txtQ, TextBox o1, TextBox o2, TextBox o3, TextBox o4, int order)
        {
            string qText = txtQ.Text.Trim();
            string opt1 = o1.Text.Trim(), opt2 = o2.Text.Trim(), opt3 = o3.Text.Trim(), opt4 = o4.Text.Trim();
            if (string.IsNullOrEmpty(qText) || string.IsNullOrEmpty(opt1) || string.IsNullOrEmpty(opt2) ||
                string.IsNullOrEmpty(opt3) || string.IsNullOrEmpty(opt4)) return;

            int qID;
            using (SqlCommand cmd = new SqlCommand(
                @"INSERT INTO AssignmentQuestions (AssignmentID, QuestionText, QuestionType, OrderIndex)
                  VALUES (@AID, @QText, 'Objective', @Ord); SELECT SCOPE_IDENTITY();", conn))
            {
                cmd.Parameters.Add("@AID", SqlDbType.Int).Value = assignmentID;
                cmd.Parameters.Add("@QText", SqlDbType.NVarChar, -1).Value = qText;
                cmd.Parameters.Add("@Ord", SqlDbType.Int).Value = order;
                qID = Convert.ToInt32(cmd.ExecuteScalar());
            }

            string[] opts = { opt1, opt2, opt3, opt4 };
            for (int i = 0; i < opts.Length; i++)
            {
                using (SqlCommand cmd = new SqlCommand(
                    "INSERT INTO AssignmentQuestionOptions (AssignmentQuestionID, OptionText, IsCorrect) VALUES (@QID, @OText, @Correct)", conn))
                {
                    cmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
                    cmd.Parameters.Add("@OText", SqlDbType.NVarChar, -1).Value = opts[i];
                    cmd.Parameters.Add("@Correct", SqlDbType.Bit).Value = (i == 0) ? 1 : 0;
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void InsertSubjectiveQuestion(SqlConnection conn, int assignmentID, TextBox txtQ, int order)
        {
            string qText = txtQ.Text.Trim();
            if (string.IsNullOrEmpty(qText)) return;

            using (SqlCommand cmd = new SqlCommand(
                @"INSERT INTO AssignmentQuestions (AssignmentID, QuestionText, QuestionType, OrderIndex)
                  VALUES (@AID, @QText, 'Subjective', @Ord)", conn))
            {
                cmd.Parameters.Add("@AID", SqlDbType.Int).Value = assignmentID;
                cmd.Parameters.Add("@QText", SqlDbType.NVarChar, -1).Value = qText;
                cmd.Parameters.Add("@Ord", SqlDbType.Int).Value = order;
                cmd.ExecuteNonQuery();
            }
        }
    }
}
