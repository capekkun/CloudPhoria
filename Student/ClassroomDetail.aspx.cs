using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class ClassroomDetail : System.Web.UI.Page
    {
        private int ClassroomID
        {
            get { return ViewState["ClassroomID"] != null ? (int)ViewState["ClassroomID"] : 0; }
            set { ViewState["ClassroomID"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                (Session["Role"].ToString() != "Student" && Session["Role"].ToString() != "Instructor"))
            { Response.Redirect("~/LogIn.aspx", true); return; }

            if (!IsPostBack)
            {
                int classroomID;
                if (!int.TryParse(Request.QueryString["classroomID"], out classroomID))
                { Response.Redirect("~/Student/Classrooms.aspx"); return; }
                ClassroomID = classroomID;
                LoadClassroom(classroomID);
            }
            else
            {
                // On postback reload messages to keep chat fresh
                if (ClassroomID > 0)
                    LoadMessages(ClassroomID);
            }
        }

        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString; }
        }

        private void LoadClassroom(int classroomID)
        {
            int userID = Convert.ToInt32(Session["UserID"]);
            string role = Session["Role"].ToString();

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    // Get classroom info
                    bool hasAccess = false;
                    string className = "";
                    string instructorName = "";
                    int instructorID = 0;

                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT c.ClassroomName, u.FullName AS InstructorName, c.InstructorID
                          FROM Classrooms c
                          INNER JOIN Users u ON u.UserID = c.InstructorID
                          WHERE c.ClassroomID = @CID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                className = rdr["ClassroomName"].ToString();
                                instructorName = rdr["InstructorName"].ToString();
                                instructorID = Convert.ToInt32(rdr["InstructorID"]);
                                if (role == "Instructor" && instructorID == userID)
                                    hasAccess = true;
                            }
                        }
                    }

                    // Check student enrollment
                    if (!hasAccess && role == "Student")
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT COUNT(*) FROM ClassroomEnrollments WHERE ClassroomID=@CID AND StudentID=@SID", conn))
                        {
                            cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                            cmd.Parameters.Add("@SID", SqlDbType.Int).Value = userID;
                            hasAccess = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                        }
                    }

                    if (!hasAccess)
                    {
                        litError.Text = "You do not have access to this classroom.";
                        pnlError.Visible = true;
                        return;
                    }

                    litClassName.Text = HttpUtility.HtmlEncode(className);
                    litInstructor.Text = HttpUtility.HtmlEncode(instructorName);
                    pnlContent.Visible = true;

                    // Member count
                    int memberCount = 1; // instructor
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM ClassroomEnrollments WHERE ClassroomID=@CID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        memberCount += Convert.ToInt32(cmd.ExecuteScalar());
                    }
                    litMemberCount.Text = memberCount.ToString();

                    // Load all sections
                    LoadMessages(classroomID);
                    LoadFiles(classroomID, conn);
                    LoadAssignments(classroomID, conn);
                    LoadMembers(classroomID, conn);
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load classroom. Please try again.";
                pnlError.Visible = true;
            }
        }

        private void LoadMessages(int classroomID)
        {
            int currentUserID = Convert.ToInt32(Session["UserID"]);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    int instructorID = 0;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT InstructorID FROM Classrooms WHERE ClassroomID=@CID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        object r = cmd.ExecuteScalar();
                        if (r != null) instructorID = Convert.ToInt32(r);
                    }

                    DataTable dtMsg = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT TOP 100 cm.MessageText, cm.SentAt, cm.SenderID,
                                 u.FullName AS SenderName
                          FROM ClassroomMessages cm
                          INNER JOIN Users u ON u.UserID = cm.SenderID
                          WHERE cm.ClassroomID = @CID
                          ORDER BY cm.SentAt ASC", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtMsg);
                    }

                    if (dtMsg.Rows.Count == 0)
                    {
                        litMessages.Text = @"<div class='teams-chat-empty'>
                            <span>&#x1F4AC;</span>
                            <div style='font-size:15px;font-weight:600;color:#374151;margin-bottom:4px;'>No messages yet</div>
                            <div style='font-size:13px;'>Start the conversation with your classmates!</div>
                        </div>";
                        return;
                    }

                    var sb = new System.Text.StringBuilder();
                    string lastDate = "";

                    foreach (DataRow row in dtMsg.Rows)
                    {
                        int senderID = Convert.ToInt32(row["SenderID"]);
                        string name = HttpUtility.HtmlEncode(row["SenderName"].ToString());
                        string text = HttpUtility.HtmlEncode(row["MessageText"].ToString());
                        DateTime sentAt = Convert.ToDateTime(row["SentAt"]);
                        string time = sentAt.ToString("HH:mm");
                        string date = sentAt.ToString("dd MMM yyyy");
                        bool isMine = senderID == currentUserID;
                        bool isInstructor = senderID == instructorID;
                        string initials = GetInitials(row["SenderName"].ToString());

                        // Date separator
                        if (date != lastDate)
                        {
                            sb.AppendFormat("<div style='text-align:center;padding:8px 0;'>" +
                                "<span style='font-size:11px;color:#9CA3AF;background:#F3F4F6;" +
                                "padding:4px 12px;border-radius:12px;'>{0}</span></div>", date);
                            lastDate = date;
                        }

                        string msgClass = isMine ? "teams-msg teams-msg-mine" : "teams-msg";
                        string avatarClass = isInstructor
                            ? "teams-msg-avatar teams-msg-avatar-instructor"
                            : "teams-msg-avatar";

                        sb.AppendFormat(
                            "<div class='{0}'>" +
                            "<div class='{1}'>{2}</div>" +
                            "<div class='teams-msg-content'>" +
                            "<div class='teams-msg-name'>{3}{4}</div>" +
                            "<div class='teams-msg-bubble'>{5}</div>" +
                            "<div class='teams-msg-time'>{6}</div>" +
                            "</div></div>",
                            msgClass, avatarClass, HttpUtility.HtmlEncode(initials),
                            name, isInstructor ? " <span style='font-size:10px;color:#F59E0B;'>&#x2B50; Instructor</span>" : "",
                            text, time);
                    }

                    litMessages.Text = sb.ToString();
                }
            }
            catch (SqlException)
            {
                litMessages.Text = "<div style='padding:20px;color:#EF4444;font-size:13px;'>Could not load messages.</div>";
            }
        }

        private void LoadFiles(int classroomID, SqlConnection conn)
        {
            DataTable dtMat = new DataTable();
            using (SqlCommand cmd = new SqlCommand(
                "SELECT FileName, FilePath, UploadedAt FROM ClassroomMaterials WHERE ClassroomID=@CID ORDER BY UploadedAt DESC", conn))
            {
                cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtMat);
            }

            if (dtMat.Rows.Count == 0)
            {
                litFiles.Text = @"<div class='teams-file-empty'>
                    <span>&#x1F4C2;</span>
                    <div style='font-size:14px;font-weight:600;color:#374151;margin-bottom:4px;'>No files shared yet</div>
                    <div style='font-size:13px;'>Your instructor will share materials here.</div>
                </div>";
                return;
            }

            var sb = new System.Text.StringBuilder();
            sb.Append("<div class='teams-file-list'>");

            foreach (DataRow row in dtMat.Rows)
            {
                string fileName = HttpUtility.HtmlEncode(row["FileName"].ToString());
                string uploadDate = Convert.ToDateTime(row["UploadedAt"]).ToString("dd MMM yyyy");
                string ext = System.IO.Path.GetExtension(row["FileName"].ToString()).ToLower();
                string icon = GetFileIcon(ext);

                sb.AppendFormat(
                    "<div class='teams-file-item'>" +
                    "<div class='teams-file-icon'>{0}</div>" +
                    "<div class='teams-file-info'>" +
                    "<div class='teams-file-name'>{1}</div>" +
                    "<div class='teams-file-meta'>Uploaded {2}</div>" +
                    "</div></div>",
                    icon, fileName, uploadDate);
            }

            sb.Append("</div>");
            litFiles.Text = sb.ToString();
        }

        private void LoadAssignments(int classroomID, SqlConnection conn)
        {
            DataTable dtAsgn = new DataTable();
            using (SqlCommand cmd = new SqlCommand(
                "SELECT AssignmentID, Title, DueDate, CreatedAt FROM ClassroomAssignments WHERE ClassroomID=@CID ORDER BY CreatedAt DESC", conn))
            {
                cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtAsgn);
            }

            if (dtAsgn.Rows.Count == 0)
            {
                litAssignments.Text = @"<div class='teams-asgn-empty'>
                    <span>&#x1F4CB;</span>
                    <div style='font-size:14px;font-weight:600;color:#374151;margin-bottom:4px;'>No assignments yet</div>
                    <div style='font-size:13px;'>Assignments from your instructor will appear here.</div>
                </div>";
                return;
            }

            var sb = new System.Text.StringBuilder();
            sb.Append("<div class='teams-asgn-list'>");

            foreach (DataRow row in dtAsgn.Rows)
            {
                string title = HttpUtility.HtmlEncode(row["Title"].ToString());
                string created = Convert.ToDateTime(row["CreatedAt"]).ToString("dd MMM yyyy");
                string dueHtml = "";

                if (row["DueDate"] != DBNull.Value)
                {
                    DateTime due = Convert.ToDateTime(row["DueDate"]);
                    bool overdue = due < DateTime.Now;
                    dueHtml = string.Format(
                        "<span class='teams-asgn-due' style='{0}'>&#x23F0; Due: {1}</span>",
                        overdue ? "background:#FEE2E2;color:#991B1B;" : "",
                        due.ToString("dd MMM yyyy"));
                }

                sb.AppendFormat(
                    "<div class='teams-asgn-card'>" +
                    "<div class='teams-asgn-title'>{0}</div>" +
                    "<div class='teams-asgn-meta'>" +
                    "<span>Posted: {1}</span>" +
                    "{2}" +
                    "</div></div>",
                    title, created, dueHtml);
            }

            sb.Append("</div>");
            litAssignments.Text = sb.ToString();
        }

        private void LoadMembers(int classroomID, SqlConnection conn)
        {
            var sb = new System.Text.StringBuilder();
            sb.Append("<div class='teams-members'>");

            // Instructor
            using (SqlCommand cmd = new SqlCommand(
                @"SELECT u.FullName FROM Classrooms c
                  INNER JOIN Users u ON u.UserID = c.InstructorID
                  WHERE c.ClassroomID = @CID", conn))
            {
                cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                object r = cmd.ExecuteScalar();
                if (r != null)
                {
                    string name = r.ToString();
                    sb.AppendFormat(
                        "<div class='teams-member-item'>" +
                        "<div class='teams-member-avatar teams-member-avatar-inst'>{0}</div>" +
                        "<div class='teams-member-info'>" +
                        "<div class='teams-member-name'>{1}</div>" +
                        "<div class='teams-member-role'>Instructor</div></div>" +
                        "<span class='teams-member-badge teams-member-badge-inst'>Instructor</span></div>",
                        HttpUtility.HtmlEncode(GetInitials(name)),
                        HttpUtility.HtmlEncode(name));
                }
            }

            // Students
            using (SqlCommand cmd = new SqlCommand(
                @"SELECT u.FullName FROM ClassroomEnrollments ce
                  INNER JOIN Users u ON u.UserID = ce.StudentID
                  WHERE ce.ClassroomID = @CID ORDER BY u.FullName", conn))
            {
                cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string name = rdr["FullName"].ToString();
                        sb.AppendFormat(
                            "<div class='teams-member-item'>" +
                            "<div class='teams-member-avatar'>{0}</div>" +
                            "<div class='teams-member-info'>" +
                            "<div class='teams-member-name'>{1}</div>" +
                            "<div class='teams-member-role'>Student</div></div>" +
                            "<span class='teams-member-badge teams-member-badge-student'>Student</span></div>",
                            HttpUtility.HtmlEncode(GetInitials(name)),
                            HttpUtility.HtmlEncode(name));
                    }
                }
            }

            sb.Append("</div>");
            litMembers.Text = sb.ToString();
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            string message = txtMessage.Text.Trim();
            if (string.IsNullOrEmpty(message) || ClassroomID == 0) return;

            int userID = Convert.ToInt32(Session["UserID"]);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO ClassroomMessages (ClassroomID, SenderID, MessageText, SentAt)
                          VALUES (@CID, @UID, @Msg, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = ClassroomID;
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                        cmd.Parameters.Add("@Msg", SqlDbType.NVarChar, 2000).Value = message;
                        cmd.ExecuteNonQuery();
                    }
                }

                txtMessage.Text = "";
                LoadMessages(ClassroomID);

                ScriptManager.RegisterStartupScript(this, GetType(), "scrollChat",
                    "setTimeout(function(){scrollChat();},100);", true);
            }
            catch (SqlException) { }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/LogIn.aspx", true);
        }

        private string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "?";
            string[] parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1)
                return parts[0].Length >= 2 ? parts[0].Substring(0, 2).ToUpper() : parts[0][0].ToString().ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }

        private string GetFileIcon(string ext)
        {
            switch (ext)
            {
                case ".pdf": return "&#x1F4D5;";
                case ".doc": case ".docx": return "&#x1F4C4;";
                case ".xls": case ".xlsx": return "&#x1F4CA;";
                case ".ppt": case ".pptx": return "&#x1F4CA;";
                case ".zip": case ".rar": return "&#x1F4E6;";
                case ".jpg": case ".jpeg": case ".png": case ".gif": return "&#x1F5BC;";
                case ".mp4": case ".avi": case ".mov": return "&#x1F3AC;";
                default: return "&#x1F4CE;";
            }
        }
    }
}
