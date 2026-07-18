using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Instructor
{
    public partial class Consultations : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Instructor")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            string licenseStatus = Session["LicenseStatus"] != null
                                   ? Session["LicenseStatus"].ToString() : "Pending";
            if (licenseStatus != "Approved")
            {
                Response.Redirect("~/Instructor/Dashboard.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Consultations";

            if (!IsPostBack)
            {
                LoadSlots();
                LoadBookings();
            }
        }

        protected string GetBookingBadge(string status)
        {
            switch (status)
            {
                case "Pending":   return "<span class='cp-badge cp-badge-amber'>Pending</span>";
                case "Confirmed": return "<span class='cp-badge cp-badge-green'>Confirmed</span>";
                case "Cancelled": return "<span class='cp-badge cp-badge-red'>Cancelled</span>";
                default:          return "<span class='cp-badge cp-badge-grey'>" + HttpUtility.HtmlEncode(status) + "</span>";
            }
        }

        private void LoadSlots()
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            string sql = @"
                SELECT SlotID, SlotDate, StartTime, EndTime, IsAvailable
                FROM   ConsultationSlots
                WHERE  InstructorID = @IID
                ORDER  BY SlotDate, StartTime";

            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }
                }

                if (dt.Rows.Count > 0)
                {
                    rptSlots.DataSource = dt;
                    rptSlots.DataBind();
                    pnlSlots.Visible   = true;
                    pnlNoSlots.Visible = false;
                }
                else
                {
                    pnlSlots.Visible   = false;
                    pnlNoSlots.Visible = true;
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load slots. Please try again.");
            }
        }

        private void LoadBookings()
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            string sql = @"
                SELECT cb.BookingID, u.FullName AS StudentName,
                       cs2.SlotDate, cs2.StartTime, cs2.EndTime,
                       cb.Topic, cb.Status
                FROM   ConsultationBookings cb
                INNER JOIN ConsultationSlots cs2 ON cs2.SlotID    = cb.SlotID
                INNER JOIN Students         s   ON s.StudentID    = cb.StudentID
                INNER JOIN Users            u   ON u.UserID       = s.StudentID
                WHERE  cs2.InstructorID = @IID
                ORDER  BY cs2.SlotDate DESC, cs2.StartTime";

            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }
                }

                if (dt.Rows.Count > 0)
                {
                    rptBookings.DataSource = dt;
                    rptBookings.DataBind();
                    pnlBookings.Visible   = true;
                    pnlNoBookings.Visible = false;
                }
                else
                {
                    pnlBookings.Visible   = false;
                    pnlNoBookings.Visible = true;
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load bookings. Please try again.");
            }
        }

        protected void btnAddSlot_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { return; }

            int instructorID = Convert.ToInt32(Session["UserID"]);

            DateTime slotDate;
            if (!DateTime.TryParse(txtSlotDate.Text.Trim(), out slotDate))
            {
                ShowError("Invalid date.");
                return;
            }

            TimeSpan startTime, endTime;
            if (!TimeSpan.TryParse(txtStartTime.Text.Trim(), out startTime))
            {
                ShowError("Invalid start time.");
                return;
            }
            if (!TimeSpan.TryParse(txtEndTime.Text.Trim(), out endTime))
            {
                ShowError("Invalid end time.");
                return;
            }
            if (endTime <= startTime)
            {
                ShowError("End time must be after start time.");
                return;
            }

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO ConsultationSlots (InstructorID, SlotDate, StartTime, EndTime, IsAvailable)
                          VALUES (@IID, @Date, @Start, @End, 1)", conn))
                    {
                        cmd.Parameters.Add("@IID",   SqlDbType.Int).Value  = instructorID;
                        cmd.Parameters.Add("@Date",  SqlDbType.Date).Value = slotDate.Date;
                        cmd.Parameters.Add("@Start", SqlDbType.Time).Value = startTime;
                        cmd.Parameters.Add("@End",   SqlDbType.Time).Value = endTime;
                        cmd.ExecuteNonQuery();
                    }
                }

                txtSlotDate.Text  = string.Empty;
                txtStartTime.Text = string.Empty;
                txtEndTime.Text   = string.Empty;

                ShowSuccess("Slot added successfully.");
                pnlSlots.Visible   = false;
                pnlNoSlots.Visible = false;
                LoadSlots();
            }
            catch (SqlException)
            {
                ShowError("Could not add slot. Please try again.");
            }
        }

        protected void rptSlots_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Delete")
                DeleteSlot(Convert.ToInt32(e.CommandArgument));
        }

        private void DeleteSlot(int slotID)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "DELETE FROM ConsultationSlots WHERE SlotID=@SID AND InstructorID=@IID", conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = slotID;
                        cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowSuccess("Slot removed.");
                pnlSlots.Visible   = false;
                pnlNoSlots.Visible = false;
                LoadSlots();
            }
            catch (SqlException)
            {
                ShowError("Could not remove slot. It may have an active booking.");
            }
        }

        protected void rptBookings_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            int bookingID    = Convert.ToInt32(e.CommandArgument);
            string newStatus = e.CommandName == "Confirm" ? "Confirmed" : "Cancelled";

            // Validate allowed status values.
            if (newStatus != "Confirmed" && newStatus != "Cancelled") return;

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"UPDATE cb SET cb.Status = @Status
                          FROM ConsultationBookings cb
                          INNER JOIN ConsultationSlots cs2 ON cs2.SlotID = cb.SlotID
                          WHERE cb.BookingID = @BID AND cs2.InstructorID = @IID", conn))
                    {
                        cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 20).Value = newStatus;
                        cmd.Parameters.Add("@BID",    SqlDbType.Int).Value           = bookingID;
                        cmd.Parameters.Add("@IID",    SqlDbType.Int).Value           = instructorID;
                        cmd.ExecuteNonQuery();
                    }

                    // If cancelled, flip the slot back to available.
                    if (newStatus == "Cancelled")
                    {
                        using (SqlCommand upd = new SqlCommand(
                            @"UPDATE cs2 SET cs2.IsAvailable = 1
                              FROM ConsultationSlots cs2
                              INNER JOIN ConsultationBookings cb ON cb.SlotID = cs2.SlotID
                              WHERE cb.BookingID = @BID AND cs2.InstructorID = @IID", conn))
                        {
                            upd.Parameters.Add("@BID", SqlDbType.Int).Value = bookingID;
                            upd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                            upd.ExecuteNonQuery();
                        }
                    }
                }
                ShowSuccess("Booking updated to " + newStatus + ".");
                pnlBookings.Visible   = false;
                pnlNoBookings.Visible = false;
                LoadSlots();
                LoadBookings();
            }
            catch (SqlException)
            {
                ShowError("Could not update booking status. Please try again.");
            }
        }

        private void ShowSuccess(string msg)
        {
            litSuccess.Text = HttpUtility.HtmlEncode(msg);
            pnlSuccess.Visible = true;
            pnlError.Visible   = false;
        }

        private void ShowError(string msg)
        {
            litError.Text = HttpUtility.HtmlEncode(msg);
            pnlError.Visible   = true;
            pnlSuccess.Visible = false;
        }
    }
}
