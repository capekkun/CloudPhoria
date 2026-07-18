using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Instructor
{
    public partial class Discussions : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Instructor")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Discussions";

            if (!IsPostBack)
            {
                int threadID;
                if (int.TryParse(Request.QueryString["threadID"], out threadID) && threadID > 0)
                {
                    LoadThreadDetail(threadID);
                    hfThreadID.Value = threadID.ToString();
                }
                else
                {
                    LoadThreads();
                }
            }
        }

        private void LoadThreads()
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            string sql = @"
                SELECT dt.ThreadID, dt.Title, dt.CreatedAt, dt.CreatedByUserID,
                       u.FullName AS AuthorName,
                       COUNT(dr.ReplyID) AS ReplyCount
                FROM   DiscussionThreads dt
                INNER JOIN Users u ON u.UserID = dt.CreatedByUserID
                LEFT  JOIN DiscussionReplies dr ON dr.ThreadID = dt.ThreadID
                GROUP  BY dt.ThreadID, dt.Title, dt.CreatedAt, dt.CreatedByUserID, u.FullName
                ORDER  BY dt.CreatedAt DESC";

            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                }

                if (dt.Rows.Count > 0)
                {
                    rptThreads.DataSource = dt;
                    rptThreads.DataBind();
                    pnlThreads.Visible = true;
                    pnlEmpty.Visible   = false;
                }
                else
                {
                    pnlThreads.Visible = false;
                    pnlEmpty.Visible   = true;
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load discussions. Please try again.");
            }
        }

        private void LoadThreadDetail(int threadID)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Thread info.
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT dt.Title, dt.Body, dt.CreatedAt, u.FullName
                          FROM DiscussionThreads dt
                          INNER JOIN Users u ON u.UserID = dt.CreatedByUserID
                          WHERE dt.ThreadID = @TID", conn))
                    {
                        cmd.Parameters.Add("@TID", SqlDbType.Int).Value = threadID;
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                litThreadTitle.Text = HttpUtility.HtmlEncode(r["Title"].ToString());
                                litThreadBody.Text  = HttpUtility.HtmlEncode(r["Body"].ToString());
                                litThreadMeta.Text  = "By " + HttpUtility.HtmlEncode(r["FullName"].ToString())
                                    + " &bull; " + Convert.ToDateTime(r["CreatedAt"]).ToString("dd MMM yyyy HH:mm");
                            }
                        }
                    }

                    // Replies.
                    DataTable dtReplies = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT dr.ReplyID, dr.Body, dr.CreatedAt, dr.CreatedByUserID,
                                 u.FullName AS AuthorName
                          FROM DiscussionReplies dr
                          INNER JOIN Users u ON u.UserID = dr.CreatedByUserID
                          WHERE dr.ThreadID = @TID
                          ORDER BY dr.CreatedAt", conn))
                    {
                        cmd.Parameters.Add("@TID", SqlDbType.Int).Value = threadID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtReplies);
                    }

                    if (dtReplies.Rows.Count > 0)
                    {
                        rptReplies.DataSource = dtReplies;
                        rptReplies.DataBind();
                        pnlReplies.Visible = true;
                    }
                }

                pnlThread.Visible = true;
            }
            catch (SqlException)
            {
                ShowError("Could not load thread. Please try again.");
            }
        }

        protected void btnCreateThread_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { return; }

            int userID = Convert.ToInt32(Session["UserID"]);
            string title = txtThreadTitle.Text.Trim();
            string body  = txtThreadBody.Text.Trim();
            string cs    = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO DiscussionThreads (CreatedByUserID, Title, Body, CreatedAt)
                          VALUES (@UID, @Title, @Body, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@UID",   SqlDbType.Int).Value           = userID;
                        cmd.Parameters.Add("@Title", SqlDbType.NVarChar, 200).Value = title;
                        cmd.Parameters.Add("@Body",  SqlDbType.NVarChar, -1).Value  = body;
                        cmd.ExecuteNonQuery();
                    }
                }

                txtThreadTitle.Text = string.Empty;
                txtThreadBody.Text  = string.Empty;

                ShowSuccess("Thread posted.");
                pnlThreads.Visible = false;
                pnlEmpty.Visible   = false;
                LoadThreads();
            }
            catch (SqlException)
            {
                ShowError("Could not post thread. Please try again.");
            }
        }

        protected void btnReply_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { return; }

            int userID   = Convert.ToInt32(Session["UserID"]);
            int threadID;
            if (!int.TryParse(hfThreadID.Value, out threadID) || threadID == 0)
            {
                ShowError("Invalid thread reference.");
                return;
            }

            string body = txtReply.Text.Trim();
            string cs   = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO DiscussionReplies (ThreadID, CreatedByUserID, Body, CreatedAt)
                          VALUES (@TID, @UID, @Body, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@TID",  SqlDbType.Int).Value          = threadID;
                        cmd.Parameters.Add("@UID",  SqlDbType.Int).Value          = userID;
                        cmd.Parameters.Add("@Body", SqlDbType.NVarChar, -1).Value = body;
                        cmd.ExecuteNonQuery();
                    }
                }

                txtReply.Text = string.Empty;
                ShowSuccess("Reply posted.");
                LoadThreadDetail(threadID);
            }
            catch (SqlException)
            {
                ShowError("Could not post reply. Please try again.");
            }
        }

        protected void rptThreads_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Delete")
                DeleteThread(Convert.ToInt32(e.CommandArgument));
        }

        private void DeleteThread(int threadID)
        {
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs  = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "DELETE FROM DiscussionThreads WHERE ThreadID=@TID AND CreatedByUserID=@UID", conn))
                    {
                        cmd.Parameters.Add("@TID", SqlDbType.Int).Value = threadID;
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowSuccess("Thread deleted.");
                pnlThreads.Visible = false;
                pnlEmpty.Visible   = false;
                LoadThreads();
            }
            catch (SqlException)
            {
                ShowError("Could not delete thread. Please try again.");
            }
        }

        protected void rptReplies_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteReply")
            {
                int replyID  = Convert.ToInt32(e.CommandArgument);
                int threadID;
                int.TryParse(hfThreadID.Value, out threadID);
                DeleteReply(replyID, threadID);
            }
        }

        private void DeleteReply(int replyID, int threadID)
        {
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs  = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "DELETE FROM DiscussionReplies WHERE ReplyID=@RID AND CreatedByUserID=@UID", conn))
                    {
                        cmd.Parameters.Add("@RID", SqlDbType.Int).Value = replyID;
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowSuccess("Reply deleted.");
                if (threadID > 0) LoadThreadDetail(threadID);
            }
            catch (SqlException)
            {
                ShowError("Could not delete reply. Please try again.");
            }
        }

        private void ShowSuccess(string msg)
        {
            litSuccess.Text = HttpUtility.HtmlEncode(msg);
            pnlSuccess.Visible = true;
            pnlError.Visible   = false;
        }

        private void ShowError(string msg)
        {
            litError.Text = HttpUtility.HtmlEncode(msg);
            pnlError.Visible   = true;
            pnlSuccess.Visible = false;
        }
    }
}
