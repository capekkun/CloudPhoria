using System;
<<<<<<< HEAD
=======
using System.Collections.Generic;
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Admin
{
    public partial class Challenges : System.Web.UI.Page
    {
<<<<<<< HEAD
=======
        private const int OPTION_COUNT = 4;

        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString; }
        }

        private int AdminID
        {
            get { return Convert.ToInt32(Session["UserID"]); }
        }

>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

<<<<<<< HEAD
            if (!IsPostBack)
            {
                LoadChallenges();
            }
        }

        private void LoadChallenges()
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Load summary counters.
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM Challenges WHERE StartDate <= GETDATE() AND EndDate >= GETDATE()", conn))
                    {
                        litActiveCount.Text = cmd.ExecuteScalar().ToString();
                    }
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM Challenges WHERE StartDate > GETDATE()", conn))
                    {
                        litUpcomingCount.Text = cmd.ExecuteScalar().ToString();
                    }
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM Challenges WHERE EndDate < GETDATE()", conn))
                    {
                        litEndedCount.Text = cmd.ExecuteScalar().ToString();
                    }

                    // Load all challenges — admin sees both admin-created and instructor-created.
                    string sql = @"
                        SELECT
                            c.ChallengeID,
                            c.Title,
                            c.Description,
                            c.XPReward,
                            c.StartDate,
                            c.EndDate,
                            c.IsGlobalAdminChallenge,
                            COALESCE(adminUser.FullName, instrUser.FullName) AS CreatorName,
                            (SELECT COUNT(*) FROM ChallengeParticipation cp
                             WHERE cp.ChallengeID = c.ChallengeID) AS ParticipantCount
                        FROM Challenges c
                        LEFT JOIN Admins a       ON a.AdminID          = c.CreatedByAdminID
                        LEFT JOIN Users adminUser ON adminUser.UserID   = a.AdminID
                        LEFT JOIN Instructors i   ON i.InstructorID    = c.CreatedByInstructorID
                        LEFT JOIN Users instrUser ON instrUser.UserID   = i.InstructorID
                        ORDER BY c.StartDate DESC";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                            da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptChallenges.DataSource = dt;
                            rptChallenges.DataBind();
                            pnlList.Visible  = true;
                            pnlEmpty.Visible = false;
                        }
                        else
                        {
                            pnlList.Visible  = false;
                            pnlEmpty.Visible = true;
                        }
=======
            ((SiteMaster)Master).PageHeading = "Global Challenges";

            if (!IsPostBack)
            {
                int manageID;
                if (int.TryParse(Request.QueryString["manageQuestions"], out manageID) && manageID > 0)
                {
                    ViewState["ManageChallengeID"] = manageID;
                    pnlGlobalChallenges.Visible = false;
                    pnlNoGlobalChallenges.Visible = false;
                    BindOptionRows();
                    LoadManageQuestions(manageID);
                    return;
                }

                LoadGlobalChallenges();
            }
            else
            {
                BindOptionRows();
            }
        }

        private void BindOptionRows()
        {
            int[] rows = new int[OPTION_COUNT];
            for (int i = 0; i < OPTION_COUNT; i++) rows[i] = i + 1;
            rptGCOptions.DataSource = rows;
            rptGCOptions.DataBind();
        }

        private void LoadManageQuestions(int challengeID)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string title = null;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT Title FROM Challenges WHERE ChallengeID=@CID AND IsGlobalAdminChallenge=1", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        object r = cmd.ExecuteScalar();
                        if (r == null || r == DBNull.Value)
                        {
                            ShowError("Global challenge not found.");
                            pnlManageQuestions.Visible = false;
                            return;
                        }
                        title = r.ToString();
                    }

                    litManageGCTitle.Text = HttpUtility.HtmlEncode(title);
                    pnlManageQuestions.Visible = true;

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT ChallengeQuestionID, QuestionText, Points, TimeLimitSeconds,
                                 (SELECT COUNT(*) FROM ChallengeQuestionOptions o WHERE o.ChallengeQuestionID = cq.ChallengeQuestionID) AS OptionCount
                          FROM ChallengeQuestions cq
                          WHERE ChallengeID=@CID
                          ORDER BY OrderIndex, ChallengeQuestionID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }

                    if (dt.Rows.Count > 0)
                    {
                        rptGCQuestions.DataSource = dt;
                        rptGCQuestions.DataBind();
                        pnlGCQuestionsList.Visible = true;
                        pnlNoGCQuestions.Visible = false;
                    }
                    else
                    {
                        pnlGCQuestionsList.Visible = false;
                        pnlNoGCQuestions.Visible = true;
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
                    }
                }
            }
            catch (SqlException)
            {
<<<<<<< HEAD
                ShowMessage("Could not load challenges. Please try again.", false);
            }
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string title = txtTitle.Text.Trim();
            if (string.IsNullOrEmpty(title))
            {
                ShowMessage("Title is required.", false);
                return;
            }

            if (!int.TryParse(txtXPReward.Text.Trim(), out int xpReward) || xpReward < 1)
            {
                ShowMessage("Enter a valid XP Reward.", false);
                return;
            }

            // Server-side date validation — do not trust client-side only.
            if (!DateTime.TryParse(txtStartDate.Text.Trim(), out DateTime startDate))
            {
                ShowMessage("Enter a valid start date.", false);
                return;
            }
            if (!DateTime.TryParse(txtEndDate.Text.Trim(), out DateTime endDate))
            {
                ShowMessage("Enter a valid end date.", false);
=======
                ShowError("Could not load challenge questions.");
            }
        }

        protected void btnAddGCQuestion_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { return; }

            int challengeID = (int)ViewState["ManageChallengeID"];
            string questionText = txtGCQText.Text.Trim();
            int points = 10; int.TryParse(txtGCQPoints.Text.Trim(), out points);
            int timeLimit = 30; int.TryParse(txtGCQTime.Text.Trim(), out timeLimit);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (SqlCommand chk = new SqlCommand(
                        "SELECT COUNT(*) FROM Challenges WHERE ChallengeID=@CID AND IsGlobalAdminChallenge=1", conn))
                    {
                        chk.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        if (Convert.ToInt32(chk.ExecuteScalar()) == 0)
                        {
                            ShowError("Global challenge not found.");
                            return;
                        }
                    }

                    List<string> optionTexts = new List<string>();
                    int correctIndex = -1;
                    foreach (RepeaterItem item in rptGCOptions.Items)
                    {
                        TextBox txtOpt = (TextBox)item.FindControl("txtGCOption");
                        RadioButton rbCorrect = (RadioButton)item.FindControl("rbGCCorrect");
                        if (txtOpt != null && !string.IsNullOrWhiteSpace(txtOpt.Text))
                        {
                            optionTexts.Add(txtOpt.Text.Trim());
                            if (rbCorrect != null && rbCorrect.Checked) correctIndex = optionTexts.Count - 1;
                        }
                    }

                    if (optionTexts.Count < 2)
                    {
                        ShowError("Provide at least 2 answer options.");
                        return;
                    }
                    if (correctIndex == -1)
                    {
                        ShowError("Select which option is correct.");
                        return;
                    }

                    int nextOrder;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT ISNULL(MAX(OrderIndex), 0) + 1 FROM ChallengeQuestions WHERE ChallengeID=@CID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        nextOrder = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    int questionID;
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO ChallengeQuestions (ChallengeID, QuestionText, Points, TimeLimitSeconds, OrderIndex)
                          OUTPUT INSERTED.ChallengeQuestionID
                          VALUES (@CID, @Text, @Points, @Time, @Order)", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        cmd.Parameters.Add("@Text", SqlDbType.NVarChar, 500).Value = questionText;
                        cmd.Parameters.Add("@Points", SqlDbType.Int).Value = points > 0 ? points : 10;
                        cmd.Parameters.Add("@Time", SqlDbType.Int).Value = timeLimit > 0 ? timeLimit : 30;
                        cmd.Parameters.Add("@Order", SqlDbType.Int).Value = nextOrder;
                        questionID = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    for (int oi = 0; oi < optionTexts.Count; oi++)
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            @"INSERT INTO ChallengeQuestionOptions (ChallengeQuestionID, OptionText, IsCorrect)
                              VALUES (@QID, @Opt, @Correct)", conn))
                        {
                            cmd.Parameters.Add("@QID", SqlDbType.Int).Value = questionID;
                            cmd.Parameters.Add("@Opt", SqlDbType.NVarChar, 300).Value = optionTexts[oi];
                            cmd.Parameters.Add("@Correct", SqlDbType.Bit).Value = (oi == correctIndex) ? 1 : 0;
                            cmd.ExecuteNonQuery();
                        }
                    }
                }

                txtGCQText.Text = string.Empty;
                txtGCQPoints.Text = "10";
                txtGCQTime.Text = "30";
                BindOptionRows();

                ShowSuccess("Question added to challenge.");
                LoadManageQuestions(challengeID);
            }
            catch (SqlException)
            {
                ShowError("Could not add the question. Please try again.");
            }
        }

        protected void rptGCQuestions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "DeleteQuestion") return;

            int questionID = Convert.ToInt32(e.CommandArgument);
            int challengeID = (int)ViewState["ManageChallengeID"];

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand(
                        "DELETE FROM ChallengeQuestionOptions WHERE ChallengeQuestionID=@QID", conn))
                    {
                        cmd.Parameters.Add("@QID", SqlDbType.Int).Value = questionID;
                        cmd.ExecuteNonQuery();
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        "DELETE FROM ChallengeQuestions WHERE ChallengeQuestionID=@QID", conn))
                    {
                        cmd.Parameters.Add("@QID", SqlDbType.Int).Value = questionID;
                        cmd.ExecuteNonQuery();
                    }
                }

                ShowSuccess("Question removed.");
                LoadManageQuestions(challengeID);
            }
            catch (SqlException)
            {
                ShowError("Could not remove the question.");
            }
        }

        private void LoadGlobalChallenges()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT c.ChallengeID, c.Title, c.XPReward, c.StartDate, c.EndDate,
                          (SELECT COUNT(*) FROM ChallengeParticipation cp WHERE cp.ChallengeID=c.ChallengeID) AS ParticipantCount
                          FROM Challenges c
                          WHERE c.IsGlobalAdminChallenge = 1
                          ORDER BY c.StartDate DESC", conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptGlobalChallenges.DataSource = dt;
                        rptGlobalChallenges.DataBind();
                        pnlGlobalChallenges.Visible = true;
                    }
                    else { pnlNoGlobalChallenges.Visible = true; }
                }
            }
            catch (SqlException) { }
        }

        protected void btnCreateGlobalChallenge_Click(object sender, EventArgs e)
        {
            string title = txtGCTitle.Text.Trim();
            string desc = txtGCDesc.Text.Trim();
            int xp; int.TryParse(txtGCXP.Text.Trim(), out xp);
            if (xp <= 0) xp = 100;

            DateTime startDate, endDate;
            if (string.IsNullOrEmpty(title))
            {
                ShowError("Title is required.");
                return;
            }
            if (!DateTime.TryParse(txtGCStart.Text.Trim(), out startDate) ||
                !DateTime.TryParse(txtGCEnd.Text.Trim(), out endDate))
            {
                ShowError("Valid start and end dates are required.");
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
                return;
            }
            if (endDate <= startDate)
            {
<<<<<<< HEAD
                ShowMessage("End date must be after the start date.", false);
                return;
            }

            string description = txtDescription.Text.Trim();
            int    adminID     = Convert.ToInt32(Session["UserID"]);
            string cs          = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    using (SqlTransaction tx = conn.BeginTransaction())
                    {
                        try
                        {
                            // IsGlobalAdminChallenge = 1 for admin-created challenges.
                            // CreatedByInstructorID = NULL (admin challenge).
                            string insertSQL = @"
                                INSERT INTO Challenges
                                    (Title, Description, CreatedByInstructorID, CreatedByAdminID,
                                     XPReward, StartDate, EndDate, IsGlobalAdminChallenge)
                                OUTPUT INSERTED.ChallengeID
                                VALUES
                                    (@Title, @Description, NULL, @AdminID,
                                     @XPReward, @StartDate, @EndDate, 1)";

                            int newChallengeID;
                            using (SqlCommand insertCmd = new SqlCommand(insertSQL, conn, tx))
                            {
                                insertCmd.Parameters.Add("@Title",       SqlDbType.NVarChar, 150).Value = title;
                                insertCmd.Parameters.Add("@Description", SqlDbType.NVarChar, -1).Value  =
                                    string.IsNullOrEmpty(description) ? (object)DBNull.Value : description;
                                insertCmd.Parameters.Add("@AdminID",     SqlDbType.Int).Value           = adminID;
                                insertCmd.Parameters.Add("@XPReward",    SqlDbType.Int).Value           = xpReward;
                                insertCmd.Parameters.Add("@StartDate",   SqlDbType.DateTime2).Value     = startDate;
                                insertCmd.Parameters.Add("@EndDate",     SqlDbType.DateTime2).Value     = endDate;
                                newChallengeID = Convert.ToInt32(insertCmd.ExecuteScalar());
                            }

                            string auditSQL = @"
                                INSERT INTO AuditLogs
                                    (PerformedByUserID, ActionType, TargetTable, TargetID, Details, CreatedAt)
                                VALUES
                                    (@AdminID, 'CREATE_CHALLENGE', 'Challenges', @ChallengeID, @Details, GETDATE())";
                            using (SqlCommand auditCmd = new SqlCommand(auditSQL, conn, tx))
                            {
                                auditCmd.Parameters.Add("@AdminID",     SqlDbType.Int).Value          = adminID;
                                auditCmd.Parameters.Add("@ChallengeID", SqlDbType.Int).Value          = newChallengeID;
                                auditCmd.Parameters.Add("@Details",     SqlDbType.NVarChar, -1).Value =
                                    $"Admin UserID {adminID} created Challenge '{title}' (ID: {newChallengeID}).";
                                auditCmd.ExecuteNonQuery();
                            }

                            tx.Commit();

                            // Clear form.
                            txtTitle.Text       = "";
                            txtDescription.Text = "";
                            txtXPReward.Text    = "";
                            txtStartDate.Text   = "";
                            txtEndDate.Text     = "";

                            ShowMessage($"Challenge '{HttpUtility.HtmlEncode(title)}' created successfully.", true);
                        }
                        catch
                        {
                            tx.Rollback();
                            throw;
                        }
                    }
                }
            }
            catch (SqlException)
            {
                ShowMessage("Could not create the challenge. Please try again.", false);
            }

            LoadChallenges();
        }

        // Returns an HTML badge reflecting whether the challenge is active, upcoming, or ended.
        protected string GetChallengeStateBadge(DateTime start, DateTime end)
        {
            DateTime now = DateTime.Now;
            if (now < start)  return "<span class='cp-badge cp-badge-blue'>Upcoming</span>";
            if (now > end)    return "<span class='cp-badge cp-badge-grey'>Ended</span>";
            return "<span class='cp-badge cp-badge-green'>Active</span>";
        }

        private void ShowMessage(string message, bool success)
        {
            string cssClass    = success ? "cp-alert cp-alert-success" : "cp-alert cp-alert-danger";
            litMessage.Text    = $"<div class='{cssClass}'>{HttpUtility.HtmlEncode(message)}</div>";
            pnlMessage.Visible = true;
=======
                ShowError("End date must be after start date.");
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO Challenges (Title, Description, CreatedByAdminID, XPReward, StartDate, EndDate, IsGlobalAdminChallenge)
                          VALUES (@Title, @Desc, @AID, @XP, @Start, @End, 1)", conn))
                    {
                        cmd.Parameters.Add("@Title", SqlDbType.NVarChar, 150).Value = title;
                        cmd.Parameters.Add("@Desc", SqlDbType.NVarChar, -1).Value = string.IsNullOrEmpty(desc) ? (object)DBNull.Value : desc;
                        cmd.Parameters.Add("@AID", SqlDbType.Int).Value = AdminID;
                        cmd.Parameters.Add("@XP", SqlDbType.Int).Value = xp;
                        cmd.Parameters.Add("@Start", SqlDbType.DateTime2).Value = startDate;
                        cmd.Parameters.Add("@End", SqlDbType.DateTime2).Value = endDate;
                        cmd.ExecuteNonQuery();
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO AuditLogs (PerformedByUserID, ActionType, TargetTable, Details, CreatedAt)
                          VALUES (@UID, 'CREATE_GLOBAL_CHALLENGE', 'Challenges', @Details, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = AdminID;
                        cmd.Parameters.Add("@Details", SqlDbType.NVarChar, -1).Value = title;
                        cmd.ExecuteNonQuery();
                    }
                }

                txtGCTitle.Text = ""; txtGCDesc.Text = ""; txtGCXP.Text = "100";
                txtGCStart.Text = ""; txtGCEnd.Text = "";
                ShowSuccess("Global challenge created.");
                LoadGlobalChallenges();
            }
            catch (SqlException)
            {
                ShowError("Could not create challenge.");
            }
        }

        protected void rptGlobalChallenges_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Delete") return;
            int challengeID = Convert.ToInt32(e.CommandArgument);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "DELETE FROM Challenges WHERE ChallengeID=@CID AND IsGlobalAdminChallenge=1", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        cmd.ExecuteNonQuery();
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO AuditLogs (PerformedByUserID, ActionType, TargetTable, TargetID, CreatedAt)
                          VALUES (@UID, 'DELETE_GLOBAL_CHALLENGE', 'Challenges', @CID, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = AdminID;
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowSuccess("Challenge deleted.");
                LoadGlobalChallenges();
            }
            catch (SqlException)
            {
                ShowError("Could not delete challenge.");
            }
        }

        private void ShowSuccess(string msg)
        {
            litSuccess.Text = HttpUtility.HtmlEncode(msg);
            pnlSuccess.Visible = true;
            pnlError.Visible = false;
        }

        private void ShowError(string msg)
        {
            litError.Text = HttpUtility.HtmlEncode(msg);
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
        }
    }
}
