using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class PathwayDetail : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            { Response.Redirect("~/LogIn.aspx", true); return; }

            if (!IsPostBack)
            {
                int pathwayID;
                if (!int.TryParse(Request.QueryString["pathwayID"], out pathwayID))
                { Response.Redirect("~/Student/Pathways.aspx"); return; }
                ViewState["PathwayID"] = pathwayID;
                LoadPathway(pathwayID);
            }
        }

        private void LoadPathway(int pathwayID)
        {
            int studentID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Pathway info
                    string pathwayName = "";
                    string description = "";
                    bool isFoundation = false;

                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT PathwayName, Description, IsFoundation FROM Pathways WHERE PathwayID=@PID", conn))
                    {
                        cmd.Parameters.Add("@PID", SqlDbType.Int).Value = pathwayID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                pathwayName = rdr["PathwayName"].ToString();
                                description = rdr["Description"] != DBNull.Value ? rdr["Description"].ToString() : "";
                                isFoundation = Convert.ToBoolean(rdr["IsFoundation"]);
                            }
                            else
                            {
                                litError.Text = "Pathway not found.";
                                pnlError.Visible = true;
                                return;
                            }
                        }
                    }

                    // Subscription check — Free tier can only access Foundation pathway
                    bool isFreeTier = false;
                    if (!isFoundation)
                    {
                        bool isFoundationOnly = true;
                        using (SqlCommand cmd = new SqlCommand(
                            @"SELECT TOP 1 sp.CanAccessFoundationOnly FROM UserSubscriptions us
                              INNER JOIN SubscriptionPlans sp ON sp.PlanID=us.PlanID
                              WHERE us.StudentID=@SID AND us.IsActive=1 ORDER BY us.StartDate DESC", conn))
                        {
                            cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                            object r = cmd.ExecuteScalar();
                            isFoundationOnly = (r == null || r == DBNull.Value) ? true : Convert.ToBoolean(r);
                        }

                        if (isFoundationOnly)
                        {
                            isFreeTier = true; // Don't return — let them see the page but block enrollment
                        }
                    }

                    litPathwayName.Text = HttpUtility.HtmlEncode(pathwayName);
                    litDescription.Text = HttpUtility.HtmlEncode(description);
                    Page.Title = pathwayName;

                    if (isFoundation)
                        litFoundationBadge.Text = "<span style='background:rgba(34,197,94,0.15);color:#22C55E;padding:3px 10px;border-radius:12px;font-size:11px;font-weight:600;'>Free</span>";

                    // Certification info
                    int certID = 0;
                    string certName = "";
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT CertificationID, CertificateName FROM Certifications WHERE PathwayID=@PID", conn))
                    {
                        cmd.Parameters.Add("@PID", SqlDbType.Int).Value = pathwayID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                certID = Convert.ToInt32(rdr["CertificationID"]);
                                certName = rdr["CertificateName"].ToString();
                            }
                        }
                    }

                    if (certID > 0)
                    {
                        litCertBadge.Text = "<span>&#x1F3C5; Certification Available</span>";
                        litCertName.Text = HttpUtility.HtmlEncode(certName);
                        pnlCertification.Visible = true;

                        // Check if student already earned it
                        using (SqlCommand cmd2 = new SqlCommand(
                            "SELECT COUNT(*) FROM UserCertifications WHERE StudentID=@SID AND CertificationID=@CID", conn))
                        {
                            cmd2.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                            cmd2.Parameters.Add("@CID", SqlDbType.Int).Value = certID;
                            if (Convert.ToInt32(cmd2.ExecuteScalar()) > 0)
                                pnlCertEarned.Visible = true;
                        }
                    }

                    // Modules for this pathway with student progress
                    DataTable dtMods = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT m.ModuleID, m.ModuleName, m.DifficultyLevel, m.XPReward,
                                 m.ExamDurationMinutes, m.ExamPassMarkPercent,
                                 (SELECT COUNT(*) FROM SubTopics st WHERE st.ModuleID=m.ModuleID AND st.IsPublished=1) AS SubTopicCount,
                                 ISNULL(mp.Status, 'NotStarted') AS ProgressStatus
                          FROM Modules m
                          LEFT JOIN ModuleProgress mp ON mp.ModuleID=m.ModuleID AND mp.StudentID=@SID
                          WHERE m.PathwayID=@PID AND m.IsPublished=1
                          ORDER BY m.ModuleID", conn))
                    {
                        cmd.Parameters.Add("@PID", SqlDbType.Int).Value = pathwayID;
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtMods);
                    }

                    // Display columns
                    dtMods.Columns.Add("StatusText", typeof(string));
                    dtMods.Columns.Add("BadgeColour", typeof(string));

                    int totalModules = dtMods.Rows.Count;
                    int completedModules = 0;
                    int totalXP = 0;
                    bool hasEnrolled = false;
                    int avgDuration = 0;
                    int avgPass = 0;

                    foreach (DataRow row in dtMods.Rows)
                    {
                        totalXP += Convert.ToInt32(row["XPReward"]);
                        avgDuration += Convert.ToInt32(row["ExamDurationMinutes"]);
                        avgPass += Convert.ToInt32(row["ExamPassMarkPercent"]);

                        string status = row["ProgressStatus"].ToString();
                        switch (status)
                        {
                            case "Completed":
                                row["StatusText"] = "Completed";
                                row["BadgeColour"] = "green";
                                completedModules++;
                                hasEnrolled = true;
                                break;
                            case "InProgress":
                                row["StatusText"] = "In Progress";
                                row["BadgeColour"] = "blue";
                                hasEnrolled = true;
                                break;
                            default:
                                row["StatusText"] = "Not Started";
                                row["BadgeColour"] = "grey";
                                break;
                        }
                    }

                    litModuleCount.Text = totalModules.ToString();
                    litTotalXP.Text = totalXP.ToString();

                    if (totalModules > 0)
                    {
                        rptModules.DataSource = dtMods;
                        rptModules.DataBind();
                        pnlModules.Visible = true;

                        // Exam info
                        litExamDuration.Text = (avgDuration / totalModules).ToString();
                        litExamPass.Text = (avgPass / totalModules).ToString();
                        litExamModules.Text = totalModules.ToString();
                        pnlExamInfo.Visible = true;

                        // Per-module exam list (only if enrolled)
                        if (hasEnrolled)
                        {
                            DataTable dtExams = new DataTable();
                            using (SqlCommand cmd = new SqlCommand(
                                @"SELECT m.ModuleID, m.ModuleName, m.ExamDurationMinutes,
                                         m.ExamPassMarkPercent, m.XPReward,
                                         (SELECT COUNT(*) FROM ExamQuestions eq WHERE eq.ModuleID = m.ModuleID) AS ExamQCount,
                                         CASE WHEN EXISTS (SELECT 1 FROM ExamAttempts ea
                                             WHERE ea.StudentID=@SID AND ea.ModuleID=m.ModuleID AND ea.IsPassed=1)
                                             THEN 1 ELSE 0 END AS IsPassed,
                                         CASE WHEN (SELECT COUNT(*) FROM SubTopics st
                                             WHERE st.ModuleID=m.ModuleID AND st.IsPublished=1) > 0
                                             AND (SELECT COUNT(*) FROM SubTopics st
                                                  WHERE st.ModuleID=m.ModuleID AND st.IsPublished=1)
                                               = (SELECT COUNT(*) FROM SubTopicProgress stp
                                                  INNER JOIN SubTopics st2 ON st2.SubTopicID=stp.SubTopicID
                                                  WHERE st2.ModuleID=m.ModuleID AND stp.StudentID=@SID AND stp.Status='Completed')
                                             THEN 1 ELSE 0 END AS CanTakeExam
                                  FROM Modules m
                                  WHERE m.PathwayID=@PID AND m.IsPublished=1
                                  ORDER BY m.ModuleID", conn))
                            {
                                cmd.Parameters.Add("@PID", SqlDbType.Int).Value = pathwayID;
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtExams);
                            }

                            // Filter to only modules that have exam questions
                            DataTable dtExamsFiltered = dtExams.Clone();
                            foreach (DataRow row in dtExams.Rows)
                            {
                                if (Convert.ToInt32(row["ExamQCount"]) > 0)
                                    dtExamsFiltered.ImportRow(row);
                            }

                            if (dtExamsFiltered.Rows.Count > 0)
                            {
                                rptModuleExams.DataSource = dtExamsFiltered;
                                rptModuleExams.DataBind();
                                pnlModuleExams.Visible = true;
                            }
                        }
                    }
                    else
                    {
                        pnlNoModules.Visible = true;
                    }

                    // Enrollment state
                    if (hasEnrolled)
                    {
                        pnlAlreadyEnrolled.Visible = true;

                        // Progress
                        int pct = totalModules > 0 ? (completedModules * 100 / totalModules) : 0;
                        litProgressPct.Text = pct.ToString();
                        pwProgressBar.Style["width"] = pct + "%";
                        litProgressDetail.Text = completedModules + " of " + totalModules + " modules completed";
                        pnlProgress.Visible = true;
                    }
                    else if (isFreeTier)
                    {
                        // Show upgrade prompt instead of enroll
                        pnlUpgradeNeeded.Visible = true;
                    }
                    else
                    {
                        pnlEnroll.Visible = true;
                    }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load pathway. Please try again.";
                pnlError.Visible = true;
            }
        }

        protected void btnEnroll_Click(object sender, EventArgs e)
        {
            int pathwayID = ViewState["PathwayID"] != null ? (int)ViewState["PathwayID"] : 0;
            if (pathwayID == 0) return;

            int studentID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Enroll student in all published modules of the pathway
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO ModuleProgress (StudentID, ModuleID, Status)
                          SELECT @SID, m.ModuleID, 'InProgress'
                          FROM Modules m
                          WHERE m.PathwayID = @PID AND m.IsPublished = 1
                          AND NOT EXISTS (
                              SELECT 1 FROM ModuleProgress mp
                              WHERE mp.ModuleID = m.ModuleID AND mp.StudentID = @SID
                          )", conn))
                    {
                        cmd.Parameters.Add("@PID", SqlDbType.Int).Value = pathwayID;
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        cmd.ExecuteNonQuery();
                    }
                }

                // Refresh page
                Response.Redirect(Request.Url.ToString());
            }
            catch (SqlException)
            {
                litError.Text = "Could not enroll. Please try again.";
                pnlError.Visible = true;
            }
        }

        protected string DiffCol(string d)
        {
            switch (d) { case "Easy": return "#22C55E"; case "Medium": return "#F59E0B"; case "Hard": return "#EF4444"; default: return "#64748B"; }
        }
    }
}
