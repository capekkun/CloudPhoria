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
            // Verify the current user is a Student.
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            // Set topbar title via Master Page property.
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

                    // Welcome name from session (already loaded by Master Page).
                    string fullName = Session["FullName"] != null
                                      ? Session["FullName"].ToString() : "Student";
                    string firstName = fullName.Split(' ')[0];
                    litWelcomeName.Text = HttpUtility.HtmlEncode(firstName);

                    // TotalXP, badges, classrooms.
                    LoadStatCards(conn, studentID);

                    // In-progress modules.
                    LoadInProgressModules(conn, studentID);

                    // Recent XP transactions (last 5).
                    LoadRecentXP(conn, studentID);

                    // Recent notifications (last 5).
                    LoadRecentNotifications(conn, studentID);
                }
            }
            catch (SqlException)
            {
                // Non-critical failure — show defaults already set in markup.
                string fn = Session["FullName"] != null ? Session["FullName"].ToString() : "Student";
                litWelcomeName.Text = HttpUtility.HtmlEncode(fn.Split(' ')[0]);
            }
        }

        private void LoadStatCards(SqlConnection conn, int studentID)
        {
            // TotalXP from Students table.
            using (SqlCommand cmd = new SqlCommand(
                "SELECT TotalXP FROM Students WHERE StudentID = @StudentID", conn))
            {
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                object r = cmd.ExecuteScalar();
                litTotalXP.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }

            // Modules completed.
            using (SqlCommand cmd = new SqlCommand(
                @"SELECT COUNT(*) FROM ModuleProgress
                  WHERE StudentID = @StudentID AND Status = 'Completed'", conn))
            {
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                object r = cmd.ExecuteScalar();
                litModulesCompleted.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }

            // Badges earned.
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*) FROM UserBadges WHERE StudentID = @StudentID", conn))
            {
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                object r = cmd.ExecuteScalar();
                litBadgesEarned.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }

            // Classrooms joined.
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
            string sql = @"
                SELECT TOP 5
                    m.ModuleID,
                    m.ModuleName,
                    p.PathwayName,
                    -- Calculate percentage of completed subtopics out of total subtopics.
                    CASE WHEN total.TotalSubs = 0 THEN 0
                         ELSE CAST(done.DoneSubs AS INT) * 100 / total.TotalSubs
                    END AS ProgressPct
                FROM ModuleProgress mp
                INNER JOIN Modules m ON m.ModuleID = mp.ModuleID
                INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
                CROSS APPLY (
                    SELECT COUNT(*) AS TotalSubs
                    FROM SubTopics st WHERE st.ModuleID = m.ModuleID AND st.IsPublished = 1
                ) total
                CROSS APPLY (
                    SELECT COUNT(*) AS DoneSubs
                    FROM SubTopicProgress stp
                    INNER JOIN SubTopics st2 ON st2.SubTopicID = stp.SubTopicID
                    WHERE stp.StudentID = @StudentID
                      AND st2.ModuleID  = m.ModuleID
                      AND stp.Status    = 'Completed'
                ) done
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
