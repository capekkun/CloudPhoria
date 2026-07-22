using System;
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
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

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
                    }
                }
            }
            catch (SqlException)
            {
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
                return;
            }
            if (endDate <= startDate)
            {
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
        }
    }
}
