using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Instructor
{
    public partial class SubTopics : System.Web.UI.Page
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

            ((SiteMaster)Master).PageHeading = "Subtopics";

            if (!IsPostBack)
            {
                LoadModuleDropdowns();

                // Pre-select module from query string if supplied.
                int qsModuleID;
                if (int.TryParse(Request.QueryString["moduleID"], out qsModuleID) && qsModuleID > 0)
                {
                    if (ddlModule.Items.FindByValue(qsModuleID.ToString()) != null)
                        ddlModule.SelectedValue = qsModuleID.ToString();
                }

                LoadSubTopics();
            }
        }

        private void LoadModuleDropdowns()
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            string sql = @"
                SELECT ModuleID, ModuleName
                FROM   Modules
                WHERE  CreatedByInstructorID = @ID
                ORDER BY ModuleName";

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

            // Filter dropdown.
            ddlModule.DataSource     = dt;
            ddlModule.DataTextField  = "ModuleName";
            ddlModule.DataValueField = "ModuleID";
            ddlModule.DataBind();
            ddlModule.Items.Insert(0, new ListItem("-- All Modules --", "0"));

            // Create modal dropdown — same data.
            ddlModuleCreate.DataSource     = dt;
            ddlModuleCreate.DataTextField  = "ModuleName";
            ddlModuleCreate.DataValueField = "ModuleID";
            ddlModuleCreate.DataBind();
            ddlModuleCreate.Items.Insert(0, new ListItem("-- Select Module --", "0"));

            pnlAddBtn.Visible = dt.Rows.Count > 0;
        }

        private void LoadSubTopics()
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            int filterModuleID;
            int.TryParse(ddlModule.SelectedValue, out filterModuleID);

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            string sql = @"
                SELECT st.SubTopicID, st.SubTopicName, st.OrderIndex,
                       st.XPReward, st.IsPublished, m.ModuleName
                FROM   SubTopics st
                INNER JOIN Modules m ON m.ModuleID = st.ModuleID
                WHERE  st.CreatedByInstructorID = @InstructorID
                       AND (@ModuleID = 0 OR st.ModuleID = @ModuleID)
                ORDER BY m.ModuleName, st.OrderIndex, st.SubTopicID";

            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@InstructorID", SqlDbType.Int).Value = instructorID;
                        cmd.Parameters.Add("@ModuleID",     SqlDbType.Int).Value = filterModuleID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }
                }

                if (filterModuleID > 0 && dt.Rows.Count == 0)
                    litModuleContext.Text = "No subtopics found for the selected module.";

                if (dt.Rows.Count > 0)
                {
                    rptSubTopics.DataSource = dt;
                    rptSubTopics.DataBind();
                    pnlSubTopics.Visible = true;
                    pnlEmpty.Visible     = false;
                }
                else
                {
                    pnlSubTopics.Visible = false;
                    pnlEmpty.Visible     = true;
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load subtopics. Please try again.");
            }
        }

        protected void ddlModule_Changed(object sender, EventArgs e)
        {
            pnlSubTopics.Visible = false;
            pnlEmpty.Visible     = false;
            LoadSubTopics();
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { return; }

            int instructorID = Convert.ToInt32(Session["UserID"]);
            int moduleID;
            if (!int.TryParse(ddlModuleCreate.SelectedValue, out moduleID) || moduleID == 0)
            {
                ShowError("Please select a module.");
                return;
            }

            string name    = txtSubTopicName.Text.Trim();
            string content = txtContent.Text.Trim();
            int orderIndex = 0; int.TryParse(txtOrderIndex.Text.Trim(), out orderIndex);
            int xpReward   = 10; int.TryParse(txtSTXP.Text.Trim(), out xpReward);

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                // Verify the module belongs to this instructor.
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand chk = new SqlCommand(
                        "SELECT COUNT(*) FROM Modules WHERE ModuleID = @MID AND CreatedByInstructorID = @IID", conn))
                    {
                        chk.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        chk.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        if (Convert.ToInt32(chk.ExecuteScalar()) == 0)
                        {
                            ShowError("You do not own the selected module.");
                            return;
                        }
                    }

                    string sql = @"
                        INSERT INTO SubTopics
                            (ModuleID, SubTopicName, ContentBody, OrderIndex,
                             XPReward, CreatedByInstructorID, IsPublished, CreatedAt)
                        VALUES
                            (@ModuleID, @Name, @Content, @Order,
                             @XP, @InstructorID, 0, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@ModuleID",    SqlDbType.Int).Value           = moduleID;
                        cmd.Parameters.Add("@Name",        SqlDbType.NVarChar, 150).Value  = name;
                        cmd.Parameters.Add("@Content",     SqlDbType.NVarChar, -1).Value   = string.IsNullOrEmpty(content) ? (object)DBNull.Value : content;
                        cmd.Parameters.Add("@Order",       SqlDbType.Int).Value            = orderIndex;
                        cmd.Parameters.Add("@XP",          SqlDbType.Int).Value            = xpReward;
                        cmd.Parameters.Add("@InstructorID",SqlDbType.Int).Value            = instructorID;
                        cmd.ExecuteNonQuery();
                    }
                }

                txtSubTopicName.Text = string.Empty;
                txtContent.Text      = string.Empty;
                txtOrderIndex.Text   = "0";
                txtSTXP.Text         = "10";

                ShowSuccess("Subtopic created successfully.");
                pnlSubTopics.Visible = false;
                pnlEmpty.Visible     = false;
                LoadSubTopics();
            }
            catch (SqlException)
            {
                ShowError("Could not create subtopic. Please try again.");
            }
        }

        protected void rptSubTopics_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "TogglePublish")
            {
                string[] parts = e.CommandArgument.ToString().Split('|');
                int subTopicID = Convert.ToInt32(parts[0]);
                bool current   = Convert.ToBoolean(parts[1]);
                TogglePublish(subTopicID, current);
            }
            else if (e.CommandName == "Delete")
            {
                DeleteSubTopic(Convert.ToInt32(e.CommandArgument));
            }
        }

        private void TogglePublish(int subTopicID, bool current)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"UPDATE SubTopics SET IsPublished = @Status
                          WHERE SubTopicID = @ID AND CreatedByInstructorID = @InstructorID", conn))
                    {
                        cmd.Parameters.Add("@Status",      SqlDbType.Bit).Value = !current;
                        cmd.Parameters.Add("@ID",          SqlDbType.Int).Value = subTopicID;
                        cmd.Parameters.Add("@InstructorID",SqlDbType.Int).Value = instructorID;
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowSuccess(!current ? "Subtopic published." : "Subtopic set to draft.");
                pnlSubTopics.Visible = false;
                pnlEmpty.Visible     = false;
                LoadSubTopics();
            }
            catch (SqlException)
            {
                ShowError("Could not update subtopic status. Please try again.");
            }
        }

        private void DeleteSubTopic(int subTopicID)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "DELETE FROM SubTopics WHERE SubTopicID = @ID AND CreatedByInstructorID = @InstructorID",
                        conn))
                    {
                        cmd.Parameters.Add("@ID",          SqlDbType.Int).Value = subTopicID;
                        cmd.Parameters.Add("@InstructorID",SqlDbType.Int).Value = instructorID;
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowSuccess("Subtopic deleted.");
                pnlSubTopics.Visible = false;
                pnlEmpty.Visible     = false;
                LoadSubTopics();
            }
            catch (SqlException)
            {
                ShowError("Could not delete subtopic. Please try again.");
            }
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
