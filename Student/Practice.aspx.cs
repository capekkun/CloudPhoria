using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class Practice : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Practice";

            if (!IsPostBack) { LoadModules(); }
        }

        private void LoadModules()
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    // Only show modules that have at least one practice question.
                    string sql = @"
                        SELECT m.ModuleID, m.ModuleName, m.DifficultyLevel,
                               p.PathwayName,
                               (SELECT COUNT(*) FROM PracticeQuestions pq
                                WHERE pq.ModuleID = m.ModuleID) AS QuestionCount
                        FROM Modules m
                        INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
                        WHERE m.IsPublished = 1
                          AND (SELECT COUNT(*) FROM PracticeQuestions pq2
                               WHERE pq2.ModuleID = m.ModuleID) > 0
                        ORDER BY p.PathwayID, m.ModuleID";

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        da.Fill(dt);

                    dt.Columns.Add("DiffColour", typeof(string));
                    foreach (DataRow row in dt.Rows)
                        row["DiffColour"] = DiffColour(row["DifficultyLevel"].ToString());

                    if (dt.Rows.Count > 0)
                    {
                        rptModules.DataSource = dt;
                        rptModules.DataBind();
                        pnlModules.Visible = true;
                    }
                    else { pnlEmpty.Visible = true; }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load practice modules. Please try again.";
                pnlError.Visible = true;
            }
        }

        private string DiffColour(string d)
        {
            switch (d)
            {
                case "Easy":   return "#22C55E";
                case "Medium": return "#F59E0B";
                case "Hard":   return "#EF4444";
                default:       return "#64748B";
            }
        }
    }
}
