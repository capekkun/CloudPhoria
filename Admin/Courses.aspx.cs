using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Admin
{
    public partial class Courses : System.Web.UI.Page
    {
        private const int OPTION_COUNT = 4;

        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString; }
        }

        private int AdminID
        {
            get { return Convert.ToInt32(Session["UserID"]); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Manage Courses";

            if (!IsPostBack)
            {
                int subTopicID, moduleID;

                // Drill-down: manage questions for a specific subtopic.
                if (int.TryParse(Request.QueryString["subTopicID"], out subTopicID) && subTopicID > 0)
                {
                    ViewState["ManageSubTopicID"] = subTopicID;
                    pnlModulesSection.Visible = false;
                    BindQOptionRows();
                    LoadManageQuestions(subTopicID);
                    return;
                }

                // Drill-down: manage subtopics for a specific module.
                if (int.TryParse(Request.QueryString["moduleID"], out moduleID) && moduleID > 0)
                {
                    ViewState["ManageModuleID"] = moduleID;
                    pnlModulesSection.Visible = false;
                    LoadManageSubTopics(moduleID);
                    return;
                }

                LoadPathwayDropdown();
                LoadCourses();
            }
            else
            {
                BindQOptionRows();
            }
        }

        private void BindQOptionRows()
        {
            int[] rows = new int[OPTION_COUNT];
            for (int i = 0; i < OPTION_COUNT; i++) rows[i] = i + 1;
            rptQOptions.DataSource = rows;
            rptQOptions.DataBind();
        }

        // -----------------------------------------------------------
        // TOP-LEVEL: Pathways overview + Modules list (assign/publish)
        // -----------------------------------------------------------

        private void LoadPathwayDropdown()
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT PathwayID, PathwayName FROM Pathways ORDER BY PathwayName", conn))
                {
                    DataTable dt = new DataTable();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    ddlModulePathway.DataSource = dt;
                    ddlModulePathway.DataTextField = "PathwayName";
                    ddlModulePathway.DataValueField = "PathwayID";
                    ddlModulePathway.DataBind();
                    ddlModulePathway.Items.Insert(0, new ListItem("-- Select Pathway --", "0"));
                }
            }
        }

        private void LoadCourses()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    DataTable dtPathways = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT p.PathwayID, p.PathwayName, p.IsFoundation,
                          (SELECT COUNT(*) FROM Modules m WHERE m.PathwayID=p.PathwayID) AS ModuleCount
                          FROM Pathways p ORDER BY p.IsFoundation DESC, p.PathwayName", conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtPathways);
                    rptPathwaysAdmin.DataSource = dtPathways;
                    rptPathwaysAdmin.DataBind();

                    DataTable dtModules = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT m.ModuleID, m.ModuleName, m.IsPublished, m.CreatedByInstructorID,
                                 p.PathwayName,
                                 (SELECT COUNT(*) FROM SubTopics st WHERE st.ModuleID = m.ModuleID) AS SubTopicCount
                          FROM Modules m
                          INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
                          ORDER BY p.PathwayName, m.ModuleName", conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtModules);
                    rptModulesAdmin.DataSource = dtModules;
                    rptModulesAdmin.DataBind();
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load courses.");
            }
        }

        protected void rptModulesAdmin_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            DropDownList ddl = (DropDownList)e.Item.FindControl("ddlAssignInstructor");
            DataRowView row = (DataRowView)e.Item.DataItem;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    DataTable dtInst = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT i.InstructorID, u.FullName FROM Instructors i
                          INNER JOIN Users u ON u.UserID = i.InstructorID
                          WHERE i.LicenseStatus='Approved' ORDER BY u.FullName", conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtInst);

                    ddl.DataSource = dtInst;
                    ddl.DataTextField = "FullName";
                    ddl.DataValueField = "InstructorID";
                    ddl.DataBind();
                    ddl.Items.Insert(0, new ListItem("-- Unassigned --", "0"));

                    object currentInstructor = row["CreatedByInstructorID"];
                    if (currentInstructor != DBNull.Value)
                    {
                        ListItem item = ddl.Items.FindByValue(currentInstructor.ToString());
                        if (item != null) ddl.SelectedValue = currentInstructor.ToString();
                    }
                }
            }
            catch (SqlException) { }
        }

        protected void btnCreateModule_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { return; }

            int pathwayID;
            if (!int.TryParse(ddlModulePathway.SelectedValue, out pathwayID) || pathwayID == 0)
            {
                ShowError("Please select a pathway.");
                return;
            }

            string name = txtModuleName.Text.Trim();
            string desc = txtModuleDesc.Text.Trim();
            string difficulty = ddlModuleDifficulty.SelectedValue;
            int xpReward = 0; int.TryParse(txtModuleXP.Text.Trim(), out xpReward);
            int examDuration = 60; int.TryParse(txtModuleExamDuration.Text.Trim(), out examDuration);
            int passMark = 70; int.TryParse(txtModulePassMark.Text.Trim(), out passMark);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO Modules
                            (PathwayID, ModuleName, Description, DifficultyLevel,
                             XPReward, ExamDurationMinutes, ExamPassMarkPercent,
                             CreatedByInstructorID, IsPublished, CreatedAt)
                          VALUES
                            (@PathwayID, @Name, @Desc, @Difficulty,
                             @XP, @Duration, @PassMark,
                             NULL, 0, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@PathwayID", SqlDbType.Int).Value = pathwayID;
                        cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 150).Value = name;
                        cmd.Parameters.Add("@Desc", SqlDbType.NVarChar, -1).Value = string.IsNullOrEmpty(desc) ? (object)DBNull.Value : desc;
                        cmd.Parameters.Add("@Difficulty", SqlDbType.NVarChar, 10).Value = difficulty;
                        cmd.Parameters.Add("@XP", SqlDbType.Int).Value = xpReward;
                        cmd.Parameters.Add("@Duration", SqlDbType.Int).Value = examDuration;
                        cmd.Parameters.Add("@PassMark", SqlDbType.Int).Value = passMark;
                        cmd.ExecuteNonQuery();
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO AuditLogs (PerformedByUserID, ActionType, TargetTable, Details, CreatedAt)
                          VALUES (@UID, 'CREATE_MODULE', 'Modules', @Details, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = AdminID;
                        cmd.Parameters.Add("@Details", SqlDbType.NVarChar, -1).Value = name;
                        cmd.ExecuteNonQuery();
                    }
                }

                txtModuleName.Text = string.Empty;
                txtModuleDesc.Text = string.Empty;
                txtModuleXP.Text = "100";
                txtModuleExamDuration.Text = "60";
                txtModulePassMark.Text = "70";

                ShowSuccess("Module created. Assign it to an instructor below when ready.");
                LoadCourses();
            }
            catch (SqlException)
            {
                ShowError("Could not create module. Please try again.");
            }
        }

        protected void rptModulesAdmin_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int moduleID = Convert.ToInt32(e.CommandArgument);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    if (e.CommandName == "Assign")
                    {
                        DropDownList ddl = (DropDownList)e.Item.FindControl("ddlAssignInstructor");
                        int instructorID = Convert.ToInt32(ddl.SelectedValue);

                        if (instructorID > 0)
                        {
                            // Full ownership transfer: reassigning a module hands over
                            // management of everything inside it (subtopics, questions,
                            // materials, practice/exam questions) to the new instructor.
                            using (SqlTransaction tx = conn.BeginTransaction())
                            {
                                using (SqlCommand cmd = new SqlCommand(
                                    "UPDATE Modules SET CreatedByInstructorID=@IID WHERE ModuleID=@MID", conn, tx))
                                {
                                    cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                                    cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                                    cmd.ExecuteNonQuery();
                                }

                                using (SqlCommand cmd = new SqlCommand(
                                    "UPDATE SubTopics SET CreatedByInstructorID=@IID WHERE ModuleID=@MID", conn, tx))
                                {
                                    cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                                    cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                                    cmd.ExecuteNonQuery();
                                }

                                using (SqlCommand cmd = new SqlCommand(
                                    @"UPDATE q SET q.CreatedByInstructorID=@IID
                                      FROM Questions q
                                      INNER JOIN SubTopics st ON st.SubTopicID = q.SubTopicID
                                      WHERE st.ModuleID=@MID", conn, tx))
                                {
                                    cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                                    cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                                    cmd.ExecuteNonQuery();
                                }

                                using (SqlCommand cmd = new SqlCommand(
                                    @"UPDATE lm SET lm.InstructorID=@IID
                                      FROM LearningMaterials lm
                                      INNER JOIN SubTopics st ON st.SubTopicID = lm.SubTopicID
                                      WHERE st.ModuleID=@MID", conn, tx))
                                {
                                    cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                                    cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                                    cmd.ExecuteNonQuery();
                                }

                                using (SqlCommand cmd = new SqlCommand(
                                    "UPDATE PracticeQuestions SET CreatedByInstructorID=@IID WHERE ModuleID=@MID", conn, tx))
                                {
                                    cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                                    cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                                    cmd.ExecuteNonQuery();
                                }

                                using (SqlCommand cmd = new SqlCommand(
                                    "UPDATE ExamQuestions SET CreatedByInstructorID=@IID WHERE ModuleID=@MID", conn, tx))
                                {
                                    cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                                    cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                                    cmd.ExecuteNonQuery();
                                }

                                tx.Commit();
                            }

                            LogAction(conn, "ASSIGN_MODULE_INSTRUCTOR", "Modules", moduleID);
                            ShowSuccess("Module and all its content reassigned to the selected instructor.");
                        }
                        else
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                "UPDATE Modules SET CreatedByInstructorID=NULL WHERE ModuleID=@MID", conn))
                            {
                                cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                                cmd.ExecuteNonQuery();
                            }
                            LogAction(conn, "UNASSIGN_MODULE_INSTRUCTOR", "Modules", moduleID);
                            ShowSuccess("Module unassigned. Existing subtopics/questions/materials keep their current instructor.");
                        }
                    }
                    else if (e.CommandName == "TogglePublish")
                    {
                        bool currentlyPublished;
                        using (SqlCommand cmd = new SqlCommand("SELECT IsPublished FROM Modules WHERE ModuleID=@MID", conn))
                        {
                            cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                            currentlyPublished = Convert.ToBoolean(cmd.ExecuteScalar());
                        }
                        using (SqlCommand cmd = new SqlCommand("UPDATE Modules SET IsPublished=@Val WHERE ModuleID=@MID", conn))
                        {
                            cmd.Parameters.Add("@Val", SqlDbType.Bit).Value = !currentlyPublished;
                            cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                            cmd.ExecuteNonQuery();
                        }
                        LogAction(conn, currentlyPublished ? "UNPUBLISH_MODULE" : "PUBLISH_MODULE", "Modules", moduleID);
                        ShowSuccess(currentlyPublished ? "Module unpublished." : "Module published.");
                    }
                    else if (e.CommandName == "DeleteModule")
                    {
                        using (SqlCommand cmd = new SqlCommand("DELETE FROM Modules WHERE ModuleID=@MID", conn))
                        {
                            cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                            cmd.ExecuteNonQuery();
                        }
                        LogAction(conn, "DELETE_MODULE", "Modules", moduleID);
                        ShowSuccess("Module deleted.");
                    }
                }
                LoadCourses();
            }
            catch (SqlException)
            {
                ShowError("Could not update module. It may have related content — remove subtopics first.");
            }
        }

        // -----------------------------------------------------------
        // DRILL-DOWN: Manage SubTopics for a Module (?moduleID=)
        // -----------------------------------------------------------

        private void LoadManageSubTopics(int moduleID)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string moduleName = null;
                    using (SqlCommand cmd = new SqlCommand("SELECT ModuleName FROM Modules WHERE ModuleID=@MID", conn))
                    {
                        cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        object r = cmd.ExecuteScalar();
                        if (r == null || r == DBNull.Value)
                        {
                            ShowError("Module not found.");
                            return;
                        }
                        moduleName = r.ToString();
                    }

                    litManageModuleTitle.Text = HttpUtility.HtmlEncode(moduleName);
                    pnlManageSubTopics.Visible = true;

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT SubTopicID, SubTopicName, OrderIndex, XPReward, IsPublished,
                                 (SELECT COUNT(*) FROM Questions q WHERE q.SubTopicID = st.SubTopicID) AS QuestionCount
                          FROM SubTopics st
                          WHERE ModuleID=@MID
                          ORDER BY OrderIndex, SubTopicID", conn))
                    {
                        cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }

                    if (dt.Rows.Count > 0)
                    {
                        rptManageSubTopics.DataSource = dt;
                        rptManageSubTopics.DataBind();
                        pnlSubTopicsList.Visible = true;
                        pnlNoSubTopics.Visible = false;
                    }
                    else
                    {
                        pnlSubTopicsList.Visible = false;
                        pnlNoSubTopics.Visible = true;
                    }
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load subtopics.");
            }
        }

        protected void btnAddSubTopic_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { return; }

            int moduleID = (int)ViewState["ManageModuleID"];
            string name = txtSTName.Text.Trim();
            string content = txtSTContent.Text.Trim();
            int orderIndex = 0; int.TryParse(txtSTOrder.Text.Trim(), out orderIndex);
            int xpReward = 10; int.TryParse(txtSTXPReward.Text.Trim(), out xpReward);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO SubTopics
                            (ModuleID, SubTopicName, ContentBody, OrderIndex, XPReward, CreatedByInstructorID, IsPublished, CreatedAt)
                          VALUES (@MID, @Name, @Content, @Order, @XP, NULL, 0, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 150).Value = name;
                        cmd.Parameters.Add("@Content", SqlDbType.NVarChar, -1).Value = string.IsNullOrEmpty(content) ? (object)DBNull.Value : content;
                        cmd.Parameters.Add("@Order", SqlDbType.Int).Value = orderIndex;
                        cmd.Parameters.Add("@XP", SqlDbType.Int).Value = xpReward;
                        cmd.ExecuteNonQuery();
                    }

                    LogAction(conn, "CREATE_SUBTOPIC", "SubTopics", moduleID);
                }

                txtSTName.Text = string.Empty;
                txtSTContent.Text = string.Empty;
                txtSTOrder.Text = "0";
                txtSTXPReward.Text = "10";

                ShowSuccess("Subtopic created.");
                LoadManageSubTopics(moduleID);
            }
            catch (SqlException)
            {
                ShowError("Could not create subtopic. Please try again.");
            }
        }

        protected void rptManageSubTopics_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int subTopicID = Convert.ToInt32(e.CommandArgument);
            int moduleID = (int)ViewState["ManageModuleID"];

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    if (e.CommandName == "TogglePublishST")
                    {
                        bool current;
                        using (SqlCommand cmd = new SqlCommand("SELECT IsPublished FROM SubTopics WHERE SubTopicID=@ID", conn))
                        {
                            cmd.Parameters.Add("@ID", SqlDbType.Int).Value = subTopicID;
                            current = Convert.ToBoolean(cmd.ExecuteScalar());
                        }
                        using (SqlCommand cmd = new SqlCommand("UPDATE SubTopics SET IsPublished=@Val WHERE SubTopicID=@ID", conn))
                        {
                            cmd.Parameters.Add("@Val", SqlDbType.Bit).Value = !current;
                            cmd.Parameters.Add("@ID", SqlDbType.Int).Value = subTopicID;
                            cmd.ExecuteNonQuery();
                        }
                        LogAction(conn, current ? "UNPUBLISH_SUBTOPIC" : "PUBLISH_SUBTOPIC", "SubTopics", subTopicID);
                        ShowSuccess(current ? "Subtopic set to draft." : "Subtopic published.");
                    }
                    else if (e.CommandName == "DeleteSubTopic")
                    {
                        using (SqlCommand cmd = new SqlCommand("DELETE FROM SubTopics WHERE SubTopicID=@ID", conn))
                        {
                            cmd.Parameters.Add("@ID", SqlDbType.Int).Value = subTopicID;
                            cmd.ExecuteNonQuery();
                        }
                        LogAction(conn, "DELETE_SUBTOPIC", "SubTopics", subTopicID);
                        ShowSuccess("Subtopic deleted.");
                    }
                }

                LoadManageSubTopics(moduleID);
            }
            catch (SqlException)
            {
                ShowError("Could not update subtopic. It may have related questions/materials — remove those first.");
            }
        }

        // -----------------------------------------------------------
        // DRILL-DOWN: Manage Questions for a SubTopic (?subTopicID=)
        // -----------------------------------------------------------

        private void LoadManageQuestions(int subTopicID)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string subTopicName = null;
                    using (SqlCommand cmd = new SqlCommand("SELECT SubTopicName FROM SubTopics WHERE SubTopicID=@SID", conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = subTopicID;
                        object r = cmd.ExecuteScalar();
                        if (r == null || r == DBNull.Value)
                        {
                            ShowError("Subtopic not found.");
                            return;
                        }
                        subTopicName = r.ToString();
                    }

                    litManageSubTopicTitle.Text = HttpUtility.HtmlEncode(subTopicName);
                    pnlManageQuestions.Visible = true;

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT QuestionID, QuestionText, QuestionType, XPReward, OrderIndex
                          FROM Questions WHERE SubTopicID=@SID ORDER BY OrderIndex, QuestionID", conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = subTopicID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }

                    if (dt.Rows.Count > 0)
                    {
                        rptManageQuestions.DataSource = dt;
                        rptManageQuestions.DataBind();
                        pnlQuestionsList.Visible = true;
                        pnlNoQuestions.Visible = false;
                    }
                    else
                    {
                        pnlQuestionsList.Visible = false;
                        pnlNoQuestions.Visible = true;
                    }
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load questions.");
            }
        }

        protected string GetQTypeBadge(string type)
        {
            switch (type)
            {
                case "MCQ": return "cp-badge-blue";
                case "Regex": return "cp-badge-indigo";
                case "StringMatch": return "cp-badge-green";
                default: return "cp-badge-grey";
            }
        }

        protected void ddlQuestionType_Changed(object sender, EventArgs e)
        {
            pnlMCQOptionsAdmin.Visible = ddlQuestionType.SelectedValue == "MCQ";
        }

        protected void btnAddQuestion_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { return; }

            int subTopicID = (int)ViewState["ManageSubTopicID"];
            string questionText = txtQText.Text.Trim();
            string questionType = ddlQuestionType.SelectedValue;
            string correctAnswer = txtQCorrectAnswer.Text.Trim();
            int xpReward = 5; int.TryParse(txtQXPReward.Text.Trim(), out xpReward);
            int orderIndex = 0; int.TryParse(txtQOrder.Text.Trim(), out orderIndex);

            if (string.IsNullOrEmpty(correctAnswer))
            {
                ShowError("Correct answer is required.");
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    int questionID;
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO Questions
                            (SubTopicID, QuestionText, QuestionType, CorrectAnswer, OrderIndex, XPReward, CreatedByInstructorID)
                          OUTPUT INSERTED.QuestionID
                          VALUES (@SID, @Text, @Type, @Correct, @Order, @XP, NULL)", conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = subTopicID;
                        cmd.Parameters.Add("@Text", SqlDbType.NVarChar, -1).Value = questionText;
                        cmd.Parameters.Add("@Type", SqlDbType.NVarChar, 20).Value = questionType;
                        cmd.Parameters.Add("@Correct", SqlDbType.NVarChar, -1).Value = correctAnswer;
                        cmd.Parameters.Add("@Order", SqlDbType.Int).Value = orderIndex;
                        cmd.Parameters.Add("@XP", SqlDbType.Int).Value = xpReward;
                        questionID = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    if (questionType == "MCQ")
                    {
                        foreach (RepeaterItem item in rptQOptions.Items)
                        {
                            TextBox txtOpt = (TextBox)item.FindControl("txtQOption");
                            CheckBox chkCorr = (CheckBox)item.FindControl("chkQCorrect");
                            if (txtOpt == null || string.IsNullOrWhiteSpace(txtOpt.Text)) continue;

                            using (SqlCommand optCmd = new SqlCommand(
                                @"INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect)
                                  VALUES (@QID, @Opt, @Correct)", conn))
                            {
                                optCmd.Parameters.Add("@QID", SqlDbType.Int).Value = questionID;
                                optCmd.Parameters.Add("@Opt", SqlDbType.NVarChar, -1).Value = txtOpt.Text.Trim();
                                optCmd.Parameters.Add("@Correct", SqlDbType.Bit).Value = (chkCorr != null && chkCorr.Checked) ? 1 : 0;
                                optCmd.ExecuteNonQuery();
                            }
                        }
                    }

                    LogAction(conn, "CREATE_QUESTION", "Questions", questionID);
                }

                txtQText.Text = string.Empty;
                txtQCorrectAnswer.Text = string.Empty;
                txtQXPReward.Text = "5";
                txtQOrder.Text = "0";
                BindQOptionRows();

                ShowSuccess("Question added.");
                LoadManageQuestions(subTopicID);
            }
            catch (SqlException)
            {
                ShowError("Could not add the question. Please try again.");
            }
        }

        protected void rptManageQuestions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "DeleteQuestion") return;

            int questionID = Convert.ToInt32(e.CommandArgument);
            int subTopicID = (int)ViewState["ManageSubTopicID"];

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("DELETE FROM AnswerOptions WHERE QuestionID=@ID", conn))
                    {
                        cmd.Parameters.Add("@ID", SqlDbType.Int).Value = questionID;
                        cmd.ExecuteNonQuery();
                    }

                    using (SqlCommand cmd = new SqlCommand("DELETE FROM Questions WHERE QuestionID=@ID", conn))
                    {
                        cmd.Parameters.Add("@ID", SqlDbType.Int).Value = questionID;
                        cmd.ExecuteNonQuery();
                    }

                    LogAction(conn, "DELETE_QUESTION", "Questions", questionID);
                }

                ShowSuccess("Question removed.");
                LoadManageQuestions(subTopicID);
            }
            catch (SqlException)
            {
                ShowError("Could not remove the question.");
            }
        }

        // -----------------------------------------------------------
        // Shared helpers
        // -----------------------------------------------------------

        private void LogAction(SqlConnection conn, string actionType, string targetTable, int? targetID)
        {
            try
            {
                using (SqlCommand cmd = new SqlCommand(
                    @"INSERT INTO AuditLogs (PerformedByUserID, ActionType, TargetTable, TargetID, CreatedAt)
                      VALUES (@UID, @Action, @Table, @TargetID, GETDATE())", conn))
                {
                    cmd.Parameters.Add("@UID", SqlDbType.Int).Value = AdminID;
                    cmd.Parameters.Add("@Action", SqlDbType.NVarChar, 100).Value = actionType;
                    cmd.Parameters.Add("@Table", SqlDbType.NVarChar, 100).Value = targetTable;
                    cmd.Parameters.Add("@TargetID", SqlDbType.Int).Value = targetID.HasValue ? (object)targetID.Value : DBNull.Value;
                    cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException) { }
        }

        private void ShowSuccess(string msg)
        {
            litSuccess.Text = HttpUtility.HtmlEncode(msg);
            pnlSuccess.Visible = true;
            pnlError.Visible = false;
        }

        private void ShowError(string msg)
        {
            litError.Text = HttpUtility.HtmlEncode(msg);
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
        }
    }
}
