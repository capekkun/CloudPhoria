using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class Classrooms : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Classrooms";

            if (!IsPostBack) { LoadClassrooms(); }
        }

        private void LoadClassrooms()
        {
            int studentID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    string sql = @"
                        SELECT c.ClassroomID, c.ClassroomName,
                               u.FullName AS InstructorName,
                               ce.EnrolledAt
                        FROM ClassroomEnrollments ce
                        INNER JOIN Classrooms c ON c.ClassroomID  = ce.ClassroomID
                        INNER JOIN Users      u ON u.UserID       = c.InstructorID
                        WHERE ce.StudentID = @StudentID
                        ORDER BY ce.EnrolledAt DESC";

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }

                    if (dt.Rows.Count > 0)
                    {
                        rptClassrooms.DataSource = dt;
                        rptClassrooms.DataBind();
                        pnlClassrooms.Visible = true;
                    }
                    else { pnlEmpty.Visible = true; }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load classrooms. Please try again.";
                pnlError.Visible = true;
            }
        }

        protected void btnJoin_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { return; }

            int studentID = Convert.ToInt32(Session["UserID"]);
            string code   = txtInviteCode.Text.Trim();
            string cs     = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Look up the classroom by invite code.
                    int classroomID = 0;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT ClassroomID FROM Classrooms WHERE InviteCode = @Code", conn))
                    {
                        cmd.Parameters.Add("@Code", SqlDbType.NVarChar, 20).Value = code;
                        object r = cmd.ExecuteScalar();
                        if (r == null || r == DBNull.Value)
                        {
                            litJoinError.Text = "Invite code not found. Please check and try again.";
                            pnlJoinError.Visible = true;
                            return;
                        }
                        classroomID = Convert.ToInt32(r);
                    }

                    // Check already enrolled.
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT COUNT(*) FROM ClassroomEnrollments
                          WHERE ClassroomID = @CID AND StudentID = @SID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        int exists = Convert.ToInt32(cmd.ExecuteScalar());
                        if (exists > 0)
                        {
                            litJoinError.Text = "You are already enrolled in this classroom.";
                            pnlJoinError.Visible = true;
                            return;
                        }
                    }

                    // Enrol.
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO ClassroomEnrollments (ClassroomID, StudentID, EnrolledAt)
                          VALUES (@CID, @SID, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        cmd.ExecuteNonQuery();
                    }

                    litJoinSuccess.Text = "You have successfully joined the classroom!";
                    pnlJoinSuccess.Visible = true;
                    txtInviteCode.Text = string.Empty;
                    LoadClassrooms();
                }
            }
            catch (SqlException)
            {
                litJoinError.Text = "Could not join classroom. Please try again.";
                pnlJoinError.Visible = true;
            }
        }
    }
}
