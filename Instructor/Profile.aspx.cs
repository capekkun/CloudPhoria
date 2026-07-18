using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Instructor
{
    public partial class Profile : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Instructor")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Profile";

            if (!IsPostBack)
                LoadProfile();
        }

        private void LoadProfile()
        {
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs  = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    string sql = @"
                        SELECT u.FullName, u.Email, u.CreatedAt,
                               i.Qualification, i.LicenseStatus, i.ApprovedAt
                        FROM   Users u
                        INNER JOIN Instructors i ON i.InstructorID = u.UserID
                        WHERE  u.UserID = @UID";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                string fullName     = r["FullName"].ToString();
                                string email        = r["Email"].ToString();
                                string qualification = r["Qualification"] != DBNull.Value
                                                       ? r["Qualification"].ToString() : string.Empty;
                                string licenseStatus = r["LicenseStatus"].ToString();
                                DateTime createdAt   = Convert.ToDateTime(r["CreatedAt"]);
                                string approvedAt    = r["ApprovedAt"] != DBNull.Value
                                                       ? Convert.ToDateTime(r["ApprovedAt"]).ToString("dd MMM yyyy") : "—";

                                // Avatar initials.
                                string[] parts    = fullName.Trim().Split(' ');
                                string initials   = parts.Length >= 2
                                    ? (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper()
                                    : fullName.Substring(0, Math.Min(2, fullName.Length)).ToUpper();

                                litInitials.Text      = HttpUtility.HtmlEncode(initials);
                                litFullName.Text      = HttpUtility.HtmlEncode(fullName);
                                litEmail.Text         = HttpUtility.HtmlEncode(email);
                                litEmailReadonly.Text = "<span style='font-size:13px;color:var(--cp-text);'>"
                                                        + HttpUtility.HtmlEncode(email) + "</span>";
                                litQualification.Text = HttpUtility.HtmlEncode(string.IsNullOrEmpty(qualification) ? "—" : qualification);
                                litMemberSince.Text   = createdAt.ToString("dd MMM yyyy");
                                litApprovedAt.Text    = HttpUtility.HtmlEncode(approvedAt);

                                // Licence badge.
                                switch (licenseStatus)
                                {
                                    case "Approved":
                                        litLicenseBadge.Text  = "<span class='cp-status cp-status-approved'>Approved</span>";
                                        litLicenseStatus.Text = "<span class='cp-status cp-status-approved'>Approved</span>";
                                        break;
                                    case "Rejected":
                                        litLicenseBadge.Text  = "<span class='cp-status cp-status-rejected'>Rejected</span>";
                                        litLicenseStatus.Text = "<span class='cp-status cp-status-rejected'>Rejected</span>";
                                        break;
                                    default:
                                        litLicenseBadge.Text  = "<span class='cp-status cp-status-pending'>Pending</span>";
                                        litLicenseStatus.Text = "<span class='cp-status cp-status-pending'>Pending</span>";
                                        break;
                                }

                                // Pre-fill edit fields.
                                txtFullName.Text      = fullName;
                                txtQualification.Text = qualification;
                            }
                        }
                    }
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load profile. Please try again.");
            }
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { return; }

            int userID        = Convert.ToInt32(Session["UserID"]);
            string fullName   = txtFullName.Text.Trim();
            string qualification = txtQualification.Text.Trim();
            string cs         = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlTransaction tx = conn.BeginTransaction())
                    {
                        // Update Users.FullName.
                        using (SqlCommand cmd = new SqlCommand(
                            "UPDATE Users SET FullName=@Name WHERE UserID=@UID", conn, tx))
                        {
                            cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 100).Value = fullName;
                            cmd.Parameters.Add("@UID",  SqlDbType.Int).Value           = userID;
                            cmd.ExecuteNonQuery();
                        }

                        // Update Instructors.Qualification.
                        using (SqlCommand cmd = new SqlCommand(
                            "UPDATE Instructors SET Qualification=@Qual WHERE InstructorID=@UID", conn, tx))
                        {
                            cmd.Parameters.Add("@Qual", SqlDbType.NVarChar, 100).Value =
                                string.IsNullOrEmpty(qualification) ? (object)DBNull.Value : qualification;
                            cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                            cmd.ExecuteNonQuery();
                        }

                        tx.Commit();
                    }
                }

                // Refresh the session name so the topbar updates.
                Session["FullName"] = fullName;

                ShowSuccess("Profile updated successfully.");
                LoadProfile();
            }
            catch (SqlException)
            {
                ShowError("Could not save profile. Please try again.");
            }
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { return; }

            int userID          = Convert.ToInt32(Session["UserID"]);
            string currentPwd   = txtCurrentPassword.Text;
            string newPwd       = txtNewPassword.Text;
            string confirmPwd   = txtConfirmPassword.Text;

            if (newPwd != confirmPwd)
            {
                ShowError("New passwords do not match.");
                return;
            }

            if (newPwd.Length < 6)
            {
                ShowError("New password must be at least 6 characters.");
                return;
            }

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Verify current password.
                    using (SqlCommand chk = new SqlCommand(
                        "SELECT PasswordHash FROM Users WHERE UserID=@UID", conn))
                    {
                        chk.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        object stored = chk.ExecuteScalar();
                        if (stored == null || stored.ToString() != currentPwd)
                        {
                            ShowError("Current password is incorrect.");
                            return;
                        }
                    }

                    // Update password.
                    // NOTE: In production, hash the new password before storing.
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE Users SET PasswordHash=@Hash WHERE UserID=@UID", conn))
                    {
                        cmd.Parameters.Add("@Hash", SqlDbType.NVarChar, 256).Value = newPwd;
                        cmd.Parameters.Add("@UID",  SqlDbType.Int).Value           = userID;
                        cmd.ExecuteNonQuery();
                    }
                }

                txtCurrentPassword.Text = string.Empty;
                txtNewPassword.Text     = string.Empty;
                txtConfirmPassword.Text = string.Empty;

                ShowSuccess("Password changed successfully.");
            }
            catch (SqlException)
            {
                ShowError("Could not change password. Please try again.");
            }
        }

        private void ShowSuccess(string msg)
        {
            litSuccess.Text = HttpUtility.HtmlEncode(msg);
            pnlSuccess.Visible = true;
            pnlError.Visible   = false;
        }

        private void ShowError(string msg)
        {
            litError.Text = HttpUtility.HtmlEncode(msg);
            pnlError.Visible   = true;
            pnlSuccess.Visible = false;
        }
    }
}
