using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class Profile : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "My Profile";

            if (!IsPostBack) { LoadProfile(); }
        }

        private void LoadProfile()
        {
            int studentID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // User + Student info.
                    string sql = @"
                        SELECT u.FullName, u.Email, u.CreatedAt,
                               s.TPNumber, s.TotalXP
                        FROM Users u
                        INNER JOIN Students s ON s.StudentID = u.UserID
                        WHERE u.UserID = @UserID";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = studentID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                string fullName = rdr["FullName"].ToString();
                                litFullName.Text = HttpUtility.HtmlEncode(fullName);
                                litEmail.Text    = HttpUtility.HtmlEncode(rdr["Email"].ToString());
                                litTPNumber.Text = HttpUtility.HtmlEncode(rdr["TPNumber"].ToString());
                                litCreatedAt.Text = Convert.ToDateTime(rdr["CreatedAt"]).ToString("dd MMM yyyy");
                                litXP.Text       = rdr["TotalXP"].ToString();

                                // Initials.
                                string[] parts = fullName.Trim().Split(' ');
                                string initials = parts.Length >= 2
                                    ? (parts[0][0].ToString() + parts[parts.Length-1][0].ToString()).ToUpper()
                                    : fullName.Substring(0, Math.Min(2, fullName.Length)).ToUpper();
                                litInitials.Text = HttpUtility.HtmlEncode(initials);
                            }
                        }
                    }

                    // Subscription plan.
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT TOP 1 sp.PlanName
                          FROM UserSubscriptions us
                          INNER JOIN SubscriptionPlans sp ON sp.PlanID = us.PlanID
                          WHERE us.StudentID = @SID AND us.IsActive = 1
                          ORDER BY us.StartDate DESC", conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        object plan = cmd.ExecuteScalar();
                        litPlan.Text = HttpUtility.HtmlEncode(
                            plan != null && plan != DBNull.Value ? plan.ToString() : "Free");
                    }

                    // Modules completed.
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM ModuleProgress WHERE StudentID=@SID AND Status='Completed'", conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        litModules.Text = cmd.ExecuteScalar().ToString();
                    }

                    // Badges.
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM UserBadges WHERE StudentID=@SID", conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        litBadges.Text = cmd.ExecuteScalar().ToString();
                    }

                    // Certifications.
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM UserCertifications WHERE StudentID=@SID", conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        litCerts.Text = cmd.ExecuteScalar().ToString();
                    }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load profile. Please try again.";
                pnlError.Visible = true;
            }
        }
    }
}
