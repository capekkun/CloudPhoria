using System;
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
                LoadChallenges();
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
