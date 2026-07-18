using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class PracticeQuiz : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Practice Quiz";

            if (!IsPostBack)
            {
                int moduleID;
                if (!int.TryParse(Request.QueryString["moduleID"], out moduleID))
                {
                    Response.Redirect("~/Student/Practice.aspx");
                    return;
                }
                LoadModuleInfo(moduleID);
            }
        }

        private void LoadModuleInfo(int moduleID)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT ModuleName FROM Modules WHERE ModuleID = @MID AND IsPublished = 1", conn))
                    {
                        cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        object r = cmd.ExecuteScalar();
                        if (r != null && r != DBNull.Value)
                        {
                            litModuleName.Text = HttpUtility.HtmlEncode(r.ToString());
                            pnlQuiz.Visible = true;
                        }
                        else
                        {
                            litError.Text = "Module not found.";
                            pnlError.Visible = true;
                        }
                    }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load the quiz. Please try again.";
                pnlError.Visible = true;
            }
        }
    }
}
