using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Instructor
{
    // READ-ONLY per the current authority model: only Admin can create, edit,
    // publish, or delete SubTopics (Admin/Courses.aspx?moduleID=). Instructors
    // can only view whatever subtopics belong to modules assigned to them.
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
                LoadModuleDropdown();

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

        private void LoadModuleDropdown()
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

            ddlModule.DataSource     = dt;
            ddlModule.DataTextField  = "ModuleName";
            ddlModule.DataValueField = "ModuleID";
            ddlModule.DataBind();
            ddlModule.Items.Insert(0, new ListItem("-- All Modules --", "0"));
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
                WHERE  m.CreatedByInstructorID = @InstructorID
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

        private void ShowError(string msg)
        {
            litError.Text      = HttpUtility.HtmlEncode(msg);
            pnlError.Visible   = true;
        }
    }
}
