using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Instructor
{
    public partial class Classrooms : System.Web.UI.Page
    {
        private int SelectedClassroomID
        {
            get { return ViewState["SelectedClassroomID"] != null ? (int)ViewState["SelectedClassroomID"] : 0; }
            set { ViewState["SelectedClassroomID"] = value; }
        }

        private int InstructorUserID => Convert.ToInt32(Session["UserID"]);
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

        // ── Page lifecycle ────────────────────────────────────────────────────
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

            ((SiteMaster)Master).PageHeading = "Classrooms";

            if (!IsPostBack)
                LoadClassrooms();
            else if (SelectedClassroomID > 0 && pnlChatRoom.Visible)
                // Refresh messages on every postback while chat is open.
                LoadMessages(SelectedClassroomID);
        }

        // ── Section 1: classroom list ─────────────────────────────────────────
        private void LoadClassrooms()
        {
            string sql = @"
                SELECT c.ClassroomID, c.ClassroomName, c.InviteCode, c.CreatedAt,
                       COUNT(ce.StudentID) AS StudentCount
                FROM   Classrooms c
                LEFT JOIN ClassroomEnrollments ce ON ce.ClassroomID = c.ClassroomID
                WHERE  c.InstructorID = @ID
                GROUP BY c.ClassroomID, c.ClassroomName, c.InviteCode, c.CreatedAt
                ORDER BY c.CreatedAt DESC";

            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@ID", SqlDbType.Int).Value = InstructorUserID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }
                }

                if (dt.Rows.Count > 0)
                {
                    rptClassrooms.DataSource = dt;
                    rptClassrooms.DataBind();
                    pnlClassrooms.Visible = true;
                }
                else
                {
                    pnlEmpty.Visible = true;
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load classrooms. Please try again.");
            }
        }

        protected void rptClassrooms_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "OpenChat")
            {
                string[] parts    = e.CommandArgument.ToString().Split(new char[] { '|' }, 2);
                int classroomID   = Convert.ToInt32(parts[0]);
                string classroomName = parts.Length > 1 ? parts[1] : string.Empty;
                OpenChatRoom(classroomID, classroomName);
            }
            else if (e.CommandName == "Delete")
            {
                DeleteClassroom(Convert.ToInt32(e.CommandArgument));
            }
        }

        // ── Section 2: open chat room ─────────────────────────────────────────
        private void OpenChatRoom(int classroomID, string classroomName)
        {
            // Verify ownership before loading anything.
            if (!OwnsClassroom(classroomID)) return;

            SelectedClassroomID         = classroomID;
            hfChatClassroomID.Value     = classroomID.ToString();
            litChatRoomName.Text        = HttpUtility.HtmlEncode(classroomName);
            litSidebarName.Text         = HttpUtility.HtmlEncode(classroomName);
            pnlChatRoom.Visible         = true;

            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                LoadMessages(classroomID);
                LoadFiles(classroomID, conn);
                LoadAssignments(classroomID, conn);
                LoadMembers(classroomID, conn);
            }

            // Emit JS to start polling.
            string script = string.Format(
                "window.addEventListener('load',function(){{" +
                "startPolling({0},{1},{2});scrollChat();}});",
                classroomID, InstructorUserID, InstructorUserID);
            ScriptManager.RegisterStartupScript(this, GetType(), "startPoll", script, true);
        }

        // ── Close chat room ───────────────────────────────────────────────────
        protected void btnCloseChat_Click(object sender, EventArgs e)
        {
            SelectedClassroomID     = 0;
            pnlChatRoom.Visible     = false;
            hfChatClassroomID.Value = string.Empty;
            ScriptManager.RegisterStartupScript(this, GetType(), "stopPoll",
                "stopPolling();", true);
        }

        // ── Chat: send message ────────────────────────────────────────────────
        protected void btnSend_Click(object sender, EventArgs e)
        {
            string message = txtMessage.Text.Trim();
            if (string.IsNullOrEmpty(message)) return;

            int classroomID = SelectedClassroomID;
            if (classroomID == 0) return;
            if (!OwnsClassroom(classroomID)) return;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO ClassroomMessages (ClassroomID, SenderID, MessageText, SentAt)
                          VALUES (@CID, @UID, @Msg, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value           = classroomID;
                        cmd.Parameters.Add("@UID", SqlDbType.Int).Value           = InstructorUserID;
                        cmd.Parameters.Add("@Msg", SqlDbType.NVarChar, 2000).Value = message;
                        cmd.ExecuteNonQuery();
                    }
                }
                txtMessage.Text = string.Empty;
                LoadMessages(classroomID);
                ScriptManager.RegisterStartupScript(this, GetType(), "scrollAfterSend",
                    "setTimeout(scrollChat,80);", true);
            }
            catch (SqlException) { /* silent — message will appear on next poll */ }
        }

        // ── Load messages (server-side render) ────────────────────────────────
        private void LoadMessages(int classroomID)
        {
            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT TOP 100
                            cm.MessageID, cm.MessageText, cm.SentAt,
                            cm.SenderID, u.FullName AS SenderName
                          FROM ClassroomMessages cm
                          INNER JOIN Users u ON u.UserID = cm.SenderID
                          WHERE cm.ClassroomID = @CID
                          ORDER BY cm.SentAt ASC", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }
                }

                if (dt.Rows.Count == 0)
                {
                    litMessages.Text =
                        "<div class='inst-chat-empty'>" +
                        "<span></span>" +
                        "<div style='font-size:14px;font-weight:600;color:#374151;margin-bottom:4px;'>No messages yet</div>" +
                        "<div style='font-size:12px;'>Start the conversation with your students!</div>" +
                        "</div>";
                    return;
                }

                var sb = new StringBuilder();
                string lastDate = string.Empty;

                foreach (DataRow row in dt.Rows)
                {
                    int senderID  = Convert.ToInt32(row["SenderID"]);
                    string name   = row["SenderName"].ToString();
                    string text   = row["MessageText"].ToString();
                    DateTime sent = Convert.ToDateTime(row["SentAt"]);
                    string date   = sent.ToString("dd MMM yyyy");
                    string time   = sent.ToString("HH:mm");
                    int msgID     = Convert.ToInt32(row["MessageID"]);
                    bool isMine   = senderID == InstructorUserID;
                    string init   = GetInitials(name);

                    // Date separator.
                    if (date != lastDate)
                    {
                        sb.AppendFormat(
                            "<div style='text-align:center;padding:6px 0;'>" +
                            "<span style='font-size:11px;color:#9CA3AF;background:#F3F4F6;" +
                            "padding:3px 10px;border-radius:10px;'>{0}</span></div>",
                            HttpUtility.HtmlEncode(date));
                        lastDate = date;
                    }

                    string msgCls = isMine ? "inst-msg inst-msg-mine" : "inst-msg";
                    string avCls  = isMine ? "inst-msg-avatar inst-msg-avatar-inst" : "inst-msg-avatar";
                    string badge  = isMine
                        ? " <span style='font-size:10px;color:#F59E0B;'>You (Instructor)</span>"
                        : string.Empty;

                    sb.AppendFormat(
                        "<div class='{0}' data-msgid='{6}'>" +
                        "<div class='{1}'>{2}</div>" +
                        "<div class='inst-msg-content'>" +
                        "<div class='inst-msg-name'>{3}{4}</div>" +
                        "<div class='inst-msg-bubble'>{5}</div>" +
                        "<div class='inst-msg-time'>{7}</div>" +
                        "</div></div>",
                        msgCls, avCls,
                        HttpUtility.HtmlEncode(init),
                        HttpUtility.HtmlEncode(name), badge,
                        HttpUtility.HtmlEncode(text),
                        msgID, time);
                }

                litMessages.Text = sb.ToString();
            }
            catch (SqlException)
            {
                litMessages.Text =
                    "<div style='padding:16px;color:#EF4444;font-size:13px;'>" +
                    "Could not load messages.</div>";
            }
        }

        // ── Load files (read-only) ────────────────────────────────────────────
        private void LoadFiles(int classroomID, SqlConnection conn)
        {
            DataTable dt = new DataTable();
            using (SqlCommand cmd = new SqlCommand(
                @"SELECT FileName, FilePath, UploadedAt
                  FROM ClassroomMaterials
                  WHERE ClassroomID=@CID
                  ORDER BY UploadedAt DESC", conn))
            {
                cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            }

            if (dt.Rows.Count == 0)
            {
                litFiles.Text =
                    "<div class='inst-empty-panel'>" +
                    "<span></span>" +
                    "<div style='font-size:13px;font-weight:600;color:#374151;margin-bottom:4px;'>No files uploaded yet</div>" +
                    "<div style='font-size:12px;'>Use the Materials page to upload files for this classroom.</div>" +
                    "</div>";
                return;
            }

            var sb = new StringBuilder();
            sb.Append("<div class='inst-file-list'>");
            foreach (DataRow row in dt.Rows)
            {
                string fileName = row["FileName"].ToString();
                string filePath = row["FilePath"].ToString();
                string uploaded = Convert.ToDateTime(row["UploadedAt"]).ToString("dd MMM yyyy");

                sb.AppendFormat(
                    "<div class='inst-file-item'>" +
                    "<div style='flex:1;min-width:0;'>" +
                    "<div class='inst-file-name'>{0}</div>" +
                    "<div class='inst-file-meta'>Uploaded {1}</div>" +
                    "</div>" +
                    "<a href='{2}' target='_blank' rel='noopener noreferrer' " +
                    "class='cp-btn cp-btn-outline cp-btn-sm'>View</a>" +
                    "</div>",
                    HttpUtility.HtmlEncode(fileName),
                    HttpUtility.HtmlEncode(uploaded),
                    HttpUtility.HtmlEncode(filePath));
            }
            sb.Append("</div>");
            litFiles.Text = sb.ToString();
        }

        // ── Load assignments (read-only) ──────────────────────────────────────
        private void LoadAssignments(int classroomID, SqlConnection conn)
        {
            DataTable dt = new DataTable();
            using (SqlCommand cmd = new SqlCommand(
                @"SELECT AssignmentID, Title, DueDate, CreatedAt
                  FROM ClassroomAssignments
                  WHERE ClassroomID=@CID
                  ORDER BY CreatedAt DESC", conn))
            {
                cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            }

            if (dt.Rows.Count == 0)
            {
                litAssignments.Text =
                    "<div class='inst-empty-panel'>" +
                    "<span></span>" +
                    "<div style='font-size:13px;font-weight:600;color:#374151;margin-bottom:4px;'>No assignments yet</div>" +
                    "<div style='font-size:12px;'>Use the Assignments page to create assignments for this classroom.</div>" +
                    "</div>";
                return;
            }

            var sb = new StringBuilder();
            sb.Append("<div style='padding:16px 20px;display:flex;flex-direction:column;gap:10px;'>");
            foreach (DataRow row in dt.Rows)
            {
                string title   = row["Title"].ToString();
                string created = Convert.ToDateTime(row["CreatedAt"]).ToString("dd MMM yyyy");
                string dueHtml = string.Empty;
                if (row["DueDate"] != DBNull.Value)
                {
                    DateTime due    = Convert.ToDateTime(row["DueDate"]);
                    bool overdue    = due < DateTime.Now;
                    string dueStyle = overdue
                        ? "background:#FEE2E2;color:#991B1B;"
                        : "background:#FEF3C7;color:#92400E;";
                    dueHtml = string.Format(
                        "<span style='font-size:11px;font-weight:600;padding:3px 8px;" +
                        "border-radius:5px;{0}'>&#x23F0; Due: {1}</span>",
                        dueStyle, due.ToString("dd MMM yyyy"));
                }

                sb.AppendFormat(
                    "<div style='background:#fff;border:1px solid #E5E7EB;border-radius:10px;" +
                    "padding:14px 16px;border-left:4px solid #6366F1;'>" +
                    "<div style='font-size:14px;font-weight:700;color:#111827;margin-bottom:5px;'>{0}</div>" +
                    "<div style='display:flex;gap:12px;align-items:center;flex-wrap:wrap;" +
                    "font-size:12px;color:#6B7280;'>" +
                    "<span>Posted: {1}</span>{2}" +
                    "</div></div>",
                    HttpUtility.HtmlEncode(title), created, dueHtml);
            }
            sb.Append("</div>");
            litAssignments.Text = sb.ToString();
        }

        // ── Load members ──────────────────────────────────────────────────────
        private void LoadMembers(int classroomID, SqlConnection conn)
        {
            var sb = new StringBuilder();
            sb.Append("<div class='inst-members-list'>");

            // Instructor row (self).
            string fullName = Session["FullName"] != null ? Session["FullName"].ToString() : "Instructor";
            sb.AppendFormat(
                "<div class='inst-member-item'>" +
                "<div class='inst-member-avatar inst-member-avatar-inst'>{0}</div>" +
                "<div style='flex:1;'>" +
                "<div class='inst-member-name'>{1}</div>" +
                "<div class='inst-member-role'>Instructor (You)</div></div>" +
                "<span style='font-size:11px;font-weight:600;padding:2px 8px;" +
                "border-radius:10px;background:#FEF3C7;color:#92400E;'>Instructor</span>" +
                "</div>",
                HttpUtility.HtmlEncode(GetInitials(fullName)),
                HttpUtility.HtmlEncode(fullName));

            // Students.
            using (SqlCommand cmd = new SqlCommand(
                @"SELECT u.FullName, ce.EnrolledAt
                  FROM ClassroomEnrollments ce
                  INNER JOIN Users u ON u.UserID = ce.StudentID
                  WHERE ce.ClassroomID=@CID
                  ORDER BY u.FullName", conn))
            {
                cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string sName = rdr["FullName"].ToString();
                        sb.AppendFormat(
                            "<div class='inst-member-item'>" +
                            "<div class='inst-member-avatar'>{0}</div>" +
                            "<div style='flex:1;'>" +
                            "<div class='inst-member-name'>{1}</div>" +
                            "<div class='inst-member-role'>Student</div></div>" +
                            "<span style='font-size:11px;font-weight:600;padding:2px 8px;" +
                            "border-radius:10px;background:#EEF2FF;color:#4338CA;'>Student</span>" +
                            "</div>",
                            HttpUtility.HtmlEncode(GetInitials(sName)),
                            HttpUtility.HtmlEncode(sName));
                    }
                }
            }

            sb.Append("</div>");
            litMembers.Text = sb.ToString();
        }

        // ── Delete classroom ──────────────────────────────────────────────────
        private void DeleteClassroom(int classroomID)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "DELETE FROM Classrooms WHERE ClassroomID=@CID AND InstructorID=@IID", conn))
                    {
                        cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                        cmd.Parameters.Add("@IID", SqlDbType.Int).Value = InstructorUserID;
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowSuccess("Classroom deleted.");
                if (SelectedClassroomID == classroomID)
                {
                    SelectedClassroomID     = 0;
                    pnlChatRoom.Visible     = false;
                    hfChatClassroomID.Value = string.Empty;
                }
                pnlClassrooms.Visible = false;
                pnlEmpty.Visible      = false;
                LoadClassrooms();
            }
            catch (SqlException)
            {
                ShowError("Could not delete classroom. Remove assignments and materials first.");
            }
        }

        // ── Create classroom ──────────────────────────────────────────────────
        protected void btnCreate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string name = txtClassName.Text.Trim();
            string code = txtInviteCode.Text.Trim().ToUpper();

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (SqlCommand chk = new SqlCommand(
                        "SELECT COUNT(*) FROM Classrooms WHERE InviteCode=@Code", conn))
                    {
                        chk.Parameters.Add("@Code", SqlDbType.NVarChar, 20).Value = code;
                        if (Convert.ToInt32(chk.ExecuteScalar()) > 0)
                        {
                            ShowError("That invite code is already in use. Please choose another.");
                            return;
                        }
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO Classrooms (InstructorID, ClassroomName, InviteCode, CreatedAt)
                          VALUES (@IID, @Name, @Code, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@IID",  SqlDbType.Int).Value          = InstructorUserID;
                        cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 100).Value = name;
                        cmd.Parameters.Add("@Code", SqlDbType.NVarChar, 20).Value  = code;
                        cmd.ExecuteNonQuery();
                    }
                }

                txtClassName.Text  = string.Empty;
                txtInviteCode.Text = string.Empty;
                ShowSuccess("Classroom created. Share the invite code with your students.");
                pnlClassrooms.Visible = false;
                pnlEmpty.Visible      = false;
                LoadClassrooms();
            }
            catch (SqlException)
            {
                ShowError("Could not create classroom. Please try again.");
            }
        }

        // ── Helpers ───────────────────────────────────────────────────────────
        private bool OwnsClassroom(int classroomID)
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Classrooms WHERE ClassroomID=@CID AND InstructorID=@IID", conn))
                {
                    cmd.Parameters.Add("@CID", SqlDbType.Int).Value = classroomID;
                    cmd.Parameters.Add("@IID", SqlDbType.Int).Value = InstructorUserID;
                    return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                }
            }
        }

        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "?";
            string[] parts = name.Trim().Split(
                new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1)
                return (parts[0].Length >= 2
                    ? parts[0].Substring(0, 2)
                    : parts[0][0].ToString()).ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }

        private void ShowSuccess(string msg)
        {
            litSuccess.Text    = HttpUtility.HtmlEncode(msg);
            pnlSuccess.Visible = true;
            pnlError.Visible   = false;
        }

        private void ShowError(string msg)
        {
            litError.Text      = HttpUtility.HtmlEncode(msg);
            pnlError.Visible   = true;
            pnlSuccess.Visible = false;
        }
    }
}
