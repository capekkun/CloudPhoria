using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class DiscussionThread : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            { Response.Redirect("~/LogIn.aspx", true); return; }

            if (!IsPostBack)
            {
                int threadID;
                if (!int.TryParse(Request.QueryString["threadID"], out threadID))
                { Response.Redirect("~/Student/Discussions.aspx"); return; }
                LoadThread(threadID);
            }
        }

        private void LoadThread(int threadID)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Thread info
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT dt.Title, dt.Body, dt.CreatedAt, u.FullName
                          FROM DiscussionThreads dt
                          INNER JOIN Users u ON u.UserID = dt.CreatedByUserID
                          WHERE dt.ThreadID = @TID", conn))
                    {
                        cmd.Parameters.Add("@TID", SqlDbType.Int).Value = threadID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                litTitle.Text  = HttpUtility.HtmlEncode(rdr["Title"].ToString());
                                litAuthor.Text = HttpUtility.HtmlEncode(rdr["FullName"].ToString());
                                litDate.Text   = Convert.ToDateTime(rdr["CreatedAt"]).ToString("dd MMM yyyy");
                                litBody.Text   = HttpUtility.HtmlEncode(rdr["Body"].ToString()).Replace("\n", "<br/>");
                                pnlThread.Visible = true;
                            }
                            else
                            {
                                litError.Text = "Thread not found.";
                                pnlError.Visible = true;
                                return;
                            }
                        }
                    }

                    // Replies
                    DataTable dtR = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT dr.Body, dr.CreatedAt, u.FullName
                          FROM DiscussionReplies dr
                          INNER JOIN Users u ON u.UserID = dr.CreatedByUserID
                          WHERE dr.ThreadID = @TID
                          ORDER BY dr.CreatedAt ASC", conn))
                    {
                        cmd.Parameters.Add("@TID", SqlDbType.Int).Value = threadID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtR);
                    }

                    if (dtR.Rows.Count > 0)
                    { rptReplies.DataSource = dtR; rptReplies.DataBind(); pnlReplies.Visible = true; }
                    else { pnlNoReplies.Visible = true; }
                }
            }
            catch (SqlException)
            { litError.Text = "Could not load the discussion. Please try again."; pnlError.Visible = true; }
        }
    }
}
