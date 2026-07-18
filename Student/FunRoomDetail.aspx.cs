using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class FunRoomDetail : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            { Response.Redirect("~/LogIn.aspx", true); return; }

            ((SiteMaster)Master).PageHeading = "Fun Room";

            if (!IsPostBack)
            {
                int roomID;
                if (!int.TryParse(Request.QueryString["roomID"], out roomID))
                { Response.Redirect("~/Student/FunRooms.aspx"); return; }
                LoadRoom(roomID);
            }
        }

        private void LoadRoom(int roomID)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT f.RoomTitle, f.ContentBody, u.FullName AS CreatorName
                          FROM FunRooms f
                          INNER JOIN Users u ON u.UserID = f.CreatedByUserID
                          WHERE f.FunRoomID = @RID AND f.Status = 'Approved'", conn))
                    {
                        cmd.Parameters.Add("@RID", SqlDbType.Int).Value = roomID;
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                litRoomTitle.Text = HttpUtility.HtmlEncode(rdr["RoomTitle"].ToString());
                                litCreator.Text   = HttpUtility.HtmlEncode(rdr["CreatorName"].ToString());
                                string body = rdr["ContentBody"] != DBNull.Value ? rdr["ContentBody"].ToString() : "";
                                litContentBody.Text = HttpUtility.HtmlEncode(body).Replace("\n", "<br />");
                                pnlContent.Visible = true;
                            }
                            else
                            { litError.Text = "Room not found or not approved."; pnlError.Visible = true; }
                        }
                    }
                }
            }
            catch (SqlException)
            { litError.Text = "Could not load the room. Please try again."; pnlError.Visible = true; }
        }
    }
}
