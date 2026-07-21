using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class SubTopicView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            bool isGuest = (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student");

            if (!IsPostBack)
            {
                int subID;
                if (!int.TryParse(Request.QueryString["subtopicID"], out subID))
                { Response.Redirect("~/Student/Pathways.aspx"); return; }
                ViewState["IsGuest"] = isGuest;
                LoadSubTopic(subID);
            }
        }

        private void LoadSubTopic(int subID)
        {
            int studentID = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0;
            bool isGuest = (studentID == 0);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Subtopic info
                    int moduleID = 0;
                    bool isFoundation = false;
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT st.SubTopicName, st.ContentBody, st.XPReward, st.ModuleID,
                                 m.ModuleName, p.IsFoundation
                          FROM SubTopics st
                          INNER JOIN Modules m ON m.ModuleID = st.ModuleID
                          INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
                          WHERE st.SubTopicID = @STID AND st.IsPublished = 1", conn))
                    {
                        cmd.Parameters.Add("@STID", SqlDbType.Int).Value = subID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                isFoundation = Convert.ToBoolean(rdr["IsFoundation"]);
                                moduleID = Convert.ToInt32(rdr["ModuleID"]);
                                litSubName.Text    = HttpUtility.HtmlEncode(rdr["SubTopicName"].ToString());
                                litModuleName.Text = HttpUtility.HtmlEncode(rdr["ModuleName"].ToString());
                                litXP.Text         = rdr["XPReward"].ToString();
                                ViewState["ModuleID"]   = Convert.ToInt32(rdr["ModuleID"]);
                                ViewState["SubTopicID"] = subID;
                                ViewState["SubXP"]      = Convert.ToInt32(rdr["XPReward"]);

                                string content = rdr["ContentBody"] != DBNull.Value
                                    ? rdr["ContentBody"].ToString() : "<em>No content available yet.</em>";
                                // Content may contain HTML from trusted instructor
                                litContent.Text = content;
                                pnlContent.Visible = true;
                            }
                            else
                            {
                                litError.Text = "Subtopic not found.";
                                pnlError.Visible = true;
                                return;
                            }
                        }
                    }

                    // Subscription check — Free tier can only access Foundation subtopics
                    if (!isFoundation && !isGuest)
                    {
                        bool isFoundationOnly = true;
                        using (SqlCommand cmd = new SqlCommand(
                            @"SELECT TOP 1 sp.CanAccessFoundationOnly FROM UserSubscriptions us
                              INNER JOIN SubscriptionPlans sp ON sp.PlanID=us.PlanID
                              WHERE us.StudentID=@SID AND us.IsActive=1 ORDER BY us.StartDate DESC", conn))
                        {
                            cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                            object sr = cmd.ExecuteScalar();
                            isFoundationOnly = (sr == null || sr == DBNull.Value) ? true : Convert.ToBoolean(sr);
                        }
                        if (isFoundationOnly)
                        {
                            litError.Text = "This content requires a Pro or Student subscription.";
                            pnlError.Visible = true;
                            pnlContent.Visible = false;
                            return;
                        }
                    }

                    // Check progress status (skip for guests)
                    if (!isGuest)
                    {
                        string status = "NotStarted";
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT Status FROM SubTopicProgress WHERE SubTopicID=@STID AND StudentID=@SID", conn))
                        {
                            cmd.Parameters.Add("@STID", SqlDbType.Int).Value = subID;
                            cmd.Parameters.Add("@SID",  SqlDbType.Int).Value = studentID;
                            object r = cmd.ExecuteScalar();
                            if (r != null && r != DBNull.Value) status = r.ToString();
                        }

                        if (status == "Completed")
                        {
                            litStatus.Text = "<span class='cp-badge cp-badge-green'>Completed</span>";
                            pnlAlreadyDone.Visible = true;
                        }
                        else
                        {
                            litStatus.Text = "<span class='cp-badge cp-badge-blue'>In Progress</span>";
                            pnlComplete.Visible = true;

                            // Mark as InProgress if not started
                            if (status == "NotStarted")
                            {
                                using (SqlCommand cmd = new SqlCommand(
                                    @"IF NOT EXISTS (SELECT 1 FROM SubTopicProgress WHERE SubTopicID=@STID AND StudentID=@SID)
                                      INSERT INTO SubTopicProgress (StudentID, SubTopicID, Status) VALUES (@SID, @STID, 'InProgress')
                                      ELSE UPDATE SubTopicProgress SET Status='InProgress' WHERE SubTopicID=@STID AND StudentID=@SID AND Status='NotStarted'", conn))
                                {
                                    cmd.Parameters.Add("@STID", SqlDbType.Int).Value = subID;
                                    cmd.Parameters.Add("@SID",  SqlDbType.Int).Value = studentID;
                                    cmd.ExecuteNonQuery();
                                }
                            }
                        }
                    }
                    else
                    {
                        litStatus.Text = "<span class='cp-badge cp-badge-grey'>Guest Preview</span>";
                    }

                    // Materials
                    DataTable dtMat = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT FileName, FilePath FROM LearningMaterials WHERE SubTopicID=@STID", conn))
                    {
                        cmd.Parameters.Add("@STID", SqlDbType.Int).Value = subID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtMat);
                    }
                    if (dtMat.Rows.Count > 0)
                    {
                        rptMaterials.DataSource = dtMat;
                        rptMaterials.DataBind();
                        pnlMaterials.Visible = true;
                    }

                    // Questions for this subtopic (hide for guests)
                    if (!isGuest)
                    {
                        DataTable dtQ = new DataTable();
                        using (SqlCommand cmd = new SqlCommand(
                            @"SELECT QuestionID, QuestionText, QuestionType, XPReward
                              FROM Questions
                              WHERE SubTopicID = @STID
                              ORDER BY OrderIndex, QuestionID", conn))
                        {
                            cmd.Parameters.Add("@STID", SqlDbType.Int).Value = subID;
                            using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtQ);
                        }
                        if (dtQ.Rows.Count > 0)
                        {
                            rptQuestions.DataSource = dtQ;
                            rptQuestions.DataBind();
                            pnlQuestions.Visible = true;
                        }
                        else
                        {
                            pnlComplete.Visible = true;
                        }
                    }
                    else
                    {
                        // Guest — show register prompt instead of questions
                        pnlGuestPrompt.Visible = true;
                    }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load subtopic. Please try again.";
                pnlError.Visible = true;
            }
        }

        // Helper to render MCQ options for a question
        protected string GetMCQOptions(int questionID)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            var sb = new System.Text.StringBuilder();
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT TOP 4 MIN(OptionID) AS OptionID, OptionText, MAX(CAST(IsCorrect AS INT)) AS IsCorrect FROM AnswerOptions WHERE QuestionID=@QID GROUP BY OptionText ORDER BY MIN(OptionID)", conn))
                    {
                        cmd.Parameters.Add("@QID", SqlDbType.Int).Value = questionID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                string optText = HttpUtility.HtmlEncode(rdr["OptionText"].ToString());
                                bool isCorrect = Convert.ToBoolean(rdr["IsCorrect"]);
                                string correctClass = isCorrect ? "correct" : "wrong";
                                sb.AppendFormat(
                                    "<div class='st-opt' data-answer='{0}' style='padding:10px 14px;" +
                                    "background:rgba(99,102,241,0.04);border:1.5px solid #E2E8F0;" +
                                    "border-radius:8px;font-size:13px;color:#172033;cursor:pointer;" +
                                    "transition:all 0.2s;margin-bottom:8px;' " +
                                    "onclick=\"selectAnswer(this,'{0}')\">" +
                                    "&#x25CB; {1}</div>",
                                    correctClass, optText);
                            }
                        }
                    }
                }
            }
            catch (SqlException) { }
            return sb.ToString();
        }

        protected void btnComplete_Click(object sender, EventArgs e)
        {
            int studentID = Convert.ToInt32(Session["UserID"]);
            int subID     = ViewState["SubTopicID"] != null ? (int)ViewState["SubTopicID"] : 0;
            int xpReward  = ViewState["SubXP"] != null ? (int)ViewState["SubXP"] : 0;
            int moduleID  = ViewState["ModuleID"] != null ? (int)ViewState["ModuleID"] : 0;
            if (subID == 0) return;

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlTransaction tran = conn.BeginTransaction())
                    {
                        // Update progress to Completed
                        using (SqlCommand cmd = new SqlCommand(
                            @"UPDATE SubTopicProgress SET Status='Completed', XPEarned=@XP, CompletedAt=GETDATE()
                              WHERE SubTopicID=@STID AND StudentID=@SID", conn, tran))
                        {
                            cmd.Parameters.Add("@STID", SqlDbType.Int).Value = subID;
                            cmd.Parameters.Add("@SID",  SqlDbType.Int).Value = studentID;
                            cmd.Parameters.Add("@XP",   SqlDbType.Int).Value = xpReward;
                            cmd.ExecuteNonQuery();
                        }

                        // Award XP
                        if (xpReward > 0)
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                @"INSERT INTO XPTransactions (StudentID, SourceType, SourceID, XPAmount, CreatedAt)
                                  VALUES (@SID, 'SubTopic', @STID, @XP, GETDATE())", conn, tran))
                            {
                                cmd.Parameters.Add("@SID",  SqlDbType.Int).Value = studentID;
                                cmd.Parameters.Add("@STID", SqlDbType.Int).Value = subID;
                                cmd.Parameters.Add("@XP",   SqlDbType.Int).Value = xpReward;
                                cmd.ExecuteNonQuery();
                            }

                            using (SqlCommand cmd = new SqlCommand(
                                "UPDATE Students SET TotalXP = TotalXP + @XP WHERE StudentID=@SID", conn, tran))
                            {
                                cmd.Parameters.Add("@XP",  SqlDbType.Int).Value = xpReward;
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                                cmd.ExecuteNonQuery();
                            }
                        }

                        // Check if all subtopics in the module are now completed -> update ModuleProgress
                        if (moduleID > 0)
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                @"DECLARE @Total INT, @Done INT;
                                  SELECT @Total = COUNT(*) FROM SubTopics WHERE ModuleID=@MID AND IsPublished=1;
                                  SELECT @Done = COUNT(*) FROM SubTopicProgress stp
                                      INNER JOIN SubTopics st ON st.SubTopicID = stp.SubTopicID
                                      WHERE st.ModuleID=@MID AND stp.StudentID=@SID AND stp.Status='Completed';
                                  IF @Total > 0 AND @Total = @Done
                                  BEGIN
                                      UPDATE ModuleProgress SET Status='Completed'
                                      WHERE ModuleID=@MID AND StudentID=@SID;
                                  END", conn, tran))
                            {
                                cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                                cmd.ExecuteNonQuery();
                            }
                        }

                        tran.Commit();
                    }
                }

                // Refresh page to show completed state
                Response.Redirect(Request.Url.ToString());
            }
            catch (SqlException)
            {
                litError.Text = "Could not mark as complete. Please try again.";
                pnlError.Visible = true;
            }
        }
    }
}
