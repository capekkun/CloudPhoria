using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Instructor
{
    public partial class Notifications : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Instructor")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Notifications";

            if (!IsPostBack)
                LoadNotifications();
        }

        private void LoadNotifications()
        {
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs  = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            string sql = @"
                SELECT NotificationID, Message, NotificationType, IsRead, CreatedAt
                FROM   Notifications
                WHERE  UserID = @UID
                ORDER  BY CreatedAt DESC";

            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }
                }

                if (dt.Rows.Count > 0)
                {
                    rptNotifications.DataSource = dt;
                    rptNotifications.DataBind();
                    pnlNotifications.Visible = true;
                    pnlEmpty.Visible         = false;

                    // Show "Mark all" only if there are unread notifications.
                    bool hasUnread = false;
                    foreach (DataRow row in dt.Rows)
                        if (!Convert.ToBoolean(row["IsRead"])) { hasUnread = true; break; }
                    pnlMarkAllBtn.Visible = hasUnread;
                }
                else
                {
                    pnlNotifications.Visible = false;
                    pnlEmpty.Visible         = true;
                }
            }
            catch (SqlException)
            {
                // Non-critical — show empty state.
                pnlEmpty.Visible = true;
            }
        }

        protected void rptNotifications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "MarkRead")
            {
                int notifID = Convert.ToInt32(e.CommandArgument);
                MarkRead(notifID);
            }
        }

        private void MarkRead(int notifID)
        {
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs  = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    // UserID is included in WHERE to prevent marking another user's notification.
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE Notifications SET IsRead=1 WHERE NotificationID=@NID AND UserID=@UID", conn))
                    {
                        cmd.Parameters.Add("@NID", SqlDbType.Int).Value = notifID;
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        cmd.ExecuteNonQuery();
                    }
                }
                pnlNotifications.Visible = false;
                pnlEmpty.Visible         = false;
                LoadNotifications();
            }
            catch (SqlException)
            {
                // Silently ignore — the list will reload unchanged.
            }
        }

        protected void btnMarkAll_Click(object sender, EventArgs e)
        {
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs  = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE Notifications SET IsRead=1 WHERE UserID=@UID AND IsRead=0", conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        cmd.ExecuteNonQuery();
                    }
                }

                litSuccess.Text    = HttpUtility.HtmlEncode("All notifications marked as read.");
                pnlSuccess.Visible = true;
                pnlNotifications.Visible = false;
                pnlEmpty.Visible         = false;
                LoadNotifications();
            }
            catch (SqlException)
            {
                // Non-critical — ignore.
            }
        }
    }
}
