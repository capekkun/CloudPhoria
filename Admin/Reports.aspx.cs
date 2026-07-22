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
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString; }
        }

        private int AdminID
        {
            get { return Convert.ToInt32(Session["UserID"]); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

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
                    }
                }
            }
            catch (SqlException)
            {
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
        }
    }
}
