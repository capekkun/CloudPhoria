using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Instructor
{
    public partial class Questions : System.Web.UI.Page
    {
        // Repeater item count for MCQ options.
        private const int MCQ_OPTION_COUNT = 4;

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

            ((SiteMaster)Master).PageHeading = "Questions";

            if (!IsPostBack)
            {
                LoadSubTopicDropdowns();
                ConfigureTypePanel();

                // Pre-select from query string.
                int qsID;
                if (int.TryParse(Request.QueryString["subTopicID"], out qsID) && qsID > 0)
                {
                    if (ddlSubTopic.Items.FindByValue(qsID.ToString()) != null)
                        ddlSubTopic.SelectedValue = qsID.ToString();
                }

                LoadQuestions();
            }
            else
            {
                // Always rebind the MCQ option rows so FindControl works during postback.
                BindOptionRows();
            }
        }

        protected string GetTypeBadge(string type)
        {
            switch (type)
            {
                case "MCQ":         return "cp-badge-blue";
                case "Regex":       return "cp-badge-indigo";
                case "StringMatch": return "cp-badge-green";
                default:            return "cp-badge-grey";
            }
        }

        private void LoadSubTopicDropdowns()
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            string sql = @"
                SELECT st.SubTopicID,
                       m.ModuleName + ' > ' + st.SubTopicName AS DisplayName
                FROM   SubTopics st
                INNER JOIN Modules m ON m.ModuleID = st.ModuleID
                WHERE  st.CreatedByInstructorID = @ID
                ORDER BY m.ModuleName, st.OrderIndex";

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

            ddlSubTopic.DataSource       = dt;
            ddlSubTopic.DataTextField    = "DisplayName";
            ddlSubTopic.DataValueField   = "SubTopicID";
            ddlSubTopic.DataBind();
            ddlSubTopic.Items.Insert(0, new ListItem("-- All Subtopics --", "0"));

            ddlSubTopicCreate.DataSource     = dt;
            ddlSubTopicCreate.DataTextField  = "DisplayName";
            ddlSubTopicCreate.DataValueField = "SubTopicID";
            ddlSubTopicCreate.DataBind();
            ddlSubTopicCreate.Items.Insert(0, new ListItem("-- Select Subtopic --", "0"));

            pnlAddBtn.Visible = dt.Rows.Count > 0;

            BindOptionRows();
        }

        private void BindOptionRows()
        {
            // Bind a simple integer sequence so the Repeater renders MCQ option rows.
            int[] rows = new int[MCQ_OPTION_COUNT];
            for (int i = 0; i < MCQ_OPTION_COUNT; i++) rows[i] = i + 1;
            rptOptions.DataSource = rows;
            rptOptions.DataBind();
        }

        private void ConfigureTypePanel()
        {
            bool isMCQ = ddlQType.SelectedValue == "MCQ";
            pnlMCQOptions.Visible    = isMCQ;
            pnlCorrectAnswer.Visible = true; // always visible — needed for all types
        }

        protected void ddlQType_Changed(object sender, EventArgs e)
        {
            ConfigureTypePanel();
        }

        protected void ddlSubTopic_Changed(object sender, EventArgs e)
        {
            pnlQuestions.Visible = false;
            pnlEmpty.Visible     = false;
            LoadQuestions();
        }

        private void LoadQuestions()
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            int filterID;
            int.TryParse(ddlSubTopic.SelectedValue, out filterID);

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            string sql = @"
                SELECT q.QuestionID, q.QuestionText, q.QuestionType,
                       q.XPReward, q.OrderIndex, st.SubTopicName
                FROM   Questions q
                INNER JOIN SubTopics st ON st.SubTopicID = q.SubTopicID
                WHERE  q.CreatedByInstructorID = @InstructorID
                       AND (@Filter = 0 OR q.SubTopicID = @Filter)
                ORDER BY st.SubTopicName, q.OrderIndex";

            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@InstructorID", SqlDbType.Int).Value = instructorID;
                        cmd.Parameters.Add("@Filter",       SqlDbType.Int).Value = filterID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }
                }

                if (dt.Rows.Count > 0)
                {
                    rptQuestions.DataSource = dt;
                    rptQuestions.DataBind();
                    pnlQuestions.Visible = true;
                    pnlEmpty.Visible     = false;
                }
                else
                {
                    pnlQuestions.Visible = false;
                    pnlEmpty.Visible     = true;
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load questions. Please try again.");
            }
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { return; }

            int instructorID = Convert.ToInt32(Session["UserID"]);

            int subTopicID;
            if (!int.TryParse(ddlSubTopicCreate.SelectedValue, out subTopicID) || subTopicID == 0)
            {
                ShowError("Please select a subtopic.");
                return;
            }

            string questionText   = txtQuestionText.Text.Trim();
            string questionType   = ddlQType.SelectedValue;
            string correctAnswer  = txtCorrectAnswer.Text.Trim();
            int xpReward   = 5;  int.TryParse(txtQXP.Text.Trim(), out xpReward);
            int orderIndex = 0;  int.TryParse(txtOrderIdx.Text.Trim(), out orderIndex);

            if (string.IsNullOrEmpty(correctAnswer))
            {
                ShowError("Correct answer is required.");
                return;
            }

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Verify ownership of the subtopic.
                    using (SqlCommand chk = new SqlCommand(
                        "SELECT COUNT(*) FROM SubTopics WHERE SubTopicID=@SID AND CreatedByInstructorID=@IID", conn))
                    {
                        chk.Parameters.Add("@SID", SqlDbType.Int).Value = subTopicID;
                        chk.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        if (Convert.ToInt32(chk.ExecuteScalar()) == 0)
                        {
                            ShowError("You do not own the selected subtopic.");
                            return;
                        }
                    }

                    // Insert the question.
                    int questionID;
                    string insertSql = @"
                        INSERT INTO Questions
                            (SubTopicID, QuestionText, QuestionType, CorrectAnswer,
                             OrderIndex, XPReward, CreatedByInstructorID)
                        OUTPUT INSERTED.QuestionID
                        VALUES (@SubTopicID, @Text, @Type, @Correct, @Order, @XP, @IID)";

                    using (SqlCommand cmd = new SqlCommand(insertSql, conn))
                    {
                        cmd.Parameters.Add("@SubTopicID", SqlDbType.Int).Value           = subTopicID;
                        cmd.Parameters.Add("@Text",       SqlDbType.NVarChar, -1).Value  = questionText;
                        cmd.Parameters.Add("@Type",       SqlDbType.NVarChar, 20).Value  = questionType;
                        cmd.Parameters.Add("@Correct",    SqlDbType.NVarChar, -1).Value  = correctAnswer;
                        cmd.Parameters.Add("@Order",      SqlDbType.Int).Value           = orderIndex;
                        cmd.Parameters.Add("@XP",         SqlDbType.Int).Value           = xpReward;
                        cmd.Parameters.Add("@IID",        SqlDbType.Int).Value           = instructorID;
                        questionID = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // Insert MCQ options when question type is MCQ.
                    if (questionType == "MCQ")
                    {
                        foreach (RepeaterItem item in rptOptions.Items)
                        {
                            TextBox  txtOpt  = (TextBox) item.FindControl("txtOption");
                            CheckBox chkCorr = (CheckBox)item.FindControl("chkCorrect");
                            if (txtOpt == null || string.IsNullOrWhiteSpace(txtOpt.Text)) continue;

                            using (SqlCommand optCmd = new SqlCommand(
                                @"INSERT INTO AnswerOptions (QuestionID, OptionText, IsCorrect)
                                  VALUES (@QID, @Opt, @Correct)", conn))
                            {
                                optCmd.Parameters.Add("@QID",    SqlDbType.Int).Value           = questionID;
                                optCmd.Parameters.Add("@Opt",    SqlDbType.NVarChar, -1).Value  = txtOpt.Text.Trim();
                                optCmd.Parameters.Add("@Correct",SqlDbType.Bit).Value            = (chkCorr != null && chkCorr.Checked) ? 1 : 0;
                                optCmd.ExecuteNonQuery();
                            }
                        }
                    }
                }

                // Reset form.
                txtQuestionText.Text  = string.Empty;
                txtCorrectAnswer.Text = string.Empty;
                txtQXP.Text           = "5";
                txtOrderIdx.Text      = "0";
                BindOptionRows();

                ShowSuccess("Question created successfully.");
                pnlQuestions.Visible = false;
                pnlEmpty.Visible     = false;
                LoadQuestions();
            }
            catch (SqlException)
            {
                ShowError("Could not create question. Please try again.");
            }
        }

        protected void rptQuestions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Delete")
                DeleteQuestion(Convert.ToInt32(e.CommandArgument));
        }

        private void DeleteQuestion(int questionID)
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "DELETE FROM Questions WHERE QuestionID=@ID AND CreatedByInstructorID=@IID", conn))
                    {
                        cmd.Parameters.Add("@ID",  SqlDbType.Int).Value = questionID;
                        cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowSuccess("Question deleted.");
                pnlQuestions.Visible = false;
                pnlEmpty.Visible     = false;
                LoadQuestions();
            }
            catch (SqlException)
            {
                ShowError("Could not delete question. Please try again.");
            }
        }

        private void ShowSuccess(string msg)
        {
            litSuccess.Text = HttpUtility.HtmlEncode(msg);
            pnlSuccess.Visible = true;
            pnlError.Visible   = false;
        }

        private void ShowError(string msg)
        {
            litError.Text = HttpUtility.HtmlEncode(msg);
            pnlError.Visible   = true;
            pnlSuccess.Visible = false;
        }
    }
}
