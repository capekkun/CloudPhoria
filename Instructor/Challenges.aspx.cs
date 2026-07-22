using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Instructor
{
    public partial class Challenges : System.Web.UI.Page
    {
        // Repeater item count for MCQ options when adding a challenge question.
        private const int OPTION_COUNT = 4;

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

            ((SiteMaster)Master).PageHeading = "Challenges";

            if (!IsPostBack)
            {
                int manageID;
                if (int.TryParse(Request.QueryString["manageQuestions"], out manageID) && manageID > 0)
                {
                    ViewState["ManageChallengeID"] = manageID;
                    pnlChallenges.Visible = false;
                    pnlEmpty.Visible = false;
                    BindOptionRows();
                    LoadManageQuestions(manageID);
                    return;
                }

                LoadChallenges();
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
            rptChOptions.DataSource = rows;
            rptChOptions.DataBind();
        }

        private void LoadManageQuestions(int challengeID)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    string title = null;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT Title FROM Challenges WHERE ChallengeID=@CID AND CreatedByInstructorID=@IID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        object r = cmd.ExecuteScalar();
                        if (r == null || r == DBNull.Value)
                        {
                            ShowError("You do not own this challenge.");
                            pnlManageQuestions.Visible = false;
                            return;
                        }
                        title = r.ToString();
                    }

                    litManageChTitle.Text = HttpUtility.HtmlEncode(title);
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
                        rptChQuestions.DataSource = dt;
                        rptChQuestions.DataBind();
                        pnlChQuestionsList.Visible = true;
                        pnlNoChQuestions.Visible = false;
                    }
                    else
                    {
                        pnlChQuestionsList.Visible = false;
                        pnlNoChQuestions.Visible = true;
                    }
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load challenge questions.");
            }
        }

        protected void btnAddChQuestion_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { return; }

            int challengeID = (int)ViewState["ManageChallengeID"];
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string questionText = txtChQText.Text.Trim();
            int points = 10; int.TryParse(txtChQPoints.Text.Trim(), out points);
            int timeLimit = 30; int.TryParse(txtChQTime.Text.Trim(), out timeLimit);

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Verify ownership.
                    using (SqlCommand chk = new SqlCommand(
                        "SELECT COUNT(*) FROM Challenges WHERE ChallengeID=@CID AND CreatedByInstructorID=@IID", conn))
                    {
                        chk.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        chk.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        if (Convert.ToInt32(chk.ExecuteScalar()) == 0)
                        {
                            ShowError("You do not own this challenge.");
                            return;
                        }
                    }

                    // Collect options first so we can validate before inserting anything.
                    List<string> optionTexts = new List<string>();
                    int correctIndex = -1;
                    int i = 0;
                    foreach (RepeaterItem item in rptChOptions.Items)
                    {
                        TextBox txtOpt = (TextBox)item.FindControl("txtChOption");
                        RadioButton rbCorrect = (RadioButton)item.FindControl("rbChCorrect");
                        if (txtOpt != null && !string.IsNullOrWhiteSpace(txtOpt.Text))
                        {
                            optionTexts.Add(txtOpt.Text.Trim());
                            if (rbCorrect != null && rbCorrect.Checked) correctIndex = optionTexts.Count - 1;
                        }
                        i++;
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

                txtChQText.Text = string.Empty;
                txtChQPoints.Text = "10";
                txtChQTime.Text = "30";
                BindOptionRows();

                ShowSuccess("Question added to challenge.");
                LoadManageQuestions(challengeID);
            }
            catch (SqlException)
            {
                ShowError("Could not add the question. Please try again.");
            }
        }

        protected void rptChQuestions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "DeleteQuestion") return;

            int questionID = Convert.ToInt32(e.CommandArgument);
            int challengeID = (int)ViewState["ManageChallengeID"];
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Ownership check via the parent Challenge before deleting.
                    using (SqlCommand chk = new SqlCommand(
                        @"SELECT COUNT(*) FROM ChallengeQuestions cq
                          INNER JOIN Challenges c ON c.ChallengeID = cq.ChallengeID
                          WHERE cq.ChallengeQuestionID=@QID AND c.CreatedByInstructorID=@IID", conn))
                    {
                        chk.Parameters.Add("@QID", SqlDbType.Int).Value = questionID;
                        chk.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        if (Convert.ToInt32(chk.ExecuteScalar()) == 0) return;
                    }

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

        // Returns an HTML badge string for use inside the Repeater.
        protected string GetChallengeStatus(object startObj, object endObj)
        {
            DateTime now   = DateTime.Now;
            DateTime start = Convert.ToDateTime(startObj);
            DateTime end   = Convert.ToDateTime(endObj);

            if (now < start)
                return "<span class='cp-badge cp-badge-grey'>Upcoming</span>";
            if (now >= start && now <= end)
                return "<span class='cp-badge cp-badge-green'>Active</span>";
            return "<span class='cp-badge cp-badge-red'>Ended</span>";
        }

        private void LoadChallenges()
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            string sql = @"
                SELECT c.ChallengeID, c.Title, c.XPReward, c.StartDate, c.EndDate,
                       COUNT(cp2.ParticipationID) AS ParticipantCount
                FROM   Challenges c
                LEFT JOIN ChallengeParticipation cp2 ON cp2.ChallengeID = c.ChallengeID
                WHERE  c.CreatedByInstructorID = @IID
                GROUP  BY c.ChallengeID, c.Title, c.XPReward, c.StartDate, c.EndDate
                ORDER  BY c.StartDate DESC";

            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }
                }

                if (dt.Rows.Count > 0)
                {
                    rptChallenges.DataSource = dt;
                    rptChallenges.DataBind();
                    pnlChallenges.Visible = true;
                    pnlEmpty.Visible      = false;
                }
                else
                {
                    pnlChallenges.Visible = false;
                    pnlEmpty.Visible      = true;
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load challenges. Please try again.");
            }
        }

        protected void btnCreateCh_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { return; }

            int instructorID = Convert.ToInt32(Session["UserID"]);
            string title = txtChTitle.Text.Trim();
            string desc  = txtChDesc.Text.Trim();
            int xp = 50; int.TryParse(txtChXP.Text.Trim(), out xp);

            DateTime startDate, endDate;
            if (!DateTime.TryParse(txtChStart.Text.Trim(), out startDate))
            {
                ShowError("Invalid start date.");
                return;
            }
            if (!DateTime.TryParse(txtChEnd.Text.Trim(), out endDate))
            {
                ShowError("Invalid end date.");
                return;
            }
            if (endDate <= startDate)
            {
                ShowError("End date must be after start date.");
                return;
            }

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO Challenges
                            (Title, Description, CreatedByInstructorID, XPReward,
                             StartDate, EndDate, IsGlobalAdminChallenge)
                          VALUES (@Title, @Desc, @IID, @XP, @Start, @End, 0)", conn))
                    {
                        cmd.Parameters.Add("@Title", SqlDbType.NVarChar, 150).Value = title;
                        cmd.Parameters.Add("@Desc",  SqlDbType.NVarChar, -1).Value  = string.IsNullOrEmpty(desc) ? (object)DBNull.Value : desc;
                        cmd.Parameters.Add("@IID",   SqlDbType.Int).Value           = instructorID;
                        cmd.Parameters.Add("@XP",    SqlDbType.Int).Value           = xp;
                        cmd.Parameters.Add("@Start", SqlDbType.DateTime2).Value     = startDate;
                        cmd.Parameters.Add("@End",   SqlDbType.DateTime2).Value     = endDate;
                        cmd.ExecuteNonQuery();
                    }
                }

                txtChTitle.Text = string.Empty;
                txtChDesc.Text  = string.Empty;
                txtChXP.Text    = "50";
                txtChStart.Text = string.Empty;
                txtChEnd.Text   = string.Empty;

                ShowSuccess("Challenge created successfully.");
                pnlChallenges.Visible = false;
                pnlEmpty.Visible      = false;
                LoadChallenges();
            }
            catch (SqlException)
            {
                ShowError("Could not create challenge. Please try again.");
            }
        }

        protected void rptChallenges_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Delete")
                DeleteChallenge(Convert.ToInt32(e.CommandArgument));
        }

        private void DeleteChallenge(int challengeID)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "DELETE FROM Challenges WHERE ChallengeID=@CID AND CreatedByInstructorID=@IID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = challengeID;
                        cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowSuccess("Challenge deleted.");
                pnlChallenges.Visible = false;
                pnlEmpty.Visible      = false;
                LoadChallenges();
            }
            catch (SqlException)
            {
                ShowError("Could not delete challenge. Please try again.");
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
    }
}
