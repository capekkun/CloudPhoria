using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class DiscussionThread : System.Web.UI.Page
    {
        private int ThreadID { get { return ViewState["ThreadID"] != null ? (int)ViewState["ThreadID"] : 0; } }

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
                ViewState["ThreadID"] = threadID;
                LoadThread(threadID);
            }
        }

        private void LoadThread(int threadID)
        {
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Thread info
                    int creatorID = 0;
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT dt.Title, dt.Body, dt.CreatedAt, dt.CreatedByUserID, u.FullName
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
                                creatorID      = Convert.ToInt32(rdr["CreatedByUserID"]);
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

                    // Show delete button only if current user created the thread
                    if (creatorID == userID)
                    {
                        pnlDeleteThread.Visible = true;
                    }

                    // Replies
                    LoadReplies(conn, threadID);
                }
            }
            catch (SqlException)
            { litError.Text = "Could not load the discussion. Please try again."; pnlError.Visible = true; }
        }

        private void LoadReplies(SqlConnection conn, int threadID)
        {
            DataTable dtR = new DataTable();
            using (SqlCommand cmd = new SqlCommand(
                @"SELECT dr.ReplyID, dr.Body, dr.CreatedAt, dr.CreatedByUserID, u.FullName
                  FROM DiscussionReplies dr
                  INNER JOIN Users u ON u.UserID = dr.CreatedByUserID
                  WHERE dr.ThreadID = @TID
                  ORDER BY dr.CreatedAt ASC", conn))
            {
                cmd.Parameters.Add("@TID", SqlDbType.Int).Value = threadID;
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtR);
            }

            if (dtR.Rows.Count > 0)
            { rptReplies.DataSource = dtR; rptReplies.DataBind(); pnlReplies.Visible = true; pnlNoReplies.Visible = false; }
            else { pnlNoReplies.Visible = true; pnlReplies.Visible = false; }
        }

        protected void btnPostReply_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int userID = Convert.ToInt32(Session["UserID"]);
            int threadID = ThreadID;
            string body = txtReply.Text.Trim();

            if (string.IsNullOrEmpty(body) || threadID == 0) return;

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO DiscussionReplies (ThreadID, CreatedByUserID, Body, CreatedAt)
                          VALUES (@TID, @UID, @Body, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@TID",  SqlDbType.Int).Value = threadID;
                        cmd.Parameters.Add("@UID",  SqlDbType.Int).Value = userID;
                        cmd.Parameters.Add("@Body", SqlDbType.NVarChar, -1).Value = body;
                        cmd.ExecuteNonQuery();
                    }

                    txtReply.Text = "";
                    pnlReplySuccess.Visible = true;
                    LoadReplies(conn, threadID);
                }
            }
            catch (SqlException)
            { litError.Text = "Could not post reply. Please try again."; pnlError.Visible = true; }
        }

        protected void btnDeleteThread_Click(object sender, EventArgs e)
        {
            int userID = Convert.ToInt32(Session["UserID"]);
            int threadID = ThreadID;
            if (threadID == 0) return;

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    // Delete replies first (child records)
                    using (SqlCommand cmd = new SqlCommand(
                        "DELETE FROM DiscussionReplies WHERE ThreadID = @TID", conn))
                    {
                        cmd.Parameters.Add("@TID", SqlDbType.Int).Value = threadID;
                        cmd.ExecuteNonQuery();
                    }
                    // Delete thread — only if current user created it
                    using (SqlCommand cmd = new SqlCommand(
                        "DELETE FROM DiscussionThreads WHERE ThreadID = @TID AND CreatedByUserID = @UID", conn))
                    {
                        cmd.Parameters.Add("@TID", SqlDbType.Int).Value = threadID;
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        cmd.ExecuteNonQuery();
                    }
                }
                Response.Redirect("~/Student/Discussions.aspx");
            }
            catch (SqlException)
            { litError.Text = "Could not delete thread. Please try again."; pnlError.Visible = true; }
        }

        protected void rptReplies_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "DeleteReply") return;

            int replyID;
            if (!int.TryParse(e.CommandArgument.ToString(), out replyID)) return;

            int userID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "DELETE FROM DiscussionReplies WHERE ReplyID = @RID AND CreatedByUserID = @UID", conn))
                    {
                        cmd.Parameters.Add("@RID", SqlDbType.Int).Value = replyID;
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        cmd.ExecuteNonQuery();
                    }
                    LoadReplies(conn, ThreadID);
                }
            }
            catch (SqlException)
            { litError.Text = "Could not delete reply."; pnlError.Visible = true; }
        }
    }
}
