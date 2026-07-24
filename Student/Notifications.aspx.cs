using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class Notifications : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Notifications";

            if (!IsPostBack) { LoadNotifications(); }
        }

        private void LoadNotifications()
        {
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    string sql = @"
                        SELECT NotificationID, Message, NotificationType,
                               IsRead, CreatedAt
                        FROM Notifications
                        WHERE UserID = @UserID
                        ORDER BY CreatedAt DESC";

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }

                    if (dt.Rows.Count > 0)
                    {
                        rptNotifications.DataSource = dt;
                        rptNotifications.DataBind();
                        pnlNotifications.Visible = true;
                    }
                    else { pnlEmpty.Visible = true; }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load notifications. Please try again.";
                pnlError.Visible = true;
            }
        }

        protected void btnMarkAllRead_Click(object sender, EventArgs e)
        {
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE Notifications SET IsRead = 1 WHERE UserID = @UserID AND IsRead = 0", conn))
                    {
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userID;
                        cmd.ExecuteNonQuery();
                    }
                }
                LoadNotifications();
            }
            catch (SqlException)
            {
                litError.Text = "Could not update notifications. Please try again.";
                pnlError.Visible = true;
            }
        }

    }
}
