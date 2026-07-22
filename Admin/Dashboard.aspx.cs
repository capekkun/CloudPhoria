using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Admin
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Only Admins may access this page.
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                LoadDashboard();
            }
        }

        private void LoadDashboard()
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    LoadPlatformStats(conn);
                    LoadPendingInstructors(conn);
                    LoadRecentReports(conn);
                    LoadPendingFunRooms(conn);
                    LoadRecentAuditLog(conn);
                    BuildPendingAlert();
                }
            }
            catch (SqlException)
            {
                // Non-critical — show safe defaults already set in markup.
            }
        }

        private void LoadPlatformStats(SqlConnection conn)
        {
            // Total users.
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*) FROM Users", conn))
            {
                object r = cmd.ExecuteScalar();
                litTotalUsers.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }

            // Pending instructor approvals.
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*) FROM Instructors WHERE LicenseStatus = 'Pending'", conn))
            {
                object r = cmd.ExecuteScalar();
                litPendingApprovals.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }

            // Open reports.
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*) FROM Reports WHERE Status = 'Open'", conn))
            {
                object r = cmd.ExecuteScalar();
                litOpenReports.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }

            // Published modules.
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*) FROM Modules WHERE IsPublished = 1", conn))
            {
                object r = cmd.ExecuteScalar();
                litPublishedModules.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }

            // Pending fun rooms.
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*) FROM FunRooms WHERE Status = 'Pending'", conn))
            {
                object r = cmd.ExecuteScalar();
                litPendingFunRooms.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }

            // Active challenges (StartDate <= now <= EndDate).
            using (SqlCommand cmd = new SqlCommand(
                @"SELECT COUNT(*) FROM Challenges
                  WHERE StartDate <= GETDATE() AND EndDate >= GETDATE()", conn))
            {
                object r = cmd.ExecuteScalar();
                litActiveChallenges.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }

            // Published boss fight rooms.
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*) FROM BossFightRooms WHERE IsPublished = 1", conn))
            {
                object r = cmd.ExecuteScalar();
                litBossFightRooms.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }

            // Registered students.
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*) FROM Students", conn))
            {
                object r = cmd.ExecuteScalar();
                litTotalStudents.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }
        }

        private void LoadPendingInstructors(SqlConnection conn)
        {
            string sql = @"
                SELECT TOP 5
                    u.FullName,
                    u.Email,
                    i.Qualification
                FROM Instructors i
                INNER JOIN Users u ON u.UserID = i.InstructorID
                WHERE i.LicenseStatus = 'Pending'
                ORDER BY i.InstructorID DESC";

            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    rptPendingInstructors.DataSource = dt;
                    rptPendingInstructors.DataBind();
                    pnlPendingInstructors.Visible = true;
                }
                else
                {
                    pnlNoPendingInstructors.Visible = true;
                }
            }
        }

        private void LoadRecentReports(SqlConnection conn)
        {
            string sql = @"
                SELECT TOP 5
                    r.ReportID,
                    u.FullName AS ReporterName,
                    r.Reason,
                    r.CreatedAt
                FROM Reports r
                INNER JOIN Users u ON u.UserID = r.ReportedByUserID
                WHERE r.Status = 'Open'
                ORDER BY r.CreatedAt DESC";

            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    rptRecentReports.DataSource = dt;
                    rptRecentReports.DataBind();
                    pnlRecentReports.Visible = true;
                }
                else
                {
                    pnlNoReports.Visible = true;
                }
            }
        }

        private void LoadPendingFunRooms(SqlConnection conn)
        {
            string sql = @"
                SELECT TOP 5
                    f.FunRoomID,
                    f.RoomTitle,
                    u.FullName AS CreatorName,
                    f.CreatedAt
                FROM FunRooms f
                INNER JOIN Users u ON u.UserID = f.CreatedByUserID
                WHERE f.Status = 'Pending'
                ORDER BY f.CreatedAt DESC";

            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    rptPendingFunRooms.DataSource = dt;
                    rptPendingFunRooms.DataBind();
                    pnlFunRoomsSection.Visible = true;
                }
            }
        }

        private void LoadRecentAuditLog(SqlConnection conn)
        {
            string sql = @"
                SELECT TOP 8
                    a.ActionType,
                    u.FullName AS PerformedBy,
                    a.CreatedAt
                FROM AuditLogs a
                INNER JOIN Users u ON u.UserID = a.PerformedByUserID
                ORDER BY a.CreatedAt DESC";

            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    rptAuditLog.DataSource = dt;
                    rptAuditLog.DataBind();
                    pnlAuditLog.Visible = true;
                }
                else
                {
                    pnlNoAudit.Visible = true;
                }
            }
        }

        private void BuildPendingAlert()
        {
            int approvals = int.TryParse(litPendingApprovals.Text, out int a) ? a : 0;
            int reports   = int.TryParse(litOpenReports.Text, out int rp) ? rp : 0;
            int funRooms  = int.TryParse(litPendingFunRooms.Text, out int fr) ? fr : 0;

            if (approvals > 0 || reports > 0 || funRooms > 0)
            {
                string msg = "";
                if (approvals > 0)
                    msg += $" {approvals} instructor approval(s) pending.";
                if (reports > 0)
                    msg += $" {reports} open report(s) require review.";
                if (funRooms > 0)
                    msg += $" {funRooms} fun room(s) awaiting review.";

                litPendingAlertText.Text = HttpUtility.HtmlEncode(msg);
                pnlPendingAlert.Visible = true;
            }
        }
    }
}
