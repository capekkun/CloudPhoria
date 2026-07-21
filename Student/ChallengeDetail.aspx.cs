using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class ChallengeDetail : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            { Response.Redirect("~/LogIn.aspx", true); return; }

            ((SiteMaster)Master).PageHeading = "Live Challenge";

            if (!IsPostBack)
            {
                int challengeID;
                if (!int.TryParse(Request.QueryString["challengeID"], out challengeID))
                { Response.Redirect("~/Student/Challenges.aspx"); return; }
                ViewState["ChallengeID"] = challengeID;
                LoadChallenge(challengeID);
            }
        }

        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString; }
        }

        private void LoadChallenge(int challengeID)
        {
            int studentID = Convert.ToInt32(Session["UserID"]);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Challenge info
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT Title, Description, XPReward, StartDate, EndDate
                          FROM Challenges WHERE ChallengeID=@CID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                litTitle.Text = HttpUtility.HtmlEncode(rdr["Title"].ToString());
                                litDescription.Text = HttpUtility.HtmlEncode(
                                    rdr["Description"] != DBNull.Value ? rdr["Description"].ToString() : "");
                                litXPReward.Text = rdr["XPReward"].ToString();
                                litEndDate.Text = Convert.ToDateTime(rdr["EndDate"]).ToString("dd MMM yyyy HH:mm");
                                ViewState["XPReward"] = Convert.ToInt32(rdr["XPReward"]);

                                // Check if challenge is active
                                DateTime end = Convert.ToDateTime(rdr["EndDate"]);
                                DateTime start = Convert.ToDateTime(rdr["StartDate"]);
                                if (DateTime.Now < start || DateTime.Now > end)
                                {
                                    litError.Text = "This challenge is not currently active.";
                                    pnlError.Visible = true;
                                    return;
                                }
                            }
                            else
                            {
                                litError.Text = "Challenge not found.";
                                pnlError.Visible = true;
                                return;
                            }
                        }
                    }

                    // Check if already participated
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT Score FROM ChallengeParticipation WHERE ChallengeID=@CID AND StudentID=@SID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        object r = cmd.ExecuteScalar();
                        if (r != null)
                        {
                            // Already completed — show result
                            int score = Convert.ToInt32(r);
                            litScore.Text = score.ToString();
                            litFinalScore.Text = score.ToString();
                            litXPEarned.Text = ViewState["XPReward"].ToString();
                            pnlStart.Style["display"] = "none";
                            pnlResult.Style["display"] = "block";
                        }
                    }

                    // Question count
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM ChallengeQuestions WHERE ChallengeID=@CID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        int qCount = Convert.ToInt32(cmd.ExecuteScalar());
                        litQuestionCount.Text = qCount.ToString();
                        ViewState["TotalQuestions"] = qCount;
                    }

                    // Load leaderboard
                    LoadLeaderboard(challengeID, conn);

                    pnlChallenge.Visible = true;
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load challenge.";
                pnlError.Visible = true;
            }
        }

        protected void btnStart_Click(object sender, EventArgs e)
        {
            ViewState["CurrentQ"] = 1;
            ViewState["Score"] = 0;
            pnlStart.Style["display"] = "none";
            pnlQuestion.Style["display"] = "block";
            LoadQuestion();
        }

        private void LoadQuestion()
        {
            int challengeID = (int)ViewState["ChallengeID"];
            int currentQ = (int)ViewState["CurrentQ"];
            int totalQ = (int)ViewState["TotalQuestions"];

            litQNum.Text = currentQ.ToString();
            litQTotal.Text = totalQ.ToString();

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Get question by order
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT ChallengeQuestionID, QuestionText, TimeLimitSeconds
                          FROM ChallengeQuestions
                          WHERE ChallengeID=@CID
                          ORDER BY OrderIndex, ChallengeQuestionID
                          OFFSET @Off ROWS FETCH NEXT 1 ROWS ONLY", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        cmd.Parameters.Add("@Off", SqlDbType.Int).Value = currentQ - 1;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                int qID = Convert.ToInt32(rdr["ChallengeQuestionID"]);
                                string qText = rdr["QuestionText"].ToString();
                                int timeLimit = Convert.ToInt32(rdr["TimeLimitSeconds"]);

                                ViewState["CurrentQID"] = qID;
                                litQText.Text = HttpUtility.HtmlEncode(qText);
                                hdnTimeLimit.Value = timeLimit.ToString();

                                rdr.Close();

                                // Load options
                                DataTable dtOpts = new DataTable();
                                using (SqlCommand optCmd = new SqlCommand(
                                    @"SELECT OptionID, OptionText FROM ChallengeQuestionOptions
                                      WHERE ChallengeQuestionID=@QID ORDER BY OptionID", conn))
                                {
                                    optCmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
                                    using (SqlDataAdapter da = new SqlDataAdapter(optCmd)) da.Fill(dtOpts);
                                }

                                var sb = new System.Text.StringBuilder();
                                foreach (DataRow row in dtOpts.Rows)
                                {
                                    string oid = row["OptionID"].ToString();
                                    string otext = HttpUtility.HtmlEncode(row["OptionText"].ToString());
                                    sb.AppendFormat(
                                        "<a href='javascript:void(0)' class='ch-opt' " +
                                        "onclick=\"selectChAnswer(this,'{0}')\">{1}</a>",
                                        oid, otext);
                                }
                                litQOpts.Text = sb.ToString();

                                // Start timer via script
                                ScriptManager.RegisterStartupScript(this, GetType(), "startTimer",
                                    "startChTimer(" + timeLimit + ");", true);
                            }
                            else
                            {
                                // No more questions — finish
                                FinishChallenge();
                            }
                        }
                    }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load question.";
                pnlError.Visible = true;
            }
        }

        protected void btnSubmitAnswer_Click(object sender, EventArgs e)
        {
            int selectedOptionID;
            if (!int.TryParse(hdnAnswer.Value, out selectedOptionID))
                selectedOptionID = 0;

            int qID = ViewState["CurrentQID"] != null ? (int)ViewState["CurrentQID"] : 0;
            int score = ViewState["Score"] != null ? (int)ViewState["Score"] : 0;

            // Check if correct
            if (selectedOptionID > 0)
            {
                try
                {
                    using (SqlConnection conn = new SqlConnection(ConnStr))
                    {
                        conn.Open();
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT IsCorrect FROM ChallengeQuestionOptions WHERE OptionID=@OID", conn))
                        {
                            cmd.Parameters.Add("@OID", SqlDbType.Int).Value = selectedOptionID;
                            object r = cmd.ExecuteScalar();
                            if (r != null && Convert.ToBoolean(r))
                            {
                                // Get points for this question
                                using (SqlCommand pCmd = new SqlCommand(
                                    "SELECT Points FROM ChallengeQuestions WHERE ChallengeQuestionID=@QID", conn))
                                {
                                    pCmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
                                    object pts = pCmd.ExecuteScalar();
                                    if (pts != null) score += Convert.ToInt32(pts);
                                }
                            }
                        }
                    }
                }
                catch (SqlException) { }
            }

            ViewState["Score"] = score;
            litScore.Text = score.ToString();

            // Move to next question
            int currentQ = (int)ViewState["CurrentQ"];
            int totalQ = (int)ViewState["TotalQuestions"];

            if (currentQ >= totalQ)
            {
                FinishChallenge();
            }
            else
            {
                ViewState["CurrentQ"] = currentQ + 1;
                LoadQuestion();
            }
        }

        private void FinishChallenge()
        {
            int challengeID = (int)ViewState["ChallengeID"];
            int studentID = Convert.ToInt32(Session["UserID"]);
            int score = ViewState["Score"] != null ? (int)ViewState["Score"] : 0;
            int xpReward = ViewState["XPReward"] != null ? (int)ViewState["XPReward"] : 0;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlTransaction tran = conn.BeginTransaction())
                    {
                        // Insert participation
                        using (SqlCommand cmd = new SqlCommand(
                            @"IF NOT EXISTS (SELECT 1 FROM ChallengeParticipation WHERE ChallengeID=@CID AND StudentID=@SID)
                              INSERT INTO ChallengeParticipation (ChallengeID, StudentID, Score, CompletedAt)
                              VALUES (@CID, @SID, @Score, GETDATE())", conn, tran))
                        {
                            cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                            cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                            cmd.Parameters.Add("@Score", SqlDbType.Int).Value = score;
                            cmd.ExecuteNonQuery();
                        }

                        // Award XP
                        if (xpReward > 0)
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                @"INSERT INTO XPTransactions (StudentID, SourceType, SourceID, XPAmount, CreatedAt)
                                  VALUES (@SID, 'Challenge', @CID, @XP, GETDATE())", conn, tran))
                            {
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                                cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                                cmd.Parameters.Add("@XP", SqlDbType.Int).Value = xpReward;
                                cmd.ExecuteNonQuery();
                            }

                            using (SqlCommand cmd = new SqlCommand(
                                "UPDATE Students SET TotalXP = TotalXP + @XP WHERE StudentID=@SID", conn, tran))
                            {
                                cmd.Parameters.Add("@XP", SqlDbType.Int).Value = xpReward;
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                                cmd.ExecuteNonQuery();
                            }
                        }

                        tran.Commit();
                    }

                    // Reload leaderboard
                    LoadLeaderboard(challengeID, conn);
                }
            }
            catch (SqlException) { }

            // Show result
            pnlQuestion.Style["display"] = "none";
            pnlResult.Style["display"] = "block";
            litFinalScore.Text = score.ToString();
            litXPEarned.Text = xpReward.ToString();
            litScore.Text = score.ToString();
        }

        private void LoadLeaderboard(int challengeID, SqlConnection conn)
        {
            DataTable dtLB = new DataTable();
            using (SqlCommand cmd = new SqlCommand(
                @"SELECT TOP 10 u.FullName, cp.Score
                  FROM ChallengeParticipation cp
                  INNER JOIN Users u ON u.UserID = cp.StudentID
                  WHERE cp.ChallengeID = @CID
                  ORDER BY cp.Score DESC, cp.CompletedAt ASC", conn))
            {
                cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtLB);
            }

            if (dtLB.Rows.Count == 0)
            {
                litLeaderboard.Text = "<div class='ch-lb-empty'>No participants yet. Be the first!</div>";
                return;
            }

            var sb = new System.Text.StringBuilder();
            int rank = 1;
            foreach (DataRow row in dtLB.Rows)
            {
                string name = HttpUtility.HtmlEncode(row["FullName"].ToString());
                string scoreStr = row["Score"].ToString();
                string rankClass = rank <= 3 ? "ch-lb-rank ch-lb-rank-" + rank : "ch-lb-rank";
                string rankIcon = rank == 1 ? "&#x1F947;" : rank == 2 ? "&#x1F948;" : rank == 3 ? "&#x1F949;" : rank.ToString();

                sb.AppendFormat(
                    "<div class='ch-lb-item'>" +
                    "<div class='{0}'>{1}</div>" +
                    "<div class='ch-lb-name'>{2}</div>" +
                    "<div class='ch-lb-score'>{3} pts</div></div>",
                    rankClass, rankIcon, name, scoreStr);
                rank++;
            }

            litLeaderboard.Text = sb.ToString();
        }
    }
}
