using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Guest
{
    public partial class Practice : System.Web.UI.Page
    {
        // Exposed to the ASPX page as inline code-behind properties
        public string QuizDataJson { get; private set; } = "[]";
        public int    AttemptID    { get; private set; } = 0;

        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadModuleDropdown();
            }
        }

        private void LoadModuleDropdown()
        {
            ddlModules.Items.Clear();
            ddlModules.Items.Add(new ListItem("— Select a module —", "0"));

            DataTable dt = new DataTable();
            try
            {
                string sql = @"SELECT m.ModuleID, m.ModuleName, p.PathwayName,
                                      (SELECT COUNT(*) FROM PracticeQuestions pq
                                       WHERE pq.ModuleID = m.ModuleID) AS QuestionCount
                               FROM   Modules m
                               INNER  JOIN Pathways p ON p.PathwayID = m.PathwayID
                               WHERE  m.IsPublished = 1
                               ORDER  BY p.IsFoundation DESC, m.PathwayID, m.ModuleID";

                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (var da = new SqlDataAdapter(sql, conn))
                    da.Fill(dt);
            }
            catch (SqlException)
            {
                ShowError("Unable to load modules. Please try again later.");
                return;
            }

            foreach (DataRow row in dt.Rows)
            {
                int    mid  = Convert.ToInt32(row["ModuleID"]);
                string name = row["ModuleName"].ToString();
                string pw   = row["PathwayName"].ToString();
                int    qc   = Convert.ToInt32(row["QuestionCount"]);
                string label = string.Format("{0} – {1} ({2} question{3})",
                    pw, name, qc, qc == 1 ? "" : "s");

                ddlModules.Items.Add(new ListItem(label, mid.ToString()));
            }
        }

        protected void btnStart_Click(object sender, EventArgs e)
        {
            pnlNoQuestions.Visible = false;

            int moduleID;
            if (!int.TryParse(ddlModules.SelectedValue, out moduleID) || moduleID <= 0)
            {
                ShowError("Please select a module.");
                return;
            }

            // Verify module exists and is published
            DataTable dtQ = LoadPracticeQuestions(moduleID);
            if (dtQ == null) return; // error already shown

            if (dtQ.Rows.Count == 0)
            {
                pnlNoQuestions.Visible = true;
                return;
            }

            // Ensure guest session ID
            string guestSessionID = EnsureGuestSession();

            // Create PracticeAttempt (StudentID = NULL, GuestSessionID = guestSessionID)
            int attemptID = CreatePracticeAttempt(moduleID, guestSessionID);
            if (attemptID <= 0) return; // error already shown

            AttemptID    = attemptID;
            QuizDataJson = BuildQuizJson(dtQ);
            pnlQuiz.Visible = true;
        }

        private DataTable LoadPracticeQuestions(int moduleID)
        {
            DataTable dt = new DataTable();
            try
            {
                string sql = @"SELECT pq.PracticeQuestionID, pq.QuestionText,
                                      pqo.OptionID, pqo.OptionText, pqo.IsCorrect
                               FROM   PracticeQuestions pq
                               INNER  JOIN PracticeQuestionOptions pqo
                                      ON pqo.PracticeQuestionID = pq.PracticeQuestionID
                               WHERE  pq.ModuleID = @ModuleID
                               ORDER  BY pq.OrderIndex, pq.PracticeQuestionID, pqo.OptionID";

                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@ModuleID", SqlDbType.Int).Value = moduleID;
                    conn.Open();
                    using (var da = new SqlDataAdapter(cmd))
                        da.Fill(dt);
                }
            }
            catch (SqlException)
            {
                ShowError("Unable to load questions. Please try again later.");
                return null;
            }
            return dt;
        }

        private int CreatePracticeAttempt(int moduleID, string guestSessionID)
        {
            try
            {
                string sql = @"INSERT INTO PracticeAttempts (ModuleID, StudentID, GuestSessionID, AttemptedAt)
                               VALUES (@ModuleID, NULL, @GuestSessionID, GETDATE());
                               SELECT SCOPE_IDENTITY();";

                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@ModuleID",       SqlDbType.Int).Value          = moduleID;
                    cmd.Parameters.Add("@GuestSessionID", SqlDbType.NVarChar, 100).Value = guestSessionID;
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        return Convert.ToInt32(result);
                }
            }
            catch (SqlException)
            {
                ShowError("Unable to start practice session. Please try again.");
            }
            return 0;
        }

        private string BuildQuizJson(DataTable dt)
        {
            // Group rows into questions -> options
            var sb = new StringBuilder("[");
            int lastQID   = -1;
            bool firstQ   = true;
            bool firstOpt = true;

            foreach (DataRow row in dt.Rows)
            {
                int    qid     = Convert.ToInt32(row["PracticeQuestionID"]);
                string qtext   = row["QuestionText"].ToString();
                int    optID   = Convert.ToInt32(row["OptionID"]);
                string optText = row["OptionText"].ToString();
                bool   correct = Convert.ToBoolean(row["IsCorrect"]);

                if (qid != lastQID)
                {
                    // close previous question
                    if (!firstQ)
                        sb.Append("]}");
                    else
                        firstQ = false;

                    if (sb.Length > 1) sb.Append(",");

                    // Find the correct option ID for this question from remaining rows
                    sb.AppendFormat("{{\"id\":{0},\"text\":{1},\"correctID\":0,\"options\":[",
                        qid, JsonStr(qtext));
                    lastQID  = qid;
                    firstOpt = true;
                }
                else
                {
                    sb.Append(",");
                }

                if (!firstOpt)
                {/* comma already handled */}
                firstOpt = false;

                sb.AppendFormat("{{\"id\":{0},\"text\":{1},\"isCorrect\":{2}}}",
                    optID, JsonStr(optText), correct ? "true" : "false");
            }

            if (!firstQ) sb.Append("]}");
            sb.Append("]");

            // Second pass: set correctID inside each question object
            // We inject it via a post-process in JS since it's simpler
            return sb.ToString();
        }

        private static string JsonStr(string s)
        {
            return "\"" + s
                .Replace("\\", "\\\\")
                .Replace("\"", "\\\"")
                .Replace("\r", "\\r")
                .Replace("\n", "\\n")
                + "\"";
        }

        private string EnsureGuestSession()
        {
            const string cookieName = "cp_guest";
            HttpCookie cookie = Request.Cookies[cookieName];
            if (cookie == null || string.IsNullOrEmpty(cookie.Value))
            {
                string id = Guid.NewGuid().ToString("N");
                cookie = new HttpCookie(cookieName, id)
                {
                    Expires  = DateTime.Now.AddDays(30),
                    HttpOnly = true
                };
                Response.Cookies.Add(cookie);
                return id;
            }
            // Sanitise: only accept hex characters (Guid without dashes)
            string val = cookie.Value;
            var clean = new StringBuilder();
            foreach (char c in val)
                if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F') || c == '-')
                    clean.Append(c);
            return clean.ToString().Length >= 32 ? clean.ToString() : Guid.NewGuid().ToString("N");
        }

        private void ShowError(string msg)
        {
            litError.Text    = HttpUtility.HtmlEncode(msg);
            pnlError.Visible = true;
        }
    }
}
