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
        public bool IsPublicPage { get; set; } = false;

        public string PageHeading { set { /* no longer needed — pages set their own title */ } }
        public string PageSubtitle { set { } }

        protected void Page_Load(object sender, EventArgs e) { }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (IsPublicPage) { HideAuthUI(); return; }

            CheckAuthentication();

            // If guest (no session), skip user-specific loading
            if (Session["UserID"] == null || Session["Role"] == null)
                return;

            LoadCurrentUser();
            ConfigureNavigation();
            LoadNotificationCount();

            if (!IsPostBack)
            {
                LoadXP();
            }
        }

        private void HideAuthUI()
        {
            pnlUserMenu.Visible      = false;
            pnlNotifications.Visible = false;
            pnlXPCounter.Visible     = false;
        }

        private void CheckAuthentication()
        {
            object uid = Session["UserID"];
            object role = Session["Role"];

            if (uid == null || role == null)
            {
                // Guest mode — show guest nav, don't redirect
                pnlGuestNav.Visible = true;
                pnlGuestActions.Visible = true;
                return;
            }

            int userID;
            if (!int.TryParse(uid.ToString(), out userID) || userID <= 0)
            { Session.Abandon(); Response.Redirect("~/LogIn.aspx", true); return; }

            string r = role.ToString();
            if (r != "Student" && r != "Instructor" && r != "Admin")
            { Session.Abandon(); Response.Redirect("~/LogIn.aspx", true); return; }
        }

        private void LoadCurrentUser()
        {
            object uid = Session["UserID"];
            if (uid == null) return;

            int userID;
            if (!int.TryParse(uid.ToString(), out userID)) return;

            string role = Session["Role"] != null ? Session["Role"].ToString() : "";
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            string fullName = "";
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT FullName, IsActive, IsBanned FROM Users WHERE UserID=@UID", conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                fullName = rdr["FullName"].ToString();
                                if (!Convert.ToBoolean(rdr["IsActive"]) || Convert.ToBoolean(rdr["IsBanned"]))
                                { Session.Abandon(); Response.Redirect("~/LogIn.aspx", true); return; }
                            }
                            else
                            { Session.Abandon(); Response.Redirect("~/LogIn.aspx", true); return; }
                        }
                    }
                }
            }
            catch (SqlException)
            {
                fullName = Session["FullName"] != null ? Session["FullName"].ToString() : "User";
            }

            // Set display values
            string initials = GetInitials(fullName);
            litTopbarInitials.Text = HttpUtility.HtmlEncode(initials);
            litTopbarName.Text     = HttpUtility.HtmlEncode(fullName);
            litTopbarRole.Text     = HttpUtility.HtmlEncode(role);
            pnlUserMenu.Visible    = true;

            if (role == "Student")
                lnkProfile.NavigateUrl = "~/Student/Profile.aspx";
            else if (role == "Instructor")
                lnkProfile.NavigateUrl = "~/Instructor/Profile.aspx";
            else if (role == "Admin")
                lnkProfile.NavigateUrl = "~/Admin/Profile.aspx";
        }

        private void ConfigureNavigation()
        {
            string role = Session["Role"] != null ? Session["Role"].ToString() : "";

            if (role == "Student")
            {
                pnlStudentNav.Visible        = true;
                pnlNotifications.Visible     = true;
                pnlXPCounter.Visible         = true;
                pnlFooterStudentLinks.Visible = true;
                lnkNotifications.HRef        = ResolveUrl("~/Student/Notifications.aspx");
            }
            else if (role == "Instructor")
            {
                pnlInstructorNav.Visible        = true;
                pnlNotifications.Visible        = true;
                pnlFooterInstructorLinks.Visible = true;
                lnkNotifications.HRef           = ResolveUrl("~/Instructor/Notifications.aspx");
            }
            else if (role == "Admin")
            {
                pnlAdminNav.Visible        = true;
                pnlNotifications.Visible   = true;
                pnlFooterAdminLinks.Visible = true;
                lnkNotifications.HRef      = ResolveUrl("~/Admin/Notifications.aspx");
            }
        }

        private void LoadXP()
        {
            if (Session["Role"] == null || Session["Role"].ToString() != "Student") return;

            int studentID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT TotalXP FROM Students WHERE StudentID=@SID", conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        object r = cmd.ExecuteScalar();
                        litTopXP.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
                    }

                    // Check if on free plan to show "Go Pro" button
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT TOP 1 sp.CanAccessFoundationOnly FROM UserSubscriptions us
                          INNER JOIN SubscriptionPlans sp ON sp.PlanID=us.PlanID
                          WHERE us.StudentID=@SID AND us.IsActive=1 ORDER BY us.StartDate DESC", conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        object r = cmd.ExecuteScalar();
                        bool isFoundationOnly = (r == null || r == DBNull.Value) ? true : Convert.ToBoolean(r);
                        if (isFoundationOnly)
                            pnlGoPro.Visible = true;
                    }
                }
            }
            catch (SqlException) { }
        }

        private void LoadNotificationCount()
        {
            object uid = Session["UserID"];
            if (uid == null) return;

            int userID = Convert.ToInt32(uid);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM Notifications WHERE UserID=@UID AND IsRead=0", conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        int count = Convert.ToInt32(cmd.ExecuteScalar());
                        if (count > 0)
                        {
                            litNotifCount.Text    = count > 99 ? "99+" : count.ToString();
                            pnlNotifBadge.Visible = true;
                        }
                    }
                }
            }
            catch (SqlException) { }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Default.aspx", true);
        }

        private string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "?";
            string[] parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1)
                return parts[0].Length >= 2 ? parts[0].Substring(0, 2).ToUpper() : parts[0][0].ToString().ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }
    }
}
