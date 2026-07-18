using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class ExamStart : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Start Exam";

            if (!IsPostBack)
            {
                int moduleID;
                if (!int.TryParse(Request.QueryString["moduleID"], out moduleID))
                {
                    Response.Redirect("~/Student/Exams.aspx");
                    return;
                }
                LoadExamInfo(moduleID);
            }
        }

        private void LoadExamInfo(int moduleID)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT ModuleName, ExamDurationMinutes, ExamPassMarkPercent, XPReward
                          FROM Modules WHERE ModuleID = @MID AND IsPublished = 1", conn))
                    {
                        cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                litModuleName.Text = HttpUtility.HtmlEncode(rdr["ModuleName"].ToString());
                                litDuration.Text   = rdr["ExamDurationMinutes"].ToString();
                                litPassMark.Text   = rdr["ExamPassMarkPercent"].ToString();
                                litXPReward.Text   = rdr["XPReward"].ToString();
                                pnlExamInfo.Visible = true;
                            }
                            else
                            {
                                litError.Text = "Module not found or not published.";
                                pnlError.Visible = true;
                            }
                        }
                    }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load exam info. Please try again.";
                pnlError.Visible = true;
            }
        }

        protected void btnStartExam_Click(object sender, EventArgs e)
        {
            // Placeholder — full exam logic will be built later.
            // For now redirect back to exams with a message.
            Response.Redirect("~/Student/Exams.aspx");
        }
    }
}
