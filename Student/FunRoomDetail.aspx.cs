using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class FunRoomDetail : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            { Response.Redirect("~/LogIn.aspx", true); return; }

            ((SiteMaster)Master).PageHeading = "Fun Room";

            if (!IsPostBack)
            {
                int roomID;
                if (!int.TryParse(Request.QueryString["roomID"], out roomID))
                { Response.Redirect("~/Student/FunRooms.aspx"); return; }
                LoadRoom(roomID);
            }
        }

        private void LoadRoom(int roomID)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Room info
                    string title = "";
                    string desc = "";
                    string creator = "";

                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT f.RoomTitle, f.ContentBody, u.FullName AS CreatorName
                          FROM FunRooms f
                          INNER JOIN Users u ON u.UserID = f.CreatedByUserID
                          WHERE f.FunRoomID = @RID AND f.Status = 'Approved'", conn))
                    {
                        cmd.Parameters.Add("@RID", SqlDbType.Int).Value = roomID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                title = rdr["RoomTitle"].ToString();
                                desc = rdr["ContentBody"] != DBNull.Value ? rdr["ContentBody"].ToString() : "";
                                creator = rdr["CreatorName"].ToString();
                            }
                            else
                            {
                                litError.Text = "Room not found or not approved.";
                                pnlError.Visible = true;
                                return;
                            }
                        }
                    }

                    litRoomTitle.Text = HttpUtility.HtmlEncode(title);
                    litDescription.Text = HttpUtility.HtmlEncode(desc);
                    litCreator.Text = HttpUtility.HtmlEncode(creator);

                    // Load questions
                    DataTable dtQ = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT FunRoomQuestionID, QuestionText, XPReward, OrderIndex
                          FROM FunRoomQuestions
                          WHERE FunRoomID = @RID
                          ORDER BY OrderIndex, FunRoomQuestionID", conn))
                    {
                        cmd.Parameters.Add("@RID", SqlDbType.Int).Value = roomID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtQ);
                    }

                    litQuestionCount.Text = dtQ.Rows.Count.ToString();
                    int totalXP = 0;
                    foreach (DataRow row in dtQ.Rows)
                        totalXP += Convert.ToInt32(row["XPReward"]);
                    litTotalXP.Text = totalXP.ToString();

                    if (dtQ.Rows.Count == 0)
                    {
                        litQuestions.Text = "<div style='text-align:center;padding:40px;color:#64748B;'>No questions in this room yet.</div>";
                        pnlContent.Visible = true;
                        return;
                    }

                    // Build quiz HTML
                    var sb = new System.Text.StringBuilder();
                    sb.AppendFormat("<script>initScore({0});</" + "script>", dtQ.Rows.Count);

                    // Score display
                    sb.Append("<div class='fr-score' style='margin-bottom:24px;'>");
                    sb.Append("<h2>Score: <span id='frScoreDisplay'>0 / " + dtQ.Rows.Count + "</span></h2>");
                    sb.Append("<p>Answer all questions to complete the room!</p></div>");

                    int qNum = 1;
                    foreach (DataRow qRow in dtQ.Rows)
                    {
                        int qID = Convert.ToInt32(qRow["FunRoomQuestionID"]);
                        string qText = HttpUtility.HtmlEncode(qRow["QuestionText"].ToString());
                        string cardID = "frq_" + qID;

                        sb.AppendFormat("<div class='fr-q-card' id='{0}'>", cardID);
                        sb.AppendFormat("<div class='fr-q-number'>Question {0}</div>", qNum);
                        sb.AppendFormat("<div class='fr-q-text'>{0}</div>", qText);
                        sb.Append("<div class='fr-q-opts'>");

                        // Load options
                        DataTable dtOpts = new DataTable();
                        using (SqlCommand optCmd = new SqlCommand(
                            @"SELECT OptionText, IsCorrect FROM FunRoomQuestionOptions
                              WHERE FunRoomQuestionID = @QID ORDER BY OptionID", conn))
                        {
                            optCmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
                            using (SqlDataAdapter da = new SqlDataAdapter(optCmd)) da.Fill(dtOpts);
                        }

                        // Shuffle options for fairness
                        var rng = new Random(qID); // deterministic per question
                        var indices = new int[dtOpts.Rows.Count];
                        for (int i = 0; i < indices.Length; i++) indices[i] = i;
                        for (int i = indices.Length - 1; i > 0; i--)
                        {
                            int j = rng.Next(i + 1);
                            int tmp = indices[i]; indices[i] = indices[j]; indices[j] = tmp;
                        }

                        foreach (int idx in indices)
                        {
                            DataRow oRow = dtOpts.Rows[idx];
                            string oText = HttpUtility.HtmlEncode(oRow["OptionText"].ToString());
                            bool isCorrect = Convert.ToBoolean(oRow["IsCorrect"]);

                            sb.AppendFormat(
                                "<a href='javascript:void(0)' class='fr-opt' data-correct='{0}' " +
                                "onclick=\"selectFROption(this, document.getElementById('{1}'), {2})\">{3}</a>",
                                isCorrect ? "1" : "0", cardID,
                                isCorrect ? "true" : "false", oText);
                        }

                        sb.Append("</div></div>"); // close opts + card
                        qNum++;
                    }

                    litQuestions.Text = sb.ToString();
                    pnlContent.Visible = true;
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load the room. Please try again.";
                pnlError.Visible = true;
            }
        }
    }
}
