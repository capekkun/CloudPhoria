using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria
{
    public partial class SiteMaster : MasterPage
    {
        // -------------------------------------------------------
        // IsPublicPage – set to true from a content page's
        // Page_Load (before base.OnInit) to skip the authentication
        // check.  Use this only for genuinely public pages such as
        // the landing page, about page, or contact page that do not
        // require a login.
        // -------------------------------------------------------
        public bool IsPublicPage { get; set; } = false;

        // -------------------------------------------------------
        // Public properties so content pages can set the topbar
        // title and subtitle without duplicating topbar markup.
        // -------------------------------------------------------

        /// <summary>
        /// Sets the visible page title shown in the topbar.
        /// </summary>
        public string PageHeading
        {
            set
            {
                if (litPageTitle != null)
                    litPageTitle.Text = HttpUtility.HtmlEncode(value);
            }
        }

        /// <summary>
        /// Sets a subtitle line beneath the topbar title.
        /// Setting this to a non-empty string also makes it visible.
        /// </summary>
        public string PageSubtitle
        {
            set
            {
                if (litPageSubtitle != null && pnlPageSubtitle != null)
                {
                    if (!string.IsNullOrWhiteSpace(value))
                    {
                        litPageSubtitle.Text = HttpUtility.HtmlEncode(value);
                        pnlPageSubtitle.Visible = true;
                    }
                }
            }
        }

        // -------------------------------------------------------
        // Page lifecycle
        // -------------------------------------------------------
        protected void Page_Load(object sender, EventArgs e)
        {
            // Nothing runs here on first load.
            // Auth and user data are loaded in Page_PreRender so that
            // content pages have already had a chance to set IsPublicPage
            // in their own Page_Load before we check it.
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            // Public pages skip auth checks and hide the authenticated UI.
            if (IsPublicPage)
            {
                pnlUserMenu.Visible      = false;
                pnlNotifications.Visible = false;
                return;
            }

            CheckAuthentication();
            LoadCurrentUser();

            if (!IsPostBack)
            {
                ConfigureNavigation();
                LoadNotificationCount();
            }
        }

        // -------------------------------------------------------
        // Step 1 – Verify that a valid authenticated session exists.
        // Redirect to the login page when no session is found.
        // Public pages (Login, Guest) do not use this Master Page
        // so this check is always appropriate here.
        // -------------------------------------------------------
        private void CheckAuthentication()
        {
            // Read session values safely without assuming they exist.
            object sessionUserID = Session["UserID"];
            object sessionRole   = Session["Role"];

            if (sessionUserID == null || sessionRole == null)
            {
                // No valid session – send to login page.
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            // Parse UserID safely.
            int userID;
            if (!int.TryParse(sessionUserID.ToString(), out userID) || userID <= 0)
            {
                // Session value is not a valid integer – clear and redirect.
                Session.Abandon();
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            // Validate the role is one of the three supported values.
            string role = sessionRole.ToString();
            if (role != "Student" && role != "Instructor" && role != "Admin")
            {
                Session.Abandon();
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }
        }

        // -------------------------------------------------------
        // Step 2 – Load the current user's name, role, and
        // relevant role-table IDs from the database so the layout
        // shows real data rather than session strings only.
        // -------------------------------------------------------
        private void LoadCurrentUser()
        {
            object sessionUserID = Session["UserID"];
            if (sessionUserID == null) { return; }

            int userID;
            if (!int.TryParse(sessionUserID.ToString(), out userID)) { return; }

            string role = Session["Role"] != null ? Session["Role"].ToString() : string.Empty;

            string connString = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            // Verify the account is still active and not banned in the database.
            // Also re-read the name in case it was updated since login.
            string sql = @"SELECT FullName, IsActive, IsBanned
                           FROM   Users
                           WHERE  UserID = @UserID";

            string fullName  = string.Empty;
            bool   isActive  = false;
            bool   isBanned  = false;

            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userID;
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                fullName = reader["FullName"].ToString();
                                isActive = Convert.ToBoolean(reader["IsActive"]);
                                isBanned = Convert.ToBoolean(reader["IsBanned"]);
                            }
                            else
                            {
                                // User row no longer exists.
                                Session.Abandon();
                                Response.Redirect("~/LogIn.aspx", true);
                                return;
                            }
                        }
                    }
                }
            }
            catch (SqlException)
            {
                // Database unavailable – fall back gracefully.
                // The user will still see their session name but
                // the topbar will show a placeholder.
                fullName = Session["FullName"] != null ? Session["FullName"].ToString() : "User";
                SetUserDisplay(fullName, role);
                return;
            }

            // Enforce account status on every request.
            if (!isActive || isBanned)
            {
                Session.Abandon();
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            SetUserDisplay(fullName, role);

            // Show the user menu and notification bell now that we have a user.
            pnlUserMenu.Visible = true;

            // Set the profile link destination based on role.
            if (role == "Student")
                lnkProfile.NavigateUrl = "~/Student/Profile.aspx";
            else if (role == "Instructor")
                lnkProfile.NavigateUrl = "~/Instructor/Profile.aspx";
            else if (role == "Admin")
                lnkProfile.NavigateUrl = "~/Admin/Profile.aspx";
        }

        // -------------------------------------------------------
        // Helper – populate display literals for the topbar and
        // sidebar profile area.
        // -------------------------------------------------------
        private void SetUserDisplay(string fullName, string role)
        {
            // Build two-character initials for the avatar.
            string initials = GetInitials(fullName);

            // Sidebar profile area.
            if (litSidebarInitials != null) litSidebarInitials.Text = HttpUtility.HtmlEncode(initials);
            if (litSidebarName     != null) litSidebarName.Text     = HttpUtility.HtmlEncode(fullName);
            if (litSidebarRole     != null) litSidebarRole.Text     = HttpUtility.HtmlEncode(role);

            // Topbar user menu area.
            if (litTopbarInitials != null) litTopbarInitials.Text = HttpUtility.HtmlEncode(initials);
            if (litTopbarName     != null) litTopbarName.Text     = HttpUtility.HtmlEncode(fullName);
            if (litTopbarRole     != null) litTopbarRole.Text     = HttpUtility.HtmlEncode(role);
        }

        // -------------------------------------------------------
        // Step 3 – Show the correct navigation panel and configure
        // the notification bell destination based on role.
        // For Instructors, check LicenseStatus as well.
        // -------------------------------------------------------
        private void ConfigureNavigation()
        {
            object sessionRole = Session["Role"];
            if (sessionRole == null) { return; }
            string role = sessionRole.ToString();

            if (role == "Student")
            {
                pnlStudentNav.Visible    = true;
                pnlNotifications.Visible = true;
                // Notification bell links to student notifications page.
                lnkNotifications.HRef    = ResolveUrl("~/Student/Notifications.aspx");
                // Footer
                pnlFooterStudentLinks.Visible = true;
                pnlFooterRole.Visible         = true;
                litFooterRole.Text            = "Student";
            }
            else if (role == "Instructor")
            {
                pnlInstructorNav.Visible = true;
                pnlNotifications.Visible = true;
                lnkNotifications.HRef    = ResolveUrl("~/Instructor/Notifications.aspx");
                ConfigureInstructorLicence();
                // Footer
                pnlFooterInstructorLinks.Visible = true;
                pnlFooterRole.Visible            = true;
                litFooterRole.Text               = "Instructor";
            }
            else if (role == "Admin")
            {
                pnlAdminNav.Visible      = true;
                pnlNotifications.Visible = true;
                lnkNotifications.HRef    = ResolveUrl("~/Admin/Notifications.aspx");
                // Footer
                pnlFooterAdminLinks.Visible = true;
                pnlFooterRole.Visible       = true;
                litFooterRole.Text          = "Admin";
            }
        }

        // -------------------------------------------------------
        // Instructor licence – read LicenseStatus from the DB
        // and show the appropriate nav panel.
        // -------------------------------------------------------
        private void ConfigureInstructorLicence()
        {
            object sessionUserID = Session["UserID"];
            if (sessionUserID == null) { return; }

            int instructorID;
            if (!int.TryParse(sessionUserID.ToString(), out instructorID)) { return; }

            string connString = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            string sql = @"SELECT LicenseStatus
                           FROM   Instructors
                           WHERE  InstructorID = @InstructorID";

            string licenseStatus = "Pending"; // Default to most restrictive if not found.

            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@InstructorID", SqlDbType.Int).Value = instructorID;
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            licenseStatus = result.ToString();
                        }
                    }
                }
            }
            catch (SqlException)
            {
                // Cannot reach database – default to restricted access.
                licenseStatus = "Pending";
            }

            // Store for other pages that may need to check licence status.
            Session["LicenseStatus"] = licenseStatus;

            if (licenseStatus == "Approved")
            {
                pnlInstructorApprovedNav.Visible = true;
            }
            else if (licenseStatus == "Pending")
            {
                pnlInstructorPending.Visible     = true;
                pnlInstructorLimitedNav.Visible  = true;
            }
            else if (licenseStatus == "Rejected")
            {
                pnlInstructorRejected.Visible    = true;
                pnlInstructorLimitedNav.Visible  = true;
            }
            else
            {
                // Unrecognised value – treat as restricted.
                pnlInstructorPending.Visible     = true;
                pnlInstructorLimitedNav.Visible  = true;
            }
        }

        // -------------------------------------------------------
        // Step 4 – Load unread notification count for the topbar
        // bell badge.  A failure here is non-critical so the page
        // continues to load without a count.
        // -------------------------------------------------------
        private void LoadNotificationCount()
        {
            object sessionUserID = Session["UserID"];
            if (sessionUserID == null) { return; }

            int userID;
            if (!int.TryParse(sessionUserID.ToString(), out userID)) { return; }

            string connString = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            // Only select the count – do not load notification content here.
            string sql = @"SELECT COUNT(*)
                           FROM   Notifications
                           WHERE  UserID   = @UserID
                           AND    IsRead   = 0";

            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userID;
                        object result = cmd.ExecuteScalar();
                        int count = (result != null && result != DBNull.Value)
                                    ? Convert.ToInt32(result)
                                    : 0;

                        if (count > 0)
                        {
                            // Cap the display at 99+ to keep the badge small.
                            litNotifCount.Text  = count > 99 ? "99+" : count.ToString();
                            pnlNotifBadge.Visible = true;
                        }
                    }
                }
            }
            catch (SqlException)
            {
                // Non-critical – silently skip the notification count.
                // A database problem here should not break the whole page.
            }
        }

        // -------------------------------------------------------
        // Logout button event handler
        // -------------------------------------------------------
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            // Clear all session values and abandon the session.
            Session.Clear();
            Session.Abandon();

            // Return the user to the login page.
            Response.Redirect("~/LogIn.aspx", true);
        }

        // -------------------------------------------------------
        // Helper – generate two-character initials from a name.
        // -------------------------------------------------------
        private string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName))
            {
                return "?";
            }

            string[] parts = fullName.Trim().Split(
                new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);

            if (parts.Length == 1)
            {
                // Single name – return first two characters if available.
                return parts[0].Length >= 2
                       ? parts[0].Substring(0, 2).ToUpper()
                       : parts[0].Substring(0, 1).ToUpper();
            }

            // First initial + last initial.
            return (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper();
        }
    }
}
