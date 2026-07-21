using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;
using System.Data;

namespace CloudPhoria.Student
{
    public partial class FunRoomCreate : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null)
            { Response.Redirect("~/LogIn.aspx", true); return; }

            string role = Session["Role"].ToString();
            if (role != "Student" && role != "Instructor")
            { Response.Redirect("~/LogIn.aspx", true); return; }

            ((SiteMaster)Master).PageHeading = "Create Fun Room";
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string title = txtTitle.Text.Trim();
            string description = txtDescription.Text.Trim();
            int userID = Convert.ToInt32(Session["UserID"]);

            if (string.IsNullOrEmpty(title))
            {
                litError.Text = "Room title is required.";
                pnlError.Visible = true;
                return;
            }

            // Collect questions (at least 1 required)
            var questions = new List<QuestionData>();

            AddQuestion(questions, txtQ1, txtQ1O1, txtQ1O2, txtQ1O3, txtQ1O4);
            AddQuestion(questions, txtQ2, txtQ2O1, txtQ2O2, txtQ2O3, txtQ2O4);
            AddQuestion(questions, txtQ3, txtQ3O1, txtQ3O2, txtQ3O3, txtQ3O4);

            if (questions.Count == 0)
            {
                litError.Text = "At least one question with all 4 options is required.";
                pnlError.Visible = true;
                return;
            }

            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlTransaction tran = conn.BeginTransaction())
                    {
                        // Insert the fun room
                        int funRoomID;
                        using (SqlCommand cmd = new SqlCommand(
                            @"INSERT INTO FunRooms (CreatedByUserID, RoomTitle, ContentBody, Status, CreatedAt)
                              VALUES (@UID, @Title, @Desc, 'Pending', GETDATE());
                              SELECT SCOPE_IDENTITY();", conn, tran))
                        {
                            cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                            cmd.Parameters.Add("@Title", SqlDbType.NVarChar, 150).Value = title;
                            cmd.Parameters.Add("@Desc", SqlDbType.NVarChar, -1).Value =
                                string.IsNullOrEmpty(description) ? (object)DBNull.Value : description;
                            funRoomID = Convert.ToInt32(cmd.ExecuteScalar());
                        }

                        // Insert questions and options
                        int order = 1;
                        foreach (var q in questions)
                        {
                            int qID;
                            using (SqlCommand cmd = new SqlCommand(
                                @"INSERT INTO FunRoomQuestions (FunRoomID, QuestionText, XPReward, OrderIndex)
                                  VALUES (@RID, @QText, 5, @Ord);
                                  SELECT SCOPE_IDENTITY();", conn, tran))
                            {
                                cmd.Parameters.Add("@RID", SqlDbType.Int).Value = funRoomID;
                                cmd.Parameters.Add("@QText", SqlDbType.NVarChar, 500).Value = q.Text;
                                cmd.Parameters.Add("@Ord", SqlDbType.Int).Value = order++;
                                qID = Convert.ToInt32(cmd.ExecuteScalar());
                            }

                            // Insert 4 options (first is correct)
                            for (int i = 0; i < q.Options.Length; i++)
                            {
                                using (SqlCommand cmd = new SqlCommand(
                                    @"INSERT INTO FunRoomQuestionOptions (FunRoomQuestionID, OptionText, IsCorrect)
                                      VALUES (@QID, @OText, @Correct)", conn, tran))
                                {
                                    cmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
                                    cmd.Parameters.Add("@OText", SqlDbType.NVarChar, 300).Value = q.Options[i];
                                    cmd.Parameters.Add("@Correct", SqlDbType.Bit).Value = (i == 0) ? 1 : 0;
                                    cmd.ExecuteNonQuery();
                                }
                            }
                        }

                        tran.Commit();
                    }
                }

                pnlForm.Visible = false;
                litSuccess.Text = "Your fun room has been submitted for admin review! You'll be notified once it's approved.";
                pnlSuccess.Visible = true;
            }
            catch (SqlException)
            {
                litError.Text = "Could not create the room. Please try again.";
                pnlError.Visible = true;
            }
        }

        private void AddQuestion(List<QuestionData> list, TextBox txtQ, TextBox o1, TextBox o2, TextBox o3, TextBox o4)
        {
            string qText = txtQ.Text.Trim();
            string opt1 = o1.Text.Trim();
            string opt2 = o2.Text.Trim();
            string opt3 = o3.Text.Trim();
            string opt4 = o4.Text.Trim();

            if (!string.IsNullOrEmpty(qText) &&
                !string.IsNullOrEmpty(opt1) && !string.IsNullOrEmpty(opt2) &&
                !string.IsNullOrEmpty(opt3) && !string.IsNullOrEmpty(opt4))
            {
                list.Add(new QuestionData { Text = qText, Options = new[] { opt1, opt2, opt3, opt4 } });
            }
        }

        private class QuestionData
        {
            public string Text;
            public string[] Options;
        }
    }
}
