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

            ((SiteMaster)Master).PageHeading = "Notifications";

            if (!IsPostBack) LoadNotifications();
        }

        private void LoadNotifications()
        {
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
        }

        protected void rptNotifications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "MarkRead") MarkRead(Convert.ToInt32(e.CommandArgument));
        }

        private void MarkRead(int notifID)
        {
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE Notifications SET IsRead=1 WHERE NotificationID=@NID AND UserID=@UID", conn))
                    {
                        cmd.Parameters.Add("@NID", SqlDbType.Int).Value = notifID;
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        cmd.ExecuteNonQuery();
                    }
                }
                LoadNotifications();
            }
            catch (SqlException) { }
        }

        protected void btnMarkAll_Click(object sender, EventArgs e)
        {
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

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
                litSuccess.Text = "All notifications marked as read.";
                pnlSuccess.Visible = true;
                LoadNotifications();
            }
            catch (SqlException) { }
        }
    }
}
