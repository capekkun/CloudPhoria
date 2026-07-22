using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Admin
{
    public partial class BossFights : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                LoadRooms("", "");
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadRooms(ddlFilterDiff.SelectedValue, ddlFilterPub.SelectedValue);
        }

        protected void btnClearFilter_Click(object sender, EventArgs e)
        {
            ddlFilterDiff.SelectedIndex = 0;
            ddlFilterPub.SelectedIndex  = 0;
            LoadRooms("", "");
        }

        private void LoadRooms(string difficulty, string published)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    string sql = @"
                        SELECT
                            r.RoomID,
                            r.Title,
                            r.DifficultyLevel,
                            r.XPReward,
                            r.IsPublished,
                            r.CreatedAt,
                            b.BossName,
                            (SELECT COUNT(*) FROM BossFightQuestions q
                             WHERE q.RoomID = r.RoomID) AS QuestionCount
                        FROM BossFightRooms r
                        LEFT JOIN Bosses b ON b.RoomID = r.RoomID
                        WHERE (@Difficulty = '' OR r.DifficultyLevel = @Difficulty)
                          AND (@Published  = '' OR r.IsPublished = @PublishedBit)
                        ORDER BY r.CreatedAt DESC";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@Difficulty",  SqlDbType.NVarChar, 20).Value = difficulty ?? "";
                        cmd.Parameters.Add("@Published",   SqlDbType.NVarChar, 2).Value  = published  ?? "";
                        cmd.Parameters.Add("@PublishedBit",SqlDbType.Bit).Value =
                            published == "1" ? (object)1 : (published == "0" ? (object)0 : DBNull.Value);

                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                            da.Fill(dt);

                        litCount.Text = dt.Rows.Count.ToString();

                        if (dt.Rows.Count > 0)
                        {
                            rptRooms.DataSource = dt;
                            rptRooms.DataBind();
                            pnlList.Visible  = true;
                            pnlEmpty.Visible = false;
                        }
                        else
                        {
                            pnlList.Visible  = false;
                            pnlEmpty.Visible = true;
                        }
                    }
                }
            }
            catch (SqlException)
            {
                ShowMessage("Could not load boss fight rooms. Please try again.", false);
            }
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string title = txtTitle.Text.Trim();
            if (string.IsNullOrEmpty(title))
            {
                ShowMessage("Title is required.", false);
                return;
            }

            if (!int.TryParse(txtXPReward.Text.Trim(), out int xpReward) || xpReward < 1)
            {
                ShowMessage("Please enter a valid XP Reward.", false);
                return;
            }

            if (!int.TryParse(txtPlayerHP.Text.Trim(), out int playerHP) || playerHP < 1)
            {
                ShowMessage("Please enter a valid Player Max HP.", false);
                return;
            }

            string difficulty = ddlDifficulty.SelectedValue;
            // Validate difficulty against the allowed check constraint values.
            if (difficulty != "Easy" && difficulty != "Medium" &&
                difficulty != "Hard" && difficulty != "Legendary")
            {
                ShowMessage("Invalid difficulty level.", false);
                return;
            }

            string theme  = txtTheme.Text.Trim();
            int    adminID = Convert.ToInt32(Session["UserID"]);
            string cs      = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    using (SqlTransaction tx = conn.BeginTransaction())
                    {
                        try
                        {
                            string insertSQL = @"
                                INSERT INTO BossFightRooms
                                    (Title, ThemeDescription, DifficultyLevel, XPReward,
                                     PlayerMaxHP, IsPublished, CreatedByAdminID, CreatedAt)
                                OUTPUT INSERTED.RoomID
                                VALUES
                                    (@Title, @Theme, @Difficulty, @XPReward,
                                     @PlayerHP, 0, @AdminID, GETDATE())";

                            int newRoomID;
                            using (SqlCommand insertCmd = new SqlCommand(insertSQL, conn, tx))
                            {
                                insertCmd.Parameters.Add("@Title",      SqlDbType.NVarChar, 150).Value = title;
                                insertCmd.Parameters.Add("@Theme",      SqlDbType.NVarChar, -1).Value  =
                                    string.IsNullOrEmpty(theme) ? (object)DBNull.Value : theme;
                                insertCmd.Parameters.Add("@Difficulty", SqlDbType.NVarChar, 20).Value  = difficulty;
                                insertCmd.Parameters.Add("@XPReward",   SqlDbType.Int).Value           = xpReward;
                                insertCmd.Parameters.Add("@PlayerHP",   SqlDbType.Int).Value           = playerHP;
                                insertCmd.Parameters.Add("@AdminID",    SqlDbType.Int).Value           = adminID;
                                newRoomID = Convert.ToInt32(insertCmd.ExecuteScalar());
                            }

                            // Audit log.
                            string auditSQL = @"
                                INSERT INTO AuditLogs
                                    (PerformedByUserID, ActionType, TargetTable, TargetID, Details, CreatedAt)
                                VALUES
                                    (@AdminID, 'CREATE_BOSSFIGHT_ROOM', 'BossFightRooms', @RoomID, @Details, GETDATE())";
                            using (SqlCommand auditCmd = new SqlCommand(auditSQL, conn, tx))
                            {
                                auditCmd.Parameters.Add("@AdminID",  SqlDbType.Int).Value          = adminID;
                                auditCmd.Parameters.Add("@RoomID",   SqlDbType.Int).Value          = newRoomID;
                                auditCmd.Parameters.Add("@Details",  SqlDbType.NVarChar, -1).Value =
                                    $"Admin UserID {adminID} created BossFightRoom '{title}' (ID: {newRoomID}).";
                                auditCmd.ExecuteNonQuery();
                            }

                            tx.Commit();

                            // Clear form.
                            txtTitle.Text    = "";
                            txtXPReward.Text = "";
                            txtPlayerHP.Text = "";
                            txtTheme.Text    = "";

                            ShowMessage($"Boss Fight room '{HttpUtility.HtmlEncode(title)}' created. Add a boss and questions to publish it.", true);
                        }
                        catch
                        {
                            tx.Rollback();
                            throw;
                        }
                    }
                }
            }
            catch (SqlException)
            {
                ShowMessage("Could not create the room. Please try again.", false);
            }

            LoadRooms(ddlFilterDiff.SelectedValue, ddlFilterPub.SelectedValue);
        }

        protected void rptRooms_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument.ToString(), out int roomID) || roomID <= 0)
            {
                ShowMessage("Invalid room ID.", false);
                return;
            }

            bool publish = e.CommandName == "Publish";
            if (e.CommandName != "Publish" && e.CommandName != "Unpublish")
            {
                ShowMessage("Unknown action.", false);
                return;
            }

            int    adminID    = Convert.ToInt32(Session["UserID"]);
            string actionType = publish ? "PUBLISH_BOSSFIGHT_ROOM" : "UNPUBLISH_BOSSFIGHT_ROOM";
            string cs         = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Verify room exists.
                    string verifySQL  = "SELECT Title FROM BossFightRooms WHERE RoomID = @RID";
                    string roomTitle  = "";
                    using (SqlCommand verifyCmd = new SqlCommand(verifySQL, conn))
                    {
                        verifyCmd.Parameters.Add("@RID", SqlDbType.Int).Value = roomID;
                        object r = verifyCmd.ExecuteScalar();
                        if (r == null || r == DBNull.Value)
                        {
                            ShowMessage("Room not found.", false);
                            return;
                        }
                        roomTitle = r.ToString();
                    }

                    // When publishing, ensure a boss record exists for this room.
                    if (publish)
                    {
                        string bossCheck = "SELECT COUNT(*) FROM Bosses WHERE RoomID = @RID";
                        using (SqlCommand checkCmd = new SqlCommand(bossCheck, conn))
                        {
                            checkCmd.Parameters.Add("@RID", SqlDbType.Int).Value = roomID;
                            int bossCount = Convert.ToInt32(checkCmd.ExecuteScalar());
                            if (bossCount == 0)
                            {
                                ShowMessage("Cannot publish: this room has no boss. Add a boss first.", false);
                                return;
                            }
                        }
                    }

                    using (SqlTransaction tx = conn.BeginTransaction())
                    {
                        try
                        {
                            string updateSQL = "UPDATE BossFightRooms SET IsPublished = @Published, UpdatedAt = GETDATE() WHERE RoomID = @RID";
                            using (SqlCommand updateCmd = new SqlCommand(updateSQL, conn, tx))
                            {
                                updateCmd.Parameters.Add("@Published", SqlDbType.Bit).Value = publish ? 1 : 0;
                                updateCmd.Parameters.Add("@RID",       SqlDbType.Int).Value = roomID;
                                updateCmd.ExecuteNonQuery();
                            }

                            string auditSQL = @"
                                INSERT INTO AuditLogs
                                    (PerformedByUserID, ActionType, TargetTable, TargetID, Details, CreatedAt)
                                VALUES
                                    (@AdminID, @ActionType, 'BossFightRooms', @TargetID, @Details, GETDATE())";
                            using (SqlCommand auditCmd = new SqlCommand(auditSQL, conn, tx))
                            {
                                auditCmd.Parameters.Add("@AdminID",    SqlDbType.Int).Value           = adminID;
                                auditCmd.Parameters.Add("@ActionType", SqlDbType.NVarChar, 100).Value = actionType;
                                auditCmd.Parameters.Add("@TargetID",   SqlDbType.Int).Value           = roomID;
                                auditCmd.Parameters.Add("@Details",    SqlDbType.NVarChar, -1).Value  =
                                    $"Admin UserID {adminID} {(publish ? "published" : "unpublished")} BossFightRoom '{roomTitle}' (ID: {roomID}).";
                                auditCmd.ExecuteNonQuery();
                            }

                            tx.Commit();
                            ShowMessage($"Room '{HttpUtility.HtmlEncode(roomTitle)}' {(publish ? "published" : "unpublished")}.", true);
                        }
                        catch
                        {
                            tx.Rollback();
                            throw;
                        }
                    }
                }
            }
            catch (SqlException)
            {
                ShowMessage("Could not update the room. Please try again.", false);
            }

            LoadRooms(ddlFilterDiff.SelectedValue, ddlFilterPub.SelectedValue);
        }

        protected string GetDifficultyBadge(string level)
        {
            switch (level)
            {
                case "Easy":      return "<span class='cp-badge cp-badge-green'>Easy</span>";
                case "Medium":    return "<span class='cp-badge cp-badge-amber'>Medium</span>";
                case "Hard":      return "<span class='cp-badge cp-badge-red'>Hard</span>";
                case "Legendary": return "<span class='cp-badge cp-badge-indigo'>Legendary</span>";
                default:          return "<span class='cp-badge cp-badge-grey'>" + HttpUtility.HtmlEncode(level) + "</span>";
            }
        }

        private void ShowMessage(string message, bool success)
        {
            string cssClass    = success ? "cp-alert cp-alert-success" : "cp-alert cp-alert-danger";
            litMessage.Text    = $"<div class='{cssClass}'>{HttpUtility.HtmlEncode(message)}</div>";
            pnlMessage.Visible = true;
        }
    }
}
