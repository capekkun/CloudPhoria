using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Instructor
{
    // READ-ONLY per the current authority model: only Admin can create, edit,
    // or delete Questions (Admin/Courses.aspx?subTopicID=). Instructors can
    // only view questions on subtopics belonging to modules assigned to them.
    public partial class Questions : System.Web.UI.Page
    {
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
                LoadSubTopicDropdown();

                int qsID;
                if (int.TryParse(Request.QueryString["subTopicID"], out qsID) && qsID > 0)
                {
                    if (ddlSubTopic.Items.FindByValue(qsID.ToString()) != null)
                        ddlSubTopic.SelectedValue = qsID.ToString();
                }

                LoadQuestions();
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

        private void LoadSubTopicDropdown()
        {
            int instructorID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            string sql = @"
                SELECT st.SubTopicID,
                       m.ModuleName + ' > ' + st.SubTopicName AS DisplayName
                FROM   SubTopics st
                INNER JOIN Modules m ON m.ModuleID = st.ModuleID
                WHERE  m.CreatedByInstructorID = @ID
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
                INNER JOIN Modules m ON m.ModuleID = st.ModuleID
                WHERE  m.CreatedByInstructorID = @InstructorID
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

        private void ShowError(string msg)
        {
            litError.Text      = HttpUtility.HtmlEncode(msg);
            pnlError.Visible   = true;
        }
    }
}
