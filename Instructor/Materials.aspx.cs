using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Instructor
{
    public partial class Materials : System.Web.UI.Page
    {
        private static readonly HashSet<string> AllowedExtensions =
            new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                ".pdf", ".docx", ".doc", ".pptx", ".ppt",
                ".txt", ".png", ".jpg", ".jpeg"
            };

        private const int MaxFileSizeBytes = 10 * 1024 * 1024; // 10 MB

        // ── Page lifecycle ────────────────────────────────────────────────────
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

            ((SiteMaster)Master).PageHeading = "Materials";

            if (!IsPostBack)
            {
                LoadDropdowns();

                // Pre-select subtopic from query string if supplied.
                int qsID;
                if (int.TryParse(Request.QueryString["subTopicID"], out qsID) && qsID > 0)
                {
                    ddlTypeFilter.SelectedValue = "Subtopic";
                    PopulateSecondaryFilter("Subtopic");
                    if (ddlSecondaryFilter.Items.FindByValue(qsID.ToString()) != null)
                        ddlSecondaryFilter.SelectedValue = qsID.ToString();
                }

                LoadMaterials();
            }
        }

        // ── Load all dropdowns ────────────────────────────────────────────────
        private void LoadDropdowns()
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();

                // Upload modal — subtopic list.
                DataTable dtST = new DataTable();
                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT st.SubTopicID,
                             m.ModuleName + ' > ' + st.SubTopicName AS DisplayName
                      FROM   SubTopics st
                      INNER JOIN Modules m ON m.ModuleID = st.ModuleID
                      WHERE  st.CreatedByInstructorID = @ID
                      ORDER BY m.ModuleName, st.OrderIndex", conn))
                {
                    cmd.Parameters.Add("@ID", SqlDbType.Int).Value = instructorID;
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtST);
                }

                ddlSubTopicUpload.DataSource     = dtST;
                ddlSubTopicUpload.DataTextField  = "DisplayName";
                ddlSubTopicUpload.DataValueField = "SubTopicID";
                ddlSubTopicUpload.DataBind();
                ddlSubTopicUpload.Items.Insert(0, new ListItem("-- Select Subtopic --", "0"));
                pnlSubtopicCard.Visible = dtST.Rows.Count > 0;

                // Upload modal — classroom list.
                DataTable dtCL = new DataTable();
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT ClassroomID, ClassroomName FROM Classrooms WHERE InstructorID=@ID ORDER BY ClassroomName",
                    conn))
                {
                    cmd.Parameters.Add("@ID", SqlDbType.Int).Value = instructorID;
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtCL);
                }

                ddlClassroomUpload.DataSource     = dtCL;
                ddlClassroomUpload.DataTextField  = "ClassroomName";
                ddlClassroomUpload.DataValueField = "ClassroomID";
                ddlClassroomUpload.DataBind();
                ddlClassroomUpload.Items.Insert(0, new ListItem("-- Select Classroom --", "0"));
                pnlClassroomCard.Visible = dtCL.Rows.Count > 0;
            }

            // Populate the context-aware secondary filter based on current type selection.
            PopulateSecondaryFilter(ddlTypeFilter.SelectedValue);
        }

        // Repopulates ddlSecondaryFilter based on the selected type.
        // "All"       → disabled, single "-- All --" item
        // "Subtopic"  → list of instructor's subtopics
        // "Classroom" → list of instructor's classrooms
        private void PopulateSecondaryFilter(string type)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            ddlSecondaryFilter.Items.Clear();

            if (type == "All")
            {
                ddlSecondaryFilter.Items.Add(new ListItem("-- All --", "0"));
                ddlSecondaryFilter.Enabled = false;
                litSecondaryLabel.Text     = "<span style='font-size:13px;color:var(--cp-text-muted);'>Filter by:</span>";
                return;
            }

            ddlSecondaryFilter.Enabled = true;

            if (type == "Subtopic")
            {
                litSecondaryLabel.Text = "<label class='cp-label' style='margin:0;white-space:nowrap;font-size:13px;'>Subtopic:</label>";
                ddlSecondaryFilter.Items.Add(new ListItem("-- All Subtopics --", "0"));

                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT st.SubTopicID,
                                 m.ModuleName + ' > ' + st.SubTopicName AS DisplayName
                          FROM   SubTopics st
                          INNER JOIN Modules m ON m.ModuleID = st.ModuleID
                          WHERE  st.CreatedByInstructorID = @ID
                          ORDER BY m.ModuleName, st.OrderIndex", conn))
                    {
                        cmd.Parameters.Add("@ID", SqlDbType.Int).Value = instructorID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                            while (rdr.Read())
                                ddlSecondaryFilter.Items.Add(
                                    new ListItem(rdr["DisplayName"].ToString(),
                                                 rdr["SubTopicID"].ToString()));
                    }
                }
            }
            else // Classroom
            {
                litSecondaryLabel.Text = "<label class='cp-label' style='margin:0;white-space:nowrap;font-size:13px;'>Classroom:</label>";
                ddlSecondaryFilter.Items.Add(new ListItem("-- All Classrooms --", "0"));

                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT ClassroomID, ClassroomName FROM Classrooms WHERE InstructorID=@ID ORDER BY ClassroomName",
                        conn))
                    {
                        cmd.Parameters.Add("@ID", SqlDbType.Int).Value = instructorID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                            while (rdr.Read())
                                ddlSecondaryFilter.Items.Add(
                                    new ListItem(rdr["ClassroomName"].ToString(),
                                                 rdr["ClassroomID"].ToString()));
                    }
                }
            }
        }

        // ── Load unified materials table ──────────────────────────────────────
        private void LoadMaterials()
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string typeFilter = ddlTypeFilter.SelectedValue; // "All", "Subtopic", "Classroom"

            int secondaryID = 0;
            int.TryParse(ddlSecondaryFilter.SelectedValue, out secondaryID);

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            // UNION of LearningMaterials (Subtopic) + ClassroomMaterials (Classroom).
            // @SecondaryID filters the relevant FK for whichever type is active.
            string sql = @"
                SELECT
                    lm.MaterialID           AS RecordID,
                    lm.FileName,
                    lm.FilePath,
                    lm.UploadedAt,
                    'Subtopic'              AS MaterialType,
                    m.ModuleName + ' > ' + st.SubTopicName AS LinkedTo
                FROM LearningMaterials lm
                INNER JOIN SubTopics st ON st.SubTopicID = lm.SubTopicID
                INNER JOIN Modules   m  ON m.ModuleID    = st.ModuleID
                WHERE lm.InstructorID = @IID
                  AND (@TypeFilter IN ('All','Subtopic'))
                  AND (@SecondaryID = 0 OR lm.SubTopicID = @SecondaryID)

                UNION ALL

                SELECT
                    cm.ClassroomMaterialID  AS RecordID,
                    cm.FileName,
                    cm.FilePath,
                    cm.UploadedAt,
                    'Classroom'             AS MaterialType,
                    c.ClassroomName         AS LinkedTo
                FROM ClassroomMaterials cm
                INNER JOIN Classrooms c ON c.ClassroomID = cm.ClassroomID
                WHERE cm.InstructorID = @IID
                  AND (@TypeFilter IN ('All','Classroom'))
                  AND (@SecondaryID = 0 OR cm.ClassroomID = @SecondaryID)

                ORDER BY UploadedAt DESC";

            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@IID",         SqlDbType.Int).Value          = instructorID;
                        cmd.Parameters.Add("@TypeFilter",  SqlDbType.NVarChar, 20).Value = typeFilter;
                        cmd.Parameters.Add("@SecondaryID", SqlDbType.Int).Value           = secondaryID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }
                }

                if (dt.Rows.Count > 0)
                {
                    rptMaterials.DataSource = dt;
                    rptMaterials.DataBind();
                    pnlMaterials.Visible = true;
                    pnlEmpty.Visible     = false;
                }
                else
                {
                    pnlMaterials.Visible = false;
                    pnlEmpty.Visible     = true;
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load materials. Please try again.");
            }
        }

        // ── Filter change handlers ────────────────────────────────────────────
        protected void ddlTypeFilter_Changed(object sender, EventArgs e)
        {
            // Repopulate secondary filter for the newly selected type, reset to "All".
            PopulateSecondaryFilter(ddlTypeFilter.SelectedValue);
            pnlMaterials.Visible = false;
            pnlEmpty.Visible     = false;
            LoadMaterials();
        }

        protected void ddlSecondaryFilter_Changed(object sender, EventArgs e)
        {
            pnlMaterials.Visible = false;
            pnlEmpty.Visible     = false;
            LoadMaterials();
        }

        // ── Upload: Subtopic material ─────────────────────────────────────────
        protected void btnUploadSubtopic_Click(object sender, EventArgs e)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);

            int subTopicID;
            if (!int.TryParse(ddlSubTopicUpload.SelectedValue, out subTopicID) || subTopicID == 0)
            {
                ShowError("Please select a subtopic.");
                return;
            }

            string originalName, ext;
            if (!ValidateUploadedFile(fuMaterial, out originalName, out ext)) return;

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Ownership check.
                    using (SqlCommand chk = new SqlCommand(
                        "SELECT COUNT(*) FROM SubTopics WHERE SubTopicID=@SID AND CreatedByInstructorID=@IID", conn))
                    {
                        chk.Parameters.Add("@SID", SqlDbType.Int).Value = subTopicID;
                        chk.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        if (Convert.ToInt32(chk.ExecuteScalar()) == 0)
                        { ShowError("You do not own the selected subtopic."); return; }
                    }

                    string storedName = BuildStoredName(originalName, ext);
                    string uploadDir  = Server.MapPath("~/uploads/materials/");
                    if (!Directory.Exists(uploadDir)) Directory.CreateDirectory(uploadDir);
                    fuMaterial.PostedFile.SaveAs(Path.Combine(uploadDir, storedName));
                    string webPath = "/uploads/materials/" + storedName;

                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO LearningMaterials
                            (SubTopicID, InstructorID, FileName, FilePath, UploadedAt)
                          VALUES (@SID, @IID, @FName, @FPath, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@SID",   SqlDbType.Int).Value           = subTopicID;
                        cmd.Parameters.Add("@IID",   SqlDbType.Int).Value           = instructorID;
                        cmd.Parameters.Add("@FName", SqlDbType.NVarChar, 255).Value = originalName;
                        cmd.Parameters.Add("@FPath", SqlDbType.NVarChar, 500).Value = webPath;
                        cmd.ExecuteNonQuery();
                    }

                    Utils.SendNotification(conn, instructorID,
                        "Material \"" + originalName + "\" uploaded for subtopic.", "Material");
                }

                ShowSuccess("Material uploaded for subtopic.");
                LoadMaterials();
            }
            catch (SqlException) { ShowError("Could not save material record. Please try again."); }
            catch (Exception)    { ShowError("File could not be saved. Please try again."); }
        }

        // ── Upload: Classroom material ────────────────────────────────────────
        protected void btnUploadClassroom_Click(object sender, EventArgs e)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);

            int classroomID;
            if (!int.TryParse(ddlClassroomUpload.SelectedValue, out classroomID) || classroomID == 0)
            {
                ShowError("Please select a classroom.");
                return;
            }

            string originalName, ext;
            if (!ValidateUploadedFile(fuClassroomMaterial, out originalName, out ext)) return;

            string description = txtClassroomDescription.Text.Trim();
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Ownership check.
                    using (SqlCommand chk = new SqlCommand(
                        "SELECT COUNT(*) FROM Classrooms WHERE ClassroomID=@CID AND InstructorID=@IID", conn))
                    {
                        chk.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        chk.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        if (Convert.ToInt32(chk.ExecuteScalar()) == 0)
                        { ShowError("You do not own the selected classroom."); return; }
                    }

                    string storedName = BuildStoredName(originalName, ext);
                    string uploadDir  = Server.MapPath("~/uploads/classroom/" + classroomID + "/");
                    if (!Directory.Exists(uploadDir)) Directory.CreateDirectory(uploadDir);
                    fuClassroomMaterial.PostedFile.SaveAs(Path.Combine(uploadDir, storedName));
                    string webPath = "/uploads/classroom/" + classroomID + "/" + storedName;

                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO ClassroomMaterials
                            (ClassroomID, InstructorID, FileName, FilePath, Description, UploadedAt)
                          VALUES (@CID, @IID, @FName, @FPath, @Desc, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@CID",   SqlDbType.Int).Value           = classroomID;
                        cmd.Parameters.Add("@IID",   SqlDbType.Int).Value           = instructorID;
                        cmd.Parameters.Add("@FName", SqlDbType.NVarChar, 255).Value = originalName;
                        cmd.Parameters.Add("@FPath", SqlDbType.NVarChar, 500).Value = webPath;
                        cmd.Parameters.Add("@Desc",  SqlDbType.NVarChar, 500).Value =
                            string.IsNullOrEmpty(description) ? (object)DBNull.Value : description;
                        cmd.ExecuteNonQuery();
                    }

                    Utils.SendNotification(conn, instructorID,
                        "Material \"" + originalName + "\" uploaded for classroom.", "Material");
                }

                txtClassroomDescription.Text = string.Empty;
                ShowSuccess("Material uploaded for classroom.");
                LoadMaterials();
            }
            catch (SqlException) { ShowError("Could not save material record. Please try again."); }
            catch (Exception)    { ShowError("File could not be saved. Please try again."); }
        }

        // ── Delete (handles both types) ───────────────────────────────────────
        protected void rptMaterials_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Delete") return;

            // CommandArgument: "RecordID|MaterialType"
            string[] parts = e.CommandArgument.ToString().Split('|');
            int    recordID    = Convert.ToInt32(parts[0]);
            string matType     = parts.Length > 1 ? parts[1] : "Subtopic";

            if (matType == "Classroom")
                DeleteClassroomMaterial(recordID);
            else
                DeleteSubtopicMaterial(recordID);
        }

        private void DeleteSubtopicMaterial(int materialID)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    string filePath = null, fileName = null;
                    using (SqlCommand get = new SqlCommand(
                        "SELECT FilePath, FileName FROM LearningMaterials WHERE MaterialID=@ID AND InstructorID=@IID",
                        conn))
                    {
                        get.Parameters.Add("@ID",  SqlDbType.Int).Value = materialID;
                        get.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        using (SqlDataReader rdr = get.ExecuteReader())
                        {
                            if (!rdr.Read()) return;
                            filePath = rdr["FilePath"].ToString();
                            fileName = rdr["FileName"].ToString();
                        }
                    }
                    using (SqlCommand del = new SqlCommand(
                        "DELETE FROM LearningMaterials WHERE MaterialID=@ID AND InstructorID=@IID", conn))
                    {
                        del.Parameters.Add("@ID",  SqlDbType.Int).Value = materialID;
                        del.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        del.ExecuteNonQuery();
                    }
                    Utils.SendNotification(conn, instructorID,
                        "Material \"" + (fileName ?? "file") + "\" was removed.", "Material");
                    TryDeleteFile(filePath);
                }
                ShowSuccess("Material removed.");
                LoadMaterials();
            }
            catch (SqlException) { ShowError("Could not remove material. Please try again."); }
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
                    string filePath = null, fileName = null;
                    using (SqlCommand get = new SqlCommand(
                        "SELECT FilePath, FileName FROM ClassroomMaterials WHERE ClassroomMaterialID=@ID AND InstructorID=@IID",
                        conn))
                    {
                        get.Parameters.Add("@ID",  SqlDbType.Int).Value = materialID;
                        get.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        using (SqlDataReader rdr = get.ExecuteReader())
                        {
                            if (!rdr.Read()) return;
                            filePath = rdr["FilePath"].ToString();
                            fileName = rdr["FileName"].ToString();
                        }
                    }
                    using (SqlCommand del = new SqlCommand(
                        "DELETE FROM ClassroomMaterials WHERE ClassroomMaterialID=@ID AND InstructorID=@IID",
                        conn))
                    {
                        del.Parameters.Add("@ID",  SqlDbType.Int).Value = materialID;
                        del.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        del.ExecuteNonQuery();
                    }
                    Utils.SendNotification(conn, instructorID,
                        "Classroom material \"" + (fileName ?? "file") + "\" was removed.", "Material");
                    TryDeleteFile(filePath);
                }
                ShowSuccess("Material removed.");
                LoadMaterials();
            }
            catch (SqlException) { ShowError("Could not remove material. Please try again."); }
        }

        // ── Private helpers ───────────────────────────────────────────────────
        private bool ValidateUploadedFile(FileUpload fu, out string originalName, out string ext)
        {
            originalName = string.Empty;
            ext          = string.Empty;

            if (!fu.HasFile)
            {
                ShowError("Please choose a file to upload.");
                return false;
            }

            originalName = Path.GetFileName(fu.FileName);
            ext          = Path.GetExtension(originalName);

            if (!AllowedExtensions.Contains(ext))
            {
                ShowError("File type not allowed. Allowed: PDF, DOCX, PPTX, TXT, PNG, JPG.");
                return false;
            }

            if (fu.PostedFile.ContentLength > MaxFileSizeBytes)
            {
                ShowError("File exceeds the 10 MB size limit.");
                return false;
            }

            return true;
        }

        private static string BuildStoredName(string originalName, string ext)
        {
            string safe = System.Text.RegularExpressions.Regex.Replace(
                Path.GetFileNameWithoutExtension(originalName), @"[^a-zA-Z0-9_\-]", "_");
            return DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + safe + ext;
        }

        private void TryDeleteFile(string webPath)
        {
            if (string.IsNullOrEmpty(webPath)) return;
            try
            {
                string physical = Server.MapPath("~" + webPath);
                if (File.Exists(physical)) File.Delete(physical);
            }
            catch { /* non-critical */ }
        }

        private void ShowSuccess(string msg)
        {
            litSuccess.Text    = HttpUtility.HtmlEncode(msg);
            pnlSuccess.Visible = true;
            pnlError.Visible   = false;
        }

        private void ShowError(string msg)
        {
            litError.Text      = HttpUtility.HtmlEncode(msg);
            pnlError.Visible   = true;
            pnlSuccess.Visible = false;
        }
    }
}
