using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class MyLearning : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "My Learning";

            if (!IsPostBack)
            {
                LoadMyLearning();
            }
        }

        private void LoadMyLearning()
        {
            int studentID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    LoadProgressList(conn, studentID, "InProgress",
                                     rptInProgress, pnlInProgress, pnlNoInProgress);
                    LoadCompletedList(conn, studentID);
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load your learning data. Please try again.";
                pnlError.Visible = true;
            }
        }

        private void LoadProgressList(SqlConnection conn, int studentID, string status,
            System.Web.UI.WebControls.Repeater rpt,
            System.Web.UI.WebControls.Panel pnlHas,
            System.Web.UI.WebControls.Panel pnlNone)
        {
            string sql = @"
                SELECT m.ModuleID, m.ModuleName, m.DifficultyLevel,
                       p.PathwayName,
                       ISNULL(total.TotalSubs, 0) AS TotalSubs,
                       ISNULL(done.DoneSubs, 0) AS CompletedSubs,
                       CASE WHEN ISNULL(total.TotalSubs, 0) = 0 THEN 0
                            ELSE CAST(ISNULL(done.DoneSubs, 0) AS INT) * 100
                                 / ISNULL(total.TotalSubs, 1)
                       END AS ProgressPct
                FROM ModuleProgress mp
                INNER JOIN Modules m  ON m.ModuleID  = mp.ModuleID
                INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
                CROSS APPLY (SELECT COUNT(*) AS TotalSubs FROM SubTopics st
                             WHERE st.ModuleID = m.ModuleID AND st.IsPublished = 1) total
                CROSS APPLY (SELECT COUNT(*) AS DoneSubs FROM SubTopicProgress stp
                             INNER JOIN SubTopics st2 ON st2.SubTopicID = stp.SubTopicID
                             WHERE stp.StudentID = @StudentID
                               AND st2.ModuleID  = m.ModuleID
                               AND stp.Status    = 'Completed') done
                WHERE mp.StudentID = @StudentID
                  AND mp.Status    = @Status
                ORDER BY mp.ProgressID DESC";

            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value     = studentID;
                cmd.Parameters.Add("@Status",    SqlDbType.NVarChar, 20).Value = status;

                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);

                // Add colour column for difficulty.
                dt.Columns.Add("DiffColour", typeof(string));
                foreach (DataRow row in dt.Rows)
                {
                    row["DiffColour"] = DiffColour(row["DifficultyLevel"].ToString());
                }

                if (dt.Rows.Count > 0)
                {
                    rpt.DataSource = dt;
                    rpt.DataBind();
                    pnlHas.Visible = true;
                }
                else
                {
                    pnlNone.Visible = true;
                }
            }
        }

        private void LoadCompletedList(SqlConnection conn, int studentID)
        {
            string sql = @"
                SELECT m.ModuleName, p.PathwayName,
                       mp.XPEarned, mp.CompletedAt
                FROM ModuleProgress mp
                INNER JOIN Modules m  ON m.ModuleID  = mp.ModuleID
                INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
                WHERE mp.StudentID = @StudentID
                  AND mp.Status    = 'Completed'
                ORDER BY mp.CompletedAt DESC";

            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                DataTable dt = new DataTable();
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    rptCompleted.DataSource = dt;
                    rptCompleted.DataBind();
                    pnlCompleted.Visible = true;
                }
                else
                {
                    pnlNoCompleted.Visible = true;
                }
            }
        }

        private string DiffColour(string diff)
        {
            switch (diff)
            {
                case "Easy":   return "#22C55E";
                case "Medium": return "#F59E0B";
                case "Hard":   return "#EF4444";
                default:       return "#64748B";
            }
        }
    }
}
