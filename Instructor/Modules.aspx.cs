using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Instructor
{
    public partial class Modules : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Instructor")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            // Only approved instructors may manage modules.
            string licenseStatus = Session["LicenseStatus"] != null
                                   ? Session["LicenseStatus"].ToString() : "Pending";
            if (licenseStatus != "Approved")
            {
                Response.Redirect("~/Instructor/Dashboard.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Modules";

            if (!IsPostBack)
            {
                LoadPathways();
                LoadModules();
            }
        }

        // Helper used in markup to map difficulty to a badge colour class.
        protected string GetDifficultyBadge(string difficulty)
        {
            switch (difficulty)
            {
                case "Easy":   return "cp-badge-green";
                case "Medium": return "cp-badge-amber";
                case "Hard":   return "cp-badge-red";
                default:       return "cp-badge-grey";
            }
        }

        private void LoadPathways()
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT PathwayID, PathwayName FROM Pathways ORDER BY PathwayName", conn))
                {
                    DataTable dt = new DataTable();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    ddlPathway.DataSource     = dt;
                    ddlPathway.DataTextField  = "PathwayName";
                    ddlPathway.DataValueField = "PathwayID";
                    ddlPathway.DataBind();
                    ddlPathway.Items.Insert(0, new ListItem("-- Select Pathway --", "0"));
                }
            }
        }

        private void LoadModules()
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            string sql = @"
                SELECT m.ModuleID, m.ModuleName, p.PathwayName,
                       m.DifficultyLevel, m.XPReward, m.IsPublished
                FROM   Modules m
                INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
                WHERE  m.CreatedByInstructorID = @ID
                ORDER BY m.CreatedAt DESC";

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

                if (dt.Rows.Count > 0)
                {
                    rptModules.DataSource = dt;
                    rptModules.DataBind();
                    pnlModules.Visible = true;
                }
                else
                {
                    pnlEmpty.Visible = true;
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load modules. Please try again.");
            }
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { return; }

            int instructorID = Convert.ToInt32(Session["UserID"]);
            int pathwayID;
            if (!int.TryParse(ddlPathway.SelectedValue, out pathwayID) || pathwayID == 0)
            {
                ShowError("Please select a pathway.");
                return;
            }

            string name       = txtModuleName.Text.Trim();
            string desc       = txtDescription.Text.Trim();
            string difficulty = ddlDifficulty.SelectedValue;

            int xpReward = 0;
            int.TryParse(txtXPReward.Text.Trim(), out xpReward);

            int examDuration = 60;
            int.TryParse(txtExamDuration.Text.Trim(), out examDuration);

            int passMark = 70;
            int.TryParse(txtPassMark.Text.Trim(), out passMark);

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    string sql = @"
                        INSERT INTO Modules
                            (PathwayID, ModuleName, Description, DifficultyLevel,
                             XPReward, ExamDurationMinutes, ExamPassMarkPercent,
                             CreatedByInstructorID, IsPublished, CreatedAt)
                        VALUES
                            (@PathwayID, @Name, @Desc, @Difficulty,
                             @XP, @Duration, @PassMark,
                             @InstructorID, 0, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@PathwayID",    SqlDbType.Int).Value          = pathwayID;
                        cmd.Parameters.Add("@Name",         SqlDbType.NVarChar, 150).Value = name;
                        cmd.Parameters.Add("@Desc",         SqlDbType.NVarChar, -1).Value  = string.IsNullOrEmpty(desc) ? (object)DBNull.Value : desc;
                        cmd.Parameters.Add("@Difficulty",   SqlDbType.NVarChar, 10).Value  = difficulty;
                        cmd.Parameters.Add("@XP",           SqlDbType.Int).Value           = xpReward;
                        cmd.Parameters.Add("@Duration",     SqlDbType.Int).Value           = examDuration;
                        cmd.Parameters.Add("@PassMark",     SqlDbType.Int).Value           = passMark;
                        cmd.Parameters.Add("@InstructorID", SqlDbType.Int).Value           = instructorID;
                        cmd.ExecuteNonQuery();
                    }
                }

                txtModuleName.Text   = string.Empty;
                txtDescription.Text  = string.Empty;
                txtXPReward.Text     = "100";
                txtExamDuration.Text = "60";
                txtPassMark.Text     = "70";

                ShowSuccess("Module created successfully.");
                ResetLists();
                LoadModules();
            }
            catch (SqlException)
            {
                ShowError("Could not create module. Please try again.");
            }
        }

        protected void rptModules_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "TogglePublish")
            {
                string[] parts = e.CommandArgument.ToString().Split('|');
                int moduleID   = Convert.ToInt32(parts[0]);
                bool current   = Convert.ToBoolean(parts[1]);
                TogglePublish(moduleID, current);
            }
            else if (e.CommandName == "Delete")
            {
                int moduleID = Convert.ToInt32(e.CommandArgument);
                DeleteModule(moduleID);
            }
        }

        private void TogglePublish(int moduleID, bool currentStatus)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    // Ownership check included in WHERE clause.
                    using (SqlCommand cmd = new SqlCommand(
                        @"UPDATE Modules SET IsPublished = @Status
                          WHERE ModuleID = @ID AND CreatedByInstructorID = @InstructorID", conn))
                    {
                        cmd.Parameters.Add("@Status",      SqlDbType.Bit).Value = !currentStatus;
                        cmd.Parameters.Add("@ID",          SqlDbType.Int).Value = moduleID;
                        cmd.Parameters.Add("@InstructorID",SqlDbType.Int).Value = instructorID;
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowSuccess(!currentStatus ? "Module published." : "Module set to draft.");
                ResetLists();
                LoadModules();
            }
            catch (SqlException)
            {
                ShowError("Could not update module status. Please try again.");
            }
        }

        private void DeleteModule(int moduleID)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    // Ownership check in WHERE clause.
                    using (SqlCommand cmd = new SqlCommand(
                        "DELETE FROM Modules WHERE ModuleID = @ID AND CreatedByInstructorID = @InstructorID",
                        conn))
                    {
                        cmd.Parameters.Add("@ID",          SqlDbType.Int).Value = moduleID;
                        cmd.Parameters.Add("@InstructorID",SqlDbType.Int).Value = instructorID;
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowSuccess("Module deleted.");
                ResetLists();
                LoadModules();
            }
            catch (SqlException)
            {
                ShowError("Could not delete module. It may have related content. Please remove subtopics first.");
            }
        }

        private void ResetLists()
        {
            pnlModules.Visible = false;
            pnlEmpty.Visible   = false;
        }

        private void ShowSuccess(string msg)
        {
            litSuccess.Text      = HttpUtility.HtmlEncode(msg);
            pnlSuccess.Visible   = true;
            pnlError.Visible     = false;
        }

        private void ShowError(string msg)
        {
            litError.Text      = HttpUtility.HtmlEncode(msg);
            pnlError.Visible   = true;
            pnlSuccess.Visible = false;
        }
    }
}
