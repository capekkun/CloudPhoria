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
<<<<<<< HEAD
=======
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString; }
        }

        private int AdminID
        {
            get { return Convert.ToInt32(Session["UserID"]); }
        }

>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
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
                LoadReports(ddlStatus.SelectedValue);
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadReports(ddlStatus.SelectedValue);
        }

        private void LoadReports(string statusFilter)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Load status counters.
                    foreach (var pair in new[] {
                        new { Lit = litOpenCount,      Status = "Open" },
                        new { Lit = litReviewedCount,  Status = "Reviewed" },
                        new { Lit = litActionCount,    Status = "ActionTaken" },
                        new { Lit = litDismissedCount, Status = "Dismissed" }
                    })
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT COUNT(*) FROM Reports WHERE Status = @S", conn))
                        {
                            cmd.Parameters.Add("@S", SqlDbType.NVarChar, 20).Value = pair.Status;
                            pair.Lit.Text = cmd.ExecuteScalar().ToString();
                        }
                    }

                    // Load report rows.
                    string sql = @"
                        SELECT
                            r.ReportID,
                            r.Reason,
                            r.Status,
                            r.ReportedContentType,
                            r.ReportedContentID,
                            r.CreatedAt,
                            reporter.FullName   AS ReporterName,
                            reported.FullName   AS ReportedUserName,
                            reviewer.FullName   AS ReviewedByName
                        FROM Reports r
                        INNER JOIN Users reporter  ON reporter.UserID  = r.ReportedByUserID
                        LEFT  JOIN Users reported  ON reported.UserID  = r.ReportedUserID
                        LEFT  JOIN Admins ra        ON ra.AdminID      = r.ReviewedByAdminID
                        LEFT  JOIN Users reviewer  ON reviewer.UserID  = ra.AdminID
                        WHERE @Status = '' OR r.Status = @Status
                        ORDER BY
                            CASE r.Status
                                WHEN 'Open'        THEN 1
                                WHEN 'Reviewed'    THEN 2
                                WHEN 'ActionTaken' THEN 3
                                WHEN 'Dismissed'   THEN 4
                            END,
                            r.CreatedAt DESC";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 20).Value = statusFilter ?? "";

                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                            da.Fill(dt);

                        litCount.Text = dt.Rows.Count.ToString();

                        if (dt.Rows.Count > 0)
                        {
                            rptReports.DataSource = dt;
                            rptReports.DataBind();
                            pnlList.Visible  = true;
                            pnlEmpty.Visible = false;
                        }
                        else
                        {
                            pnlList.Visible  = false;
                            pnlEmpty.Visible = true;
                        }
=======
            ((SiteMaster)Master).PageHeading = "Reports";

            if (!IsPostBack) LoadReports();
        }

        private void LoadReports()
        {
            string statusFilter = ddlStatusFilter.SelectedValue;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT r.ReportID, r.Reason, r.Status, r.ReportedContentType, r.CreatedAt,
                                 ru.FullName AS ReporterName, tu.FullName AS ReportedUserName
                          FROM Reports r
                          INNER JOIN Users ru ON ru.UserID = r.ReportedByUserID
                          LEFT JOIN Users tu ON tu.UserID = r.ReportedUserID
                          WHERE (@Status = '' OR r.Status = @Status)
                          ORDER BY r.CreatedAt DESC", conn))
                    {
                        cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 20).Value = statusFilter;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }

                    if (dt.Rows.Count > 0)
                    {
                        rptReports.DataSource = dt;
                        rptReports.DataBind();
                        pnlReports.Visible = true;
                        pnlNoReports.Visible = false;
                    }
                    else
                    {
                        pnlReports.Visible = false;
                        pnlNoReports.Visible = true;
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
                    }
                }
            }
            catch (SqlException)
            {
<<<<<<< HEAD
                ShowMessage("Could not load reports. Please try again.", false);
            }
        }

        protected void rptReports_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument.ToString(), out int reportID) || reportID <= 0)
            {
                ShowMessage("Invalid report ID.", false);
                return;
            }

            // Validate the new status value against the allowed check constraint values.
            string newStatus = "";
            switch (e.CommandName)
            {
                case "MarkReviewed": newStatus = "Reviewed";    break;
                case "ActionTaken":  newStatus = "ActionTaken"; break;
                case "Dismiss":      newStatus = "Dismissed";   break;
                default:
                    ShowMessage("Unknown action.", false);
                    return;
            }

            int    adminID    = Convert.ToInt32(Session["UserID"]);
            string cs         = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Verify report exists.
                    string verifySQL = "SELECT ReportID FROM Reports WHERE ReportID = @RID";
                    using (SqlCommand verifyCmd = new SqlCommand(verifySQL, conn))
                    {
                        verifyCmd.Parameters.Add("@RID", SqlDbType.Int).Value = reportID;
                        object exists = verifyCmd.ExecuteScalar();
                        if (exists == null || exists == DBNull.Value)
                        {
                            ShowMessage("Report not found.", false);
                            LoadReports(ddlStatus.SelectedValue);
                            return;
                        }
                    }

                    using (SqlTransaction tx = conn.BeginTransaction())
                    {
                        try
                        {
                            // Update report status and set the reviewing admin.
                            string updateSQL = @"
                                UPDATE Reports
                                SET Status            = @Status,
                                    ReviewedByAdminID = @AdminID
                                WHERE ReportID = @RID";

                            using (SqlCommand updateCmd = new SqlCommand(updateSQL, conn, tx))
                            {
                                updateCmd.Parameters.Add("@Status",  SqlDbType.NVarChar, 20).Value = newStatus;
                                updateCmd.Parameters.Add("@AdminID", SqlDbType.Int).Value          = adminID;
                                updateCmd.Parameters.Add("@RID",     SqlDbType.Int).Value          = reportID;
                                updateCmd.ExecuteNonQuery();
                            }

                            // Audit log.
                            string auditSQL = @"
                                INSERT INTO AuditLogs
                                    (PerformedByUserID, ActionType, TargetTable, TargetID, Details, CreatedAt)
                                VALUES
                                    (@AdminID, @ActionType, 'Reports', @TargetID, @Details, GETDATE())";

                            using (SqlCommand auditCmd = new SqlCommand(auditSQL, conn, tx))
                            {
                                auditCmd.Parameters.Add("@AdminID",    SqlDbType.Int).Value           = adminID;
                                auditCmd.Parameters.Add("@ActionType", SqlDbType.NVarChar, 100).Value =
                                    "REPORT_" + newStatus.ToUpper();
                                auditCmd.Parameters.Add("@TargetID",   SqlDbType.Int).Value           = reportID;
                                auditCmd.Parameters.Add("@Details",    SqlDbType.NVarChar, -1).Value  =
                                    $"Admin UserID {adminID} set ReportID {reportID} status to '{newStatus}'.";
                                auditCmd.ExecuteNonQuery();
                            }

                            tx.Commit();
                            ShowMessage($"Report #{reportID} marked as '{newStatus}'.", true);
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
                ShowMessage("Could not update the report. Please try again.", false);
            }

            LoadReports(ddlStatus.SelectedValue);
        }

        protected string GetStatusBadge(string status)
        {
            switch (status)
            {
                case "Open":        return "<span class='cp-badge cp-badge-red'>Open</span>";
                case "Reviewed":    return "<span class='cp-badge cp-badge-amber'>Reviewed</span>";
                case "ActionTaken": return "<span class='cp-badge cp-badge-green'>Action Taken</span>";
                case "Dismissed":   return "<span class='cp-badge cp-badge-grey'>Dismissed</span>";
                default:            return "<span class='cp-badge cp-badge-grey'>" + HttpUtility.HtmlEncode(status) + "</span>";
            }
        }

        private void ShowMessage(string message, bool success)
        {
            string cssClass    = success ? "cp-alert cp-alert-success" : "cp-alert cp-alert-danger";
            litMessage.Text    = $"<div class='{cssClass}'>{HttpUtility.HtmlEncode(message)}</div>";
            pnlMessage.Visible = true;
=======
                ShowError("Could not load reports.");
            }
        }

        protected void ddlStatusFilter_Changed(object sender, EventArgs e) { LoadReports(); }

        protected void rptReports_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int reportID = Convert.ToInt32(e.CommandArgument);
            string newStatus = e.CommandName == "MarkReviewed" ? "Reviewed"
                : e.CommandName == "ActionTaken" ? "ActionTaken"
                : e.CommandName == "Dismiss" ? "Dismissed" : null;

            if (newStatus == null) return;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE Reports SET Status=@Status, ReviewedByAdminID=@AID WHERE ReportID=@RID", conn))
                    {
                        cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 20).Value = newStatus;
                        cmd.Parameters.Add("@AID", SqlDbType.Int).Value = AdminID;
                        cmd.Parameters.Add("@RID", SqlDbType.Int).Value = reportID;
                        cmd.ExecuteNonQuery();
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO AuditLogs (PerformedByUserID, ActionType, TargetTable, TargetID, CreatedAt)
                          VALUES (@UID, @Action, 'Reports', @RID, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = AdminID;
                        cmd.Parameters.Add("@Action", SqlDbType.NVarChar, 100).Value = "REPORT_" + newStatus.ToUpper();
                        cmd.Parameters.Add("@RID", SqlDbType.Int).Value = reportID;
                        cmd.ExecuteNonQuery();
                    }
                }

                ShowSuccess("Report updated.");
                LoadReports();
            }
            catch (SqlException)
            {
                ShowError("Could not update report.");
            }
        }

        private void ShowSuccess(string msg)
        {
            litSuccess.Text = HttpUtility.HtmlEncode(msg);
            pnlSuccess.Visible = true;
            pnlError.Visible = false;
        }

        private void ShowError(string msg)
        {
            litError.Text = HttpUtility.HtmlEncode(msg);
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
        }
    }
}
