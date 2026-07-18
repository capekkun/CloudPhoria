using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class Discussions : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Discussions";

            if (!IsPostBack) { LoadThreads(); }
        }

        private void LoadThreads()
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    string sql = @"
                        SELECT dt.ThreadID, dt.Title, dt.CreatedAt,
                               u.FullName,
                               m.ModuleName,
                               st.SubTopicName,
                               (SELECT COUNT(*) FROM DiscussionReplies dr
                                WHERE dr.ThreadID = dt.ThreadID) AS ReplyCount
                        FROM DiscussionThreads dt
                        INNER JOIN Users    u  ON u.UserID       = dt.CreatedByUserID
                        LEFT  JOIN Modules  m  ON m.ModuleID     = dt.ModuleID
                        LEFT  JOIN SubTopics st ON st.SubTopicID = dt.SubTopicID
                        ORDER BY dt.CreatedAt DESC";

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptThreads.DataSource = dt;
                        rptThreads.DataBind();
                        pnlThreads.Visible = true;
                    }
                    else { pnlEmpty.Visible = true; }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load discussions. Please try again.";
                pnlError.Visible = true;
            }
        }
    }
}
