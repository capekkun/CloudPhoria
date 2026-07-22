using System;
using System.Configuration;
using System.Data;
<<<<<<< HEAD
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
=======
using System.Web;
using System.Web.UI;
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
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

<<<<<<< HEAD
            if (!IsPostBack)
            {
                LoadProfile();
            }
=======
            ((SiteMaster)Master).PageHeading = "Profile";

            if (!IsPostBack) LoadProfile();
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
        }

        private void LoadProfile()
        {
<<<<<<< HEAD
            int    userID = Convert.ToInt32(Session["UserID"]);
            string cs     = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
=======
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
<<<<<<< HEAD

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
=======
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT FullName, Email, CreatedAt FROM Users WHERE UserID=@UID", conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                string fullName = r["FullName"].ToString();
                                string email = r["Email"].ToString();
                                DateTime createdAt = Convert.ToDateTime(r["CreatedAt"]);

                                string[] parts = fullName.Trim().Split(' ');
                                string initials = parts.Length >= 2
                                    ? (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper()
                                    : fullName.Substring(0, Math.Min(2, fullName.Length)).ToUpper();

                                litInitials.Text = HttpUtility.HtmlEncode(initials);
                                litFullName.Text = HttpUtility.HtmlEncode(fullName);
                                litEmail.Text = HttpUtility.HtmlEncode(email);
                                litEmailReadonly.Text = "<span style='font-size:13px;color:var(--cp-text);'>" + HttpUtility.HtmlEncode(email) + "</span>";
                                litMemberSince.Text = createdAt.ToString("dd MMM yyyy");

                                txtFullName.Text = fullName;
                            }
                        }
                    }
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
                }
            }
            catch (SqlException)
            {
<<<<<<< HEAD
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
=======
                ShowError("Could not load profile.");
            }
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int userID = Convert.ToInt32(Session["UserID"]);
            string fullName = txtFullName.Text.Trim();
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
<<<<<<< HEAD

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
=======
                    using (SqlCommand cmd = new SqlCommand("UPDATE Users SET FullName=@Name WHERE UserID=@UID", conn))
                    {
                        cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 100).Value = fullName;
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        cmd.ExecuteNonQuery();
                    }
                }

                Session["FullName"] = fullName;
                ShowSuccess("Profile updated successfully.");
                LoadProfile();
            }
            catch (SqlException)
            {
                ShowError("Could not save profile.");
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
            }
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

<<<<<<< HEAD
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
=======
            int userID = Convert.ToInt32(Session["UserID"]);
            string currentPwd = txtCurrentPassword.Text;
            string newPwd = txtNewPassword.Text;
            string confirmPwd = txtConfirmPassword.Text;

            if (newPwd != confirmPwd) { ShowError("New passwords do not match."); return; }
            if (newPwd.Length < 6) { ShowError("New password must be at least 6 characters."); return; }

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
<<<<<<< HEAD

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
=======
                    using (SqlCommand chk = new SqlCommand("SELECT PasswordHash FROM Users WHERE UserID=@UID", conn))
                    {
                        chk.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        object stored = chk.ExecuteScalar();
                        if (stored == null || stored.ToString() != currentPwd)
                        {
                            ShowError("Current password is incorrect.");
                            return;
                        }
                    }
                    using (SqlCommand cmd = new SqlCommand("UPDATE Users SET PasswordHash=@Hash WHERE UserID=@UID", conn))
                    {
                        cmd.Parameters.Add("@Hash", SqlDbType.NVarChar, 256).Value = newPwd;
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        cmd.ExecuteNonQuery();
                    }
                }

                txtCurrentPassword.Text = ""; txtNewPassword.Text = ""; txtConfirmPassword.Text = "";
                ShowSuccess("Password changed successfully.");
            }
            catch (SqlException)
            {
                ShowError("Could not change password.");
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
