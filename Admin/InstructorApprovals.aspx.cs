using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Admin
{
    public partial class InstructorApprovals : System.Web.UI.Page
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
                LoadInstructors(ddlFilter.SelectedValue);
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadInstructors(ddlFilter.SelectedValue);
        }

        private void LoadInstructors(string statusFilter)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    string sql = @"
                        SELECT
                            i.InstructorID,
                            u.FullName,
                            u.Email,
                            i.Qualification,
                            i.LicenseStatus,
                            i.ApprovedAt,
                            u.CreatedAt,
                            approver.FullName AS ApprovedByName
                        FROM Instructors i
                        INNER JOIN Users u ON u.UserID = i.InstructorID
                        LEFT  JOIN Users approver ON approver.UserID = i.ApprovedBy
                        WHERE @Status = '' OR i.LicenseStatus = @Status
                        ORDER BY
                            CASE i.LicenseStatus
                                WHEN 'Pending'  THEN 1
                                WHEN 'Rejected' THEN 2
                                WHEN 'Approved' THEN 3
                            END,
                            u.CreatedAt DESC";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 20).Value = statusFilter ?? "";

                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                            da.Fill(dt);

                        litCount.Text = dt.Rows.Count.ToString();

                        if (dt.Rows.Count > 0)
                        {
                            rptInstructors.DataSource = dt;
                            rptInstructors.DataBind();
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
                ShowMessage("Could not load instructors. Please try again.", false);
            }
        }

        protected void rptInstructors_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument.ToString(), out int instructorID) || instructorID <= 0)
            {
                ShowMessage("Invalid instructor ID.", false);
                return;
            }

            int adminID = Convert.ToInt32(Session["UserID"]);

            string newStatus  = "";
            string actionType = "";

            switch (e.CommandName)
            {
                case "Approve":
                    newStatus  = "Approved";
                    actionType = "APPROVE_INSTRUCTOR";
                    break;
                case "Reject":
                    newStatus  = "Rejected";
                    actionType = "REJECT_INSTRUCTOR";
                    break;
                case "SetPending":
                    newStatus  = "Pending";
                    actionType = "RESET_INSTRUCTOR_PENDING";
                    break;
                default:
                    ShowMessage("Unknown action.", false);
                    return;
            }

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Verify the instructor record exists.
                    string verifySQL = "SELECT InstructorID FROM Instructors WHERE InstructorID = @IID";
                    using (SqlCommand verifyCmd = new SqlCommand(verifySQL, conn))
                    {
                        verifyCmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        object exists = verifyCmd.ExecuteScalar();
                        if (exists == null || exists == DBNull.Value)
                        {
                            ShowMessage("Instructor not found.", false);
                            return;
                        }
                    }

                    using (SqlTransaction tx = conn.BeginTransaction())
                    {
                        try
                        {
                            // Update the licence status. For Approve/Reject set ApprovedBy and ApprovedAt;
                            // for reset back to Pending, clear those fields.
                            string updateSQL = newStatus == "Pending"
                                ? @"UPDATE Instructors
                                    SET LicenseStatus = @Status,
                                        ApprovedBy    = NULL,
                                        ApprovedAt    = NULL
                                    WHERE InstructorID = @IID"
                                : @"UPDATE Instructors
                                    SET LicenseStatus = @Status,
                                        ApprovedBy    = @AdminID,
                                        ApprovedAt    = GETDATE()
                                    WHERE InstructorID = @IID";

                            using (SqlCommand updateCmd = new SqlCommand(updateSQL, conn, tx))
                            {
                                updateCmd.Parameters.Add("@Status",  SqlDbType.NVarChar, 20).Value = newStatus;
                                updateCmd.Parameters.Add("@IID",     SqlDbType.Int).Value          = instructorID;
                                if (newStatus != "Pending")
                                    updateCmd.Parameters.Add("@AdminID", SqlDbType.Int).Value = adminID;
                                updateCmd.ExecuteNonQuery();
                            }

                            // Send a notification to the instructor.
                            string notifMsg = newStatus == "Approved"
                                ? "Your instructor application has been approved. You now have full access."
                                : newStatus == "Rejected"
                                    ? "Your instructor application has been reviewed. Please contact support for more details."
                                    : "Your instructor application status has been reset to Pending.";

                            // Get the UserID for the instructor (same as InstructorID in this schema).
                            string notifSQL = @"
                                INSERT INTO Notifications (UserID, Message, NotificationType, IsRead, CreatedAt)
                                VALUES (@UserID, @Message, 'InstructorApproval', 0, GETDATE())";
                            using (SqlCommand notifCmd = new SqlCommand(notifSQL, conn, tx))
                            {
                                notifCmd.Parameters.Add("@UserID",  SqlDbType.Int).Value           = instructorID;
                                notifCmd.Parameters.Add("@Message", SqlDbType.NVarChar, 500).Value = notifMsg;
                                notifCmd.ExecuteNonQuery();
                            }

                            // Write audit log.
                            string auditSQL = @"
                                INSERT INTO AuditLogs
                                    (PerformedByUserID, ActionType, TargetTable, TargetID, Details, CreatedAt)
                                VALUES
                                    (@AdminID, @ActionType, 'Instructors', @TargetID, @Details, GETDATE())";
                            using (SqlCommand auditCmd = new SqlCommand(auditSQL, conn, tx))
                            {
                                auditCmd.Parameters.Add("@AdminID",    SqlDbType.Int).Value           = adminID;
                                auditCmd.Parameters.Add("@ActionType", SqlDbType.NVarChar, 100).Value = actionType;
                                auditCmd.Parameters.Add("@TargetID",   SqlDbType.Int).Value           = instructorID;
                                auditCmd.Parameters.Add("@Details",    SqlDbType.NVarChar, -1).Value  =
                                    $"Admin UserID {adminID} set InstructorID {instructorID} LicenseStatus to '{newStatus}'.";
                                auditCmd.ExecuteNonQuery();
                            }

                            tx.Commit();
                            ShowMessage($"Instructor status updated to '{newStatus}'.", true);
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
                ShowMessage("Could not update instructor status. Please try again.", false);
            }

            LoadInstructors(ddlFilter.SelectedValue);
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
