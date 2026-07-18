using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class ModuleDetail : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            { Response.Redirect("~/LogIn.aspx", true); return; }

            if (!IsPostBack)
            {
                int moduleID;
                if (!int.TryParse(Request.QueryString["moduleID"], out moduleID))
                { Response.Redirect("~/Student/Pathways.aspx"); return; }
                LoadModule(moduleID);
            }
        }

        private void LoadModule(int moduleID)
        {
            int studentID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Module info
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT m.ModuleName, m.Description, m.DifficultyLevel, m.XPReward,
                                 m.ExamDurationMinutes, m.ExamPassMarkPercent,
                                 p.PathwayName
                          FROM Modules m
                          INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
                          WHERE m.ModuleID = @MID AND m.IsPublished = 1", conn))
                    {
                        cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                litModuleName.Text = HttpUtility.HtmlEncode(rdr["ModuleName"].ToString());
                                litModuleDesc.Text = HttpUtility.HtmlEncode(
                                    rdr["Description"] != DBNull.Value ? rdr["Description"].ToString() : "");
                                litPathway.Text    = HttpUtility.HtmlEncode(rdr["PathwayName"].ToString());
                                litDifficulty.Text = HttpUtility.HtmlEncode(rdr["DifficultyLevel"].ToString());
                                litDiffColour.Text = DiffCol(rdr["DifficultyLevel"].ToString());
                                litXP.Text         = rdr["XPReward"].ToString();
                                litExamDuration.Text = rdr["ExamDurationMinutes"].ToString();
                                litExamPass.Text   = rdr["ExamPassMarkPercent"].ToString();
                            }
                            else
                            {
                                litError.Text = "Module not found.";
                                pnlError.Visible = true;
                                return;
                            }
                        }
                    }

                    // Subtopics with student progress
                    DataTable dtSubs = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT st.SubTopicID, st.SubTopicName, st.XPReward, st.OrderIndex,
                                 ISNULL(stp.Status, 'NotStarted') AS ProgressStatus
                          FROM SubTopics st
                          LEFT JOIN SubTopicProgress stp ON stp.SubTopicID = st.SubTopicID
                              AND stp.StudentID = @SID
                          WHERE st.ModuleID = @MID AND st.IsPublished = 1
                          ORDER BY st.OrderIndex, st.SubTopicID", conn))
                    {
                        cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtSubs);
                    }

                    // Add display columns
                    dtSubs.Columns.Add("StatusClass", typeof(string));
                    dtSubs.Columns.Add("StatusIcon", typeof(string));
                    dtSubs.Columns.Add("StatusText", typeof(string));
                    dtSubs.Columns.Add("BadgeColour", typeof(string));

                    int completed = 0;
                    int total = dtSubs.Rows.Count;

                    foreach (DataRow row in dtSubs.Rows)
                    {
                        string status = row["ProgressStatus"].ToString();
                        switch (status)
                        {
                            case "Completed":
                                row["StatusClass"] = "st-ico-done";
                                row["StatusIcon"]  = "&#x2713;";
                                row["StatusText"]  = "Completed";
                                row["BadgeColour"] = "green";
                                completed++;
                                break;
                            case "InProgress":
                                row["StatusClass"] = "st-ico-progress";
                                row["StatusIcon"]  = "&#x25B6;";
                                row["StatusText"]  = "In Progress";
                                row["BadgeColour"] = "blue";
                                break;
                            default:
                                row["StatusClass"] = "st-ico-locked";
                                row["StatusIcon"]  = "&#x1F4D6;";
                                row["StatusText"]  = "Not Started";
                                row["BadgeColour"] = "grey";
                                break;
                        }
                    }

                    litSubCount.Text = total.ToString();

                    if (total > 0)
                    {
                        rptSubtopics.DataSource = dtSubs;
                        rptSubtopics.DataBind();
                        pnlSubtopics.Visible = true;

                        // Progress
                        int pct = total > 0 ? (completed * 100 / total) : 0;
                        litProgressPct.Text = pct.ToString();
                        progressBar.Style["width"] = pct + "%";
                        pnlProgress.Visible = true;
                    }
                    else
                    {
                        pnlNoSubtopics.Visible = true;
                        litSubCount.Text = "0";
                    }

                    // Show exam section if there are exam questions
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM ExamQuestions WHERE ModuleID=@MID", conn))
                    {
                        cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        int examQCount = Convert.ToInt32(cmd.ExecuteScalar());
                        if (examQCount > 0) pnlExam.Visible = true;
                    }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load module. Please try again.";
                pnlError.Visible = true;
            }
        }

        private string DiffCol(string d)
        {
            switch(d){ case"Easy":return"#22C55E";case"Medium":return"#F59E0B";case"Hard":return"#EF4444";default:return"#64748B";}
        }
    }
}
