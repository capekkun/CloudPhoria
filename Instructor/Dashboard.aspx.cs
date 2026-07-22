using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Instructor
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Instructor")
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
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            string fullName = Session["FullName"] != null ? Session["FullName"].ToString() : "Instructor";
            litWelcomeName.Text = HttpUtility.HtmlEncode(fullName.Split(' ')[0]);

            // Determine licence status from session (set by Master Page).
            string licenseStatus = Session["LicenseStatus"] != null
                                   ? Session["LicenseStatus"].ToString()
                                   : "Pending";

            if (licenseStatus == "Pending")
            {
                pnlPendingNotice.Visible = true;
                return;
            }
            if (licenseStatus == "Rejected")
            {
                pnlRejectedNotice.Visible = true;
                return;
            }

            // Approved — show full dashboard.
            pnlStats.Visible = true;
            pnlHeaderActions.Visible = true;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    LoadStatCards(conn, instructorID);
                    LoadClassroomSummary(conn, instructorID);
                    LoadRecentSubmissions(conn, instructorID);
                    LoadRecentNotifications(conn, instructorID);
                }
            }
            catch (SqlException)
            {
                // Non-critical — defaults already set.
            }
        }

        private void LoadStatCards(SqlConnection conn, int instructorID)
        {
            // Classroom count.
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*) FROM Classrooms WHERE InstructorID = @ID", conn))
            {
                cmd.Parameters.Add("@ID", SqlDbType.Int).Value = instructorID;
                object r = cmd.ExecuteScalar();
                litClassroomCount.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }

            // Module count.
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*) FROM Modules WHERE CreatedByInstructorID = @ID", conn))
            {
                cmd.Parameters.Add("@ID", SqlDbType.Int).Value = instructorID;
                object r = cmd.ExecuteScalar();
                litModuleCount.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }

            // Total distinct students across all classrooms.
            using (SqlCommand cmd = new SqlCommand(
                @"SELECT COUNT(DISTINCT ce.StudentID)
                  FROM ClassroomEnrollments ce
                  INNER JOIN Classrooms c ON c.ClassroomID = ce.ClassroomID
                  WHERE c.InstructorID = @ID", conn))
            {
                cmd.Parameters.Add("@ID", SqlDbType.Int).Value = instructorID;
                object r = cmd.ExecuteScalar();
                litStudentCount.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }

            // Pending submissions (submissions without feedback).
            using (SqlCommand cmd = new SqlCommand(
                @"SELECT COUNT(*)
                  FROM AssignmentSubmissions asub
                  INNER JOIN ClassroomAssignments ca ON ca.AssignmentID = asub.AssignmentID
                  INNER JOIN Classrooms c ON c.ClassroomID = ca.ClassroomID
                  LEFT JOIN Feedback fb ON fb.SubmissionID = asub.SubmissionID
                  WHERE c.InstructorID = @ID AND fb.FeedbackID IS NULL", conn))
            {
                cmd.Parameters.Add("@ID", SqlDbType.Int).Value = instructorID;
                object r = cmd.ExecuteScalar();
                litPendingAssignments.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
            }
        }

        private void LoadClassroomSummary(SqlConnection conn, int instructorID)
        {
            string sql = @"
                SELECT TOP 5
                    c.ClassroomID,
                    c.ClassroomName,
                    c.InviteCode,
                    c.CreatedAt,
                    COUNT(ce.StudentID) AS StudentCount
                FROM Classrooms c
                LEFT JOIN ClassroomEnrollments ce ON ce.ClassroomID = c.ClassroomID
                WHERE c.InstructorID = @ID
                GROUP BY c.ClassroomID, c.ClassroomName, c.InviteCode, c.CreatedAt
                ORDER BY c.CreatedAt DESC";

            DataTable dt = new DataTable();
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@ID", SqlDbType.Int).Value = instructorID;
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            }

            if (dt.Rows.Count > 0)
            {
                rptClassrooms.DataSource = dt;
                rptClassrooms.DataBind();
                pnlClassroomList.Visible = true;
            }
            else
            {
                pnlNoClassrooms.Visible = true;
            }
        }

        private void LoadRecentSubmissions(SqlConnection conn, int instructorID)
        {
            string sql = @"
                SELECT TOP 5
                    u.FullName AS StudentName,
                    ca.Title   AS AssignmentTitle,
                    asub.SubmittedAt
                FROM AssignmentSubmissions asub
                INNER JOIN ClassroomAssignments ca ON ca.AssignmentID = asub.AssignmentID
                INNER JOIN Classrooms c ON c.ClassroomID = ca.ClassroomID
                INNER JOIN Students s ON s.StudentID = asub.StudentID
                INNER JOIN Users u ON u.UserID = s.StudentID
                LEFT JOIN Feedback fb ON fb.SubmissionID = asub.SubmissionID
                WHERE c.InstructorID = @ID AND fb.FeedbackID IS NULL
                ORDER BY asub.SubmittedAt DESC";

            DataTable dt = new DataTable();
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@ID", SqlDbType.Int).Value = instructorID;
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            }

            if (dt.Rows.Count > 0)
            {
                rptSubmissions.DataSource = dt;
                rptSubmissions.DataBind();
                pnlSubmissions.Visible = true;
            }
            else
            {
                pnlNoSubmissions.Visible = true;
            }
        }

        private void LoadRecentNotifications(SqlConnection conn, int instructorID)
        {
            string sql = @"
                SELECT TOP 5 Message, IsRead, CreatedAt
                FROM Notifications
                WHERE UserID = @UserID
                ORDER BY CreatedAt DESC";

            DataTable dt = new DataTable();
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = instructorID;
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            }

            if (dt.Rows.Count > 0)
            {
                rptNotifications.DataSource = dt;
                rptNotifications.DataBind();
                pnlRecentNotif.Visible = true;
            }
        }
    }
}
