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
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Boss Fights";

            if (!IsPostBack) { LoadBossFights(); }
        }

        private void LoadBossFights()
        {
            int studentID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Published rooms with boss info.
                    string roomsSql = @"
                        SELECT bfr.RoomID, bfr.Title, bfr.DifficultyLevel, bfr.XPReward,
                               b.BossName, b.MaxHP,
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

                    // Battle history.
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
    }
}
