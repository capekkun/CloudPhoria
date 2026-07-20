using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class PracticeQuiz : System.Web.UI.Page
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
                { Response.Redirect("~/Student/Practice.aspx"); return; }

                LoadQuestions(moduleID);
            }
        }

        private void LoadQuestions(int moduleID)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Get module name
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT ModuleName FROM Modules WHERE ModuleID=@MID", conn))
                    {
                        cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        object r = cmd.ExecuteScalar();
                        litModuleName.Text = r != null ? HttpUtility.HtmlEncode(r.ToString()) : "Unknown";
                    }

                    // Load all practice questions for this module
                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT pq.PracticeQuestionID, pq.QuestionText
                          FROM PracticeQuestions pq
                          WHERE pq.ModuleID = @MID
                          ORDER BY pq.OrderIndex, pq.PracticeQuestionID", conn))
                    {
                        cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }

                    if (dt.Rows.Count == 0)
                    {
                        pnlEmpty.Visible = true;
                        return;
                    }

                    // Store question IDs in ViewState
                    int[] questionIDs = new int[dt.Rows.Count];
                    for (int i = 0; i < dt.Rows.Count; i++)
                        questionIDs[i] = Convert.ToInt32(dt.Rows[i]["PracticeQuestionID"]);

                    ViewState["QuestionIDs"] = questionIDs;
                    ViewState["CurrentIndex"] = 0;
                    ViewState["Score"] = 0;
                    ViewState["ModuleID"] = moduleID;

                    ShowQuestion(conn, questionIDs[0], 0, dt.Rows.Count);
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load practice questions.";
                pnlError.Visible = true;
            }
        }

        private void ShowQuestion(SqlConnection conn, int questionID, int index, int total)
        {
            litQNum.Text = (index + 1).ToString();
            litQTotal.Text = total.ToString();

            using (SqlCommand cmd = new SqlCommand(
                "SELECT QuestionText FROM PracticeQuestions WHERE PracticeQuestionID=@QID", conn))
            {
                cmd.Parameters.Add("@QID", SqlDbType.Int).Value = questionID;
                object r = cmd.ExecuteScalar();
                litQText.Text = HttpUtility.HtmlEncode(r != null ? r.ToString() : "");
            }

            DataTable dtOpts = new DataTable();
            using (SqlCommand cmd = new SqlCommand(
                @"SELECT OptionID, OptionText FROM PracticeQuestionOptions
                  WHERE PracticeQuestionID=@QID ORDER BY OptionID", conn))
            {
                cmd.Parameters.Add("@QID", SqlDbType.Int).Value = questionID;
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtOpts);
            }

            // Render as HTML links using __doPostBack
            var sb = new System.Text.StringBuilder();
            for (int i = 0; i < dtOpts.Rows.Count; i++)
            {
                string oid = dtOpts.Rows[i]["OptionID"].ToString();
                string otext = HttpUtility.HtmlEncode(dtOpts.Rows[i]["OptionText"].ToString());
                sb.AppendFormat(
                    "<a href='#' class='pq-opt' onclick=\"document.getElementById('{0}').value='{1}';" +
                    "__doPostBack('{2}','');return false;\">{3}</a>",
                    hdnPQAnswer.ClientID, oid, btnPQSubmit.UniqueID, otext);
            }
            if (dtOpts.Rows.Count == 0)
            {
                sb.Append("<div style='padding:16px;color:#DC2626;font-size:13px;background:rgba(239,68,68,0.08);border-radius:8px;'>" +
                    "&#x26A0; No answer options found for PracticeQuestionID=" + questionID +
                    ". Please add options to the PracticeQuestionOptions table.</div>");
            }
            litPQOpts.Text = sb.ToString();

            pnlQuestion.Visible = true;
            pnlFeedback.Visible = false;
        }

        protected void btnPQSubmit_Click(object sender, EventArgs e)
        {
            int selectedID;
            if (!int.TryParse(hdnPQAnswer.Value, out selectedID)) return;

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            bool isCorrect = false;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT IsCorrect FROM PracticeQuestionOptions WHERE OptionID=@OID", conn))
                    {
                        cmd.Parameters.Add("@OID", SqlDbType.Int).Value = selectedID;
                        object r = cmd.ExecuteScalar();
                        isCorrect = r != null && Convert.ToBoolean(r);
                    }
                }
            }
            catch (SqlException) { return; }

            if (isCorrect)
            {
                ViewState["Score"] = (int)ViewState["Score"] + 1;
                litFeedback.Text = "&#x2713; Correct! Well done.";
                feedbackDiv.Attributes["class"] = "pq-result pq-result-correct";
            }
            else
            {
                litFeedback.Text = "&#x2717; Wrong answer. Try again next time!";
                feedbackDiv.Attributes["class"] = "pq-result pq-result-wrong";
            }

            // Clear options after answering
            litPQOpts.Text = "";

            pnlFeedback.Visible = true;
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            int[] questionIDs = (int[])ViewState["QuestionIDs"];
            int currentIndex = (int)ViewState["CurrentIndex"] + 1;
            ViewState["CurrentIndex"] = currentIndex;

            if (currentIndex >= questionIDs.Length)
            {
                pnlQuestion.Visible = false;
                pnlScore.Visible = true;
                litScoreNum.Text = ViewState["Score"].ToString();
                litScoreTotal.Text = questionIDs.Length.ToString();
                return;
            }

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    ShowQuestion(conn, questionIDs[currentIndex], currentIndex, questionIDs.Length);
                }
            }
            catch (SqlException ex)
            {
                litError.Text = "Error loading next question: " + HttpUtility.HtmlEncode(ex.Message);
                pnlError.Visible = true;
            }
        }
    }
}
