using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class Achievements : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Achievements";

            if (!IsPostBack) { LoadAchievements(); }
        }

        private void LoadAchievements()
        {
            int studentID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // TotalXP.
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT TotalXP FROM Students WHERE StudentID = @SID", conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        object r = cmd.ExecuteScalar();
                        litTotalXP.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
                    }

                    // Badges.
                    string badgeSql = @"
                        SELECT b.BadgeName, ub.AwardedAt
                        FROM UserBadges ub
                        INNER JOIN Badges b ON b.BadgeID = ub.BadgeID
                        WHERE ub.StudentID = @SID
                        ORDER BY ub.AwardedAt DESC";

                    DataTable dtBadges = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(badgeSql, conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtBadges);
                    }

                    litBadgeCount.Text = dtBadges.Rows.Count.ToString();
                    if (dtBadges.Rows.Count > 0)
                    {
                        rptBadges.DataSource = dtBadges;
                        rptBadges.DataBind();
                        pnlBadges.Visible = true;
                    }
                    else { pnlNoBadges.Visible = true; }

                    // Certifications.
                    string certSql = @"
                        SELECT c.CertificateName, uc.IssuedAt
                        FROM UserCertifications uc
                        INNER JOIN Certifications c ON c.CertificationID = uc.CertificationID
                        WHERE uc.StudentID = @SID
                        ORDER BY uc.IssuedAt DESC";

                    DataTable dtCerts = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(certSql, conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtCerts);
                    }

                    litCertCount.Text = dtCerts.Rows.Count.ToString();
                    if (dtCerts.Rows.Count > 0)
                    {
                        rptCerts.DataSource = dtCerts;
                        rptCerts.DataBind();
                        pnlCerts.Visible = true;
                    }
                    else { pnlNoCerts.Visible = true; }

                    // XP History (last 20).
                    string xpSql = @"
                        SELECT TOP 20 SourceType, XPAmount, CreatedAt
                        FROM XPTransactions
                        WHERE StudentID = @SID
                        ORDER BY CreatedAt DESC";

                    DataTable dtXP = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(xpSql, conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtXP);
                    }

                    if (dtXP.Rows.Count > 0)
                    {
                        rptXP.DataSource = dtXP;
                        rptXP.DataBind();
                        pnlXPHistory.Visible = true;
                    }
                    else { pnlNoXP.Visible = true; }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load achievements. Please try again.";
                pnlError.Visible = true;
            }
        }
    }
}
