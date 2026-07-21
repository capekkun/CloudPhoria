using System;
using System.Configuration;
using System.Data;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Admin
{
    public partial class Dashboard : System.Web.UI.Page
    {
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Admin Dashboard";

            if (!IsPostBack) LoadOverview();
        }

        private void LoadOverview()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Students", conn))
                        litTotalStudents.Text = cmd.ExecuteScalar().ToString();

                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Instructors", conn))
                        litTotalInstructors.Text = cmd.ExecuteScalar().ToString();

                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Instructors WHERE LicenseStatus='Pending'", conn))
                    {
                        string count = cmd.ExecuteScalar().ToString();
                        litPendingCount.Text = count;
                        litPendingCount2.Text = count;
                    }

                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Modules WHERE IsPublished=1", conn))
                        litTotalModules.Text = cmd.ExecuteScalar().ToString();

                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Reports WHERE Status='Open'", conn))
                    {
                        string count = cmd.ExecuteScalar().ToString();
                        litOpenReports.Text = count;
                        litOpenReports2.Text = count;
                    }

                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Users WHERE IsBanned=1", conn))
                        litBannedCount.Text = cmd.ExecuteScalar().ToString();

                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Challenges WHERE IsGlobalAdminChallenge=1", conn))
                        litGlobalChallengeCount.Text = cmd.ExecuteScalar().ToString();

                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Classrooms", conn))
                        litTotalClassrooms.Text = cmd.ExecuteScalar().ToString();

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT TOP 8 al.ActionType, al.CreatedAt, u.FullName AS PerformedByName
                          FROM AuditLogs al
                          INNER JOIN Users u ON u.UserID = al.PerformedByUserID
                          ORDER BY al.CreatedAt DESC", conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptRecentActivity.DataSource = dt;
                        rptRecentActivity.DataBind();
                        pnlRecentActivity.Visible = true;
                    }
                    else { pnlNoActivity.Visible = true; }
                }
            }
            catch (SqlException) { }
        }
    }
}
