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

        protected string GetNotifIcon(object notifType)
        {
            string t = notifType != null && notifType != DBNull.Value
                       ? notifType.ToString() : "";
            switch (t)
            {
                case "BadgeAwarded":     return "&#x1F3C5;";
                case "CertIssued":       return "&#x1F4DC;";
                case "BossFightWon":     return "&#x1F480;";
                case "BossFightLost":    return "&#x1F4A5;";
                case "ChallengeAlert":   return "&#x26A1;";
                case "FeedbackReceived": return "&#x1F4DD;";
                case "AssignmentPosted": return "&#x1F4CB;";
                case "ConsultBooked":    return "&#x1F4C5;";
                case "MaterialUploaded": return "&#x1F4CE;";
                case "NewModule":        return "&#x1F4D6;";
                default:                 return "&#x1F514;";
            }
        }
    }
}
