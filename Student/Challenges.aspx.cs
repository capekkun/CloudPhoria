using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class Challenges : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            bool isGuest = (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student");

            if (!IsPostBack) { LoadChallenges(); }
        }

        private void LoadChallenges()
        {
            int studentID = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0;
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Active challenges (StartDate <= now <= EndDate).
                    string activeSql = @"
                        SELECT c.ChallengeID, c.Title, c.Description,
                               c.XPReward, c.EndDate,
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
                        SELECT c.Title, cp.Score, cp.CompletedAt
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
    }
}
