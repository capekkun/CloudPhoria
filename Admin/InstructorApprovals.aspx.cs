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
            if (Session["UserID"] == null || Session["Role"] == null || Session["Role"].ToString() != "Admin")
            { Response.Redirect("~/LogIn.aspx", true); return; }
            if (!IsPostBack) LoadInstructors(ddlFilter.SelectedValue);
        }

        protected void btnFilter_Click(object sender, EventArgs e) { LoadInstructors(ddlFilter.SelectedValue); }

        private void LoadInstructors(string statusFilter)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    string sql = @"SELECT i.InstructorID, u.FullName, u.Email, i.Qualification, i.LicenseStatus, i.ApprovedAt, u.CreatedAt, approver.FullName AS ApprovedByName
                        FROM Instructors i INNER JOIN Users u ON u.UserID = i.InstructorID LEFT JOIN Users approver ON approver.UserID = i.ApprovedBy
                        WHERE @Status = '' OR i.LicenseStatus = @Status
                        ORDER BY CASE i.LicenseStatus WHEN 'Pending' THEN 1 WHEN 'Rejected' THEN 2 WHEN 'Approved' THEN 3 END, u.CreatedAt DESC";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 20).Value = statusFilter ?? "";
                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                        litCount.Text = dt.Rows.Count.ToString();
                        if (dt.Rows.Count > 0) { rptInstructors.DataSource = dt; rptInstructors.DataBind(); pnlList.Visible = true; pnlEmpty.Visible = false; }
                        else { pnlList.Visible = false; pnlEmpty.Visible = true; }
                    }
                }
            }
            catch (SqlException) { ShowMessage("Could not load instructors.", false); }
        }

        protected void rptInstructors_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument.ToString(), out int instructorID)) { ShowMessage("Invalid ID.", false); return; }
            int adminID = Convert.ToInt32(Session["UserID"]);
            string newStatus = "", actionType = "";
            switch (e.CommandName) { case "Approve": newStatus = "Approved"; actionType = "APPROVE_INSTRUCTOR"; break; case "Reject": newStatus = "Rejected"; actionType = "REJECT_INSTRUCTOR"; break; case "SetPending": newStatus = "Pending"; actionType = "RESET_INSTRUCTOR_PENDING"; break; default: ShowMessage("Unknown action.", false); return; }
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand v = new SqlCommand("SELECT InstructorID FROM Instructors WHERE InstructorID = @IID", conn))
                    { v.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID; if (v.ExecuteScalar() == null) { ShowMessage("Instructor not found.", false); return; } }
                    using (SqlTransaction tx = conn.BeginTransaction())
                    {
                        try
                        {
                            string updateSQL = newStatus == "Pending"
                                ? "UPDATE Instructors SET LicenseStatus=@S, ApprovedBy=NULL, ApprovedAt=NULL WHERE InstructorID=@IID"
                                : "UPDATE Instructors SET LicenseStatus=@S, ApprovedBy=@AdminID, ApprovedAt=GETDATE() WHERE InstructorID=@IID";
                            using (SqlCommand u = new SqlCommand(updateSQL, conn, tx))
                            { u.Parameters.Add("@S", SqlDbType.NVarChar, 20).Value = newStatus; u.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID; if (newStatus != "Pending") u.Parameters.Add("@AdminID", SqlDbType.Int).Value = adminID; u.ExecuteNonQuery(); }
                            string notifMsg = newStatus == "Approved" ? "Your instructor application has been approved." : newStatus == "Rejected" ? "Your instructor application has been reviewed. Contact support for details." : "Your instructor application status has been reset to Pending.";
                            using (SqlCommand n = new SqlCommand("INSERT INTO Notifications (UserID,Message,NotificationType,IsRead,CreatedAt) VALUES (@UID,@M,'InstructorApproval',0,GETDATE())", conn, tx))
                            { n.Parameters.Add("@UID", SqlDbType.Int).Value = instructorID; n.Parameters.Add("@M", SqlDbType.NVarChar, 500).Value = notifMsg; n.ExecuteNonQuery(); }
                            using (SqlCommand a = new SqlCommand("INSERT INTO AuditLogs (PerformedByUserID,ActionType,TargetTable,TargetID,Details,CreatedAt) VALUES (@A,@AT,'Instructors',@T,@D,GETDATE())", conn, tx))
                            { a.Parameters.Add("@A", SqlDbType.Int).Value = adminID; a.Parameters.Add("@AT", SqlDbType.NVarChar, 100).Value = actionType; a.Parameters.Add("@T", SqlDbType.Int).Value = instructorID; a.Parameters.Add("@D", SqlDbType.NVarChar, -1).Value = $"Admin {adminID} set InstructorID {instructorID} to '{newStatus}'."; a.ExecuteNonQuery(); }
                            tx.Commit(); ShowMessage($"Status updated to '{newStatus}'.", true);
                        }
                        catch { tx.Rollback(); throw; }
                    }
                }
            }
            catch (SqlException) { ShowMessage("Could not update status.", false); }
            LoadInstructors(ddlFilter.SelectedValue);
        }

        protected string GetStatusBadge(string status)
        {
            switch (status) { case "Approved": return "<span class='cp-status cp-status-approved'>Approved</span>"; case "Rejected": return "<span class='cp-status cp-status-rejected'>Rejected</span>"; default: return "<span class='cp-status cp-status-pending'>Pending</span>"; }
        }

        private void ShowMessage(string message, bool success)
        {
            string cssClass = success ? "cp-alert cp-alert-success" : "cp-alert cp-alert-danger";
            litMessage.Text = $"<div class='{cssClass}'>{HttpUtility.HtmlEncode(message)}</div>";
            pnlMessage.Visible = true;
        }
    }
}
