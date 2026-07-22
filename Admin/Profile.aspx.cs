using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
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

            ((SiteMaster)Master).PageHeading = "Profile";

            if (!IsPostBack) LoadProfile();
        }

        private void LoadProfile()
        {
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
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
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load profile.");
            }
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int userID = Convert.ToInt32(Session["UserID"]);
            string fullName = txtFullName.Text.Trim();
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
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
            }
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int userID = Convert.ToInt32(Session["UserID"]);
            string currentPwd = txtCurrentPassword.Text;
            string newPwd = txtNewPassword.Text;
            string confirmPwd = txtConfirmPassword.Text;

            if (newPwd != confirmPwd) { ShowError("New passwords do not match."); return; }
            if (newPwd.Length < 6) { ShowError("New password must be at least 6 characters."); return; }

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
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
        }
    }
}
