using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class AssignmentDetail : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            { Response.Redirect("~/LogIn.aspx", true); return; }

            ((SiteMaster)Master).PageHeading = "Assignment";

            if (!IsPostBack)
            {
                int assignmentID;
                if (!int.TryParse(Request.QueryString["assignmentID"], out assignmentID))
                { Response.Redirect("~/Student/Classrooms.aspx"); return; }
                ViewState["AssignmentID"] = assignmentID;
                LoadAssignment(assignmentID);
            }
        }

        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString; }
        }

        private void LoadAssignment(int assignmentID)
        {
            int studentID = Convert.ToInt32(Session["UserID"]);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Assignment info + verify student is enrolled in the classroom
                    string title = "", desc = "", classroom = "", instructor = "";
                    DateTime? dueDate = null;
                    int classroomID = 0;

                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT ca.Title, ca.Description, ca.DueDate, ca.ClassroomID,
                                 c.ClassroomName, u.FullName AS InstructorName
                          FROM ClassroomAssignments ca
                          INNER JOIN Classrooms c ON c.ClassroomID = ca.ClassroomID
                          INNER JOIN Users u ON u.UserID = ca.InstructorID
                          WHERE ca.AssignmentID = @AID", conn))
                    {
                        cmd.Parameters.Add("@AID", SqlDbType.Int).Value = assignmentID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                title = rdr["Title"].ToString();
                                desc = rdr["Description"] != DBNull.Value ? rdr["Description"].ToString() : "";
                                classroom = rdr["ClassroomName"].ToString();
                                instructor = rdr["InstructorName"].ToString();
                                classroomID = Convert.ToInt32(rdr["ClassroomID"]);
                                if (rdr["DueDate"] != DBNull.Value)
                                    dueDate = Convert.ToDateTime(rdr["DueDate"]);
                            }
                            else
                            {
                                litError.Text = "Assignment not found.";
                                pnlError.Visible = true;
                                return;
                            }
                        }
                    }

                    // Verify enrollment
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM ClassroomEnrollments WHERE ClassroomID=@CID AND StudentID=@SID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        if (Convert.ToInt32(cmd.ExecuteScalar()) == 0)
                        {
                            litError.Text = "You are not enrolled in this classroom.";
                            pnlError.Visible = true;
                            return;
                        }
                    }

                    litTitle.Text = HttpUtility.HtmlEncode(title);
                    litDesc.Text = HttpUtility.HtmlEncode(desc);
                    litClassroom.Text = HttpUtility.HtmlEncode(classroom);
                    litInstructor.Text = HttpUtility.HtmlEncode(instructor);
                    litDue.Text = dueDate.HasValue
                        ? "<span>&#x23F0; Due: " + dueDate.Value.ToString("dd MMM yyyy") + "</span>"
                        : "";

                    // Load questions
                    DataTable dtQ = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT AssignmentQuestionID, QuestionText, QuestionType, OrderIndex
                          FROM AssignmentQuestions
                          WHERE AssignmentID = @AID
                          ORDER BY OrderIndex, AssignmentQuestionID", conn))
                    {
                        cmd.Parameters.Add("@AID", SqlDbType.Int).Value = assignmentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtQ);
                    }

                    if (dtQ.Rows.Count == 0)
                    {
                        pnlNoQuestions.Visible = true;
                        return;
                    }

                    // Check if already submitted
                    bool alreadySubmitted = false;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM AssignmentSubmissions WHERE AssignmentID=@AID AND StudentID=@SID", conn))
                    {
                        cmd.Parameters.Add("@AID", SqlDbType.Int).Value = assignmentID;
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        alreadySubmitted = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                    }

                    // Build questions HTML
                    var sb = new System.Text.StringBuilder();
                    int qNum = 1;

                    foreach (DataRow qRow in dtQ.Rows)
                    {
                        int qID = Convert.ToInt32(qRow["AssignmentQuestionID"]);
                        string qText = HttpUtility.HtmlEncode(qRow["QuestionText"].ToString());
                        string qType = qRow["QuestionType"].ToString();

                        // Check for existing submission
                        string existingAnswer = null;
                        if (alreadySubmitted)
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                "SELECT AnswerText FROM AssignmentSubmissions WHERE AssignmentQuestionID=@QID AND StudentID=@SID", conn))
                            {
                                cmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                                object r = cmd.ExecuteScalar();
                                if (r != null && r != DBNull.Value)
                                    existingAnswer = r.ToString();
                            }
                        }

                        string cardClass = alreadySubmitted ? "asgn-q asgn-submitted" : "asgn-q";
                        sb.AppendFormat("<div class='{0}'>", cardClass);
                        sb.AppendFormat("<div class='asgn-q-num'>Question {0} &bull; {1}</div>", qNum, qType);
                        sb.AppendFormat("<div class='asgn-q-text'>{0}</div>", qText);

                        if (qType == "Objective")
                        {
                            // Load options
                            DataTable dtOpts = new DataTable();
                            using (SqlCommand optCmd = new SqlCommand(
                                "SELECT OptionID, OptionText FROM AssignmentQuestionOptions WHERE AssignmentQuestionID=@QID ORDER BY OptionID", conn))
                            {
                                optCmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
                                using (SqlDataAdapter da = new SqlDataAdapter(optCmd)) da.Fill(dtOpts);
                            }

                            if (alreadySubmitted)
                            {
                                foreach (DataRow oRow in dtOpts.Rows)
                                {
                                    string oText = HttpUtility.HtmlEncode(oRow["OptionText"].ToString());
                                    bool isSelected = existingAnswer == oRow["OptionText"].ToString();
                                    sb.AppendFormat("<div class='asgn-opt{0}' style='pointer-events:none;'>{1}{2}</div>",
                                        isSelected ? " selected" : "",
                                        isSelected ? "" : "",
                                        oText);
                                }
                            }
                            else
                            {
                                sb.AppendFormat("<input type='hidden' id='hdn_{0}' name='q_{0}' value='' />", qID);
                                foreach (DataRow oRow in dtOpts.Rows)
                                {
                                    string oText = HttpUtility.HtmlEncode(oRow["OptionText"].ToString());
                                    sb.AppendFormat("<div class='asgn-opt' data-val='{0}' onclick=\"selectOption(this,'{1}')\">{0}</div>",
                                        oText, qID);
                                }
                            }
                        }
                        else // Subjective
                        {
                            if (alreadySubmitted)
                            {
                                sb.AppendFormat("<div style='padding:12px;background:#F8FAFC;border-radius:8px;font-size:13px;'>{0}</div>",
                                    HttpUtility.HtmlEncode(existingAnswer ?? "(no answer)"));
                            }
                            else
                            {
                                sb.AppendFormat("<textarea name='q_{0}' rows='4' class='cp-input' style='width:100%;font-size:13px;' placeholder='Type your answer here...'></textarea>", qID);
                            }
                        }

                        sb.Append("</div>");
                        qNum++;
                    }

                    litQuestions.Text = sb.ToString();
                    pnlQuestions.Visible = true;

                    if (!alreadySubmitted)
                        pnlSubmitBtn.Visible = true;
                    else
                    {
                        litSuccess.Text = "You have already submitted this assignment.";
                        pnlSuccess.Visible = true;
                    }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load assignment. Please try again.";
                pnlError.Visible = true;
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            int assignmentID = ViewState["AssignmentID"] != null ? (int)ViewState["AssignmentID"] : 0;
            if (assignmentID == 0) return;

            int studentID = Convert.ToInt32(Session["UserID"]);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Get all questions for this assignment
                    DataTable dtQ = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT AssignmentQuestionID FROM AssignmentQuestions WHERE AssignmentID=@AID ORDER BY OrderIndex", conn))
                    {
                        cmd.Parameters.Add("@AID", SqlDbType.Int).Value = assignmentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtQ);
                    }

                    using (SqlTransaction tran = conn.BeginTransaction())
                    {
                        foreach (DataRow row in dtQ.Rows)
                        {
                            int qID = Convert.ToInt32(row["AssignmentQuestionID"]);
                            string answer = Request.Form["q_" + qID];
                            if (string.IsNullOrEmpty(answer)) answer = "";

                            using (SqlCommand cmd = new SqlCommand(
                                @"IF NOT EXISTS (SELECT 1 FROM AssignmentSubmissions WHERE AssignmentQuestionID=@QID AND StudentID=@SID)
                                  INSERT INTO AssignmentSubmissions (AssignmentID, AssignmentQuestionID, StudentID, AnswerText, SubmittedAt)
                                  VALUES (@AID, @QID, @SID, @Ans, GETDATE())", conn, tran))
                            {
                                cmd.Parameters.Add("@AID", SqlDbType.Int).Value = assignmentID;
                                cmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                                cmd.Parameters.Add("@Ans", SqlDbType.NVarChar, -1).Value =
                                    string.IsNullOrEmpty(answer) ? (object)DBNull.Value : answer;
                                cmd.ExecuteNonQuery();
                            }
                        }
                        tran.Commit();
                    }
                }

                // Reload to show submitted state
                Response.Redirect(Request.Url.ToString());
            }
            catch (SqlException)
            {
                litError.Text = "Could not submit. Please try again.";
                pnlError.Visible = true;
            }
        }
    }
}
