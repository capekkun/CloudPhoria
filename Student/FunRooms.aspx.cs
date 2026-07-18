using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class FunRooms : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Fun Rooms";

            if (!IsPostBack) { LoadRooms(); }
        }

        private void LoadRooms()
        {
            int userID = Convert.ToInt32(Session["UserID"]);
            string cs  = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // My own submissions (any status).
                    string mySql = @"
                        SELECT RoomTitle, Status
                        FROM FunRooms
                        WHERE CreatedByUserID = @UserID
                        ORDER BY CreatedAt DESC";

                    DataTable dtMine = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(mySql, conn))
                    {
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtMine);
                    }

                    if (dtMine.Rows.Count > 0)
                    {
                        rptMyRooms.DataSource = dtMine;
                        rptMyRooms.DataBind();
                        pnlMyRooms.Visible = true;
                    }

                    // All approved rooms from others.
                    string approvedSql = @"
                        SELECT f.FunRoomID, f.RoomTitle, u.FullName AS CreatorName
                        FROM FunRooms f
                        INNER JOIN Users u ON u.UserID = f.CreatedByUserID
                        WHERE f.Status = 'Approved'
                        ORDER BY f.CreatedAt DESC";

                    DataTable dtApproved = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(approvedSql, conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        da.Fill(dtApproved);

                    if (dtApproved.Rows.Count > 0)
                    {
                        rptRooms.DataSource = dtApproved;
                        rptRooms.DataBind();
                        pnlRooms.Visible = true;
                    }
                    else if (dtMine.Rows.Count == 0)
                    {
                        pnlEmpty.Visible = true;
                    }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load fun rooms. Please try again.";
                pnlError.Visible = true;
            }
        }

        // Helper used in ASPX databinding expression.
        protected string GetStatusBadge(string status)
        {
            switch (status)
            {
                case "Approved": return "<span class='cp-badge cp-badge-green'>Approved</span>";
                case "Rejected": return "<span class='cp-badge cp-badge-red'>Rejected</span>";
                default:         return "<span class='cp-badge cp-badge-amber'>Pending Review</span>";
            }
        }
    }
}
