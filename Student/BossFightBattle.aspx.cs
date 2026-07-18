using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class BossFightBattle : System.Web.UI.Page
    {
        private string _difficulty = "Easy";

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

        public string GetDiffClass()
        {
            return _difficulty.ToLower();
        }

        private void LoadBattleInfo(int roomID)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    string sql = @"
                        SELECT bfr.Title, bfr.DifficultyLevel, bfr.XPReward, bfr.PlayerMaxHP,
                               b.BossName, b.MaxHP, b.IconPath
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
                                string bossName  = rdr["BossName"].ToString();
                                _difficulty      = rdr["DifficultyLevel"].ToString();
                                int bossMaxHP    = Convert.ToInt32(rdr["MaxHP"]);
                                int playerMaxHP  = Convert.ToInt32(rdr["PlayerMaxHP"]);
                                int xpReward     = Convert.ToInt32(rdr["XPReward"]);
                                string iconPath  = rdr["IconPath"] != DBNull.Value
                                                   ? rdr["IconPath"].ToString() : "";

                                litBossName.Text    = HttpUtility.HtmlEncode(bossName);
                                litDifficulty.Text  = HttpUtility.HtmlEncode(_difficulty);
                                litBossHP.Text      = bossMaxHP.ToString();
                                litBossMaxHP.Text   = bossMaxHP.ToString();
                                litPlayerHP.Text    = playerMaxHP.ToString();
                                litPlayerMaxHP.Text = playerMaxHP.ToString();
                                litXPReward.Text    = xpReward.ToString();

                                // Use boss icon if available, otherwise skull emoji
                                if (!string.IsNullOrEmpty(iconPath))
                                {
                                    litBossEmoji.Text = "<img src='" +
                                        HttpUtility.HtmlAttributeEncode(ResolveUrl("~" + iconPath)) +
                                        "' style='width:80px;height:80px;border-radius:50%;object-fit:cover;' alt='" +
                                        HttpUtility.HtmlAttributeEncode(bossName) + "' />";
                                }

                                pnlBattle.Visible = true;
                            }
                            else
                            {
                                litError.Text = "Boss fight room not found or not published.";
                                pnlError.Visible = true;
                            }
                        }
                    }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load the boss fight. Please try again.";
                pnlError.Visible = true;
            }
        }

        protected void btnStartBattle_Click(object sender, EventArgs e)
        {
            int roomID;
            if (!int.TryParse(Request.QueryString["roomID"], out roomID))
            {
                Response.Redirect("~/Student/BossFights.aspx");
                return;
            }

            int studentID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Get boss and room info for session creation.
                    int playerMaxHP = 100;
                    int bossMaxHP   = 100;

                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT bfr.PlayerMaxHP, b.MaxHP
                          FROM BossFightRooms bfr
                          INNER JOIN Bosses b ON b.RoomID = bfr.RoomID
                          WHERE bfr.RoomID = @RoomID", conn))
                    {
                        cmd.Parameters.Add("@RoomID", SqlDbType.Int).Value = roomID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                playerMaxHP = Convert.ToInt32(rdr["PlayerMaxHP"]);
                                bossMaxHP   = Convert.ToInt32(rdr["MaxHP"]);
                            }
                        }
                    }

                    // Create a new battle session.
                    int sessionID = 0;
                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO BattleSessions
                          (RoomID, StudentID, PlayerMaxHP, PlayerCurrentHP, BossMaxHP, BossCurrentHP, Status, XPAwarded, StartedAt)
                          VALUES (@RoomID, @StudentID, @PMaxHP, @PMaxHP, @BMaxHP, @BMaxHP, 'InProgress', 0, GETDATE());
                          SELECT SCOPE_IDENTITY();", conn))
                    {
                        cmd.Parameters.Add("@RoomID",    SqlDbType.Int).Value = roomID;
                        cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                        cmd.Parameters.Add("@PMaxHP",    SqlDbType.Int).Value = playerMaxHP;
                        cmd.Parameters.Add("@BMaxHP",    SqlDbType.Int).Value = bossMaxHP;

                        object result = cmd.ExecuteScalar();
                        sessionID = Convert.ToInt32(result);
                    }

                    // Redirect to the active battle with session ID.
                    // For now reload the same page showing battle started.
                    litError.Text = "&#x2694; Battle started! Session #" + sessionID +
                        " — Turn-based combat questions will load here. (Full combat system coming in dedicated task)";
                    pnlError.Visible = true;
                    // Reload the page to show updated state.
                }
            }
            catch (SqlException ex)
            {
                litError.Text = "Could not start the battle. " + HttpUtility.HtmlEncode(ex.Message);
                pnlError.Visible = true;
            }
        }
    }
}
