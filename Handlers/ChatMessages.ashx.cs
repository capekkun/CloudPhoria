using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.SessionState;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Handlers
{
    /// <summary>
    /// Lightweight JSON endpoint for the classroom chat auto-poll.
    /// Returns new ClassroomMessages after a given MessageID.
    /// Requires an active session with Instructor or Student role.
    /// </summary>
    public class ChatMessages : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable => false;

        public void ProcessRequest(HttpContext ctx)
        {
            ctx.Response.ContentType = "application/json";
            ctx.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            // Auth check.
            if (ctx.Session["UserID"] == null || ctx.Session["Role"] == null)
            {
                ctx.Response.Write("{\"error\":\"unauthorised\"}");
                return;
            }

            int classroomID, afterID;
            if (!int.TryParse(ctx.Request.QueryString["classroomID"], out classroomID) || classroomID <= 0)
            {
                ctx.Response.Write("{\"messages\":[]}");
                return;
            }
            int.TryParse(ctx.Request.QueryString["afterID"], out afterID);

            string role   = ctx.Session["Role"].ToString();
            int    userID = Convert.ToInt32(ctx.Session["UserID"]);
            string cs     = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                // Verify the caller has access to this classroom.
                bool hasAccess = false;
                int  instructorID = 0;

                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT InstructorID FROM Classrooms WHERE ClassroomID=@CID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        object r = cmd.ExecuteScalar();
                        if (r == null || r == DBNull.Value)
                        {
                            ctx.Response.Write("{\"messages\":[]}");
                            return;
                        }
                        instructorID = Convert.ToInt32(r);
                        hasAccess    = (role == "Instructor" && instructorID == userID);
                    }

                    if (!hasAccess && role == "Student")
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT COUNT(*) FROM ClassroomEnrollments WHERE ClassroomID=@CID AND StudentID=@SID",
                            conn))
                        {
                            cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                            cmd.Parameters.Add("@SID", SqlDbType.Int).Value = userID;
                            hasAccess = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                        }
                    }

                    if (!hasAccess)
                    {
                        ctx.Response.Write("{\"error\":\"forbidden\"}");
                        return;
                    }

                    // Fetch new messages since afterID.
                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT TOP 50
                            cm.MessageID, cm.SenderID, cm.MessageText, cm.SentAt,
                            u.FullName AS SenderName
                          FROM ClassroomMessages cm
                          INNER JOIN Users u ON u.UserID = cm.SenderID
                          WHERE cm.ClassroomID = @CID AND cm.MessageID > @AfterID
                          ORDER BY cm.SentAt ASC", conn))
                    {
                        cmd.Parameters.Add("@CID",     SqlDbType.Int).Value = classroomID;
                        cmd.Parameters.Add("@AfterID", SqlDbType.Int).Value = afterID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }

                    var sb = new StringBuilder();
                    sb.Append("{\"messages\":[");
                    bool first = true;

                    foreach (DataRow row in dt.Rows)
                    {
                        if (!first) sb.Append(",");
                        first = false;

                        int    msgID      = Convert.ToInt32(row["MessageID"]);
                        int    senderID   = Convert.ToInt32(row["SenderID"]);
                        string senderName = row["SenderName"].ToString();
                        string text       = row["MessageText"].ToString();
                        string time       = Convert.ToDateTime(row["SentAt"]).ToString("HH:mm");
                        string initials   = GetInitials(senderName);

                        sb.AppendFormat(
                            "{{\"messageID\":{0},\"senderID\":{1},\"senderName\":{2}," +
                            "\"messageText\":{3},\"sentAt\":{4},\"initials\":{5}," +
                            "\"instructorID\":{6}}}",
                            msgID, senderID,
                            JsonString(senderName), JsonString(text),
                            JsonString(time), JsonString(initials),
                            instructorID);
                    }

                    sb.Append("]}");
                    ctx.Response.Write(sb.ToString());
                }
            }
            catch (SqlException)
            {
                ctx.Response.Write("{\"messages\":[]}");
            }
        }

        private static string JsonString(string s)
        {
            if (s == null) return "\"\"";
            return "\"" + s
                .Replace("\\", "\\\\")
                .Replace("\"", "\\\"")
                .Replace("\n", "\\n")
                .Replace("\r", "\\r")
                .Replace("\t", "\\t") + "\"";
        }

        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "?";
            string[] parts = name.Trim().Split(
                new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1)
                return (parts[0].Length >= 2 ? parts[0].Substring(0, 2) : parts[0][0].ToString()).ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }
    }
}
