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
            bool isGuest = (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student");

            if (!IsPostBack)
            {
                if (isGuest)
                {
                    // Guests see pricing, but the buttons route to register instead of paying
                    pnlFreeNotCurrent.Visible = true;
                    pnlProUpgrade.Visible = true;
                }
                else
                {
                    LoadCurrentPlan();
                }
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
                        pnlFreeCurrent.Visible = true;
                        pnlProUpgrade.Visible = true;
                    }
                    else
                    {
                        pnlFreeNotCurrent.Visible = true;
                        pnlProCurrent.Visible = true;
                    }
                }
            }
            catch (SqlException)
            {
                // If we can't tell the plan, assume Free rather than granting Pro access
                pnlFreeCurrent.Visible = true;
                pnlProUpgrade.Visible = true;
            }
        }

        protected void btnPay_Click(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null)
            {
                Response.Redirect("~/Register.aspx");
                return;
            }

            string cardName = txtCardName.Text.Trim();
            string cardNumber = txtCardNumber.Text.Trim().Replace(" ", "");
            string expiry = txtExpiry.Text.Trim();
            string cvv = txtCVV.Text.Trim();

            if (string.IsNullOrEmpty(cardName) || cardNumber.Length < 13 ||
                string.IsNullOrEmpty(expiry) || cvv.Length < 3)
            {
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

                    int proPlanID = 2; // fallback if the plans table lookup below returns nothing
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT PlanID FROM SubscriptionPlans WHERE CanAccessFoundationOnly = 0 ORDER BY PlanID", conn))
                    {
                        object r = cmd.ExecuteScalar();
                        if (r != null) proPlanID = Convert.ToInt32(r);
                    }

                    using (SqlTransaction tran = conn.BeginTransaction())
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            "UPDATE UserSubscriptions SET IsActive = 0 WHERE StudentID = @SID", conn, tran))
                        {
                            cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                            cmd.ExecuteNonQuery();
                        }

                        using (SqlCommand cmd = new SqlCommand(
                            @"INSERT INTO UserSubscriptions (StudentID, PlanID, StartDate, EndDate, IsActive)
                              VALUES (@SID, @PID, GETDATE(), NULL, 1)", conn, tran))
                        {
                            cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                            cmd.Parameters.Add("@PID", SqlDbType.Int).Value = proPlanID;
                            cmd.ExecuteNonQuery();
                        }

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
