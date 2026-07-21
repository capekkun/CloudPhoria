using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class Upgrade : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            { Response.Redirect("~/LogIn.aspx", true); return; }

            ((SiteMaster)Master).PageHeading = "Upgrade";

            if (!IsPostBack)
            {
                LoadCurrentPlan();
            }
        }

        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString; }
        }

        private void LoadCurrentPlan()
        {
            int studentID = Convert.ToInt32(Session["UserID"]);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    bool isFoundationOnly = true;
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT TOP 1 sp.CanAccessFoundationOnly
                          FROM UserSubscriptions us
                          INNER JOIN SubscriptionPlans sp ON sp.PlanID = us.PlanID
                          WHERE us.StudentID = @SID AND us.IsActive = 1
                          ORDER BY us.StartDate DESC", conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        object r = cmd.ExecuteScalar();
                        isFoundationOnly = (r == null || r == DBNull.Value) ? true : Convert.ToBoolean(r);
                    }

                    if (isFoundationOnly)
                    {
                        // On Free plan
                        pnlFreeCurrent.Visible = true;
                        pnlProUpgrade.Visible = true;
                    }
                    else
                    {
                        // On Pro plan
                        pnlFreeNotCurrent.Visible = true;
                        pnlProCurrent.Visible = true;
                    }
                }
            }
            catch (SqlException)
            {
                // Default to Free if error
                pnlFreeCurrent.Visible = true;
                pnlProUpgrade.Visible = true;
            }
        }

        protected void btnPay_Click(object sender, EventArgs e)
        {
            // Validate basic card fields
            string cardName = txtCardName.Text.Trim();
            string cardNumber = txtCardNumber.Text.Trim().Replace(" ", "");
            string expiry = txtExpiry.Text.Trim();
            string cvv = txtCVV.Text.Trim();

            if (string.IsNullOrEmpty(cardName) || cardNumber.Length < 13 ||
                string.IsNullOrEmpty(expiry) || cvv.Length < 3)
            {
                // Show modal again with error
                ScriptManager.RegisterStartupScript(this, GetType(), "showModal",
                    "openPaymentModal();alert('Please fill in all payment fields correctly.');", true);
                return;
            }

            int studentID = Convert.ToInt32(Session["UserID"]);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Get Pro plan ID
                    int proPlanID = 2;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT PlanID FROM SubscriptionPlans WHERE CanAccessFoundationOnly = 0 ORDER BY PlanID", conn))
                    {
                        object r = cmd.ExecuteScalar();
                        if (r != null) proPlanID = Convert.ToInt32(r);
                    }

                    using (SqlTransaction tran = conn.BeginTransaction())
                    {
                        // Deactivate existing subscriptions
                        using (SqlCommand cmd = new SqlCommand(
                            "UPDATE UserSubscriptions SET IsActive = 0 WHERE StudentID = @SID", conn, tran))
                        {
                            cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                            cmd.ExecuteNonQuery();
                        }

                        // Insert new Pro subscription
                        using (SqlCommand cmd = new SqlCommand(
                            @"INSERT INTO UserSubscriptions (StudentID, PlanID, StartDate, EndDate, IsActive)
                              VALUES (@SID, @PID, GETDATE(), NULL, 1)", conn, tran))
                        {
                            cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                            cmd.Parameters.Add("@PID", SqlDbType.Int).Value = proPlanID;
                            cmd.ExecuteNonQuery();
                        }

                        // Create notification
                        using (SqlCommand cmd = new SqlCommand(
                            @"INSERT INTO Notifications (UserID, Message, NotificationType, IsRead, CreatedAt)
                              VALUES (@UID, 'Welcome to Pro! You now have full access to all pathways and features.', 'Subscription', 0, GETDATE())", conn, tran))
                        {
                            cmd.Parameters.Add("@UID", SqlDbType.Int).Value = studentID;
                            cmd.ExecuteNonQuery();
                        }

                        tran.Commit();
                    }
                }

                // Show success
                pnlSuccessOverlay.Visible = true;
            }
            catch (SqlException)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                    "openPaymentModal();alert('Payment processing failed. Please try again.');", true);
            }
        }
    }
}
