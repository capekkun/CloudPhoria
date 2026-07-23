using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Instructor
{
    public partial class Classrooms : System.Web.UI.Page
    {
        // Allowed upload extensions for classroom materials (same policy as Instructor/Materials.aspx).
        private static readonly HashSet<string> AllowedExtensions = new HashSet<string>(
            StringComparer.OrdinalIgnoreCase)
        {
            ".pdf", ".docx", ".doc", ".pptx", ".ppt", ".txt", ".png", ".jpg", ".jpeg"
        };

        private const int MaxFileSizeBytes = 10 * 1024 * 1024; // 10 MB

        private int SelectedClassroomID
        {
            get { return ViewState["SelectedClassroomID"] != null ? (int)ViewState["SelectedClassroomID"] : 0; }
            set { ViewState["SelectedClassroomID"] = value; }
        }

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

                // If a classroom ID is in the query string, show its students + materials.
                int classroomID;
                if (int.TryParse(Request.QueryString["id"], out classroomID) && classroomID > 0)
                {
                    SelectedClassroomID = classroomID;
                    pnlClassroomMaterialsSection.Visible = true;
                    LoadStudents(classroomID);
                    LoadClassroomMaterials(classroomID);
                }
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

        private void LoadClassroomMaterials(int classroomID)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT ClassroomMaterialID, FileName, FilePath, Description, UploadedAt
                          FROM ClassroomMaterials
                          WHERE ClassroomID=@CID AND InstructorID=@IID
                          ORDER BY UploadedAt DESC", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }
                }

                if (dt.Rows.Count > 0)
                {
                    rptClassroomMaterials.DataSource = dt;
                    rptClassroomMaterials.DataBind();
                    pnlClassroomMaterials.Visible = true;
                    pnlNoMaterials.Visible = false;
                }
                else
                {
                    pnlClassroomMaterials.Visible = false;
                    pnlNoMaterials.Visible = true;
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load classroom materials.");
            }
        }

        protected void btnUploadMaterial_Click(object sender, EventArgs e)
        {
            int classroomID = SelectedClassroomID;
            int instructorID = Convert.ToInt32(Session["UserID"]);

            if (classroomID == 0)
            {
                ShowError("No classroom selected.");
                return;
            }

            if (!fuClassroomMaterial.HasFile)
            {
                ShowError("Please choose a file to upload.");
                return;
            }

            string originalName = Path.GetFileName(fuClassroomMaterial.FileName);
            string ext = Path.GetExtension(originalName);

            if (!AllowedExtensions.Contains(ext))
            {
                ShowError("File type not allowed. Allowed: PDF, DOCX, PPTX, TXT, PNG, JPG.");
                return;
            }

            if (fuClassroomMaterial.PostedFile.ContentLength > MaxFileSizeBytes)
            {
                ShowError("File exceeds the 10 MB size limit.");
                return;
            }

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Verify classroom ownership.
                    using (SqlCommand chk = new SqlCommand(
                        "SELECT COUNT(*) FROM Classrooms WHERE ClassroomID=@CID AND InstructorID=@IID", conn))
                    {
                        chk.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        chk.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        if (Convert.ToInt32(chk.ExecuteScalar()) == 0)
                        {
                            ShowError("You do not own the selected classroom.");
                            return;
                        }
                    }

                    // Build a safe stored file name: timestamp + safe original name.
                    string safeOriginal = Path.GetFileNameWithoutExtension(originalName);
                    safeOriginal = System.Text.RegularExpressions.Regex.Replace(safeOriginal, @"[^a-zA-Z0-9_\-]", "_");
                    string storedName = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + safeOriginal + ext;

                    // Physical save path — per-classroom folder, per project rules.
                    string uploadDir = Server.MapPath("~/uploads/classroom/" + classroomID + "/");
                    if (!Directory.Exists(uploadDir))
                        Directory.CreateDirectory(uploadDir);

                    string physicalPath = Path.Combine(uploadDir, storedName);
                    fuClassroomMaterial.PostedFile.SaveAs(physicalPath);

                    string webPath = "/uploads/classroom/" + classroomID + "/" + storedName;
                    string description = txtMaterialDescription.Text.Trim();

                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO ClassroomMaterials (ClassroomID, InstructorID, FileName, FilePath, Description, UploadedAt)
                          VALUES (@CID, @IID, @FName, @FPath, @Desc, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        cmd.Parameters.Add("@FName", SqlDbType.NVarChar, 255).Value = originalName;
                        cmd.Parameters.Add("@FPath", SqlDbType.NVarChar, 500).Value = webPath;
                        cmd.Parameters.Add("@Desc", SqlDbType.NVarChar, 500).Value =
                            string.IsNullOrEmpty(description) ? (object)DBNull.Value : description;
                        cmd.ExecuteNonQuery();
                    }
                }

                txtMaterialDescription.Text = string.Empty;
                ShowSuccess("Material uploaded to classroom.");
                LoadClassroomMaterials(classroomID);
            }
            catch (SqlException)
            {
                ShowError("Could not save material record. Please try again.");
            }
            catch (Exception)
            {
                ShowError("File could not be saved. Please try again.");
            }
        }

        protected void rptClassroomMaterials_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteMaterial")
                DeleteClassroomMaterial(Convert.ToInt32(e.CommandArgument));
        }

        private void DeleteClassroomMaterial(int materialID)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    string filePath = null;
                    using (SqlCommand get = new SqlCommand(
                        "SELECT FilePath FROM ClassroomMaterials WHERE ClassroomMaterialID=@ID AND InstructorID=@IID", conn))
                    {
                        get.Parameters.Add("@ID", SqlDbType.Int).Value = materialID;
                        get.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        object r = get.ExecuteScalar();
                        if (r == null || r == DBNull.Value) return; // Not owned by this instructor.
                        filePath = r.ToString();
                    }

                    using (SqlCommand del = new SqlCommand(
                        "DELETE FROM ClassroomMaterials WHERE ClassroomMaterialID=@ID AND InstructorID=@IID", conn))
                    {
                        del.Parameters.Add("@ID", SqlDbType.Int).Value = materialID;
                        del.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        del.ExecuteNonQuery();
                    }

                    if (!string.IsNullOrEmpty(filePath))
                    {
                        try
                        {
                            string physical = Server.MapPath("~" + filePath);
                            if (File.Exists(physical)) File.Delete(physical);
                        }
                        catch
                        {
                            // Non-critical — DB record already removed.
                        }
                    }
                }

                ShowSuccess("Material removed.");
                LoadClassroomMaterials(SelectedClassroomID);
            }
            catch (SqlException)
            {
                ShowError("Could not remove material. Please try again.");
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
