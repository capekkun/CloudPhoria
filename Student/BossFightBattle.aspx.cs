using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class BossFightBattle : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Boss Battle";

            if (!IsPostBack)
            {
                int roomID;
                if (!int.TryParse(Request.QueryString["roomID"], out roomID))
                {
                    Response.Redirect("~/Student/BossFights.aspx");
                    return;
                }
                LoadBattleInfo(roomID);
            }
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
        }

        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString; }
        }

        private void LoadBattleInfo(int roomID)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    string sql = @"SELECT bfr.Title, bfr.DifficultyLevel, bfr.XPReward, bfr.PlayerMaxHP,
                                          b.BossName, b.MaxHP, b.IconPath, b.AttackStrength
                                   FROM BossFightRooms bfr
                                   INNER JOIN Bosses b ON b.RoomID = bfr.RoomID
                                   WHERE bfr.RoomID = @RoomID AND bfr.IsPublished = 1";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@RoomID", SqlDbType.Int).Value = roomID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                string bossName = rdr["BossName"].ToString();
                                string diff     = rdr["DifficultyLevel"].ToString();
                                int bossMaxHP   = Convert.ToInt32(rdr["MaxHP"]);
                                int playerMaxHP = Convert.ToInt32(rdr["PlayerMaxHP"]);
                                int xpReward    = Convert.ToInt32(rdr["XPReward"]);
                                string iconPath = rdr["IconPath"] != DBNull.Value ? rdr["IconPath"].ToString() : "";

                                litBossName.Text    = HttpUtility.HtmlEncode(bossName);
                                litDifficulty.Text  = HttpUtility.HtmlEncode(diff);
                                litBossHP.Text      = bossMaxHP.ToString();
                                litBossMaxHP.Text   = bossMaxHP.ToString();
                                litPlayerHP.Text    = playerMaxHP.ToString();
                                litPlayerMaxHP.Text = playerMaxHP.ToString();
                                litXPReward.Text    = xpReward.ToString();

                                // Set difficulty class on the span
                                spanDiff.Attributes["class"] = "bf-boss-diff bf-diff-" + diff.ToLower();

                                // Boss visual — use icon image if valid, else SVG monster
                                if (!string.IsNullOrEmpty(iconPath) && System.IO.File.Exists(Server.MapPath("~" + iconPath)))
                                {
                                    litBossVisual.Text = "<img src='" + ResolveUrl("~" + iconPath) +
                                        "' alt='" + HttpUtility.HtmlAttributeEncode(bossName) + "' />";
                                }
                                else
                                {
                                    // Default SVG dragon monster
                                    litBossVisual.Text = @"<svg class='bf-monster-svg' viewBox='0 0 80 80' fill='none' xmlns='http://www.w3.org/2000/svg'>
                                        <ellipse cx='40' cy='44' rx='26' ry='22' fill='#7C3AED'/>
                                        <ellipse cx='40' cy='44' rx='20' ry='17' fill='#5B21B6'/>
                                        <!-- Horns -->
                                        <path d='M22 32 L18 16 L28 28 Z' fill='#DC2626'/>
                                        <path d='M58 32 L62 16 L52 28 Z' fill='#DC2626'/>
                                        <!-- Eyes - glowing red -->
                                        <ellipse cx='32' cy='40' rx='5' ry='6' fill='#111'/>
                                        <ellipse cx='48' cy='40' rx='5' ry='6' fill='#111'/>
                                        <circle cx='32' cy='39' r='3' fill='#EF4444'/>
                                        <circle cx='48' cy='39' r='3' fill='#EF4444'/>
                                        <circle cx='33' cy='38' r='1.5' fill='#FCA5A5'/>
                                        <circle cx='49' cy='38' r='1.5' fill='#FCA5A5'/>
                                        <!-- Mouth with fangs -->
                                        <path d='M30 52 Q40 58 50 52' stroke='#111' stroke-width='2' fill='none'/>
                                        <path d='M33 52 L35 56 L37 52' fill='#fff'/>
                                        <path d='M43 52 L45 56 L47 52' fill='#fff'/>
                                        <!-- Wings -->
                                        <path d='M14 38 Q8 26 16 20 Q20 28 18 35 Z' fill='#9333EA' opacity='0.7'/>
                                        <path d='M66 38 Q72 26 64 20 Q60 28 62 35 Z' fill='#9333EA' opacity='0.7'/>
                                        <!-- Fire breath particles -->
                                        <circle cx='40' cy='62' r='3' fill='#F97316' opacity='0.6'/>
                                        <circle cx='36' cy='65' r='2' fill='#EF4444' opacity='0.5'/>
                                        <circle cx='44' cy='64' r='2.5' fill='#F59E0B' opacity='0.5'/>
                                        <!-- Spikes on head -->
                                        <path d='M35 28 L37 22 L39 28' fill='#A855F7'/>
                                        <path d='M39 27 L41 20 L43 27' fill='#A855F7'/>
                                        <path d='M43 28 L45 22 L47 28' fill='#A855F7'/>
                                    </svg>";
                                }

                                pnlStart.Style["display"] = "block";

                                // Store in ViewState for battle
                                ViewState["RoomID"]      = roomID;
                                ViewState["BossMaxHP"]   = bossMaxHP;
                                ViewState["PlayerMaxHP"] = playerMaxHP;
                                ViewState["XPReward"]    = xpReward;
                                ViewState["AttackStr"]   = Convert.ToInt32(rdr["AttackStrength"]);
                            }
                            else
                            {
                                ShowError("Boss fight room not found.");
                            }
                        }
                    }
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load the boss fight. Please try again.");
            }
        }

        protected void btnStartBattle_Click(object sender, EventArgs e)
        {
            int roomID    = ViewState["RoomID"]    != null ? (int)ViewState["RoomID"] : 0;
            int bossMaxHP = ViewState["BossMaxHP"] != null ? (int)ViewState["BossMaxHP"] : 100;
            int playerMax = ViewState["PlayerMaxHP"] != null ? (int)ViewState["PlayerMaxHP"] : 100;
            int studentID = Convert.ToInt32(Session["UserID"]);

            if (roomID == 0) { ShowError("Invalid room."); return; }

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO BattleSessions
                          (RoomID, StudentID, PlayerMaxHP, PlayerCurrentHP, BossMaxHP, BossCurrentHP, Status, XPAwarded, StartedAt)
                          VALUES (@RID, @SID, @PMax, @PMax, @BMax, @BMax, 'InProgress', 0, GETDATE());
                          SELECT SCOPE_IDENTITY();", conn))
                    {
                        cmd.Parameters.Add("@RID",  SqlDbType.Int).Value = roomID;
                        cmd.Parameters.Add("@SID",  SqlDbType.Int).Value = studentID;
                        cmd.Parameters.Add("@PMax", SqlDbType.Int).Value = playerMax;
                        cmd.Parameters.Add("@BMax", SqlDbType.Int).Value = bossMaxHP;

                        int sessionID = Convert.ToInt32(cmd.ExecuteScalar());
                        ViewState["SessionID"]   = sessionID;
                        ViewState["BossCurrentHP"]   = bossMaxHP;
                        ViewState["PlayerCurrentHP"] = playerMax;
                        ViewState["TurnNumber"]      = 1;
                    }
                }

                pnlStart.Style["display"] = "none";
                LoadNextQuestion();
            }
            catch (SqlException)
            {
                ShowError("Could not start the battle. Please try again.");
            }
        }

        private void LoadNextQuestion()
        {
            int roomID = (int)ViewState["RoomID"];
            int turn   = (int)ViewState["TurnNumber"];

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string sql = @"SELECT TOP 1 bfq.BossFightQuestionID, bfq.QuestionText,
                                          bfq.DamageValue, bfq.TimeLimitSeconds
                                   FROM BossFightQuestions bfq
                                   WHERE bfq.RoomID = @RoomID
                                   ORDER BY NEWID()";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@RoomID", SqlDbType.Int).Value = roomID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                int qID       = Convert.ToInt32(rdr["BossFightQuestionID"]);
                                string qText  = rdr["QuestionText"].ToString();
                                int damage    = Convert.ToInt32(rdr["DamageValue"]);
                                int timeLimit = Convert.ToInt32(rdr["TimeLimitSeconds"]);

                                ViewState["CurrentQID"]    = qID;
                                ViewState["CurrentDamage"] = damage;

                                litTurnNumber.Text = turn.ToString();
                                hdnTimeLimit.Value = timeLimit.ToString();
                                litQuestionText.Text = HttpUtility.HtmlEncode(qText);

                                // Set timer data attribute for JS
                                bfTimer.Attributes["data-seconds"] = timeLimit.ToString();
                                ScriptManager.RegisterStartupScript(this, GetType(), "startTimer",
                                    "startBFTimer(" + timeLimit + ");", true);

                                rdr.Close();

                                // Load options into the 4 static buttons
                                DataTable dtOpts = new DataTable();
                                using (SqlCommand optCmd = new SqlCommand(
                                    @"SELECT OptionID, OptionText
                                      FROM BossFightQuestionOptions
                                      WHERE BossFightQuestionID = @QID
                                      ORDER BY NEWID()", conn))
                                {
                                    optCmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
                                    using (SqlDataAdapter da = new SqlDataAdapter(optCmd))
                                        da.Fill(dtOpts);
                                }

                                // Render options as clickable HTML
                                var sb = new System.Text.StringBuilder();
                                for (int i = 0; i < dtOpts.Rows.Count; i++)
                                {
                                    string oid = dtOpts.Rows[i]["OptionID"].ToString();
                                    string otext = HttpUtility.HtmlEncode(dtOpts.Rows[i]["OptionText"].ToString());
                                    sb.AppendFormat(
                                        "<a href='#' class='bf-opt-btn' onclick=\"document.getElementById('{0}').value='{1}';" +
                                        "__doPostBack('{2}','');return false;\">{3}</a>",
                                        hdnAnswer.ClientID, oid, btnProcessAnswer.UniqueID, otext);
                                }
                                litBFOpts.Text = sb.ToString();

                                if (dtOpts.Rows.Count == 0)
                                {
                                    litBFOpts.Text = "<div style='color:#FCA5A5;font-size:13px;'>No options found for this question.</div>";
                                }

                                pnlQuestion.Style["display"] = "block";
                                pnlTurnResult.Style["display"] = "none";
                                pnlStart.Style["display"] = "none";
                            }
                            else
                            {
                                EndBattle(true);
                            }
                        }
                    }
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load the next question.");
            }
        }

        protected void btnProcessAnswer_Click(object sender, EventArgs e)
        {
            int selectedOptionID;
            if (!int.TryParse(hdnAnswer.Value, out selectedOptionID)) return;

            int qID       = (int)ViewState["CurrentQID"];
            int damage    = (int)ViewState["CurrentDamage"];
            int attackStr = (int)ViewState["AttackStr"];
            int sessionID = (int)ViewState["SessionID"];
            int bossHP    = (int)ViewState["BossCurrentHP"];
            int playerHP  = (int)ViewState["PlayerCurrentHP"];

            bool isCorrect = false;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT IsCorrect FROM BossFightQuestionOptions WHERE OptionID = @OID", conn))
                    {
                        cmd.Parameters.Add("@OID", SqlDbType.Int).Value = selectedOptionID;
                        object r = cmd.ExecuteScalar();
                        isCorrect = (r != null && Convert.ToBoolean(r));
                    }

                    int dmgToBoss   = isCorrect ? damage : 0;
                    int dmgToPlayer = isCorrect ? 0 : attackStr;

                    bossHP   = Math.Max(0, bossHP - dmgToBoss);
                    playerHP = Math.Max(0, playerHP - dmgToPlayer);

                    ViewState["BossCurrentHP"]   = bossHP;
                    ViewState["PlayerCurrentHP"] = playerHP;

                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO BattleSessionAnswers
                          (SessionID, BossFightQuestionID, SelectedOptionID, IsCorrect,
                           DamageDealtToBoss, DamageTakenByPlayer, AnsweredAt)
                          VALUES (@SID, @QID, @OID, @Correct, @DTB, @DTP, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@SID",     SqlDbType.Int).Value = sessionID;
                        cmd.Parameters.Add("@QID",     SqlDbType.Int).Value = qID;
                        cmd.Parameters.Add("@OID",     SqlDbType.Int).Value = selectedOptionID;
                        cmd.Parameters.Add("@Correct", SqlDbType.Bit).Value = isCorrect;
                        cmd.Parameters.Add("@DTB",     SqlDbType.Int).Value = dmgToBoss;
                        cmd.Parameters.Add("@DTP",     SqlDbType.Int).Value = dmgToPlayer;
                        cmd.ExecuteNonQuery();
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        @"UPDATE BattleSessions SET BossCurrentHP=@BHP, PlayerCurrentHP=@PHP
                          WHERE SessionID=@SID", conn))
                    {
                        cmd.Parameters.Add("@BHP", SqlDbType.Int).Value = bossHP;
                        cmd.Parameters.Add("@PHP", SqlDbType.Int).Value = playerHP;
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = sessionID;
                        cmd.ExecuteNonQuery();
                    }
                }

                // Update HP display
                int bossMax   = (int)ViewState["BossMaxHP"];
                int playerMax = (int)ViewState["PlayerMaxHP"];
                litBossHP.Text   = bossHP.ToString();
                litPlayerHP.Text = playerHP.ToString();
                bossHPBar.Style["width"]   = ((bossHP * 100) / Math.Max(1, bossMax)) + "%";
                playerHPBar.Style["width"] = ((playerHP * 100) / Math.Max(1, playerMax)) + "%";

                if (bossHP <= 0) { EndBattle(true); return; }
                if (playerHP <= 0) { EndBattle(false); return; }

                // Show turn result
                pnlQuestion.Style["display"] = "none";
                pnlTurnResult.Style["display"] = "block";

                if (isCorrect)
                {
                    litTurnIcon.Text  = "&#x2694;&#xFE0F;";
                    litTurnTitle.Text = "DIRECT HIT!";
                    litTurnDesc.Text  = "You dealt " + damage + " damage to the boss!";
                }
                else
                {
                    litTurnIcon.Text  = "&#x1F4A5;";
                    litTurnTitle.Text = "THE BOSS ATTACKS!";
                    litTurnDesc.Text  = "Wrong answer! The boss dealt " + attackStr + " damage to you!";
                }

                ViewState["TurnNumber"] = (int)ViewState["TurnNumber"] + 1;
            }
            catch (SqlException)
            {
                ShowError("An error occurred during combat.");
            }
        }

        protected void btnNextTurn_Click(object sender, EventArgs e)
        {
            pnlTurnResult.Style["display"] = "none";
            LoadNextQuestion();
        }

        private void EndBattle(bool won)
        {
            int sessionID = (int)ViewState["SessionID"];
            int studentID = Convert.ToInt32(Session["UserID"]);
            int xpReward  = won ? (int)ViewState["XPReward"] : 0;
            string status = won ? "Won" : "Lost";

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlTransaction tran = conn.BeginTransaction())
                    {
                        // Update session status
                        using (SqlCommand cmd = new SqlCommand(
                            @"UPDATE BattleSessions
                              SET Status = @Status, XPAwarded = @XP, EndedAt = GETDATE()
                              WHERE SessionID = @SID", conn, tran))
                        {
                            cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 20).Value = status;
                            cmd.Parameters.Add("@XP",     SqlDbType.Int).Value = xpReward;
                            cmd.Parameters.Add("@SID",    SqlDbType.Int).Value = sessionID;
                            cmd.ExecuteNonQuery();
                        }

                        if (won && xpReward > 0)
                        {
                            // Insert XP transaction
                            using (SqlCommand cmd = new SqlCommand(
                                @"INSERT INTO XPTransactions (StudentID, SourceType, SourceID, XPAmount, CreatedAt)
                                  VALUES (@SID, 'BossFight', @RoomID, @XP, GETDATE())", conn, tran))
                            {
                                cmd.Parameters.Add("@SID",    SqlDbType.Int).Value = studentID;
                                cmd.Parameters.Add("@RoomID", SqlDbType.Int).Value = (int)ViewState["RoomID"];
                                cmd.Parameters.Add("@XP",     SqlDbType.Int).Value = xpReward;
                                cmd.ExecuteNonQuery();
                            }

                            // Update TotalXP
                            using (SqlCommand cmd = new SqlCommand(
                                "UPDATE Students SET TotalXP = TotalXP + @XP WHERE StudentID = @SID", conn, tran))
                            {
                                cmd.Parameters.Add("@XP",  SqlDbType.Int).Value = xpReward;
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                                cmd.ExecuteNonQuery();
                            }

                            // Create notification for the victory
                            using (SqlCommand cmd = new SqlCommand(
                                @"INSERT INTO Notifications (UserID, Message, NotificationType, IsRead, CreatedAt)
                                  VALUES (@UID, @Msg, 'BossFightWon', 0, GETDATE())", conn, tran))
                            {
                                cmd.Parameters.Add("@UID", SqlDbType.Int).Value = studentID;
                                cmd.Parameters.Add("@Msg", SqlDbType.NVarChar, 500).Value =
                                    "Victory! You defeated the boss. +" + xpReward + " XP earned.";
                                cmd.ExecuteNonQuery();
                            }
                        }

                        // Insert notification for boss fight result
                        string notifMsg = won
                            ? "Victory! You defeated the boss. +" + xpReward + " XP earned."
                            : "You were defeated by the boss. Want to try again?";
                        string notifType = won ? "BossFightWon" : "BossFightLost";
                        using (SqlCommand cmd = new SqlCommand(
                            @"INSERT INTO Notifications (UserID, Message, NotificationType, IsRead, CreatedAt)
                              VALUES (@UID, @Msg, @Type, 0, GETDATE())", conn, tran))
                        {
                            cmd.Parameters.Add("@UID",  SqlDbType.Int).Value = studentID;
                            cmd.Parameters.Add("@Msg",  SqlDbType.NVarChar, 500).Value = notifMsg;
                            cmd.Parameters.Add("@Type", SqlDbType.NVarChar, 30).Value = notifType;
                            cmd.ExecuteNonQuery();
                        }

                        tran.Commit();
                    }
                }
            }
            catch (SqlException) { /* non-critical for display */ }

            // Show result
            pnlStart.Style["display"] = "none";
            pnlQuestion.Style["display"] = "none";
            pnlTurnResult.Style["display"] = "none";
            pnlResult.Style["display"] = "block";

            if (won)
            {
                litResultIcon.Text  = "&#x1F3C6;";
                litResultTitle.Text = "VICTORY!";
                litResultSub.Text   = "You defeated the boss! The cloud realm is safer.";
                litResultXP.Text    = xpReward.ToString();
                pnlResultXP.Visible = true;
            }
            else
            {
                litResultIcon.Text  = "&#x1F4A0;";
                litResultTitle.Text = "DEFEATED";
                litResultSub.Text   = "The boss was too strong this time. Train more and try again!";
            }
        }

        private void ShowError(string msg)
        {
            litError.Text    = HttpUtility.HtmlEncode(msg);
            pnlError.Visible = true;
        }
    }
}
