using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class DiscussionCreate : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            { Response.Redirect("~/LogIn.aspx", true); return; }
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int userID = Convert.ToInt32(Session["UserID"]);
            string title = txtTitle.Text.Trim();
            string body  = txtBody.Text.Trim();

            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(body)) return;

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO DiscussionThreads (CreatedByUserID, Title, Body, CreatedAt)
                          VALUES (@UID, @Title, @Body, GETDATE());
                          SELECT SCOPE_IDENTITY();", conn))
                    {
                        cmd.Parameters.Add("@UID",   SqlDbType.Int).Value = userID;
                        cmd.Parameters.Add("@Title", SqlDbType.NVarChar, 200).Value = title;
                        cmd.Parameters.Add("@Body",  SqlDbType.NVarChar, -1).Value = body;

                        int newID = Convert.ToInt32(cmd.ExecuteScalar());
                        Response.Redirect("~/Student/DiscussionThread.aspx?threadID=" + newID);
                    }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not create discussion. Please try again.";
                pnlError.Visible = true;
            }
        }
    }
}
