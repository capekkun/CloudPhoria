using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class SubTopicView : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            { Response.Redirect("~/LogIn.aspx", true); return; }

            if (!IsPostBack)
            {
                int subID;
                if (!int.TryParse(Request.QueryString["subtopicID"], out subID))
                { Response.Redirect("~/Student/Pathways.aspx"); return; }
                LoadSubTopic(subID);
            }
        }

        private void LoadSubTopic(int subID)
        {
            int studentID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Subtopic info
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT st.SubTopicName, st.ContentBody, st.XPReward, st.ModuleID,
                                 m.ModuleName
                          FROM SubTopics st
                          INNER JOIN Modules m ON m.ModuleID = st.ModuleID
                          WHERE st.SubTopicID = @STID AND st.IsPublished = 1", conn))
                    {
                        cmd.Parameters.Add("@STID", SqlDbType.Int).Value = subID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                litSubName.Text    = HttpUtility.HtmlEncode(rdr["SubTopicName"].ToString());
                                litModuleName.Text = HttpUtility.HtmlEncode(rdr["ModuleName"].ToString());
                                litXP.Text         = rdr["XPReward"].ToString();
                                ViewState["ModuleID"]   = Convert.ToInt32(rdr["ModuleID"]);
                                ViewState["SubTopicID"] = subID;
                                ViewState["SubXP"]      = Convert.ToInt32(rdr["XPReward"]);

                                string content = rdr["ContentBody"] != DBNull.Value
                                    ? rdr["ContentBody"].ToString() : "<em>No content available yet.</em>";
                                // Content may contain HTML from trusted instructor
                                litContent.Text = content;
                                pnlContent.Visible = true;
                            }
                            else
                            {
                                litError.Text = "Subtopic not found.";
                                pnlError.Visible = true;
                                return;
                            }
                        }
                    }

                    // Check progress status
                    string status = "NotStarted";
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT Status FROM SubTopicProgress WHERE SubTopicID=@STID AND StudentID=@SID", conn))
                    {
                        cmd.Parameters.Add("@STID", SqlDbType.Int).Value = subID;
                        cmd.Parameters.Add("@SID",  SqlDbType.Int).Value = studentID;
                        object r = cmd.ExecuteScalar();
                        if (r != null && r != DBNull.Value) status = r.ToString();
                    }

                    if (status == "Completed")
                    {
                        litStatus.Text = "<span class='cp-badge cp-badge-green'>Completed</span>";
                        pnlAlreadyDone.Visible = true;
                    }
                    else
                    {
                        litStatus.Text = "<span class='cp-badge cp-badge-blue'>In Progress</span>";
                        pnlComplete.Visible = true;

                        // Mark as InProgress if not started
                        if (status == "NotStarted")
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                @"IF NOT EXISTS (SELECT 1 FROM SubTopicProgress WHERE SubTopicID=@STID AND StudentID=@SID)
                                  INSERT INTO SubTopicProgress (StudentID, SubTopicID, Status) VALUES (@SID, @STID, 'InProgress')
                                  ELSE UPDATE SubTopicProgress SET Status='InProgress' WHERE SubTopicID=@STID AND StudentID=@SID AND Status='NotStarted'", conn))
                            {
                                cmd.Parameters.Add("@STID", SqlDbType.Int).Value = subID;
                                cmd.Parameters.Add("@SID",  SqlDbType.Int).Value = studentID;
                                cmd.ExecuteNonQuery();
                            }
                        }
                    }

                    // Materials
                    DataTable dtMat = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT FileName, FilePath FROM LearningMaterials WHERE SubTopicID=@STID", conn))
                    {
                        cmd.Parameters.Add("@STID", SqlDbType.Int).Value = subID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtMat);
                    }
                    if (dtMat.Rows.Count > 0)
                    {
                        rptMaterials.DataSource = dtMat;
                        rptMaterials.DataBind();
                        pnlMaterials.Visible = true;
                    }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load subtopic. Please try again.";
                pnlError.Visible = true;
            }
        }

        protected void btnComplete_Click(object sender, EventArgs e)
        {
            int studentID = Convert.ToInt32(Session["UserID"]);
            int subID     = ViewState["SubTopicID"] != null ? (int)ViewState["SubTopicID"] : 0;
            int xpReward  = ViewState["SubXP"] != null ? (int)ViewState["SubXP"] : 0;
            if (subID == 0) return;

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlTransaction tran = conn.BeginTransaction())
                    {
                        // Update progress to Completed
                        using (SqlCommand cmd = new SqlCommand(
                            @"UPDATE SubTopicProgress SET Status='Completed', XPEarned=@XP, CompletedAt=GETDATE()
                              WHERE SubTopicID=@STID AND StudentID=@SID", conn, tran))
                        {
                            cmd.Parameters.Add("@STID", SqlDbType.Int).Value = subID;
                            cmd.Parameters.Add("@SID",  SqlDbType.Int).Value = studentID;
                            cmd.Parameters.Add("@XP",   SqlDbType.Int).Value = xpReward;
                            cmd.ExecuteNonQuery();
                        }

                        // Award XP
                        if (xpReward > 0)
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                @"INSERT INTO XPTransactions (StudentID, SourceType, SourceID, XPAmount, CreatedAt)
                                  VALUES (@SID, 'SubTopic', @STID, @XP, GETDATE())", conn, tran))
                            {
                                cmd.Parameters.Add("@SID",  SqlDbType.Int).Value = studentID;
                                cmd.Parameters.Add("@STID", SqlDbType.Int).Value = subID;
                                cmd.Parameters.Add("@XP",   SqlDbType.Int).Value = xpReward;
                                cmd.ExecuteNonQuery();
                            }

                            using (SqlCommand cmd = new SqlCommand(
                                "UPDATE Students SET TotalXP = TotalXP + @XP WHERE StudentID=@SID", conn, tran))
                            {
                                cmd.Parameters.Add("@XP",  SqlDbType.Int).Value = xpReward;
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                                cmd.ExecuteNonQuery();
                            }
                        }

                        tran.Commit();
                    }
                }

                // Refresh page to show completed state
                Response.Redirect(Request.Url.ToString());
            }
            catch (SqlException)
            {
                litError.Text = "Could not mark as complete. Please try again.";
                pnlError.Visible = true;
            }
        }
    }
}
