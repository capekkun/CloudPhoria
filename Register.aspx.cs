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
            // If already logged in, redirect to dashboard
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

            // Basic validation
            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                ShowError("Please fill in all required fields.");
                return;
            }

            if (password.Length < 6)
            {
                ShowError("Password must be at least 6 characters.");
                return;
            }

            // Instructor validation
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

                    // Check if email already exists
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

                        // Insert into Users
                        using (SqlCommand cmd = new SqlCommand(
                            @"INSERT INTO Users (FullName, Email, PasswordHash, Role, IsActive, IsBanned, CreatedAt)
                              VALUES (@Name, @Email, @Pass, @Role, 1, 0, GETDATE());
                              SELECT SCOPE_IDENTITY();", conn, tran))
                        {
                            cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 100).Value = fullName;
                            cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 100).Value = email;
                            cmd.Parameters.Add("@Pass", SqlDbType.NVarChar, 256).Value = password; // Demo only — use hash in production
                            cmd.Parameters.Add("@Role", SqlDbType.NVarChar, 20).Value = role;
                            userID = Convert.ToInt32(cmd.ExecuteScalar());
                        }

                        if (role == "Student")
                        {
                            // Insert into Students
                            string tp = txtTPNumber.Text.Trim();
                            using (SqlCommand cmd = new SqlCommand(
                                @"SET IDENTITY_INSERT Students ON;
                                  INSERT INTO Students (StudentID, TPNumber, TotalXP)
                                  VALUES (@SID, @TP, 0);
                                  SET IDENTITY_INSERT Students OFF;", conn, tran))
                            {
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = userID;
                                cmd.Parameters.Add("@TP", SqlDbType.NVarChar, 20).Value =
                                    string.IsNullOrEmpty(tp) ? (object)DBNull.Value : tp;
                                cmd.ExecuteNonQuery();
                            }

                            // Give Free subscription
                            using (SqlCommand cmd = new SqlCommand(
                                @"INSERT INTO UserSubscriptions (StudentID, PlanID, StartDate, EndDate, IsActive)
                                  VALUES (@SID, 1, GETDATE(), NULL, 1)", conn, tran))
                            {
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = userID;
                                cmd.ExecuteNonQuery();
                            }

                            tran.Commit();

                            // Auto-login
                            Session["UserID"] = userID;
                            Session["Role"] = "Student";
                            Session["FullName"] = fullName;
                            Response.Redirect("~/Student/Dashboard.aspx");
                        }
                        else if (role == "Instructor")
                        {
                            // Insert into Instructors with Pending status
                            string qualification = txtQualification.Text.Trim();
                            using (SqlCommand cmd = new SqlCommand(
                                @"SET IDENTITY_INSERT Instructors ON;
                                  INSERT INTO Instructors (InstructorID, Qualification, LicenseStatus)
                                  VALUES (@IID, @Qual, 'Pending');
                                  SET IDENTITY_INSERT Instructors OFF;", conn, tran))
                            {
                                cmd.Parameters.Add("@IID", SqlDbType.Int).Value = userID;
                                cmd.Parameters.Add("@Qual", SqlDbType.NVarChar, 200).Value = qualification;
                                cmd.ExecuteNonQuery();
                            }

                            // Create notification for admin
                            using (SqlCommand cmd = new SqlCommand(
                                @"INSERT INTO Notifications (UserID, Message, NotificationType, IsRead, CreatedAt)
                                  SELECT AdminID, @Msg, 'InstructorPending', 0, GETDATE() FROM Admins", conn, tran))
                            {
                                cmd.Parameters.Add("@Msg", SqlDbType.NVarChar, 500).Value =
                                    "New instructor registration: " + fullName + " (" + email + ") is pending approval.";
                                cmd.ExecuteNonQuery();
                            }

                            tran.Commit();

                            // Show success but don't auto-login (needs approval)
                            pnlForm.Visible = false;
                            litSuccess.Text = "Your instructor account has been created! An admin will review your credentials and approve your account. " +
                                "You'll be able to sign in once approved. Check back soon!";
                            pnlSuccess.Visible = true;
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                ShowError("Registration failed. Please try again. (" + ex.Message + ")");
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
