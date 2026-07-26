using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria
{
    public partial class Register : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] != null && Session["Role"] != null)
            {
                string role = Session["Role"].ToString();
                if (role == "Student") Response.Redirect("~/Student/Dashboard.aspx");
                else if (role == "Instructor") Response.Redirect("~/Instructor/Dashboard.aspx");
                else if (role == "Admin") Response.Redirect("~/Admin/Dashboard.aspx");
            }
        }

        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString; }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;
            string role = ddlRole.SelectedValue;

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                ShowError("Please fill in all required fields.");
                return;
            }

            // Re-check format server-side — client validators can be bypassed.
            if (!System.Text.RegularExpressions.Regex.IsMatch(fullName, @"^[A-Za-z]+([ '\-][A-Za-z]+)+$"))
            {
                ShowError("Please enter your full name (letters and spaces, at least 2 words).");
                return;
            }

            if (!System.Text.RegularExpressions.Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
            {
                ShowError("Please enter a valid email address.");
                return;
            }

            if (!System.Text.RegularExpressions.Regex.IsMatch(password, @"^(?=.*[A-Za-z])(?=.*\d).{6,}$"))
            {
                ShowError("Password must be at least 6 characters and include a letter and a number.");
                return;
            }

            if (role == "Instructor")
            {
                if (string.IsNullOrEmpty(txtQualification.Text.Trim()))
                {
                    ShowError("Qualification is required for instructor accounts.");
                    return;
                }
                if (string.IsNullOrEmpty(txtPermit.Text.Trim()))
                {
                    ShowError("Teaching permit description is required for instructor accounts.");
                    return;
                }
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM Users WHERE Email=@Email", conn))
                    {
                        cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 100).Value = email;
                        if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
                        {
                            ShowError("An account with this email already exists. Please sign in instead.");
                            return;
                        }
                    }

                    using (SqlTransaction tran = conn.BeginTransaction())
                    {
                        int userID;

                        using (SqlCommand cmd = new SqlCommand(
                            @"INSERT INTO Users (FullName, Email, PasswordHash, Role, IsActive, IsBanned, CreatedAt)
                              VALUES (@Name, @Email, @Pass, @Role, 1, 0, GETDATE());
                              SELECT SCOPE_IDENTITY();", conn, tran))
                        {
                            cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 100).Value = fullName;
                            cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 100).Value = email;
                            // Hash before saving - never store plaintext passwords
                            cmd.Parameters.Add("@Pass", SqlDbType.NVarChar, 256).Value = Utils.ComputeSHA256(password);
                            cmd.Parameters.Add("@Role", SqlDbType.NVarChar, 20).Value = role;
                            userID = Convert.ToInt32(cmd.ExecuteScalar());
                        }

                        if (role == "Student")
                        {
                            string tp = txtTPNumber.Text.Trim();
                            using (SqlCommand cmd = new SqlCommand(
                                @"INSERT INTO Students (StudentID, TPNumber, TotalXP)
                                  VALUES (@SID, @TP, 0);", conn, tran))
                            {
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = userID;
                                cmd.Parameters.Add("@TP", SqlDbType.NVarChar, 20).Value =
                                    string.IsNullOrEmpty(tp) ? (object)DBNull.Value : tp;
                                cmd.ExecuteNonQuery();
                            }

                            // New students start on the free plan (PlanID 1)
                            using (SqlCommand cmd = new SqlCommand(
                                @"INSERT INTO UserSubscriptions (StudentID, PlanID, StartDate, EndDate, IsActive)
                                  VALUES (@SID, 1, GETDATE(), NULL, 1)", conn, tran))
                            {
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = userID;
                                cmd.ExecuteNonQuery();
                            }

                            tran.Commit();

                            Session["UserID"] = userID;
                            Session["Role"] = "Student";
                            Session["FullName"] = fullName;
                            Response.Redirect("~/Student/Dashboard.aspx");
                        }
                        else if (role == "Instructor")
                        {
                            // New instructors need admin approval before they can teach
                            string qualification = txtQualification.Text.Trim();
                            using (SqlCommand cmd = new SqlCommand(
                                @"INSERT INTO Instructors (InstructorID, Qualification, LicenseStatus)
                                  VALUES (@IID, @Qual, 'Pending');", conn, tran))
                            {
                                cmd.Parameters.Add("@IID", SqlDbType.Int).Value = userID;
                                cmd.Parameters.Add("@Qual", SqlDbType.NVarChar, 200).Value = qualification;
                                cmd.ExecuteNonQuery();
                            }

                            // Notify every admin, not just one
                            using (SqlCommand cmd = new SqlCommand(
                                @"INSERT INTO Notifications (UserID, Message, NotificationType, IsRead, CreatedAt)
                                  SELECT AdminID, @Msg, 'InstructorPending', 0, GETDATE() FROM Admins", conn, tran))
                            {
                                cmd.Parameters.Add("@Msg", SqlDbType.NVarChar, 500).Value =
                                    "New instructor registration: " + fullName + " (" + email + ") is pending approval.";
                                cmd.ExecuteNonQuery();
                            }

                            tran.Commit();

                            // No auto-login here - account isn't usable until approved
                            pnlForm.Visible = false;
                            litSuccess.Text = "Your instructor account has been created! An admin will review your credentials and approve your account. " +
                                "You'll be able to sign in once approved. Check back soon!";
                            pnlSuccess.Visible = true;
                        }
                    }
                }
            }
            catch (SqlException)
            {
                // Do not expose database error details to the user.
                ShowError("Registration failed. Please try again.");
            }
        }

        private void ShowError(string msg)
        {
            litError.Text = HttpUtility.HtmlEncode(msg);
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
        }
    }
}
