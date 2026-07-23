using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Admin
{
    public partial class Users : System.Web.UI.Page
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
                LoadUsers("", "", "");
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadUsers(txtSearch.Text.Trim(), ddlRole.SelectedValue, ddlStatus.SelectedValue);
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text          = "";
            ddlRole.SelectedValue   = "";
            ddlStatus.SelectedValue = "";
            LoadUsers("", "", "");
        }

        private void LoadUsers(string search, string role, string status)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    string sql = @"
                        SELECT u.UserID, u.FullName, u.Email, u.Role,
                               u.IsActive, u.IsBanned, u.CreatedAt
                        FROM Users u
                        WHERE (@Search = '' OR u.FullName LIKE '%' + @Search + '%' OR u.Email LIKE '%' + @Search + '%')
                          AND (@Role   = '' OR u.Role = @Role)
                          AND (@Status = ''
                               OR (@Status = 'banned'   AND u.IsBanned = 1)
                               OR (@Status = 'active'   AND u.IsActive = 1 AND u.IsBanned = 0)
                               OR (@Status = 'inactive' AND u.IsActive = 0 AND u.IsBanned = 0))
                        ORDER BY u.CreatedAt DESC";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@Search", SqlDbType.NVarChar, 100).Value = search ?? "";
                        cmd.Parameters.Add("@Role",   SqlDbType.NVarChar, 20).Value  = role   ?? "";
                        cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 20).Value  = status ?? "";
                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                        litResultCount.Text = dt.Rows.Count.ToString();
                        if (dt.Rows.Count > 0) { rptUsers.DataSource = dt; rptUsers.DataBind(); pnlUsers.Visible = true; pnlNoUsers.Visible = false; }
                        else { pnlUsers.Visible = false; pnlNoUsers.Visible = true; }
                    }
                }
            }
            catch (SqlException) { ShowMessage("Could not load users.", false); }
        }

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument.ToString(), out int targetUserID)) { ShowMessage("Invalid user ID.", false); return; }
            int currentAdminID = Convert.ToInt32(Session["UserID"]);
            if (targetUserID == currentAdminID) { ShowMessage("You cannot modify your own account.", false); LoadUsers(txtSearch.Text.Trim(), ddlRole.SelectedValue, ddlStatus.SelectedValue); return; }
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    string targetRole = "";
                    using (SqlCommand v = new SqlCommand("SELECT Role FROM Users WHERE UserID = @UID", conn))
                    { v.Parameters.Add("@UID", SqlDbType.Int).Value = targetUserID; object r = v.ExecuteScalar(); if (r == null) { ShowMessage("User not found.", false); return; } targetRole = r.ToString(); }

                    string updateSQL = "", actionType = "";
                    switch (e.CommandName)
                    {
                        case "Ban":        updateSQL = "UPDATE Users SET IsBanned = 1 WHERE UserID = @UID"; actionType = "BAN_USER"; break;
                        case "Unban":      updateSQL = "UPDATE Users SET IsBanned = 0 WHERE UserID = @UID"; actionType = "UNBAN_USER"; break;
                        case "Deactivate": updateSQL = "UPDATE Users SET IsActive = 0 WHERE UserID = @UID"; actionType = "DEACTIVATE_USER"; break;
                        case "Activate":   updateSQL = "UPDATE Users SET IsActive = 1 WHERE UserID = @UID"; actionType = "ACTIVATE_USER"; break;
                        default: ShowMessage("Unknown action.", false); return;
                    }
                    using (SqlTransaction tx = conn.BeginTransaction())
                    {
                        try
                        {
                            using (SqlCommand u = new SqlCommand(updateSQL, conn, tx)) { u.Parameters.Add("@UID", SqlDbType.Int).Value = targetUserID; u.ExecuteNonQuery(); }
                            using (SqlCommand a = new SqlCommand("INSERT INTO AuditLogs (PerformedByUserID,ActionType,TargetTable,TargetID,Details,CreatedAt) VALUES (@A,@AT,'Users',@T,@D,GETDATE())", conn, tx))
                            { a.Parameters.Add("@A", SqlDbType.Int).Value = currentAdminID; a.Parameters.Add("@AT", SqlDbType.NVarChar, 100).Value = actionType; a.Parameters.Add("@T", SqlDbType.Int).Value = targetUserID; a.Parameters.Add("@D", SqlDbType.NVarChar, -1).Value = $"Admin {currentAdminID} {actionType} on UserID {targetUserID} ({targetRole})."; a.ExecuteNonQuery(); }
                            tx.Commit(); ShowMessage("Action applied.", true);
                        }
                        catch { tx.Rollback(); throw; }
                    }
                }
            }
            catch (SqlException) { ShowMessage("Could not complete action.", false); }
            LoadUsers(txtSearch.Text.Trim(), ddlRole.SelectedValue, ddlStatus.SelectedValue);
        }

        protected string GetRoleBadge(string role)
        {
            switch (role) { case "Admin": return "<span class='cp-badge cp-badge-red'>Admin</span>"; case "Instructor": return "<span class='cp-badge cp-badge-indigo'>Instructor</span>"; default: return "<span class='cp-badge cp-badge-blue'>Student</span>"; }
        }

        protected string GetStatusBadge(bool isActive, bool isBanned)
        {
            if (isBanned) return "<span class='cp-badge cp-badge-red'>Banned</span>";
            if (!isActive) return "<span class='cp-badge cp-badge-grey'>Inactive</span>";
            return "<span class='cp-badge cp-badge-green'>Active</span>";
        }

        protected bool IsSelf(object userIDObj)
        {
            if (Session["UserID"] == null) return false;
            if (!int.TryParse(userIDObj.ToString(), out int uid)) return false;
            return uid == Convert.ToInt32(Session["UserID"]);
        }

        private void ShowMessage(string message, bool success)
        {
            string cssClass = success ? "cp-alert cp-alert-success" : "cp-alert cp-alert-danger";
            litMessage.Text = $"<div class='{cssClass}'>{HttpUtility.HtmlEncode(message)}</div>";
            pnlMessage.Visible = true;
        }
    }
}
