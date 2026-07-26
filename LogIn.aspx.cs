using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria
{
    public partial class LogIn : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RedirectAuthenticatedUser();
            }
        }

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

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            // Validators run client-side first, but check again in case JS was bypassed
            if (!Page.IsValid) { return; }

            string email    = txtEmail.Text.Trim().ToLowerInvariant();
            string password = txtPassword.Text; // don't trim - spaces can be part of a password

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                ShowError("Please enter your email and password.");
                return;
            }

            AuthenticateUser(email, password);
        }

        private void AuthenticateUser(string email, string password)
        {
            string connString = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

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
                                // Keep this message generic - don't reveal if the email exists
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

                            if (!VerifyPassword(password, storedHash))
                            {
                                ShowError("Invalid email or password.");
                                return;
                            }

                            // Check banned before inactive - a banned user shouldn't think
                            // their account is just inactive
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

                            if (role != "Student" && role != "Instructor" && role != "Admin")
                            {
                                ShowError("Your account role is not supported. Please contact the administrator.");
                                return;
                            }

                            if (role == "Instructor")
                            {
                                string licenseStatus = GetInstructorLicenseStatus(userID, conn);

                                if (licenseStatus == null)
                                {
                                    // No Instructors row for this user - treat as restricted
                                    ShowStatus("Your instructor account is not fully set up. Please contact the administrator.");
                                    return;
                                }

                                // Session is created regardless of license status so the
                                // Master Page can show the right restricted/approved nav
                                CreateSession(userID, fullName, role);
                                Session["LicenseStatus"] = licenseStatus;

                                if (licenseStatus == "Approved")
                                {
                                    Response.Redirect("~/Instructor/Dashboard.aspx", true);
                                }
                                else if (licenseStatus == "Pending")
                                {
                                    ShowStatus("Your instructor licence is pending approval. Some features are restricted until an administrator approves your account.");
                                    Response.Redirect("~/Instructor/Dashboard.aspx", true);
                                }
                                else if (licenseStatus == "Rejected")
                                {
                                    ShowStatus("Your instructor licence application was not approved. Please contact the administrator.");
                                    Response.Redirect("~/Instructor/Dashboard.aspx", true);
                                }
                                else
                                {
                                    ShowStatus("Your instructor account status could not be determined. Please contact the administrator.");
                                }
                                return;
                            }

                            CreateSession(userID, fullName, role);
                            RedirectByRole(role, null);
                        }
                    }
                }
            }
            catch (SqlException)
            {
                // Keep DB error details away from the user
                ShowError("We could not sign you in at the moment. Please try again.");
            }
        }

        // Returns null if no Instructor record exists for this user
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

        // Seed data stores plaintext 'password123' in PasswordHash for demo
        // accounts, so we try a hash match first, then fall back to plaintext.
        // TODO: re-hash the seed accounts and drop the plaintext fallback before prod.
        private bool VerifyPassword(string submittedPassword, string storedHash)
        {
            // Accounts made through Register.aspx are always hashed
            string submittedHash = Utils.ComputeSHA256(submittedPassword);
            if (string.Equals(submittedHash, storedHash, StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }

            // Only old seed accounts hit this path
            if (string.Equals(submittedPassword, storedHash, StringComparison.Ordinal))
            {
                return true;
            }

            return false;
        }

        private void CreateSession(int userID, string fullName, string role)
        {
            // Clear old session data first to avoid session fixation
            Session.Clear();

            Session["UserID"]   = userID;
            Session["Role"]     = role;
            Session["FullName"] = fullName;
        }

        private void RedirectByRole(string role, string returnUrl)
        {
            // returnUrl isn't wired up yet - reserved for future use

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
        }

        private void ShowError(string message)
        {
            litError.Text     = HttpUtility.HtmlEncode(message);
            pnlError.Visible  = true;
            pnlStatus.Visible = false;
        }

        private void ShowStatus(string message)
        {
            litStatus.Text    = HttpUtility.HtmlEncode(message);
            pnlStatus.Visible  = true;
            pnlError.Visible   = false;
        }
    }
}
