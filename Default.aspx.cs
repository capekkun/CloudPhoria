using System;
using System.Web.UI;

namespace CloudPhoria
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // If the user is already logged in, send them to the right dashboard.
            if (Session["UserID"] != null && Session["Role"] != null)
            {
                string role = Session["Role"].ToString();
                if (role == "Student")
                    Response.Redirect("~/Student/Dashboard.aspx");
                else if (role == "Instructor")
                    Response.Redirect("~/Instructor/Dashboard.aspx");
                else if (role == "Admin")
                    Response.Redirect("~/Admin/Dashboard.aspx");
            }
        }
    }
}
