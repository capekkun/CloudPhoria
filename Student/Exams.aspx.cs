using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class Exams : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Module Exams";

            if (!IsPostBack)
            {
                int moduleID;
                if (int.TryParse(Request.QueryString["moduleID"], out moduleID) && moduleID > 0)
                {
                    // Exam detail mode — show exam info for this module
                    // TODO: Full exam logic to be re-integrated here
                    LoadExams();
                    return;
                }
                LoadExams();
            }
        }

        private void LoadExams()
        {
            int studentID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Modules with exam questions that the student hasn't passed yet.
                    string availSql = @"
                        SELECT m.ModuleID, m.ModuleName,
                               m.ExamDurationMinutes, m.ExamPassMarkPercent, m.XPReward,
                               CASE WHEN (SELECT COUNT(*) FROM SubTopics st WHERE st.ModuleID=m.ModuleID AND st.IsPublished=1) > 0
                                    AND (SELECT COUNT(*) FROM SubTopics st WHERE st.ModuleID=m.ModuleID AND st.IsPublished=1)
                                      = (SELECT COUNT(*) FROM SubTopicProgress stp
                                         INNER JOIN SubTopics st2 ON st2.SubTopicID=stp.SubTopicID
                                         WHERE st2.ModuleID=m.ModuleID AND stp.StudentID=@StudentID AND stp.Status='Completed')
                                    THEN 1 ELSE 0 END AS IsUnlocked
                        FROM Modules m
                        WHERE m.IsPublished = 1
                          AND (SELECT COUNT(*) FROM ExamQuestions eq
                               WHERE eq.ModuleID = m.ModuleID) > 0
                          AND NOT EXISTS (
                              SELECT 1 FROM ExamAttempts ea
                              WHERE ea.StudentID = @StudentID
                                AND ea.ModuleID  = m.ModuleID
                                AND ea.IsPassed  = 1)
                        ORDER BY m.ModuleID";

                    DataTable dtAvail = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(availSql, conn))
                    {
                        cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtAvail);
                    }

                    if (dtAvail.Rows.Count > 0)
                    {
                        rptAvailable.DataSource = dtAvail;
                        rptAvailable.DataBind();
                        pnlAvailable.Visible = true;
                    }
                    else { pnlNoAvailable.Visible = true; }

                    // Past attempts with a submitted time (completed attempts).
                    string histSql = @"
                        SELECT m.ModuleName, ea.SubmittedAt,
                               ea.ScorePercent, ea.IsPassed, ea.XPAwarded
                        FROM ExamAttempts ea
                        INNER JOIN Modules m ON m.ModuleID = ea.ModuleID
                        WHERE ea.StudentID   = @StudentID
                          AND ea.SubmittedAt IS NOT NULL
                        ORDER BY ea.SubmittedAt DESC";

                    DataTable dtHist = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(histSql, conn))
                    {
                        cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtHist);
                    }

                    if (dtHist.Rows.Count > 0)
                    {
                        rptHistory.DataSource = dtHist;
                        rptHistory.DataBind();
                        pnlHistory.Visible = true;
                    }
                    else { pnlNoHistory.Visible = true; }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load exam data. Please try again.";
                pnlError.Visible = true;
            }
        }
    }
}
