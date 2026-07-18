using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Instructor
{
    public partial class Classrooms : System.Web.UI.Page
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

            ((SiteMaster)Master).PageHeading = "Classrooms";

            if (!IsPostBack)
            {
                LoadClassrooms();

                // If a classroom ID is in the query string, show its students.
                int classroomID;
                if (int.TryParse(Request.QueryString["id"], out classroomID) && classroomID > 0)
                    LoadStudents(classroomID);
            }
        }

        private void LoadClassrooms()
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            string sql = @"
                SELECT c.ClassroomID, c.ClassroomName, c.InviteCode, c.CreatedAt,
                       COUNT(ce.StudentID) AS StudentCount
                FROM   Classrooms c
                LEFT JOIN ClassroomEnrollments ce ON ce.ClassroomID = c.ClassroomID
                WHERE  c.InstructorID = @ID
                GROUP BY c.ClassroomID, c.ClassroomName, c.InviteCode, c.CreatedAt
                ORDER BY c.CreatedAt DESC";

            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@ID", SqlDbType.Int).Value = instructorID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }
                }

                // Add a computed HTML column (empty — students shown via separate panel).
                dt.Columns.Add("EnrolledHTML", typeof(string));
                foreach (DataRow row in dt.Rows) row["EnrolledHTML"] = string.Empty;

                if (dt.Rows.Count > 0)
                {
                    rptClassrooms.DataSource = dt;
                    rptClassrooms.DataBind();
                    pnlClassrooms.Visible = true;
                }
                else
                {
                    pnlEmpty.Visible = true;
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load classrooms. Please try again.");
            }
        }

        private void LoadStudents(int classroomID)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                // Verify ownership.
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand chk = new SqlCommand(
                        "SELECT ClassroomName FROM Classrooms WHERE ClassroomID=@CID AND InstructorID=@IID", conn))
                    {
                        chk.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        chk.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        object name = chk.ExecuteScalar();
                        if (name == null || name == DBNull.Value) return;
                        litSelectedClassroom.Text = HttpUtility.HtmlEncode(name.ToString());
                    }

                    string sql = @"
                        SELECT u.FullName, u.Email, ce.EnrolledAt
                        FROM   ClassroomEnrollments ce
                        INNER JOIN Students s ON s.StudentID = ce.StudentID
                        INNER JOIN Users    u ON u.UserID    = s.StudentID
                        WHERE  ce.ClassroomID = @CID
                        ORDER BY ce.EnrolledAt DESC";

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }

                    rptStudents.DataSource = dt;
                    rptStudents.DataBind();
                    pnlStudents.Visible = true;
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load student list. Please try again.");
            }
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { return; }

            int instructorID = Convert.ToInt32(Session["UserID"]);
            string name = txtClassName.Text.Trim();
            string code = txtInviteCode.Text.Trim().ToUpper();
            string cs   = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Unique invite code check.
                    using (SqlCommand chk = new SqlCommand(
                        "SELECT COUNT(*) FROM Classrooms WHERE InviteCode=@Code", conn))
                    {
                        chk.Parameters.Add("@Code", SqlDbType.NVarChar, 20).Value = code;
                        if (Convert.ToInt32(chk.ExecuteScalar()) > 0)
                        {
                            ShowError("That invite code is already in use. Please choose another.");
                            return;
                        }
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO Classrooms (InstructorID, ClassroomName, InviteCode, CreatedAt)
                          VALUES (@IID, @Name, @Code, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@IID",  SqlDbType.Int).Value          = instructorID;
                        cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 100).Value = name;
                        cmd.Parameters.Add("@Code", SqlDbType.NVarChar, 20).Value  = code;
                        cmd.ExecuteNonQuery();
                    }
                }

                txtClassName.Text  = string.Empty;
                txtInviteCode.Text = string.Empty;

                ShowSuccess("Classroom created. Share the invite code with your students.");
                pnlClassrooms.Visible = false;
                pnlEmpty.Visible      = false;
                LoadClassrooms();
            }
            catch (SqlException)
            {
                ShowError("Could not create classroom. Please try again.");
            }
        }

        protected void rptClassrooms_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Delete")
                DeleteClassroom(Convert.ToInt32(e.CommandArgument));
        }

        private void DeleteClassroom(int classroomID)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "DELETE FROM Classrooms WHERE ClassroomID=@CID AND InstructorID=@IID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowSuccess("Classroom deleted.");
                pnlClassrooms.Visible = false;
                pnlEmpty.Visible      = false;
                pnlStudents.Visible   = false;
                LoadClassrooms();
            }
            catch (SqlException)
            {
                ShowError("Could not delete classroom. Remove enrolled students and assignments first.");
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
