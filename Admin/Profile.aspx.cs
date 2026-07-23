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
            { Response.Redirect("~/LogIn.aspx", true); return; }
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
                    string fullName = "", email = "";
                    DateTime joined = DateTime.MinValue;
                    using (SqlCommand cmd = new SqlCommand("SELECT FullName, Email, CreatedAt FROM Users WHERE UserID=@UID", conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read()) { fullName = rdr["FullName"].ToString(); email = rdr["Email"].ToString(); joined = Convert.ToDateTime(rdr["CreatedAt"]); }
                            else { Session.Abandon(); Response.Redirect("~/LogIn.aspx", true); return; }
                        }
                    }
                    litFullName.Text = HttpUtility.HtmlEncode(fullName);
                    litEmail.Text = HttpUtility.HtmlEncode(email);
                    litJoined.Text = joined.ToString("dd MMMM yyyy");
                    litInitials.Text = HttpUtility.HtmlEncode(GetInitials(fullName));
                    txtFullName.Text = fullName; txtEmail.Text = email;
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM AuditLogs WHERE PerformedByUserID=@UID", conn))
                    { cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID; litActionsCount.Text = cmd.ExecuteScalar().ToString(); }
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Instructors WHERE ApprovedBy=@UID AND LicenseStatus='Approved'", conn))
                    { cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID; litApprovedCount.Text = cmd.ExecuteScalar().ToString(); }
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Reports WHERE ReviewedByAdminID=@A", conn))
                    { cmd.Parameters.Add("@A", SqlDbType.Int).Value = userID; litReportsReviewed.Text = cmd.ExecuteScalar().ToString(); }
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM BossFightRooms WHERE CreatedByAdminID=@A", conn))
                    { cmd.Parameters.Add("@A", SqlDbType.Int).Value = userID; litBossCreated.Text = cmd.ExecuteScalar().ToString(); }
                }
            }
            catch (SqlException) { ShowMessage("Could not load profile.", false); }
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email)) { ShowMessage("Name and email are required.", false); return; }
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand c = new SqlCommand("SELECT COUNT(*) FROM Users WHERE Email=@E AND UserID<>@UID", conn))
                    { c.Parameters.Add("@E", SqlDbType.NVarChar, 100).Value = email; c.Parameters.Add("@UID", SqlDbType.Int).Value = userID; if (Convert.ToInt32(c.ExecuteScalar()) > 0) { ShowMessage("Email already in use.", false); return; } }
                    using (SqlCommand u = new SqlCommand("UPDATE Users SET FullName=@N, Email=@E WHERE UserID=@UID", conn))
                    { u.Parameters.Add("@N", SqlDbType.NVarChar, 100).Value = fullName; u.Parameters.Add("@E", SqlDbType.NVarChar, 100).Value = email; u.Parameters.Add("@UID", SqlDbType.Int).Value = userID; u.ExecuteNonQuery(); }
                    Session["FullName"] = fullName;
                    ShowMessage("Profile updated.", true); LoadProfile();
                }
            }
            catch (SqlException) { ShowMessage("Could not update profile.", false); }
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            string currentPwd = txtCurrentPwd.Text, newPwd = txtNewPwd.Text, confirmPwd = txtConfirmPwd.Text;
            if (newPwd.Length < 8) { ShowMessage("New password must be at least 8 characters.", false); return; }
            if (newPwd != confirmPwd) { ShowMessage("Passwords do not match.", false); return; }
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    string storedHash = "";
                    using (SqlCommand s = new SqlCommand("SELECT PasswordHash FROM Users WHERE UserID=@UID", conn))
                    { s.Parameters.Add("@UID", SqlDbType.Int).Value = userID; object r = s.ExecuteScalar(); if (r == null) { ShowMessage("Account not found.", false); return; } storedHash = r.ToString(); }
                    if (!VerifyPassword(currentPwd, storedHash)) { ShowMessage("Current password is incorrect.", false); return; }
                    string newHash = HashPassword(newPwd);
                    using (SqlCommand u = new SqlCommand("UPDATE Users SET PasswordHash=@H WHERE UserID=@UID", conn))
                    { u.Parameters.Add("@H", SqlDbType.NVarChar, 256).Value = newHash; u.Parameters.Add("@UID", SqlDbType.Int).Value = userID; u.ExecuteNonQuery(); }
                    txtCurrentPwd.Text = ""; txtNewPwd.Text = ""; txtConfirmPwd.Text = "";
                    ShowMessage("Password changed.", true);
                }
            }
            catch (SqlException) { ShowMessage("Could not change password.", false); }
        }

        private bool VerifyPassword(string submitted, string stored)
        {
            if (string.IsNullOrEmpty(stored)) return false;
            if (stored.Length == 64) return string.Equals(HashPassword(submitted), stored, StringComparison.OrdinalIgnoreCase);
            return submitted == stored;
        }

        private string HashPassword(string password)
        {
            using (SHA256 sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder sb = new StringBuilder();
                foreach (byte b in bytes) sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }

        private string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "?";
            string[] parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Length >= 2 ? parts[0].Substring(0, 2).ToUpper() : parts[0][0].ToString().ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }

        private void ShowMessage(string message, bool success)
        {
            string cssClass = success ? "cp-alert cp-alert-success" : "cp-alert cp-alert-danger";
            litMessage.Text = $"<div class='{cssClass}'>{HttpUtility.HtmlEncode(message)}</div>";
            pnlMessage.Visible = true;
        }
    }
}
