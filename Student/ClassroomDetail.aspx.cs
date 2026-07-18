using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class ClassroomDetail : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            { Response.Redirect("~/LogIn.aspx", true); return; }

            ((SiteMaster)Master).PageHeading = "Classroom";

            if (!IsPostBack)
            {
                int classroomID;
                if (!int.TryParse(Request.QueryString["classroomID"], out classroomID))
                { Response.Redirect("~/Student/Classrooms.aspx"); return; }
                LoadClassroom(classroomID);
            }
        }

        private void LoadClassroom(int classroomID)
        {
            int studentID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Verify student is enrolled
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT c.ClassroomName, u.FullName AS InstructorName
                          FROM ClassroomEnrollments ce
                          INNER JOIN Classrooms c ON c.ClassroomID = ce.ClassroomID
                          INNER JOIN Users u ON u.UserID = c.InstructorID
                          WHERE ce.ClassroomID = @CID AND ce.StudentID = @SID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                litClassName.Text  = HttpUtility.HtmlEncode(rdr["ClassroomName"].ToString());
                                litInstructor.Text = HttpUtility.HtmlEncode(rdr["InstructorName"].ToString());
                            }
                            else
                            { litError.Text = "You are not enrolled in this classroom."; pnlError.Visible = true; return; }
                        }
                    }

                    pnlContent.Visible = true;

                    // Materials
                    DataTable dtMat = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT FileName, UploadedAt FROM ClassroomMaterials WHERE ClassroomID=@CID ORDER BY UploadedAt DESC", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtMat);
                    }
                    if (dtMat.Rows.Count > 0)
                    { rptMaterials.DataSource = dtMat; rptMaterials.DataBind(); pnlMaterials.Visible = true; }
                    else { pnlNoMaterials.Visible = true; }

                    // Assignments
                    DataTable dtAsgn = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT Title, DueDate FROM ClassroomAssignments WHERE ClassroomID=@CID ORDER BY CreatedAt DESC", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtAsgn);
                    }
                    if (dtAsgn.Rows.Count > 0)
                    { rptAssignments.DataSource = dtAsgn; rptAssignments.DataBind(); pnlAssignments.Visible = true; }
                    else { pnlNoAssignments.Visible = true; }
                }
            }
            catch (SqlException)
            { litError.Text = "Could not load classroom. Please try again."; pnlError.Visible = true; }
        }
    }
}
