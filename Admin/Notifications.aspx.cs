using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Admin
{
    public partial class Notifications : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

<<<<<<< HEAD
            if (!IsPostBack)
            {
                LoadNotifications();
            }
=======
            ((SiteMaster)Master).PageHeading = "Notifications";

            if (!IsPostBack) LoadNotifications();
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
        }

        private void LoadNotifications()
        {
<<<<<<< HEAD
            int    userID = Convert.ToInt32(Session["UserID"]);
            string cs     = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Unread count.
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM Notifications WHERE UserID = @UID AND IsRead = 0", conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        litUnreadCount.Text = cmd.ExecuteScalar().ToString();
                    }

                    // Total count.
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM Notifications WHERE UserID = @UID", conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        litTotalCount.Text = cmd.ExecuteScalar().ToString();
                    }

                    // Notification rows — most recent first, cap at 100.
                    string sql = @"
                        SELECT TOP 100
                            NotificationID,
                            Message,
                            NotificationType,
                            IsRead,
                            CreatedAt
                        FROM Notifications
                        WHERE UserID = @UID
                        ORDER BY CreatedAt DESC";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;

                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                            da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptNotifications.DataSource = dt;
                            rptNotifications.DataBind();
                            pnlList.Visible  = true;
                            pnlEmpty.Visible = false;
                        }
                        else
                        {
                            pnlList.Visible  = false;
                            pnlEmpty.Visible = true;
                        }
                    }
                }
            }
            catch (SqlException)
            {
                pnlList.Visible  = false;
                pnlEmpty.Visible = true;
            }
=======
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT NotificationID, Message, NotificationType, IsRead, CreatedAt FROM Notifications WHERE UserID=@UID ORDER BY CreatedAt DESC", conn))
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
                    pnlEmpty.Visible = false;

                    bool hasUnread = false;
                    foreach (DataRow row in dt.Rows)
                        if (!Convert.ToBoolean(row["IsRead"])) { hasUnread = true; break; }
                    pnlMarkAllBtn.Visible = hasUnread;
                }
                else
                {
                    pnlNotifications.Visible = false;
                    pnlEmpty.Visible = true;
                }
            }
            catch (SqlException) { pnlEmpty.Visible = true; }
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
        }

        protected void rptNotifications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
<<<<<<< HEAD
            if (e.CommandName != "MarkRead") return;

            if (!int.TryParse(e.CommandArgument.ToString(), out int notifID) || notifID <= 0)
                return;

            int    userID = Convert.ToInt32(Session["UserID"]);
            string cs     = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
=======
            if (e.CommandName == "MarkRead") MarkRead(Convert.ToInt32(e.CommandArgument));
        }

        private void MarkRead(int notifID)
        {
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
<<<<<<< HEAD

                    // Verify ownership — only the intended user can mark their own notification.
                    string updateSQL = @"
                        UPDATE Notifications
                        SET IsRead = 1
                        WHERE NotificationID = @NID
                          AND UserID         = @UID";

                    using (SqlCommand cmd = new SqlCommand(updateSQL, conn))
=======
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE Notifications SET IsRead=1 WHERE NotificationID=@NID AND UserID=@UID", conn))
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
                    {
                        cmd.Parameters.Add("@NID", SqlDbType.Int).Value = notifID;
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        cmd.ExecuteNonQuery();
                    }
                }
<<<<<<< HEAD
            }
            catch (SqlException)
            {
                ShowMessage("Could not mark notification as read. Please try again.", false);
            }

            LoadNotifications();
        }

        protected void btnMarkAllRead_Click(object sender, EventArgs e)
        {
            int    userID = Convert.ToInt32(Session["UserID"]);
            string cs     = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
=======
                LoadNotifications();
            }
            catch (SqlException) { }
        }

        protected void btnMarkAll_Click(object sender, EventArgs e)
        {
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
<<<<<<< HEAD

                    // Only update notifications that belong to this user.
                    string sql = "UPDATE Notifications SET IsRead = 1 WHERE UserID = @UID AND IsRead = 0";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        int rows = cmd.ExecuteNonQuery();
                        ShowMessage($"Marked {rows} notification(s) as read.", true);
                    }
                }
            }
            catch (SqlException)
            {
                ShowMessage("Could not update notifications. Please try again.", false);
            }

            LoadNotifications();
        }

        private void ShowMessage(string message, bool success)
        {
            string cssClass    = success ? "cp-alert cp-alert-success" : "cp-alert cp-alert-danger";
            litMessage.Text    = $"<div class='{cssClass}'>{HttpUtility.HtmlEncode(message)}</div>";
            pnlMessage.Visible = true;
=======
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE Notifications SET IsRead=1 WHERE UserID=@UID AND IsRead=0", conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        cmd.ExecuteNonQuery();
                    }
                }
                litSuccess.Text = "All notifications marked as read.";
                pnlSuccess.Visible = true;
                LoadNotifications();
            }
            catch (SqlException) { }
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
        }
    }
}
