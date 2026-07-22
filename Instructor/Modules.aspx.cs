using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Instructor
{
    // READ-ONLY per the current authority model: only Admin can create, edit,
    // publish, or delete Modules (Admin/Courses.aspx). Instructors can only
    // view whatever modules an Admin has assigned to them via the
    // "Assign Instructor" cascade — this page no longer offers Create/Edit/
    // Publish/Delete actions.
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

        private void ShowError(string msg)
        {
            litError.Text      = HttpUtility.HtmlEncode(msg);
            pnlError.Visible   = true;
        }
    }
}
