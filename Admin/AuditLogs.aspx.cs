using System;
using System.Configuration;
using System.Data;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Admin
{
    public partial class AuditLogs : System.Web.UI.Page
    {
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Audit Logs";

            if (!IsPostBack) LoadLog();
        }

        private void LoadLog()
        {
            string search = txtSearch.Text.Trim();

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT TOP 200 al.ActionType, al.TargetTable, al.TargetID, al.Details, al.CreatedAt,
                                 u.FullName AS PerformedByName
                          FROM AuditLogs al
                          INNER JOIN Users u ON u.UserID = al.PerformedByUserID
                          WHERE (@Search = '' OR al.ActionType LIKE '%' + @Search + '%')
                          ORDER BY al.CreatedAt DESC", conn))
                    {
                        cmd.Parameters.Add("@Search", SqlDbType.NVarChar, 100).Value = search;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }

                    if (dt.Rows.Count > 0)
                    {
                        rptAuditLog.DataSource = dt;
                        rptAuditLog.DataBind();
                        pnlEmpty.Visible = false;
                    }
                    else
                    {
                        pnlEmpty.Visible = true;
                    }
                }
            }
            catch (SqlException) { pnlEmpty.Visible = true; }
        }

        protected void btnSearch_Click(object sender, EventArgs e) { LoadLog(); }
    }
}
