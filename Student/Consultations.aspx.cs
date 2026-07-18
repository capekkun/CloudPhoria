using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class Consultations : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Consultations";

            if (!IsPostBack) { LoadData(); }
        }

        private void LoadData()
        {
            int studentID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // My bookings.
                    string bookSql = @"
                        SELECT u.FullName AS InstructorName,
                               s.SlotDate, s.StartTime, s.EndTime,
                               cb.Status, cb.Topic
                        FROM ConsultationBookings cb
                        INNER JOIN ConsultationSlots s ON s.SlotID = cb.SlotID
                        INNER JOIN Users u ON u.UserID = s.InstructorID
                        WHERE cb.StudentID = @StudentID
                        ORDER BY s.SlotDate DESC, s.StartTime DESC";

                    DataTable dtBook = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(bookSql, conn))
                    {
                        cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtBook);
                    }

                    if (dtBook.Rows.Count > 0)
                    {
                        rptBookings.DataSource = dtBook;
                        rptBookings.DataBind();
                        pnlBookings.Visible = true;
                    }
                    else { pnlNoBookings.Visible = true; }

                    // Available slots (future dates that are still available).
                    string slotsSql = @"
                        SELECT cs.SlotID, u.FullName AS InstructorName,
                               cs.SlotDate, cs.StartTime, cs.EndTime
                        FROM ConsultationSlots cs
                        INNER JOIN Users u ON u.UserID = cs.InstructorID
                        WHERE cs.IsAvailable = 1
                          AND cs.SlotDate >= CAST(GETDATE() AS DATE)
                        ORDER BY cs.SlotDate ASC, cs.StartTime ASC";

                    DataTable dtSlots = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(slotsSql, conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        da.Fill(dtSlots);

                    if (dtSlots.Rows.Count > 0)
                    {
                        rptSlots.DataSource = dtSlots;
                        rptSlots.DataBind();
                        pnlSlots.Visible = true;
                    }
                    else { pnlNoSlots.Visible = true; }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load consultation data. Please try again.";
                pnlError.Visible = true;
            }
        }

        protected void BookSlot_Command(object sender, CommandEventArgs e)
        {
            int slotID;
            if (!int.TryParse(e.CommandArgument.ToString(), out slotID)) { return; }

            int studentID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlTransaction tran = conn.BeginTransaction())
                    {
                        // Check availability within the transaction.
                        using (SqlCommand chk = new SqlCommand(
                            "SELECT IsAvailable FROM ConsultationSlots WHERE SlotID = @SlotID", conn, tran))
                        {
                            chk.Parameters.Add("@SlotID", SqlDbType.Int).Value = slotID;
                            object avail = chk.ExecuteScalar();
                            if (avail == null || !Convert.ToBoolean(avail))
                            {
                                litError.Text = "This slot is no longer available.";
                                pnlError.Visible = true;
                                return;
                            }
                        }

                        // Insert booking.
                        using (SqlCommand ins = new SqlCommand(
                            @"INSERT INTO ConsultationBookings (SlotID, StudentID, Status, BookedAt)
                              VALUES (@SlotID, @StudentID, 'Pending', GETDATE())", conn, tran))
                        {
                            ins.Parameters.Add("@SlotID",    SqlDbType.Int).Value = slotID;
                            ins.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                            ins.ExecuteNonQuery();
                        }

                        // Mark slot as unavailable.
                        using (SqlCommand upd = new SqlCommand(
                            "UPDATE ConsultationSlots SET IsAvailable = 0 WHERE SlotID = @SlotID", conn, tran))
                        {
                            upd.Parameters.Add("@SlotID", SqlDbType.Int).Value = slotID;
                            upd.ExecuteNonQuery();
                        }

                        tran.Commit();
                    }
                }

                litSuccess.Text = "Consultation slot booked successfully!";
                pnlSuccess.Visible = true;
                LoadData();
            }
            catch (SqlException)
            {
                litError.Text = "Could not book this slot. Please try again.";
                pnlError.Visible = true;
            }
        }
    }
}
