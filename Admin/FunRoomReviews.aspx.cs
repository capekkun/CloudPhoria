using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Admin
{
    public partial class FunRoomReviews : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                LoadFunRooms(ddlStatus.SelectedValue);
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadFunRooms(ddlStatus.SelectedValue);
        }

        private void LoadFunRooms(string statusFilter)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    string sql = @"
                        SELECT
                            f.FunRoomID,
                            f.RoomTitle,
                            f.ContentBody,
                            f.Status,
                            f.CreatedAt,
                            creator.FullName   AS CreatorName,
                            reviewer.FullName  AS ReviewedByName
                        FROM FunRooms f
                        INNER JOIN Users creator  ON creator.UserID  = f.CreatedByUserID
                        LEFT  JOIN Users reviewer ON reviewer.UserID =
                            (SELECT u2.UserID FROM Admins a2
                             INNER JOIN Users u2 ON u2.UserID = a2.AdminID
                             WHERE a2.AdminID = f.ReviewedByAdminID)
                        WHERE @Status = '' OR f.Status = @Status
                        ORDER BY
                            CASE f.Status
                                WHEN 'Pending'  THEN 1
                                WHEN 'Rejected' THEN 2
                                WHEN 'Approved' THEN 3
                            END,
                            f.CreatedAt DESC";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 20).Value = statusFilter ?? "";

                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                            da.Fill(dt);

                        litCount.Text = dt.Rows.Count.ToString();

                        if (dt.Rows.Count > 0)
                        {
                            rptFunRooms.DataSource = dt;
                            rptFunRooms.DataBind();
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
                ShowMessage("Could not load fun rooms. Please try again.", false);
            }
        }

        protected void rptFunRooms_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument.ToString(), out int funRoomID) || funRoomID <= 0)
            {
                ShowMessage("Invalid fun room ID.", false);
                return;
            }

            string newStatus  = "";
            string actionType = "";

            switch (e.CommandName)
            {
                case "Approve":
                    newStatus  = "Approved";
                    actionType = "APPROVE_FUNROOM";
                    break;
                case "Reject":
                    newStatus  = "Rejected";
                    actionType = "REJECT_FUNROOM";
                    break;
                case "SetPending":
                    newStatus  = "Pending";
                    actionType = "RESET_FUNROOM_PENDING";
                    break;
                default:
                    ShowMessage("Unknown action.", false);
                    return;
            }

            int adminID = Convert.ToInt32(Session["UserID"]);

            // We need the AdminID from the Admins table for ReviewedByAdminID.
            // In the shared-PK pattern AdminID == UserID, so adminID is correct.
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Verify the fun room exists and get creator UserID for notification.
                    int    creatorUserID = 0;
                    string roomTitle     = "";
                    string verifySQL     = @"
                        SELECT f.CreatedByUserID, f.RoomTitle
                        FROM FunRooms f
                        WHERE f.FunRoomID = @FID";

                    using (SqlCommand verifyCmd = new SqlCommand(verifySQL, conn))
                    {
                        verifyCmd.Parameters.Add("@FID", SqlDbType.Int).Value = funRoomID;
                        using (SqlDataReader rdr = verifyCmd.ExecuteReader())
                        {
                            if (!rdr.Read())
                            {
                                ShowMessage("Fun room not found.", false);
                                return;
                            }
                            creatorUserID = Convert.ToInt32(rdr["CreatedByUserID"]);
                            roomTitle     = rdr["RoomTitle"].ToString();
                        }
                    }

                    using (SqlTransaction tx = conn.BeginTransaction())
                    {
                        try
                        {
                            // Update FunRooms status and reviewer.
                            string updateSQL = newStatus == "Pending"
                                ? @"UPDATE FunRooms
                                    SET Status             = @Status,
                                        ReviewedByAdminID  = NULL
                                    WHERE FunRoomID = @FID"
                                : @"UPDATE FunRooms
                                    SET Status             = @Status,
                                        ReviewedByAdminID  = @AdminID
                                    WHERE FunRoomID = @FID";

                            using (SqlCommand updateCmd = new SqlCommand(updateSQL, conn, tx))
                            {
                                updateCmd.Parameters.Add("@Status", SqlDbType.NVarChar, 20).Value = newStatus;
                                updateCmd.Parameters.Add("@FID",    SqlDbType.Int).Value          = funRoomID;
                                if (newStatus != "Pending")
                                    updateCmd.Parameters.Add("@AdminID", SqlDbType.Int).Value = adminID;
                                updateCmd.ExecuteNonQuery();
                            }

                            // Notify the creator.
                            string notifMsg = newStatus == "Approved"
                                ? $"Your Fun Room \"{roomTitle}\" has been approved and is now visible to everyone."
                                : newStatus == "Rejected"
                                    ? $"Your Fun Room \"{roomTitle}\" was not approved. Please review our content guidelines."
                                    : $"Your Fun Room \"{roomTitle}\" has been reset to Pending review.";

                            string notifType = newStatus == "Rejected" ? "FunRoomRejected" : "FunRoomApproved";

                            string notifSQL = @"
                                INSERT INTO Notifications (UserID, Message, NotificationType, IsRead, CreatedAt)
                                VALUES (@UserID, @Message, @NotifType, 0, GETDATE())";
                            using (SqlCommand notifCmd = new SqlCommand(notifSQL, conn, tx))
                            {
                                notifCmd.Parameters.Add("@UserID",    SqlDbType.Int).Value           = creatorUserID;
                                notifCmd.Parameters.Add("@Message",   SqlDbType.NVarChar, 500).Value = notifMsg;
                                notifCmd.Parameters.Add("@NotifType", SqlDbType.NVarChar, 30).Value  = notifType;
                                notifCmd.ExecuteNonQuery();
                            }

                            // Audit log.
                            string auditSQL = @"
                                INSERT INTO AuditLogs
                                    (PerformedByUserID, ActionType, TargetTable, TargetID, Details, CreatedAt)
                                VALUES
                                    (@AdminID, @ActionType, 'FunRooms', @TargetID, @Details, GETDATE())";
                            using (SqlCommand auditCmd = new SqlCommand(auditSQL, conn, tx))
                            {
                                auditCmd.Parameters.Add("@AdminID",    SqlDbType.Int).Value           = adminID;
                                auditCmd.Parameters.Add("@ActionType", SqlDbType.NVarChar, 100).Value = actionType;
                                auditCmd.Parameters.Add("@TargetID",   SqlDbType.Int).Value           = funRoomID;
                                auditCmd.Parameters.Add("@Details",    SqlDbType.NVarChar, -1).Value  =
                                    $"Admin UserID {adminID} set FunRoomID {funRoomID} ('{roomTitle}') status to '{newStatus}'.";
                                auditCmd.ExecuteNonQuery();
                            }

                            tx.Commit();
                            ShowMessage($"Fun room status updated to '{newStatus}'.", true);
                        }
                        catch
                        {
                            tx.Rollback();
                            throw;
                        }
                    }
                }
            }
            catch (SqlException)
            {
                ShowMessage("Could not update fun room. Please try again.", false);
            }

            LoadFunRooms(ddlStatus.SelectedValue);
        }

        protected string GetStatusBadge(string status)
        {
            switch (status)
            {
                case "Approved": return "<span class='cp-status cp-status-approved'>Approved</span>";
                case "Rejected": return "<span class='cp-status cp-status-rejected'>Rejected</span>";
                default:         return "<span class='cp-status cp-status-pending'>Pending</span>";
            }
        }

        private void ShowMessage(string message, bool success)
        {
            string cssClass    = success ? "cp-alert cp-alert-success" : "cp-alert cp-alert-danger";
            litMessage.Text    = $"<div class='{cssClass}'>{HttpUtility.HtmlEncode(message)}</div>";
            pnlMessage.Visible = true;
        }
    }
}
