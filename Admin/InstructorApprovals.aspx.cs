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

            ((SiteMaster)Master).PageHeading = "Instructor Approvals";

            if (!IsPostBack) LoadApprovals();
        }

        private void LoadApprovals()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    DataTable dtPending = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT i.InstructorID, u.FullName, u.Email, i.Qualification, u.CreatedAt
                          FROM Instructors i
                          INNER JOIN Users u ON u.UserID = i.InstructorID
                          WHERE i.LicenseStatus = 'Pending'
                          ORDER BY u.CreatedAt", conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtPending);

                    if (dtPending.Rows.Count > 0)
                    {
                        rptPendingInstructors.DataSource = dtPending;
                        rptPendingInstructors.DataBind();
                        pnlPendingInstructors.Visible = true;
                    }
                    else { pnlNoPending.Visible = true; }

                    DataTable dtAll = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT u.FullName, i.Qualification, i.LicenseStatus, i.ApprovedAt
                          FROM Instructors i
                          INNER JOIN Users u ON u.UserID = i.InstructorID
                          ORDER BY u.FullName", conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtAll);

                    rptAllInstructors.DataSource = dtAll;
                    rptAllInstructors.DataBind();
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load instructor applications.");
            }
        }

        protected void rptPendingInstructors_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int instructorID = Convert.ToInt32(e.CommandArgument);
            string newStatus = e.CommandName == "Approve" ? "Approved" : "Rejected";

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"UPDATE Instructors SET LicenseStatus=@Status, ApprovedBy=@AID, ApprovedAt=GETDATE()
                          WHERE InstructorID=@IID", conn))
                    {
                        cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 20).Value = newStatus;
                        cmd.Parameters.Add("@AID", SqlDbType.Int).Value = AdminID;
                        cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        cmd.ExecuteNonQuery();
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO Notifications (UserID, Message, NotificationType, IsRead, CreatedAt)
                          VALUES (@UID, @Msg, 'InstructorLicense', 0, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = instructorID;
                        cmd.Parameters.Add("@Msg", SqlDbType.NVarChar, 500).Value =
                            newStatus == "Approved"
                                ? "Congratulations! Your instructor licence has been approved. You can now create content."
                                : "Your instructor licence application was not approved. Please contact support.";
                        cmd.ExecuteNonQuery();
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO AuditLogs (PerformedByUserID, ActionType, TargetTable, TargetID, CreatedAt)
                          VALUES (@UID, @Action, 'Instructors', @IID, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = AdminID;
                        cmd.Parameters.Add("@Action", SqlDbType.NVarChar, 100).Value =
                            newStatus == "Approved" ? "APPROVE_INSTRUCTOR" : "REJECT_INSTRUCTOR";
                        cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        cmd.ExecuteNonQuery();
                    }
                }

                ShowSuccess("Instructor " + newStatus.ToLower() + ".");
                LoadApprovals();
            }
            catch (SqlException)
            {
                ShowError("Could not update instructor status.");
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
