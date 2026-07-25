using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class BossFights : System.Web.UI.Page
    {
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString; }
        }

        // Boss icon/background images are uploaded as a matching pair, e.g.
        // "/uploads/bosses/firewall-beast-icon.png" and "...-bg.png".
        // IconPath is stored in the database (Bosses.IconPath); the background
        // path is derived from it by convention, avoiding a second DB column.
        // Used by the rooms grid repeater markup to render each room's icon.
        protected static string GetBossIconPath(object iconPath)
        {
            string path = iconPath != null && iconPath != DBNull.Value ? iconPath.ToString() : "";
            return HttpUtility.HtmlAttributeEncode(path);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            bool isGuest = (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student");

            if (!IsPostBack)
            {
                int roomID;
                if (!isGuest && int.TryParse(Request.QueryString["roomID"], out roomID) && roomID > 0)
                {
                    ViewState["RoomID"] = roomID;
                    LoadBattleStart(roomID);
                    return;
                }
                LoadBossFights();
            }
        }

        private void LoadBossFights()
        {
            int studentID = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string roomsSql = @"
                        SELECT bfr.RoomID, bfr.Title, bfr.DifficultyLevel, bfr.XPReward,
                               b.BossName, b.MaxHP, b.IconPath,
                               CASE WHEN EXISTS (
                                   SELECT 1 FROM BattleSessions bs
                                   WHERE bs.RoomID    = bfr.RoomID
                                     AND bs.StudentID = @StudentID
                                     AND bs.Status    = 'Won')
                               THEN 1 ELSE 0 END AS HasWon
                        FROM BossFightRooms bfr
                        INNER JOIN Bosses b ON b.RoomID = bfr.RoomID
                        WHERE bfr.IsPublished = 1
                        ORDER BY bfr.DifficultyLevel, bfr.RoomID";

                    DataTable dtRooms = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(roomsSql, conn))
                    {
                        cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtRooms);
                    }

                    if (dtRooms.Rows.Count > 0)
                    {
                        rptRooms.DataSource = dtRooms;
                        rptRooms.DataBind();
                        pnlRooms.Visible = true;
                    }
                    else { pnlEmpty.Visible = true; }

                    string historySql = @"
                        SELECT bfr.Title, bs.Status, bs.XPAwarded, bs.StartedAt
                        FROM BattleSessions bs
                        INNER JOIN BossFightRooms bfr ON bfr.RoomID = bs.RoomID
                        WHERE bs.StudentID = @StudentID
                        ORDER BY bs.StartedAt DESC";

                    DataTable dtHist = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(historySql, conn))
                    {
                        cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtHist);
                    }

                    if (dtHist.Rows.Count > 0)
                    {
                        rptHistory.DataSource = dtHist;
                        rptHistory.DataBind();
                        pnlHistory.Visible = true;
                    }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load boss fights. Please try again.";
                pnlError.Visible = true;
            }
        }

        private void LoadBattleStart(int roomID)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT bfr.Title, bfr.XPReward, b.BossName, b.MaxHP, b.AttackStrength, b.IconPath
                          FROM BossFightRooms bfr
                          INNER JOIN Bosses b ON b.RoomID = bfr.RoomID
                          WHERE bfr.RoomID = @RID AND bfr.IsPublished = 1", conn))
                    {
                        cmd.Parameters.Add("@RID", SqlDbType.Int).Value = roomID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                litStartBossName.Text = HttpUtility.HtmlEncode(rdr["BossName"].ToString());
                                ViewState["BossMaxHP"] = Convert.ToInt32(rdr["MaxHP"]);
                                ViewState["AttackStr"] = Convert.ToInt32(rdr["AttackStrength"]);
                                ViewState["XPReward"] = Convert.ToInt32(rdr["XPReward"]);
                                ViewState["PlayerMaxHP"] = 100;

                                string iconPath = rdr["IconPath"] != DBNull.Value ? rdr["IconPath"].ToString() : "";
                                ViewState["BossIconPath"] = iconPath;

                                if (!string.IsNullOrEmpty(iconPath))
                                {
                                    imgStartBossIcon.ImageUrl = iconPath;
                                    imgStartBossIcon.Visible = true;

                                    string bgPath = iconPath.Replace("-icon.png", "-bg.png");
                                    pnlBattle.Style["background-image"] =
                                        "linear-gradient(180deg,rgba(11,15,26,0.75) 0%,rgba(26,10,46,0.75) 40%,rgba(11,15,26,0.85) 100%), url('" +
                                        HttpUtility.HtmlAttributeEncode(bgPath) + "')";
                                    pnlBattle.Style["background-size"] = "cover";
                                    pnlBattle.Style["background-position"] = "center";
                                }
                            }
                            else
                            {
                                litError.Text = "Boss fight room not found.";
                                pnlError.Visible = true;
                                return;
                            }
                        }
                    }
                }
                pnlBattle.Visible = true;
            }
            catch (SqlException)
            {
                litError.Text = "Could not load boss fight.";
                pnlError.Visible = true;
            }
        }

        protected void btnStartBattle_Click(object sender, EventArgs e)
        {
            int roomID = (int)ViewState["RoomID"];
            int studentID = Convert.ToInt32(Session["UserID"]);
            int bossMaxHP = (int)ViewState["BossMaxHP"];
            int playerMax = (int)ViewState["PlayerMaxHP"];

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO BattleSessions (RoomID, StudentID, PlayerMaxHP, PlayerCurrentHP, BossMaxHP, BossCurrentHP, Status, XPAwarded, StartedAt)
                          VALUES (@RID, @SID, @PMax, @PMax, @BMax, @BMax, 'InProgress', 0, GETDATE());
                          SELECT SCOPE_IDENTITY();", conn))
                    {
                        cmd.Parameters.Add("@RID", SqlDbType.Int).Value = roomID;
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        cmd.Parameters.Add("@PMax", SqlDbType.Int).Value = playerMax;
                        cmd.Parameters.Add("@BMax", SqlDbType.Int).Value = bossMaxHP;
                        ViewState["SessionID"] = Convert.ToInt32(cmd.ExecuteScalar());
                    }
                }

                ViewState["BossCurrentHP"] = bossMaxHP;
                ViewState["PlayerCurrentHP"] = playerMax;

                litBattleBossName.Text = litStartBossName.Text;
                imgBattleBossIcon.ImageUrl = imgStartBossIcon.ImageUrl;
                imgBattleBossIcon.Visible = imgStartBossIcon.Visible;

                pnlBattleStart.Visible = false;
                pnlBattleActive.Visible = true;
                LoadNextQuestion();
            }
            catch (SqlException)
            {
                litError.Text = "Could not start the battle.";
                pnlError.Visible = true;
            }
        }

        private void LoadNextQuestion()
        {
            int roomID = (int)ViewState["RoomID"];
            int sessionID = (int)ViewState["SessionID"];

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string sql = @"SELECT TOP 1 bfq.BossFightQuestionID, bfq.QuestionText,
                                          bfq.DamageValue, bfq.TimeLimitSeconds
                                   FROM BossFightQuestions bfq
                                   WHERE bfq.RoomID = @RoomID
                                   AND bfq.BossFightQuestionID NOT IN (
                                       SELECT bsa.BossFightQuestionID FROM BattleSessionAnswers bsa
                                       WHERE bsa.SessionID = @SessionID)
                                   ORDER BY NEWID()";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@RoomID", SqlDbType.Int).Value = roomID;
                        cmd.Parameters.Add("@SessionID", SqlDbType.Int).Value = sessionID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                int qID = Convert.ToInt32(rdr["BossFightQuestionID"]);
                                string qText = rdr["QuestionText"].ToString();
                                int damage = Convert.ToInt32(rdr["DamageValue"]);
                                int timeLimit = Convert.ToInt32(rdr["TimeLimitSeconds"]);

                                ViewState["CurrentQID"] = qID;
                                ViewState["CurrentDamage"] = damage;
                                ViewState["CurrentTimeLimit"] = timeLimit;

                                litBattleQText.Text = HttpUtility.HtmlEncode(qText);
                                rdr.Close();

                                // Load options (shuffled)
                                DataTable dtOpts = new DataTable();
                                using (SqlCommand optCmd = new SqlCommand(
                                    @"SELECT OptionID, OptionText FROM BossFightQuestionOptions
                                      WHERE BossFightQuestionID = @QID ORDER BY NEWID()", conn))
                                {
                                    optCmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
                                    using (SqlDataAdapter da = new SqlDataAdapter(optCmd)) da.Fill(dtOpts);
                                }

                                var sb = new System.Text.StringBuilder();
                                foreach (DataRow row in dtOpts.Rows)
                                {
                                    string oid = row["OptionID"].ToString();
                                    string otext = HttpUtility.HtmlEncode(row["OptionText"].ToString());
                                    sb.AppendFormat("<div class='drag-opt' data-val='{0}'>{1}</div>", oid, otext);
                                }
                                litDragOptions.Text = sb.ToString();

                                UpdateHPDisplay();

                                pnlBattleActive.Visible = true;
                                pnlTurnResult.Visible = false;

                                ScriptManager.RegisterStartupScript(this, GetType(), "startTimer",
                                    "window.startBattleTimer(" + timeLimit + "); document.querySelectorAll('.drag-opt').forEach(function(o){o.setAttribute('draggable','true');});", true);
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
                litError.Text = "Could not load the next question.";
                pnlError.Visible = true;
            }
        }

        private void UpdateHPDisplay()
        {
            int bossHP = (int)ViewState["BossCurrentHP"];
            int bossMax = (int)ViewState["BossMaxHP"];
            int playerHP = (int)ViewState["PlayerCurrentHP"];
            int playerMax = (int)ViewState["PlayerMaxHP"];

            litBossHP.Text = bossHP.ToString();
            litBossMaxHP.Text = bossMax.ToString();
            litPlayerHP.Text = playerHP.ToString();
            litPlayerMaxHP.Text = playerMax.ToString();
            bossHPBar.Style["width"] = ((bossHP * 100) / Math.Max(1, bossMax)) + "%";
            playerHPBar.Style["width"] = ((playerHP * 100) / Math.Max(1, playerMax)) + "%";
        }

        protected void btnSubmitAnswer_Click(object sender, EventArgs e)
        {
            int selectedOptionID;
            if (!int.TryParse(hdnSelectedOption.Value, out selectedOptionID))
                selectedOptionID = 0; // timeout

            int qID = (int)ViewState["CurrentQID"];
            int damage = (int)ViewState["CurrentDamage"];
            int attackStr = (int)ViewState["AttackStr"];
            int sessionID = (int)ViewState["SessionID"];
            int bossHP = (int)ViewState["BossCurrentHP"];
            int playerHP = (int)ViewState["PlayerCurrentHP"];

            bool isCorrect = false;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    if (selectedOptionID > 0)
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT IsCorrect FROM BossFightQuestionOptions WHERE OptionID=@OID", conn))
                        {
                            cmd.Parameters.Add("@OID", SqlDbType.Int).Value = selectedOptionID;
                            object r = cmd.ExecuteScalar();
                            isCorrect = (r != null && Convert.ToBoolean(r));
                        }
                    }

                    int dmgToBoss = isCorrect ? damage : 0;
                    int dmgToPlayer = isCorrect ? 0 : attackStr;

                    bossHP = Math.Max(0, bossHP - dmgToBoss);
                    playerHP = Math.Max(0, playerHP - dmgToPlayer);

                    ViewState["BossCurrentHP"] = bossHP;
                    ViewState["PlayerCurrentHP"] = playerHP;

                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO BattleSessionAnswers
                          (SessionID, BossFightQuestionID, SelectedOptionID, IsCorrect, DamageDealtToBoss, DamageTakenByPlayer, AnsweredAt)
                          VALUES (@SID, @QID, @OID, @Correct, @DTB, @DTP, GETDATE())", conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = sessionID;
                        cmd.Parameters.Add("@QID", SqlDbType.Int).Value = qID;
                        cmd.Parameters.Add("@OID", SqlDbType.Int).Value = selectedOptionID > 0 ? (object)selectedOptionID : DBNull.Value;
                        cmd.Parameters.Add("@Correct", SqlDbType.Bit).Value = isCorrect;
                        cmd.Parameters.Add("@DTB", SqlDbType.Int).Value = dmgToBoss;
                        cmd.Parameters.Add("@DTP", SqlDbType.Int).Value = dmgToPlayer;
                        cmd.ExecuteNonQuery();
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE BattleSessions SET BossCurrentHP=@BHP, PlayerCurrentHP=@PHP WHERE SessionID=@SID", conn))
                    {
                        cmd.Parameters.Add("@BHP", SqlDbType.Int).Value = bossHP;
                        cmd.Parameters.Add("@PHP", SqlDbType.Int).Value = playerHP;
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = sessionID;
                        cmd.ExecuteNonQuery();
                    }
                }

                UpdateHPDisplay();

                if (bossHP <= 0) { EndBattle(true); return; }
                if (playerHP <= 0) { EndBattle(false); return; }

                pnlBattleActive.Visible = false;
                pnlTurnResult.Visible = true;

                if (isCorrect)
                {
                    litTurnIcon.Text = "";
                    litTurnTitle.Text = "Direct Hit!";
                    litTurnDesc.Text = "You dealt " + damage + " damage to the boss!";
                }
                else
                {
                    litTurnIcon.Text = "";
                    litTurnTitle.Text = "The Boss Attacks!";
                    litTurnDesc.Text = "Wrong drop! The boss dealt " + attackStr + " damage to you!";
                }
            }
            catch (SqlException)
            {
                litError.Text = "An error occurred during combat.";
                pnlError.Visible = true;
            }
        }

        protected void btnNextTurn_Click(object sender, EventArgs e)
        {
            pnlTurnResult.Visible = false;
            hdnSelectedOption.Value = "";
            LoadNextQuestion();
        }

        private void EndBattle(bool won)
        {
            int sessionID = (int)ViewState["SessionID"];
            int studentID = Convert.ToInt32(Session["UserID"]);
            int xpReward = won ? (int)ViewState["XPReward"] : 0;
            string status = won ? "Won" : "Lost";

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    using (SqlTransaction tran = conn.BeginTransaction())
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            "UPDATE BattleSessions SET Status=@Status, XPAwarded=@XP, EndedAt=GETDATE() WHERE SessionID=@SID", conn, tran))
                        {
                            cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 20).Value = status;
                            cmd.Parameters.Add("@XP", SqlDbType.Int).Value = xpReward;
                            cmd.Parameters.Add("@SID", SqlDbType.Int).Value = sessionID;
                            cmd.ExecuteNonQuery();
                        }

                        if (won && xpReward > 0)
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                @"INSERT INTO XPTransactions (StudentID, SourceType, SourceID, XPAmount, CreatedAt)
                                  VALUES (@SID, 'BossFight', @RoomID, @XP, GETDATE())", conn, tran))
                            {
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                                cmd.Parameters.Add("@RoomID", SqlDbType.Int).Value = (int)ViewState["RoomID"];
                                cmd.Parameters.Add("@XP", SqlDbType.Int).Value = xpReward;
                                cmd.ExecuteNonQuery();
                            }

                            using (SqlCommand cmd = new SqlCommand(
                                "UPDATE Students SET TotalXP = TotalXP + @XP WHERE StudentID=@SID", conn, tran))
                            {
                                cmd.Parameters.Add("@XP", SqlDbType.Int).Value = xpReward;
                                cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                                cmd.ExecuteNonQuery();
                            }
                        }

                        tran.Commit();
                    }
                }
            }
            catch (SqlException) { /* non-critical for display */ }

            pnlBattleActive.Visible = false;
            pnlTurnResult.Visible = false;
            pnlBattleResult.Visible = true;

            if (won)
            {
                litResultIcon.Text = "";
                litResultTitle.Text = "Victory!";
                litResultSub.Text = "You defeated the boss! The cloud realm is safer.";
                litResultXP.Text = xpReward.ToString();
                pnlResultXP.Visible = true;
            }
            else
            {
                litResultIcon.Text = "";
                litResultTitle.Text = "Defeated";
                litResultSub.Text = "The boss was too strong this time. Train more and try again!";
            }
        }
    }
}
