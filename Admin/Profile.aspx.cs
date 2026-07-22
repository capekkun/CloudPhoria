using System;
using System.Configuration;
using System.Data;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Admin
{
    public partial class Profile : System.Web.UI.Page
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
                LoadProfile();
            }
        }

        private void LoadProfile()
        {
            int    userID = Convert.ToInt32(Session["UserID"]);
            string cs     = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Load user details.
                    string userSQL = "SELECT FullName, Email, CreatedAt FROM Users WHERE UserID = @UID";
                    string fullName = "";
                    string email    = "";
                    DateTime joined = DateTime.MinValue;

                    using (SqlCommand cmd = new SqlCommand(userSQL, conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                fullName = rdr["FullName"].ToString();
                                email    = rdr["Email"].ToString();
                                joined   = Convert.ToDateTime(rdr["CreatedAt"]);
                            }
                            else
                            {
                                // Session is stale — force logout.
                                Session.Abandon();
                                Response.Redirect("~/LogIn.aspx", true);
                                return;
                            }
                        }
                    }

                    litFullName.Text = HttpUtility.HtmlEncode(fullName);
                    litEmail.Text    = HttpUtility.HtmlEncode(email);
                    litJoined.Text   = joined.ToString("dd MMMM yyyy");
                    litInitials.Text = HttpUtility.HtmlEncode(GetInitials(fullName));

                    // Pre-fill edit form.
                    txtFullName.Text = fullName;
                    txtEmail.Text    = email;

                    // Load activity stats.
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM AuditLogs WHERE PerformedByUserID = @UID", conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        litActionsCount.Text = cmd.ExecuteScalar().ToString();
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM Instructors WHERE ApprovedBy = @UID AND LicenseStatus = 'Approved'", conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        litApprovedCount.Text = cmd.ExecuteScalar().ToString();
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM Reports WHERE ReviewedByAdminID = @AdminID", conn))
                    {
                        cmd.Parameters.Add("@AdminID", SqlDbType.Int).Value = userID;
                        litReportsReviewed.Text = cmd.ExecuteScalar().ToString();
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM BossFightRooms WHERE CreatedByAdminID = @AdminID", conn))
                    {
                        cmd.Parameters.Add("@AdminID", SqlDbType.Int).Value = userID;
                        litBossCreated.Text = cmd.ExecuteScalar().ToString();
                    }
                }
            }
            catch (SqlException)
            {
                ShowMessage("Could not load profile. Please try again.", false);
            }
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string fullName = txtFullName.Text.Trim();
            string email    = txtEmail.Text.Trim().ToLower();

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email))
            {
                ShowMessage("Name and email are required.", false);
                return;
            }

            int    userID = Convert.ToInt32(Session["UserID"]);
            string cs     = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Check the email is not already taken by another user.
                    string emailCheckSQL = "SELECT COUNT(*) FROM Users WHERE Email = @Email AND UserID <> @UID";
                    using (SqlCommand checkCmd = new SqlCommand(emailCheckSQL, conn))
                    {
                        checkCmd.Parameters.Add("@Email", SqlDbType.NVarChar, 100).Value = email;
                        checkCmd.Parameters.Add("@UID",   SqlDbType.Int).Value           = userID;
                        int conflict = Convert.ToInt32(checkCmd.ExecuteScalar());
                        if (conflict > 0)
                        {
                            ShowMessage("That email address is already in use by another account.", false);
                            return;
                        }
                    }

                    string updateSQL = "UPDATE Users SET FullName = @Name, Email = @Email WHERE UserID = @UID";
                    using (SqlCommand cmd = new SqlCommand(updateSQL, conn))
                    {
                        cmd.Parameters.Add("@Name",  SqlDbType.NVarChar, 100).Value = fullName;
                        cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 100).Value = email;
                        cmd.Parameters.Add("@UID",   SqlDbType.Int).Value           = userID;
                        cmd.ExecuteNonQuery();
                    }

                    // Update session so the Master Page reflects the new name immediately.
                    Session["FullName"] = fullName;

                    ShowMessage("Profile updated successfully.", true);
                    LoadProfile();
                }
            }
            catch (SqlException)
            {
                ShowMessage("Could not update profile. Please try again.", false);
            }
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string currentPwd = txtCurrentPwd.Text;
            string newPwd     = txtNewPwd.Text;
            string confirmPwd = txtConfirmPwd.Text;

            if (newPwd.Length < 8)
            {
                ShowMessage("New password must be at least 8 characters.", false);
                return;
            }

            if (newPwd != confirmPwd)
            {
                ShowMessage("New passwords do not match.", false);
                return;
            }

            int    userID = Convert.ToInt32(Session["UserID"]);
            string cs     = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Retrieve the stored hash for comparison.
                    string selectSQL = "SELECT PasswordHash FROM Users WHERE UserID = @UID";
                    string storedHash = "";
                    using (SqlCommand selectCmd = new SqlCommand(selectSQL, conn))
                    {
                        selectCmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        object r = selectCmd.ExecuteScalar();
                        if (r == null || r == DBNull.Value)
                        {
                            ShowMessage("Account not found.", false);
                            return;
                        }
                        storedHash = r.ToString();
                    }

                    // Verify the current password against what is stored.
                    // The sample data stores plaintext; production should use bcrypt/PBKDF2.
                    // This check supports both: if the stored value looks like a hash use hash compare,
                    // otherwise fall back to plaintext compare for demo data.
                    bool currentMatches = VerifyPassword(currentPwd, storedHash);
                    if (!currentMatches)
                    {
                        ShowMessage("Current password is incorrect.", false);
                        return;
                    }

                    // Hash the new password before storing.
                    string newHash = HashPassword(newPwd);

                    string updateSQL = "UPDATE Users SET PasswordHash = @Hash WHERE UserID = @UID";
                    using (SqlCommand updateCmd = new SqlCommand(updateSQL, conn))
                    {
                        updateCmd.Parameters.Add("@Hash", SqlDbType.NVarChar, 256).Value = newHash;
                        updateCmd.Parameters.Add("@UID",  SqlDbType.Int).Value           = userID;
                        updateCmd.ExecuteNonQuery();
                    }

                    // Clear the password fields after success.
                    txtCurrentPwd.Text = "";
                    txtNewPwd.Text     = "";
                    txtConfirmPwd.Text = "";

                    ShowMessage("Password changed successfully.", true);
                }
            }
            catch (SqlException)
            {
                ShowMessage("Could not change password. Please try again.", false);
            }
        }

        // Simple password verification: compare plaintext (demo data) or SHA-256 hash.
        // Replace with bcrypt in production for proper security.
        private bool VerifyPassword(string submitted, string stored)
        {
            if (string.IsNullOrEmpty(stored)) return false;

            // If the stored value is a SHA-256 hex string (64 chars), compare hashes.
            if (stored.Length == 64)
                return string.Equals(HashPassword(submitted), stored, StringComparison.OrdinalIgnoreCase);

            // Otherwise compare as plaintext (demo data only).
            return submitted == stored;
        }

        private string HashPassword(string password)
        {
            using (SHA256 sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder sb = new StringBuilder();
                foreach (byte b in bytes)
                    sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }

        private string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "?";
            string[] parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1)
                return parts[0].Length >= 2 ? parts[0].Substring(0, 2).ToUpper() : parts[0][0].ToString().ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }

        private void ShowMessage(string message, bool success)
        {
            string cssClass    = success ? "cp-alert cp-alert-success" : "cp-alert cp-alert-danger";
            litMessage.Text    = $"<div class='{cssClass}'>{HttpUtility.HtmlEncode(message)}</div>";
            pnlMessage.Visible = true;
        }
    }
}
