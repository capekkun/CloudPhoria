using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Admin
{
    public partial class Reports : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null || Session["Role"].ToString() != "Admin")
            { Response.Redirect("~/LogIn.aspx", true); return; }
            if (!IsPostBack) LoadReports(ddlStatus.SelectedValue);
        }

        protected void btnFilter_Click(object sender, EventArgs e) { LoadReports(ddlStatus.SelectedValue); }

        private void LoadReports(string statusFilter)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    foreach (var p in new[] { new { L = litOpenCount, S = "Open" }, new { L = litReviewedCount, S = "Reviewed" }, new { L = litActionCount, S = "ActionTaken" }, new { L = litDismissedCount, S = "Dismissed" } })
                    { using (SqlCommand c = new SqlCommand("SELECT COUNT(*) FROM Reports WHERE Status=@S", conn)) { c.Parameters.Add("@S", SqlDbType.NVarChar, 20).Value = p.S; p.L.Text = c.ExecuteScalar().ToString(); } }

                    string sql = @"SELECT r.ReportID, r.Reason, r.Status, r.ReportedContentType, r.ReportedContentID, r.CreatedAt,
                        reporter.FullName AS ReporterName, reported.FullName AS ReportedUserName, reviewer.FullName AS ReviewedByName
                        FROM Reports r INNER JOIN Users reporter ON reporter.UserID = r.ReportedByUserID
                        LEFT JOIN Users reported ON reported.UserID = r.ReportedUserID
                        LEFT JOIN Admins ra ON ra.AdminID = r.ReviewedByAdminID LEFT JOIN Users reviewer ON reviewer.UserID = ra.AdminID
                        WHERE @Status = '' OR r.Status = @Status
                        ORDER BY CASE r.Status WHEN 'Open' THEN 1 WHEN 'Reviewed' THEN 2 WHEN 'ActionTaken' THEN 3 WHEN 'Dismissed' THEN 4 END, r.CreatedAt DESC";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 20).Value = statusFilter ?? "";
                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                        litCount.Text = dt.Rows.Count.ToString();
                        if (dt.Rows.Count > 0) { rptReports.DataSource = dt; rptReports.DataBind(); pnlList.Visible = true; pnlEmpty.Visible = false; }
                        else { pnlList.Visible = false; pnlEmpty.Visible = true; }
                    }
                }
            }
            catch (SqlException) { ShowMessage("Could not load reports.", false); }
        }

        protected void rptReports_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument.ToString(), out int reportID)) { ShowMessage("Invalid report ID.", false); return; }
            string newStatus = "";
            switch (e.CommandName) { case "MarkReviewed": newStatus = "Reviewed"; break; case "ActionTaken": newStatus = "ActionTaken"; break; case "Dismiss": newStatus = "Dismissed"; break; default: ShowMessage("Unknown action.", false); return; }
            int adminID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand v = new SqlCommand("SELECT ReportID FROM Reports WHERE ReportID=@RID", conn))
                    { v.Parameters.Add("@RID", SqlDbType.Int).Value = reportID; if (v.ExecuteScalar() == null) { ShowMessage("Report not found.", false); LoadReports(ddlStatus.SelectedValue); return; } }
                    using (SqlTransaction tx = conn.BeginTransaction())
                    {
                        try
                        {
                            using (SqlCommand u = new SqlCommand("UPDATE Reports SET Status=@S, ReviewedByAdminID=@A WHERE ReportID=@RID", conn, tx))
                            { u.Parameters.Add("@S", SqlDbType.NVarChar, 20).Value = newStatus; u.Parameters.Add("@A", SqlDbType.Int).Value = adminID; u.Parameters.Add("@RID", SqlDbType.Int).Value = reportID; u.ExecuteNonQuery(); }
                            using (SqlCommand a = new SqlCommand("INSERT INTO AuditLogs (PerformedByUserID,ActionType,TargetTable,TargetID,Details,CreatedAt) VALUES (@A,@AT,'Reports',@T,@D,GETDATE())", conn, tx))
                            { a.Parameters.Add("@A", SqlDbType.Int).Value = adminID; a.Parameters.Add("@AT", SqlDbType.NVarChar, 100).Value = "REPORT_" + newStatus.ToUpper(); a.Parameters.Add("@T", SqlDbType.Int).Value = reportID; a.Parameters.Add("@D", SqlDbType.NVarChar, -1).Value = $"Admin {adminID} set ReportID {reportID} to '{newStatus}'."; a.ExecuteNonQuery(); }
                            tx.Commit(); ShowMessage($"Report #{reportID} marked as '{newStatus}'.", true);
                        }
                        catch { tx.Rollback(); throw; }
                    }
                }
            }
            catch (SqlException) { ShowMessage("Could not update report.", false); }
            LoadReports(ddlStatus.SelectedValue);
        }

        protected string GetStatusBadge(string status)
        {
            switch (status) { case "Open": return "<span class='cp-badge cp-badge-red'>Open</span>"; case "Reviewed": return "<span class='cp-badge cp-badge-amber'>Reviewed</span>"; case "ActionTaken": return "<span class='cp-badge cp-badge-green'>Action Taken</span>"; case "Dismissed": return "<span class='cp-badge cp-badge-grey'>Dismissed</span>"; default: return "<span class='cp-badge cp-badge-grey'>" + HttpUtility.HtmlEncode(status) + "</span>"; }
        }

        private void ShowMessage(string message, bool success)
        {
            string cssClass = success ? "cp-alert cp-alert-success" : "cp-alert cp-alert-danger";
            litMessage.Text = $"<div class='{cssClass}'>{HttpUtility.HtmlEncode(message)}</div>";
            pnlMessage.Visible = true;
        }
    }
}
