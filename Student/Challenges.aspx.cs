using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class Challenges : System.Web.UI.Page
    {
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            bool isGuest = (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student");

            if (!IsPostBack)
            {
                int leaderboardID;
                if (int.TryParse(Request.QueryString["leaderboard"], out leaderboardID) && leaderboardID > 0)
                {
                    pnlListingView.Visible = false;
                    LoadLeaderboardOnly(leaderboardID);
                    return;
                }

                int challengeID;
                if (!isGuest && int.TryParse(Request.QueryString["challengeID"], out challengeID) && challengeID > 0)
                {
                    pnlListingView.Visible = false;
                    ViewState["ChallengeID"] = challengeID;
                    LoadChallengeIntro(challengeID);
                    return;
                }

                LoadChallenges();
            }
        }

        private void LoadChallenges()
        {
            int studentID = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Active challenges (StartDate <= now <= EndDate).
                    string activeSql = @"
                        SELECT c.ChallengeID, c.Title, c.Description,
                               c.XPReward, c.EndDate,
                               (SELECT COUNT(*) FROM ChallengeQuestions cq WHERE cq.ChallengeID = c.ChallengeID) AS QuestionCount,
                               CASE WHEN EXISTS (
                                   SELECT 1 FROM ChallengeParticipation cp2
                                   WHERE cp2.ChallengeID = c.ChallengeID
                                     AND cp2.StudentID   = @StudentID)
                               THEN 1 ELSE 0 END AS HasParticipated
                        FROM Challenges c
                        WHERE c.StartDate <= GETDATE()
                          AND c.EndDate   >= GETDATE()
                        ORDER BY c.EndDate ASC";

                    DataTable dtActive = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(activeSql, conn))
                    {
                        cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtActive);
                    }

                    if (dtActive.Rows.Count > 0)
                    {
                        rptActive.DataSource = dtActive;
                        rptActive.DataBind();
                        pnlActive.Visible = true;
                    }
                    else { pnlNoActive.Visible = true; }

                    // Past participation.
                    string pastSql = @"
                        SELECT c.ChallengeID, c.Title, cp.Score, cp.CompletedAt
                        FROM ChallengeParticipation cp
                        INNER JOIN Challenges c ON c.ChallengeID = cp.ChallengeID
                        WHERE cp.StudentID = @StudentID
                        ORDER BY cp.CompletedAt DESC";

                    DataTable dtPast = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(pastSql, conn))
                    {
                        cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtPast);
                    }

                    if (dtPast.Rows.Count > 0)
                    {
                        rptPast.DataSource = dtPast;
                        rptPast.DataBind();
                        pnlPast.Visible = true;
                    }
                    else { pnlNoPast.Visible = true; }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load challenges. Please try again.";
                pnlError.Visible = true;
            }
        }

        // -----------------------------------------------------------
        // ENTER CHALLENGE FLOW
        // -----------------------------------------------------------

        private void LoadChallengeIntro(int challengeID)
        {
            int studentID = Convert.ToInt32(Session["UserID"]);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string title = null, description = null;
                    int xpReward = 0;
                    bool isActive = false;

                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT Title, Description, XPReward,
                                 CASE WHEN StartDate <= GETDATE() AND EndDate >= GETDATE() THEN 1 ELSE 0 END AS IsActive
                          FROM Challenges WHERE ChallengeID=@CID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (!rdr.Read())
                            {
                                litError.Text = "Challenge not found.";
                                pnlError.Visible = true;
                                return;
                            }
                            title = rdr["Title"].ToString();
                            description = rdr["Description"] != DBNull.Value ? rdr["Description"].ToString() : "";
                            xpReward = Convert.ToInt32(rdr["XPReward"]);
                            isActive = Convert.ToBoolean(rdr["IsActive"]);
                        }
                    }

                    ViewState["XPReward"] = xpReward;
                    litIntroTitle.Text = HttpUtility.HtmlEncode(title);
                    litIntroDesc.Text = HttpUtility.HtmlEncode(description);
                    litIntroXP.Text = xpReward.ToString();

                    if (!isActive)
                    {
                        litIntroMessage.Text = "This challenge is not currently active.";
                        pnlIntroMessage.Visible = true;
                        pnlIntro.Visible = true;
                        pnlStartBtn.Visible = false;
                        return;
                    }

                    bool alreadyParticipated;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM ChallengeParticipation WHERE ChallengeID=@CID AND StudentID=@SID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        alreadyParticipated = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                    }

                    if (alreadyParticipated)
                    {
                        litIntroMessage.Text = "You have already completed this challenge.";
                        pnlIntroMessage.Visible = true;
                        pnlIntro.Visible = true;
                        pnlStartBtn.Visible = false;
                        return;
                    }

                    int questionCount;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM ChallengeQuestions WHERE ChallengeID=@CID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        questionCount = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    if (questionCount == 0)
                    {
                        litIntroMessage.Text = "This challenge has no questions yet. Check back soon.";
                        pnlIntroMessage.Visible = true;
                        pnlIntro.Visible = true;
                        pnlStartBtn.Visible = false;
                        return;
                    }

                    litIntroQCount.Text = questionCount.ToString();
                    pnlIntro.Visible = true;
                    pnlStartBtn.Visible = true;
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load this challenge.";
                pnlError.Visible = true;
            }
        }

        protected void btnStartChallenge_Click(object sender, EventArgs e)
        {
            int challengeID = (int)ViewState["ChallengeID"];
            int studentID = Convert.ToInt32(Session["UserID"]);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Re-check in case of a double-click / duplicate submit.
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM ChallengeParticipation WHERE ChallengeID=@CID AND StudentID=@SID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
                        {
                            litIntroMessage.Text = "You have already completed this challenge.";
                            pnlIntroMessage.Visible = true;
                            pnlStartBtn.Visible = false;
                            return;
                        }
                    }

                    List<int> qIDs = new List<int>();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT ChallengeQuestionID FROM ChallengeQuestions WHERE ChallengeID=@CID ORDER BY OrderIndex, ChallengeQuestionID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read()) qIDs.Add(Convert.ToInt32(rdr["ChallengeQuestionID"]));
                        }
                    }

                    ViewState["QuestionIDs"] = string.Join(",", qIDs);
                    ViewState["QIndex"] = 0;
                    ViewState["Score"] = 0;
                }

                pnlIntro.Visible = false;
                LoadCurrentQuestion();
            }
            catch (SqlException)
            {
                litError.Text = "Could not start the challenge.";
                pnlError.Visible = true;
            }
        }

        private void LoadCurrentQuestion()
        {
            string csv = ViewState["QuestionIDs"] != null ? ViewState["QuestionIDs"].ToString() : "";
            int index = ViewState["QIndex"] != null ? (int)ViewState["QIndex"] : 0;
            List<int> qIDs = csv.Length > 0 ? csv.Split(',').Select(int.Parse).ToList() : new List<int>();

            if (index >= qIDs.Count)
            {
                EndChallenge();
                return;
            }

            int qID = qIDs[index];

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string qText = null;
                    int points = 10, timeLimit = 30;

                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT QuestionText, Points, TimeLimitSeconds FROM ChallengeQuestions WHERE ChallengeQuestionID=@QID", conn))
                    {
                        cmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                qText = rdr["QuestionText"].ToString();
                                points = Convert.ToInt32(rdr["Points"]);
                                timeLimit = Convert.ToInt32(rdr["TimeLimitSeconds"]);
                            }
                        }
                    }

                    ViewState["CurrentQID"] = qID;
                    ViewState["CurrentPoints"] = points;

                    litQuizQText.Text = HttpUtility.HtmlEncode(qText);
                    litQuizProgress.Text = (index + 1) + " / " + qIDs.Count;

                    DataTable dtOpts = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT OptionID, OptionText FROM ChallengeQuestionOptions WHERE ChallengeQuestionID=@QID ORDER BY NEWID()", conn))
                    {
                        cmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtOpts);
                    }

                    var sb = new System.Text.StringBuilder();
                    foreach (DataRow row in dtOpts.Rows)
                    {
                        string oid = row["OptionID"].ToString();
                        string otext = HttpUtility.HtmlEncode(row["OptionText"].ToString());
                        sb.AppendFormat("<div class='quiz-opt' data-val='{0}'>{1}</div>", oid, otext);
                    }
                    litQuizOptions.Text = sb.ToString();

                    hdnSelectedOption.Value = "";
                    pnlQuizAnswer.Visible = true;
                    pnlQuizResult.Visible = false;
                    pnlQuiz.Visible = true;

                    ScriptManager.RegisterStartupScript(this, GetType(), "startChTimer",
                        "window.startChallengeTimer(" + timeLimit + ");", true);
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load the next question.";
                pnlError.Visible = true;
            }
        }

        protected void btnSubmitChAnswer_Click(object sender, EventArgs e)
        {
            int selectedOptionID;
            if (!int.TryParse(hdnSelectedOption.Value, out selectedOptionID))
                selectedOptionID = 0; // timeout / no selection

            int points = (int)ViewState["CurrentPoints"];
            int score = (int)ViewState["Score"];
            bool isCorrect = false;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    if (selectedOptionID > 0)
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT IsCorrect FROM ChallengeQuestionOptions WHERE OptionID=@OID", conn))
                        {
                            cmd.Parameters.Add("@OID", SqlDbType.Int).Value = selectedOptionID;
                            object r = cmd.ExecuteScalar();
                            isCorrect = (r != null && Convert.ToBoolean(r));
                        }
                    }
                }

                if (isCorrect) score += points;
                ViewState["Score"] = score;

                int index = (int)ViewState["QIndex"];
                ViewState["QIndex"] = index + 1;

                pnlQuizAnswer.Visible = false;
                pnlQuizResult.Visible = true;

                if (isCorrect)
                {
                    litQuizResultIcon.Text = "&#x2705;";
                    litQuizResultTitle.Text = "Correct!";
                    litQuizResultDesc.Text = "+" + points + " points";
                }
                else
                {
                    litQuizResultIcon.Text = "&#x274C;";
                    litQuizResultTitle.Text = selectedOptionID == 0 ? "Time's up!" : "Not quite.";
                    litQuizResultDesc.Text = "No points this round.";
                }
            }
            catch (SqlException)
            {
                litError.Text = "An error occurred submitting your answer.";
                pnlError.Visible = true;
            }
        }

        protected void btnNextChQuestion_Click(object sender, EventArgs e)
        {
            LoadCurrentQuestion();
        }

        private void EndChallenge()
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

                    // Guard against a duplicate insert (unique constraint on ChallengeID+StudentID).
                    bool alreadyParticipated;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM ChallengeParticipation WHERE ChallengeID=@CID AND StudentID=@SID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        alreadyParticipated = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                    }

                    if (!alreadyParticipated)
                    {
                        using (SqlTransaction tx = conn.BeginTransaction())
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                @"INSERT INTO ChallengeParticipation (ChallengeID, StudentID, Score, CompletedAt)
                                  VALUES (@CID, @SID, @Score, GETDATE())", conn, tx))
                            {
                                cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                                cmd.Parameters.Add("@Score", SqlDbType.Int).Value = score;
                                cmd.ExecuteNonQuery();
                            }

                            if (xpReward > 0)
                            {
                                using (SqlCommand cmd = new SqlCommand(
                                    @"INSERT INTO XPTransactions (StudentID, SourceType, SourceID, XPAmount, CreatedAt)
                                      VALUES (@SID, 'Challenge', @CID, @XP, GETDATE())", conn, tx))
                                {
                                    cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                                    cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                                    cmd.Parameters.Add("@XP", SqlDbType.Int).Value = xpReward;
                                    cmd.ExecuteNonQuery();
                                }

                                using (SqlCommand cmd = new SqlCommand(
                                    "UPDATE Students SET TotalXP = TotalXP + @XP WHERE StudentID=@SID", conn, tx))
                                {
                                    cmd.Parameters.Add("@XP", SqlDbType.Int).Value = xpReward;
                                    cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            tx.Commit();
                        }
                    }
                }

                pnlQuiz.Visible = false;
                litFinalScore.Text = score.ToString();
                litFinalXP.Text = xpReward.ToString();
                pnlFinalResult.Visible = true;

                BindLeaderboard(challengeID);
            }
            catch (SqlException)
            {
                litError.Text = "Could not save your challenge result.";
                pnlError.Visible = true;
            }
        }

        // -----------------------------------------------------------
        // LEADERBOARD
        // -----------------------------------------------------------

        private void BindLeaderboard(int challengeID)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT TOP 10 u.FullName, cp.Score, cp.CompletedAt
                          FROM ChallengeParticipation cp
                          INNER JOIN Students s ON s.StudentID = cp.StudentID
                          INNER JOIN Users u ON u.UserID = s.StudentID
                          WHERE cp.ChallengeID = @CID
                          ORDER BY cp.Score DESC, cp.CompletedAt ASC", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }

                    if (dt.Rows.Count > 0)
                    {
                        rptLeaderboard.DataSource = dt;
                        rptLeaderboard.DataBind();
                        pnlLeaderboard.Visible = true;
                    }
                }
            }
            catch (SqlException) { /* leaderboard is a nice-to-have, fail quietly */ }
        }

        private void LoadLeaderboardOnly(int challengeID)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("SELECT Title FROM Challenges WHERE ChallengeID=@CID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        object title = cmd.ExecuteScalar();
                        litLeaderboardOnlyTitle.Text = title != null ? HttpUtility.HtmlEncode(title.ToString()) : "Challenge";
                    }
                }
            }
            catch (SqlException) { }

            pnlLeaderboardOnlyView.Visible = true;
            BindLeaderboard(challengeID);
        }
    }
}
