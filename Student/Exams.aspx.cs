using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class Exams : System.Web.UI.Page
    {
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString; }
        }

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
                    pnlListing.Visible = false;
                    ViewState["ExamModuleID"] = moduleID;
                    LoadExamIntro(moduleID);
                    return;
                }
                LoadExams();
            }
        }

        private void LoadExams()
        {
            int studentID = Convert.ToInt32(Session["UserID"]);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
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

        // -----------------------------------------------------------
        // ENTER EXAM FLOW
        // -----------------------------------------------------------

        private void LoadExamIntro(int moduleID)
        {
            int studentID = Convert.ToInt32(Session["UserID"]);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string moduleName = null;
                    int durationMin = 60, passMark = 70, xpReward = 0;

                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT ModuleName, ExamDurationMinutes, ExamPassMarkPercent, XPReward
                          FROM Modules WHERE ModuleID=@MID AND IsPublished=1", conn))
                    {
                        cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (!rdr.Read())
                            {
                                litError.Text = "Module not found.";
                                pnlError.Visible = true;
                                return;
                            }
                            moduleName = rdr["ModuleName"].ToString();
                            durationMin = Convert.ToInt32(rdr["ExamDurationMinutes"]);
                            passMark = Convert.ToInt32(rdr["ExamPassMarkPercent"]);
                            xpReward = Convert.ToInt32(rdr["XPReward"]);
                        }
                    }

                    ViewState["ExamDurationMin"] = durationMin;
                    ViewState["ExamPassMark"] = passMark;
                    ViewState["ExamXPReward"] = xpReward;

                    litExamIntroTitle.Text = HttpUtility.HtmlEncode(moduleName);
                    litExamIntroDuration.Text = durationMin.ToString();
                    litExamIntroPassMark.Text = passMark.ToString();
                    litExamIntroXP.Text = xpReward.ToString();

                    // Already passed?
                    bool alreadyPassed;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM ExamAttempts WHERE StudentID=@SID AND ModuleID=@MID AND IsPassed=1", conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        alreadyPassed = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                    }

                    if (alreadyPassed)
                    {
                        litExamIntroMessage.Text = "You have already passed this module's exam.";
                        pnlExamIntroMessage.Visible = true;
                        pnlExamIntro.Visible = true;
                        pnlExamStartBtn.Visible = false;
                        return;
                    }

                    // Locked (subtopics not all completed)?
                    int subtopicCount, completedCount;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM SubTopics WHERE ModuleID=@MID AND IsPublished=1", conn))
                    {
                        cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        subtopicCount = Convert.ToInt32(cmd.ExecuteScalar());
                    }
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT COUNT(*) FROM SubTopicProgress stp
                          INNER JOIN SubTopics st ON st.SubTopicID = stp.SubTopicID
                          WHERE st.ModuleID=@MID AND stp.StudentID=@SID AND stp.Status='Completed'", conn))
                    {
                        cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        completedCount = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    if (subtopicCount == 0 || completedCount < subtopicCount)
                    {
                        litExamIntroMessage.Text = "This exam is locked. Complete all subtopics in this module first.";
                        pnlExamIntroMessage.Visible = true;
                        pnlExamIntro.Visible = true;
                        pnlExamStartBtn.Visible = false;
                        return;
                    }

                    int questionCount;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM ExamQuestions WHERE ModuleID=@MID", conn))
                    {
                        cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        questionCount = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    if (questionCount == 0)
                    {
                        litExamIntroMessage.Text = "This exam has no questions yet. Check back soon.";
                        pnlExamIntroMessage.Visible = true;
                        pnlExamIntro.Visible = true;
                        pnlExamStartBtn.Visible = false;
                        return;
                    }

                    litExamIntroQCount.Text = questionCount.ToString();
                    pnlExamIntro.Visible = true;
                    pnlExamStartBtn.Visible = true;
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load this exam.";
                pnlError.Visible = true;
            }
        }

        protected void btnStartExam_Click(object sender, EventArgs e)
        {
            int moduleID = (int)ViewState["ExamModuleID"];
            int studentID = Convert.ToInt32(Session["UserID"]);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    DateTime startedAt;
                    int attemptID;
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO ExamAttempts (StudentID, ModuleID, StartedAt, IsPassed, XPAwarded)
                          OUTPUT INSERTED.ExamAttemptID, INSERTED.StartedAt
                          VALUES (@SID, @MID, GETDATE(), 0, 0)", conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            rdr.Read();
                            attemptID = Convert.ToInt32(rdr["ExamAttemptID"]);
                            startedAt = Convert.ToDateTime(rdr["StartedAt"]);
                        }
                    }

                    ViewState["ExamAttemptID"] = attemptID;
                    ViewState["ExamStartedAt"] = startedAt;

                    List<int> qIDs = new List<int>();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT ExamQuestionID FROM ExamQuestions WHERE ModuleID=@MID ORDER BY OrderIndex, ExamQuestionID", conn))
                    {
                        cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read()) qIDs.Add(Convert.ToInt32(rdr["ExamQuestionID"]));
                        }
                    }

                    ViewState["ExamQuestionIDs"] = string.Join(",", qIDs);
                    ViewState["ExamQIndex"] = 0;
                    ViewState["ExamCorrectCount"] = 0;
                }

                pnlExamIntro.Visible = false;
                LoadCurrentExamQuestion();
            }
            catch (SqlException)
            {
                litError.Text = "Could not start the exam.";
                pnlError.Visible = true;
            }
        }

        private int GetRemainingSeconds()
        {
            int durationMin = (int)ViewState["ExamDurationMin"];
            DateTime startedAt = (DateTime)ViewState["ExamStartedAt"];
            int elapsed = (int)DateTime.Now.Subtract(startedAt).TotalSeconds;
            return (durationMin * 60) - elapsed;
        }

        private void LoadCurrentExamQuestion()
        {
            // Server-side authority: if time has run out, finish now regardless of
            // how many questions remain — the browser timer is a visual aid only.
            if (GetRemainingSeconds() <= 0)
            {
                FinishExam(true);
                return;
            }

            string csv = ViewState["ExamQuestionIDs"] != null ? ViewState["ExamQuestionIDs"].ToString() : "";
            int index = ViewState["ExamQIndex"] != null ? (int)ViewState["ExamQIndex"] : 0;
            List<int> qIDs = csv.Length > 0 ? csv.Split(',').Select(int.Parse).ToList() : new List<int>();

            if (index >= qIDs.Count)
            {
                FinishExam(false);
                return;
            }

            int qID = qIDs[index];

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string qText = null;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT QuestionText FROM ExamQuestions WHERE ExamQuestionID=@QID", conn))
                    {
                        cmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
                        object r = cmd.ExecuteScalar();
                        qText = r != null ? r.ToString() : "";
                    }

                    ViewState["ExamCurrentQID"] = qID;

                    litExamQText.Text = HttpUtility.HtmlEncode(qText);
                    litExamProgress.Text = (index + 1) + " / " + qIDs.Count;

                    DataTable dtOpts = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT OptionID, OptionText FROM ExamQuestionOptions WHERE ExamQuestionID=@QID ORDER BY NEWID()", conn))
                    {
                        cmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtOpts);
                    }

                    var sb = new System.Text.StringBuilder();
                    foreach (DataRow row in dtOpts.Rows)
                    {
                        string oid = row["OptionID"].ToString();
                        string otext = HttpUtility.HtmlEncode(row["OptionText"].ToString());
                        sb.AppendFormat("<div class='examq-opt' data-val='{0}'>{1}</div>", oid, otext);
                    }
                    litExamOptions.Text = sb.ToString();

                    hdnExamSelectedOption.Value = "";
                    pnlExamAnswer.Visible = true;
                    pnlExamArena.Visible = true;

                    int remaining = Math.Max(0, GetRemainingSeconds());
                    ScriptManager.RegisterStartupScript(this, GetType(), "startExamTimer",
                        "window.startExamTimer(" + remaining + ");", true);
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load the next question.";
                pnlError.Visible = true;
            }
        }

        protected void btnSubmitExamAnswer_Click(object sender, EventArgs e)
        {
            int selectedOptionID;
            if (!int.TryParse(hdnExamSelectedOption.Value, out selectedOptionID))
                selectedOptionID = 0; // no selection / timeout

            int qID = (int)ViewState["ExamCurrentQID"];
            int attemptID = (int)ViewState["ExamAttemptID"];
            int correctCount = (int)ViewState["ExamCorrectCount"];
            bool isCorrect = false;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    if (selectedOptionID > 0)
                    {
                        // Prevention of invalid option submissions — the option must
                        // actually belong to the current question.
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT IsCorrect FROM ExamQuestionOptions WHERE OptionID=@OID AND ExamQuestionID=@QID", conn))
                        {
                            cmd.Parameters.Add("@OID", SqlDbType.Int).Value = selectedOptionID;
                            cmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
                            object r = cmd.ExecuteScalar();
                            isCorrect = (r != null && Convert.ToBoolean(r));
                        }
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO ExamAnswers (ExamAttemptID, ExamQuestionID, SelectedOptionID, IsCorrect)
                          VALUES (@AID, @QID, @OID, @Correct)", conn))
                    {
                        cmd.Parameters.Add("@AID", SqlDbType.Int).Value = attemptID;
                        cmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
                        cmd.Parameters.Add("@OID", SqlDbType.Int).Value = selectedOptionID > 0 ? (object)selectedOptionID : DBNull.Value;
                        cmd.Parameters.Add("@Correct", SqlDbType.Bit).Value = isCorrect;
                        cmd.ExecuteNonQuery();
                    }
                }

                if (isCorrect) correctCount++;
                ViewState["ExamCorrectCount"] = correctCount;

                int index = (int)ViewState["ExamQIndex"];
                ViewState["ExamQIndex"] = index + 1;

                // Server-side time check after recording the answer — if the clock
                // ran out while the student was answering, stop here instead of
                // showing another question.
                if (GetRemainingSeconds() <= 0)
                {
                    FinishExam(true);
                    return;
                }

                LoadCurrentExamQuestion();
            }
            catch (SqlException)
            {
                litError.Text = "An error occurred submitting your answer.";
                pnlError.Visible = true;
            }
        }

        private void FinishExam(bool expired)
        {
            int moduleID = (int)ViewState["ExamModuleID"];
            int studentID = Convert.ToInt32(Session["UserID"]);
            int attemptID = (int)ViewState["ExamAttemptID"];
            int correctCount = ViewState["ExamCorrectCount"] != null ? (int)ViewState["ExamCorrectCount"] : 0;

            string csv = ViewState["ExamQuestionIDs"] != null ? ViewState["ExamQuestionIDs"].ToString() : "";
            int totalQuestions = csv.Length > 0 ? csv.Split(',').Length : 0;
            int passMark = (int)ViewState["ExamPassMark"];
            int xpReward = (int)ViewState["ExamXPReward"];

            decimal scorePercent = totalQuestions > 0
                ? Math.Round((decimal)correctCount * 100 / totalQuestions, 2)
                : 0;
            bool isPassed = scorePercent >= passMark;
            int xpAwarded = isPassed ? xpReward : 0;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlTransaction tx = conn.BeginTransaction())
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            @"UPDATE ExamAttempts SET SubmittedAt=GETDATE(), ScorePercent=@Score,
                                                       IsPassed=@Passed, XPAwarded=@XP
                              WHERE ExamAttemptID=@AID", conn, tx))
                        {
                            cmd.Parameters.Add("@Score", SqlDbType.Decimal).Value = scorePercent;
                            cmd.Parameters.Add("@Passed", SqlDbType.Bit).Value = isPassed;
                            cmd.Parameters.Add("@XP", SqlDbType.Int).Value = xpAwarded;
                            cmd.Parameters.Add("@AID", SqlDbType.Int).Value = attemptID;
                            cmd.ExecuteNonQuery();
                        }

                        if (isPassed && xpAwarded > 0)
                        {
                            // Prevention of duplicate XP awards — only award if the
                            // student has not already passed this module's exam before
                            // (this attempt just became the first passing one).
                            int priorPasses;
                            using (SqlCommand cmd = new SqlCommand(
                                @"SELECT COUNT(*) FROM ExamAttempts
                                  WHERE StudentID=@SID AND ModuleID=@MID AND IsPassed=1 AND ExamAttemptID<>@AID", conn, tx))
                            {
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                                cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                                cmd.Parameters.Add("@AID", SqlDbType.Int).Value = attemptID;
                                priorPasses = Convert.ToInt32(cmd.ExecuteScalar());
                            }

                            if (priorPasses == 0)
                            {
                                using (SqlCommand cmd = new SqlCommand(
                                    @"INSERT INTO XPTransactions (StudentID, SourceType, SourceID, XPAmount, CreatedAt)
                                      VALUES (@SID, 'ModuleExam', @MID, @XP, GETDATE())", conn, tx))
                                {
                                    cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                                    cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                                    cmd.Parameters.Add("@XP", SqlDbType.Int).Value = xpAwarded;
                                    cmd.ExecuteNonQuery();
                                }

                                using (SqlCommand cmd = new SqlCommand(
                                    "UPDATE Students SET TotalXP = TotalXP + @XP WHERE StudentID=@SID", conn, tx))
                                {
                                    cmd.Parameters.Add("@XP", SqlDbType.Int).Value = xpAwarded;
                                    cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                                    cmd.ExecuteNonQuery();
                                }
                            }
                            else
                            {
                                xpAwarded = 0; // Already passed before — do not report XP twice.
                            }
                        }

                        tx.Commit();
                    }
                }

                pnlExamArena.Visible = false;
                litExamFinalScore.Text = scorePercent.ToString("0.##");
                litExamFinalCorrect.Text = correctCount.ToString();
                litExamFinalTotal.Text = totalQuestions.ToString();
                litExamFinalXP.Text = xpAwarded.ToString();

                if (expired)
                {
                    litExamFinalExpiredNote.Text = "Time ran out — unanswered questions were counted as incorrect.";
                    pnlExamFinalExpiredNote.Visible = true;
                }

                if (isPassed)
                {
                    litExamFinalIcon.Text = "";
                    litExamFinalTitle.Text = "Exam Passed!";
                    pnlExamFinalXP.Visible = xpAwarded > 0;
                }
                else
                {
                    litExamFinalIcon.Text = "";
                    litExamFinalTitle.Text = "Exam Not Passed";
                }

                pnlExamFinalResult.Visible = true;
            }
            catch (SqlException)
            {
                litError.Text = "Could not save your exam result.";
                pnlError.Visible = true;
            }
        }
    }
}
