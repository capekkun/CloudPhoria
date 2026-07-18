using System;
using System.Configuration;
using System.Data;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria
{
    public partial class LogIn : System.Web.UI.Page
    {
        // -------------------------------------------------------
        // Page load – redirect already-authenticated users.
        // -------------------------------------------------------
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RedirectAuthenticatedUser();
            }
        }

        // -------------------------------------------------------
        // If a valid session already exists, send the user to
        // the appropriate dashboard without showing the login form.
        // -------------------------------------------------------
        private void RedirectAuthenticatedUser()
        {
            object sessionUserID = Session["UserID"];
            object sessionRole   = Session["Role"];

            if (sessionUserID == null || sessionRole == null) { return; }

            int userID;
            if (!int.TryParse(sessionUserID.ToString(), out userID) || userID <= 0) { return; }

            string role = sessionRole.ToString();
            RedirectByRole(role, null);
        }

        // -------------------------------------------------------
        // Login button click – validate, authenticate, redirect.
        // -------------------------------------------------------
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            // Web Forms validators run before the event handler.
            // If client validation was bypassed, stop here.
            if (!Page.IsValid) { return; }

            // Read and sanitise inputs.
            string email    = txtEmail.Text.Trim().ToLowerInvariant();
            string password = txtPassword.Text; // Do NOT trim passwords.

            // Server-side input checks (defensive — validators should catch these first).
            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                ShowError("Please enter your email and password.");
                return;
            }

            AuthenticateUser(email, password);
        }

        // -------------------------------------------------------
        // Query the Users table and verify credentials.
        // -------------------------------------------------------
        private void AuthenticateUser(string email, string password)
        {
            string connString = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            // Select only the columns needed for authentication.
            // Do NOT use SELECT *.
            string sql = @"SELECT UserID, FullName, PasswordHash, Role, IsActive, IsBanned
                           FROM   Users
                           WHERE  Email = @Email";

            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 100).Value = email;

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                // No account found – use a generic message to avoid
                                // revealing whether the email exists.
                                ShowError("Invalid email or password.");
                                return;
                            }

                            int    userID       = Convert.ToInt32(reader["UserID"]);
                            string fullName     = reader["FullName"].ToString();
                            string storedHash   = reader["PasswordHash"].ToString();
                            string role         = reader["Role"].ToString();
                            bool   isActive     = Convert.ToBoolean(reader["IsActive"]);
                            bool   isBanned     = Convert.ToBoolean(reader["IsBanned"]);

                            reader.Close();

                            // ---- Verify password ----
                            if (!VerifyPassword(password, storedHash))
                            {
                                ShowError("Invalid email or password.");
                                return;
                            }

                            // ---- Check account status ----
                            // Check banned first – a banned user should not be told their
                            // account is merely inactive.
                            if (isBanned)
                            {
                                ShowStatus("Your account has been restricted. Please contact the administrator.");
                                return;
                            }

                            if (!isActive)
                            {
                                ShowStatus("Your account is currently inactive. Please contact the administrator.");
                                return;
                            }

                            // ---- Validate role ----
                            if (role != "Student" && role != "Instructor" && role != "Admin")
                            {
                                ShowError("Your account role is not supported. Please contact the administrator.");
                                return;
                            }

                            // ---- Instructor licence check ----
                            if (role == "Instructor")
                            {
                                string licenseStatus = GetInstructorLicenseStatus(userID, conn);

                                if (licenseStatus == null)
                                {
                                    // Instructor record is missing – treat as restricted.
                                    ShowStatus("Your instructor account is not fully set up. Please contact the administrator.");
                                    return;
                                }

                                // Create session for all instructors so the Master Page
                                // can show the correct status in the sidebar.
                                CreateSession(userID, fullName, role);
                                Session["LicenseStatus"] = licenseStatus;

                                if (licenseStatus == "Approved")
                                {
                                    Response.Redirect("~/Instructor/Dashboard.aspx", true);
                                }
                                else if (licenseStatus == "Pending")
                                {
                                    // Pending instructors see the dashboard which will
                                    // show a restricted view via the Master Page.
                                    ShowStatus("Your instructor licence is pending approval. Some features are restricted until an administrator approves your account.");
                                    // Redirect to dashboard — the Master Page will show restricted nav.
                                    Response.Redirect("~/Instructor/Dashboard.aspx", true);
                                }
                                else if (licenseStatus == "Rejected")
                                {
                                    ShowStatus("Your instructor licence application was not approved. Please contact the administrator.");
                                    Response.Redirect("~/Instructor/Dashboard.aspx", true);
                                }
                                else
                                {
                                    // Unknown status — restrict.
                                    ShowStatus("Your instructor account status could not be determined. Please contact the administrator.");
                                }
                                return;
                            }

                            // ---- All other roles ----
                            CreateSession(userID, fullName, role);
                            RedirectByRole(role, null);
                        }
                    }
                }
            }
            catch (SqlException)
            {
                // Do not expose database error details to the user.
                ShowError("We could not sign you in at the moment. Please try again.");
            }
        }

        // -------------------------------------------------------
        // Read the LicenseStatus for the given instructor from DB.
        // Returns null if no Instructor record exists.
        // Reuses the existing open connection.
        // -------------------------------------------------------
        private string GetInstructorLicenseStatus(int instructorID, SqlConnection conn)
        {
            string sql = @"SELECT LicenseStatus
                           FROM   Instructors
                           WHERE  InstructorID = @InstructorID";

            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@InstructorID", SqlDbType.Int).Value = instructorID;
                object result = cmd.ExecuteScalar();

                if (result == null || result == DBNull.Value)
                {
                    return null;
                }

                return result.ToString();
            }
        }

        // -------------------------------------------------------
        // Verify the submitted password against the stored value.
        //
        // PASSWORD STORAGE NOTE:
        // The seed database stores plaintext 'password123' in the
        // PasswordHash column for demo purposes only.
        // New accounts should store SHA-256 hashes.
        //
        // This method attempts SHA-256 comparison first.
        // If that fails, it falls back to a plaintext comparison
        // so the seed demo accounts still work during development.
        //
        // BEFORE PRODUCTION: remove the plaintext fallback and
        // update all seed accounts to store SHA-256 hashes.
        // -------------------------------------------------------
        private bool VerifyPassword(string submittedPassword, string storedHash)
        {
            // First attempt: compare SHA-256 hash of submitted password.
            string submittedHash = ComputeSHA256(submittedPassword);
            if (string.Equals(submittedHash, storedHash, StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }

            // Development fallback: plaintext comparison for seed demo accounts.
            // TODO: Remove before production deployment.
            if (string.Equals(submittedPassword, storedHash, StringComparison.Ordinal))
            {
                return true;
            }

            return false;
        }

        // -------------------------------------------------------
        // Compute a SHA-256 hex string for the given plain text.
        // -------------------------------------------------------
        private string ComputeSHA256(string plainText)
        {
            using (SHA256 sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(plainText));
                StringBuilder sb = new StringBuilder(64);
                foreach (byte b in bytes)
                {
                    sb.Append(b.ToString("x2"));
                }
                return sb.ToString();
            }
        }

        // -------------------------------------------------------
        // Create the authenticated session.
        // Clear any previous session values first to prevent
        // session fixation.
        // -------------------------------------------------------
        private void CreateSession(int userID, string fullName, string role)
        {
            // Clear any previous session values to prevent session fixation.
            Session.Clear();
            Session.Abandon();

            Session["UserID"]   = userID;
            Session["Role"]     = role;
            Session["FullName"] = fullName;
        }

        // -------------------------------------------------------
        // Redirect to the dashboard matching the authenticated role.
        // -------------------------------------------------------
        private void RedirectByRole(string role, string returnUrl)
        {
            // Return URL is not currently implemented.
            // Placeholder for future safe return-URL handling.

            if (role == "Student")
            {
                Response.Redirect("~/Student/Dashboard.aspx", true);
            }
            else if (role == "Instructor")
            {
                Response.Redirect("~/Instructor/Dashboard.aspx", true);
            }
            else if (role == "Admin")
            {
                Response.Redirect("~/Admin/Dashboard.aspx", true);
            }
            // Unknown roles fall through silently – caller handles messaging.
        }

        // -------------------------------------------------------
        // Show a general error message (wrong credentials, etc.)
        // -------------------------------------------------------
        private void ShowError(string message)
        {
            litError.Text     = HttpUtility.HtmlEncode(message);
            pnlError.Visible  = true;
            pnlStatus.Visible = false;
        }

        // -------------------------------------------------------
        // Show an account-status message (inactive, pending, etc.)
        // -------------------------------------------------------
        private void ShowStatus(string message)
        {
            litStatus.Text    = HttpUtility.HtmlEncode(message);
            pnlStatus.Visible  = true;
            pnlError.Visible   = false;
        }
    }
}
