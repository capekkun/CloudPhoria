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
        // Allowed upload extensions.
        private static readonly HashSet<string> AllowedExtensions = new HashSet<string>(
            StringComparer.OrdinalIgnoreCase)
        {
            ".pdf", ".docx", ".doc", ".pptx", ".ppt", ".txt", ".png", ".jpg", ".jpeg"
        };

        private const int MaxFileSizeBytes = 10 * 1024 * 1024; // 10 MB

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
                LoadSubTopicDropdowns();

                int qsID;
                if (int.TryParse(Request.QueryString["subTopicID"], out qsID) && qsID > 0)
                    if (ddlSubTopic.Items.FindByValue(qsID.ToString()) != null)
                        ddlSubTopic.SelectedValue = qsID.ToString();

                LoadMaterials();
            }
        }

        private void LoadSubTopicDropdowns()
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            string sql = @"
                SELECT st.SubTopicID,
                       m.ModuleName + ' > ' + st.SubTopicName AS DisplayName
                FROM   SubTopics st
                INNER JOIN Modules m ON m.ModuleID = st.ModuleID
                WHERE  st.CreatedByInstructorID = @ID
                ORDER BY m.ModuleName, st.OrderIndex";

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

            ddlSubTopic.DataSource       = dt;
            ddlSubTopic.DataTextField    = "DisplayName";
            ddlSubTopic.DataValueField   = "SubTopicID";
            ddlSubTopic.DataBind();
            ddlSubTopic.Items.Insert(0, new ListItem("-- All Subtopics --", "0"));

            ddlSubTopicUpload.DataSource     = dt;
            ddlSubTopicUpload.DataTextField  = "DisplayName";
            ddlSubTopicUpload.DataValueField = "SubTopicID";
            ddlSubTopicUpload.DataBind();
            ddlSubTopicUpload.Items.Insert(0, new ListItem("-- Select Subtopic --", "0"));

            pnlUploadBtn.Visible = dt.Rows.Count > 0;
        }

        private void LoadMaterials()
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            int filterID; int.TryParse(ddlSubTopic.SelectedValue, out filterID);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            string sql = @"
                SELECT lm.MaterialID, lm.FileName, lm.FilePath,
                       lm.UploadedAt, st.SubTopicName
                FROM   LearningMaterials lm
                INNER JOIN SubTopics st ON st.SubTopicID = lm.SubTopicID
                WHERE  lm.InstructorID = @IID
                       AND (@Filter = 0 OR lm.SubTopicID = @Filter)
                ORDER BY lm.UploadedAt DESC";

            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@IID",    SqlDbType.Int).Value = instructorID;
                        cmd.Parameters.Add("@Filter", SqlDbType.Int).Value = filterID;
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

        protected void ddlSubTopic_Changed(object sender, EventArgs e)
        {
            pnlMaterials.Visible = false;
            pnlEmpty.Visible     = false;
            LoadMaterials();
        }

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);

            int subTopicID;
            if (!int.TryParse(ddlSubTopicUpload.SelectedValue, out subTopicID) || subTopicID == 0)
            {
                ShowError("Please select a subtopic.");
                return;
            }

            if (!fuMaterial.HasFile)
            {
                ShowError("Please choose a file to upload.");
                return;
            }

            string originalName = Path.GetFileName(fuMaterial.FileName);
            string ext          = Path.GetExtension(originalName);

            if (!AllowedExtensions.Contains(ext))
            {
                ShowError("File type not allowed. Allowed: PDF, DOCX, PPTX, TXT, PNG, JPG.");
                return;
            }

            if (fuMaterial.PostedFile.ContentLength > MaxFileSizeBytes)
            {
                ShowError("File exceeds the 10 MB size limit.");
                return;
            }

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                // Verify subtopic ownership.
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand chk = new SqlCommand(
                        "SELECT COUNT(*) FROM SubTopics WHERE SubTopicID=@SID AND CreatedByInstructorID=@IID", conn))
                    {
                        chk.Parameters.Add("@SID", SqlDbType.Int).Value = subTopicID;
                        chk.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        if (Convert.ToInt32(chk.ExecuteScalar()) == 0)
                        {
                            ShowError("You do not own the selected subtopic.");
                            return;
                        }
                    }

                    // Build a safe stored file name: timestamp + safe original name.
                    string safeOriginal = Path.GetFileNameWithoutExtension(originalName);
                    safeOriginal = System.Text.RegularExpressions.Regex.Replace(safeOriginal, @"[^a-zA-Z0-9_\-]", "_");
                    string storedName = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + safeOriginal + ext;

                    // Physical save path.
                    string uploadDir = Server.MapPath("~/uploads/materials/");
                    if (!Directory.Exists(uploadDir))
                        Directory.CreateDirectory(uploadDir);

                    string physicalPath = Path.Combine(uploadDir, storedName);
                    fuMaterial.PostedFile.SaveAs(physicalPath);

                    string webPath = "/uploads/materials/" + storedName;

                    // Insert DB record.
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO LearningMaterials (SubTopicID, InstructorID, FileName, FilePath, UploadedAt)
                          VALUES (@SID, @IID, @FName, @FPath, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@SID",   SqlDbType.Int).Value           = subTopicID;
                        cmd.Parameters.Add("@IID",   SqlDbType.Int).Value           = instructorID;
                        cmd.Parameters.Add("@FName", SqlDbType.NVarChar, 255).Value = originalName;
                        cmd.Parameters.Add("@FPath", SqlDbType.NVarChar, 500).Value = webPath;
                        cmd.ExecuteNonQuery();
                    }
                }

                ShowSuccess("Material uploaded successfully.");
                pnlMaterials.Visible = false;
                pnlEmpty.Visible     = false;
                LoadMaterials();
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

        protected void rptMaterials_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Delete")
                DeleteMaterial(Convert.ToInt32(e.CommandArgument));
        }

        private void DeleteMaterial(int materialID)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    // Retrieve file path first so we can delete the physical file.
                    string filePath = null;
                    using (SqlCommand get = new SqlCommand(
                        "SELECT FilePath FROM LearningMaterials WHERE MaterialID=@ID AND InstructorID=@IID", conn))
                    {
                        get.Parameters.Add("@ID",  SqlDbType.Int).Value = materialID;
                        get.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        object r = get.ExecuteScalar();
                        if (r == null || r == DBNull.Value) return; // Not owned by this instructor.
                        filePath = r.ToString();
                    }

                    using (SqlCommand del = new SqlCommand(
                        "DELETE FROM LearningMaterials WHERE MaterialID=@ID AND InstructorID=@IID", conn))
                    {
                        del.Parameters.Add("@ID",  SqlDbType.Int).Value = materialID;
                        del.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        del.ExecuteNonQuery();
                    }

                    // Delete the physical file if it exists.
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
                pnlMaterials.Visible = false;
                pnlEmpty.Visible     = false;
                LoadMaterials();
            }
            catch (SqlException)
            {
                ShowError("Could not remove material. Please try again.");
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
