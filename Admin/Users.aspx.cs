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
<<<<<<< HEAD
=======
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString; }
        }

        private int AdminID
        {
            get { return Convert.ToInt32(Session["UserID"]); }
        }

>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
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
                LoadUsers("", "", "");
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadUsers(txtSearch.Text.Trim(), ddlRole.SelectedValue, ddlStatus.SelectedValue);
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text        = "";
            ddlRole.SelectedValue = "";
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
                        WHERE (@Search = ''
                               OR u.FullName LIKE '%' + @Search + '%'
                               OR u.Email    LIKE '%' + @Search + '%')
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
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                            da.Fill(dt);

                        litResultCount.Text = dt.Rows.Count.ToString();

                        if (dt.Rows.Count > 0)
                        {
                            rptUsers.DataSource = dt;
                            rptUsers.DataBind();
                            pnlUsers.Visible   = true;
                            pnlNoUsers.Visible = false;
                        }
                        else
                        {
                            pnlUsers.Visible   = false;
                            pnlNoUsers.Visible = true;
                        }
                    }
=======
            ((SiteMaster)Master).PageHeading = "Manage Users";

            if (!IsPostBack) LoadUsers();
        }

        private void LoadUsers()
        {
            string search = txtSearch.Text.Trim();
            string roleFilter = ddlRoleFilter.SelectedValue;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    string sql = @"SELECT UserID, FullName, Email, Role, IsActive, IsBanned, CreatedAt
                                    FROM Users
                                    WHERE (@Search = '' OR FullName LIKE '%' + @Search + '%' OR Email LIKE '%' + @Search + '%')
                                      AND (@Role = '' OR Role = @Role)
                                    ORDER BY CreatedAt DESC";
                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@Search", SqlDbType.NVarChar, 100).Value = search;
                        cmd.Parameters.Add("@Role", SqlDbType.NVarChar, 20).Value = roleFilter;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }

                    rptUsers.DataSource = dt;
                    rptUsers.DataBind();
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
                }
            }
            catch (SqlException)
            {
<<<<<<< HEAD
                ShowMessage("Could not load users. Please try again.", false);
            }
        }

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument.ToString(), out int targetUserID) || targetUserID <= 0)
            {
                ShowMessage("Invalid user ID.", false);
                return;
            }

            int currentAdminID = Convert.ToInt32(Session["UserID"]);

            // Prevent admin from modifying their own account through this page.
            if (targetUserID == currentAdminID)
            {
                ShowMessage("You cannot modify your own account status here.", false);
                LoadUsers(txtSearch.Text.Trim(), ddlRole.SelectedValue, ddlStatus.SelectedValue);
                return;
            }

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Verify the target user exists and get their role for audit logging.
                    string targetRole = "";
                    string verifySQL  = "SELECT Role FROM Users WHERE UserID = @UID";
                    using (SqlCommand verifyCmd = new SqlCommand(verifySQL, conn))
                    {
                        verifyCmd.Parameters.Add("@UID", SqlDbType.Int).Value = targetUserID;
                        object result = verifyCmd.ExecuteScalar();
                        if (result == null || result == DBNull.Value)
                        {
                            ShowMessage("User not found.", false);
                            LoadUsers(txtSearch.Text.Trim(), ddlRole.SelectedValue, ddlStatus.SelectedValue);
                            return;
                        }
                        targetRole = result.ToString();
                    }

                    string updateSQL  = "";
                    string actionType = "";

                    switch (e.CommandName)
                    {
                        case "Ban":
                            updateSQL  = "UPDATE Users SET IsBanned = 1 WHERE UserID = @UID";
                            actionType = "BAN_USER";
                            break;
                        case "Unban":
                            updateSQL  = "UPDATE Users SET IsBanned = 0 WHERE UserID = @UID";
                            actionType = "UNBAN_USER";
                            break;
                        case "Deactivate":
                            updateSQL  = "UPDATE Users SET IsActive = 0 WHERE UserID = @UID";
                            actionType = "DEACTIVATE_USER";
                            break;
                        case "Activate":
                            updateSQL  = "UPDATE Users SET IsActive = 1 WHERE UserID = @UID";
                            actionType = "ACTIVATE_USER";
                            break;
                        default:
                            ShowMessage("Unknown action.", false);
                            LoadUsers(txtSearch.Text.Trim(), ddlRole.SelectedValue, ddlStatus.SelectedValue);
                            return;
                    }

                    // Apply status change and write audit log in one transaction.
                    using (SqlTransaction tx = conn.BeginTransaction())
                    {
                        try
                        {
                            using (SqlCommand updateCmd = new SqlCommand(updateSQL, conn, tx))
                            {
                                updateCmd.Parameters.Add("@UID", SqlDbType.Int).Value = targetUserID;
                                updateCmd.ExecuteNonQuery();
                            }

                            string auditSQL = @"
                                INSERT INTO AuditLogs
                                    (PerformedByUserID, ActionType, TargetTable, TargetID, Details, CreatedAt)
                                VALUES
                                    (@AdminID, @ActionType, 'Users', @TargetID, @Details, GETDATE())";

                            using (SqlCommand auditCmd = new SqlCommand(auditSQL, conn, tx))
                            {
                                auditCmd.Parameters.Add("@AdminID",    SqlDbType.Int).Value           = currentAdminID;
                                auditCmd.Parameters.Add("@ActionType", SqlDbType.NVarChar, 100).Value = actionType;
                                auditCmd.Parameters.Add("@TargetID",   SqlDbType.Int).Value           = targetUserID;
                                auditCmd.Parameters.Add("@Details",    SqlDbType.NVarChar, -1).Value  =
                                    $"Admin UserID {currentAdminID} performed {actionType} on UserID {targetUserID} (Role: {targetRole}).";
                                auditCmd.ExecuteNonQuery();
                            }

                            tx.Commit();
                            ShowMessage("Action applied successfully.", true);
                        }
                        catch
                        {
                            tx.Rollback();
                            throw;
                        }
                    }
                }
            }
            catch (SqlException)
            {
                ShowMessage("Could not complete the action. Please try again.", false);
            }

            LoadUsers(txtSearch.Text.Trim(), ddlRole.SelectedValue, ddlStatus.SelectedValue);
        }

        // Called from markup data-binding expressions.
        protected string GetRoleBadge(string role)
        {
            switch (role)
            {
                case "Admin":
                    return "<span class='cp-badge cp-badge-red'>Admin</span>";
                case "Instructor":
                    return "<span class='cp-badge cp-badge-indigo'>Instructor</span>";
                default:
                    return "<span class='cp-badge cp-badge-blue'>Student</span>";
            }
        }

        protected string GetStatusBadge(bool isActive, bool isBanned)
        {
            if (isBanned)  return "<span class='cp-badge cp-badge-red'>Banned</span>";
            if (!isActive) return "<span class='cp-badge cp-badge-grey'>Inactive</span>";
            return "<span class='cp-badge cp-badge-green'>Active</span>";
        }

        // Returns true when the bound UserID is the currently logged-in admin.
        // Used in Visible binding expressions on the action LinkButtons.
        protected bool IsSelf(object userIDObj)
        {
            if (Session["UserID"] == null) return false;
            if (!int.TryParse(userIDObj.ToString(), out int uid)) return false;
            return uid == Convert.ToInt32(Session["UserID"]);
        }

        private void ShowMessage(string message, bool success)
        {
            string cssClass = success ? "cp-alert cp-alert-success" : "cp-alert cp-alert-danger";
            litMessage.Text    = $"<div class='{cssClass}'>{HttpUtility.HtmlEncode(message)}</div>";
            pnlMessage.Visible = true;
=======
                ShowError("Could not load users.");
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e) { LoadUsers(); }
        protected void ddlRoleFilter_Changed(object sender, EventArgs e) { LoadUsers(); }

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int userID = Convert.ToInt32(e.CommandArgument);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    if (e.CommandName == "ToggleBan")
                    {
                        bool currentlyBanned;
                        using (SqlCommand cmd = new SqlCommand("SELECT IsBanned FROM Users WHERE UserID=@UID", conn))
                        {
                            cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                            currentlyBanned = Convert.ToBoolean(cmd.ExecuteScalar());
                        }
                        using (SqlCommand cmd = new SqlCommand("UPDATE Users SET IsBanned=@Val WHERE UserID=@UID", conn))
                        {
                            cmd.Parameters.Add("@Val", SqlDbType.Bit).Value = !currentlyBanned;
                            cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                            cmd.ExecuteNonQuery();
                        }
                        LogAction(conn, currentlyBanned ? "UNBAN_USER" : "BAN_USER", "Users", userID);
                        ShowSuccess(currentlyBanned ? "User unbanned." : "User banned.");
                    }
                    else if (e.CommandName == "ToggleActive")
                    {
                        bool currentlyActive;
                        using (SqlCommand cmd = new SqlCommand("SELECT IsActive FROM Users WHERE UserID=@UID", conn))
                        {
                            cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                            currentlyActive = Convert.ToBoolean(cmd.ExecuteScalar());
                        }
                        using (SqlCommand cmd = new SqlCommand("UPDATE Users SET IsActive=@Val WHERE UserID=@UID", conn))
                        {
                            cmd.Parameters.Add("@Val", SqlDbType.Bit).Value = !currentlyActive;
                            cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                            cmd.ExecuteNonQuery();
                        }
                        LogAction(conn, currentlyActive ? "DEACTIVATE_USER" : "ACTIVATE_USER", "Users", userID);
                        ShowSuccess(currentlyActive ? "User deactivated." : "User activated.");
                    }
                    else if (e.CommandName == "DeleteUser")
                    {
                        if (userID == AdminID)
                        {
                            ShowError("You cannot delete your own account.");
                            return;
                        }
                        using (SqlCommand cmd = new SqlCommand("DELETE FROM Users WHERE UserID=@UID", conn))
                        {
                            cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                            cmd.ExecuteNonQuery();
                        }
                        LogAction(conn, "DELETE_USER", "Users", userID);
                        ShowSuccess("User deleted.");
                    }
                }
                LoadUsers();
            }
            catch (SqlException)
            {
                ShowError("Could not update user. This user may have related records that must be removed first.");
            }
        }

        protected void btnCreateUser_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string role = ddlNewUserRole.SelectedValue;
            string name = txtNewUserName.Text.Trim();
            string email = txtNewUserEmail.Text.Trim();
            string password = txtNewUserPassword.Text;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (SqlCommand chk = new SqlCommand("SELECT COUNT(*) FROM Users WHERE Email=@Email", conn))
                    {
                        chk.Parameters.Add("@Email", SqlDbType.NVarChar, 100).Value = email;
                        if (Convert.ToInt32(chk.ExecuteScalar()) > 0)
                        {
                            ShowError("A user with this email already exists.");
                            return;
                        }
                    }

                    using (SqlTransaction tran = conn.BeginTransaction())
                    {
                        int newUserID;
                        using (SqlCommand cmd = new SqlCommand(
                            @"INSERT INTO Users (FullName, Email, PasswordHash, Role, IsActive, IsBanned, CreatedAt)
                              VALUES (@Name, @Email, @Pass, @Role, 1, 0, GETDATE());
                              SELECT SCOPE_IDENTITY();", conn, tran))
                        {
                            cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 100).Value = name;
                            cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 100).Value = email;
                            cmd.Parameters.Add("@Pass", SqlDbType.NVarChar, 256).Value = password;
                            cmd.Parameters.Add("@Role", SqlDbType.NVarChar, 20).Value = role;
                            newUserID = Convert.ToInt32(cmd.ExecuteScalar());
                        }

                        if (role == "Student")
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                @"SET IDENTITY_INSERT Students ON;
                                  INSERT INTO Students (StudentID, TPNumber, TotalXP) VALUES (@SID, @TP, 0);
                                  SET IDENTITY_INSERT Students OFF;", conn, tran))
                            {
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = newUserID;
                                cmd.Parameters.Add("@TP", SqlDbType.NVarChar, 20).Value = "TP" + newUserID.ToString("D6");
                                cmd.ExecuteNonQuery();
                            }
                            using (SqlCommand cmd = new SqlCommand(
                                "INSERT INTO UserSubscriptions (StudentID, PlanID, StartDate, EndDate, IsActive) VALUES (@SID, 1, GETDATE(), NULL, 1)", conn, tran))
                            {
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = newUserID;
                                cmd.ExecuteNonQuery();
                            }
                        }
                        else if (role == "Instructor")
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                @"SET IDENTITY_INSERT Instructors ON;
                                  INSERT INTO Instructors (InstructorID, LicenseStatus) VALUES (@IID, 'Approved');
                                  SET IDENTITY_INSERT Instructors OFF;", conn, tran))
                            {
                                cmd.Parameters.Add("@IID", SqlDbType.Int).Value = newUserID;
                                cmd.ExecuteNonQuery();
                            }
                        }
                        else if (role == "Admin")
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                @"SET IDENTITY_INSERT Admins ON;
                                  INSERT INTO Admins (AdminID) VALUES (@AID);
                                  SET IDENTITY_INSERT Admins OFF;", conn, tran))
                            {
                                cmd.Parameters.Add("@AID", SqlDbType.Int).Value = newUserID;
                                cmd.ExecuteNonQuery();
                            }
                        }

                        tran.Commit();
                    }

                    LogAction(conn, "CREATE_USER", "Users", null, "Created " + role + " account: " + email);
                }

                txtNewUserName.Text = "";
                txtNewUserEmail.Text = "";
                txtNewUserPassword.Text = "";
                ShowSuccess("User created successfully.");
                LoadUsers();
            }
            catch (SqlException)
            {
                ShowError("Could not create user. Please try again.");
            }
        }

        private void LogAction(SqlConnection conn, string actionType, string targetTable, int? targetID, string details = null)
        {
            try
            {
                using (SqlCommand cmd = new SqlCommand(
                    @"INSERT INTO AuditLogs (PerformedByUserID, ActionType, TargetTable, TargetID, Details, CreatedAt)
                      VALUES (@UID, @Action, @Table, @TargetID, @Details, GETDATE())", conn))
                {
                    cmd.Parameters.Add("@UID", SqlDbType.Int).Value = AdminID;
                    cmd.Parameters.Add("@Action", SqlDbType.NVarChar, 100).Value = actionType;
                    cmd.Parameters.Add("@Table", SqlDbType.NVarChar, 100).Value = string.IsNullOrEmpty(targetTable) ? (object)DBNull.Value : targetTable;
                    cmd.Parameters.Add("@TargetID", SqlDbType.Int).Value = targetID.HasValue ? (object)targetID.Value : DBNull.Value;
                    cmd.Parameters.Add("@Details", SqlDbType.NVarChar, -1).Value = string.IsNullOrEmpty(details) ? (object)DBNull.Value : details;
                    cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException) { }
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
