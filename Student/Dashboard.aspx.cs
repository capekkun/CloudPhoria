using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Dashboard";

            if (!IsPostBack)
            {
                LoadDashboard();
            }
        }

        private void LoadDashboard()
        {
            int studentID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    string fullName = Session["FullName"] != null
                                      ? Session["FullName"].ToString() : "Student";
                    string firstName = fullName.Split(' ')[0];
                    litWelcomeName.Text = HttpUtility.HtmlEncode(firstName);

                    LoadStatCards(conn, studentID);
                    LoadInProgressModules(conn, studentID);
                    LoadRecentXP(conn, studentID);
                    LoadRecentNotifications(conn, studentID);
                }
            }
            catch (SqlException)
            {
                // Markup already has sensible defaults, so just keep the welcome name working.
                string fn = Session["FullName"] != null ? Session["FullName"].ToString() : "Student";
                litWelcomeName.Text = HttpUtility.HtmlEncode(fn.Split(' ')[0]);
            }
        }

        private void LoadStatCards(SqlConnection conn, int studentID)
        {
            using (SqlCommand cmd = new SqlCommand(
                "SELECT TotalXP FROM Students WHERE StudentID = @StudentID", conn))
            {
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                object r = cmd.ExecuteScalar();
                litTotalXP.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }

            using (SqlCommand cmd = new SqlCommand(
                @"SELECT COUNT(*) FROM ModuleProgress
                  WHERE StudentID = @StudentID AND Status = 'Completed'", conn))
            {
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                object r = cmd.ExecuteScalar();
                litModulesCompleted.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }

            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*) FROM UserBadges WHERE StudentID = @StudentID", conn))
            {
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                object r = cmd.ExecuteScalar();
                litBadgesEarned.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }

            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*) FROM ClassroomEnrollments WHERE StudentID = @StudentID", conn))
            {
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                object r = cmd.ExecuteScalar();
                litClassroomsJoined.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }
        }

        private void LoadInProgressModules(SqlConnection conn, int studentID)
        {
            // Progress counts the module's exam as one extra "step" alongside its
            // ProgressPct here is the PATHWAY's overall completion (completed
            // modules / total modules), same definition PathwayDetail.aspx uses —
            // not this single module's own subtopic/exam progress. Keeping both
            // pages on the same definition avoids showing two different numbers
            // for what looks like the same "progress" at a glance.
            string sql = @"
                SELECT TOP 5
                    m.ModuleID,
                    m.ModuleName,
                    p.PathwayName,
                    CASE WHEN pathwayTotal.TotalModules = 0 THEN 0
                         ELSE pathwayDone.DoneModules * 100 / pathwayTotal.TotalModules
                    END AS ProgressPct
                FROM ModuleProgress mp
                INNER JOIN Modules m ON m.ModuleID = mp.ModuleID
                INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
                CROSS APPLY (
                    SELECT COUNT(*) AS TotalModules
                    FROM Modules m2 WHERE m2.PathwayID = m.PathwayID AND m2.IsPublished = 1
                ) pathwayTotal
                CROSS APPLY (
                    SELECT COUNT(*) AS DoneModules
                    FROM ModuleProgress mp2
                    INNER JOIN Modules m3 ON m3.ModuleID = mp2.ModuleID
                    WHERE mp2.StudentID = @StudentID
                      AND m3.PathwayID  = m.PathwayID
                      AND mp2.Status    = 'Completed'
                ) pathwayDone
                WHERE mp.StudentID = @StudentID
                  AND mp.Status    = 'InProgress'
                ORDER BY mp.ProgressID DESC";

            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    rptInProgress.DataSource = dt;
                    rptInProgress.DataBind();
                    pnlContinueLearning.Visible = true;
                }
                else
                {
                    pnlNoContinue.Visible = true;
                }
            }
        }

        private void LoadRecentXP(SqlConnection conn, int studentID)
        {
            string sql = @"
                SELECT TOP 5 SourceType, XPAmount, CreatedAt
                FROM XPTransactions
                WHERE StudentID = @StudentID
                ORDER BY CreatedAt DESC";

            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    rptRecentXP.DataSource = dt;
                    rptRecentXP.DataBind();
                    pnlRecentXP.Visible = true;
                }
                else
                {
                    pnlNoXP.Visible = true;
                }
            }
        }

        private void LoadRecentNotifications(SqlConnection conn, int studentID)
        {
            string sql = @"
                SELECT TOP 5 Message, IsRead, CreatedAt
                FROM Notifications
                WHERE UserID = @UserID
                ORDER BY CreatedAt DESC";

            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = studentID;
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    rptNotifications.DataSource = dt;
                    rptNotifications.DataBind();
                    pnlRecentNotif.Visible = true;
                }
            }
        }
    }
}
