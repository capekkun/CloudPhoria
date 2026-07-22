using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Admin
{
    public partial class AuditLogs : System.Web.UI.Page
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
                LoadLogs("", "");
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadLogs(txtSearch.Text.Trim(), ddlTable.SelectedValue);
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text         = "";
            ddlTable.SelectedIndex = 0;
            LoadLogs("", "");
        }

        private void LoadLogs(string search, string targetTable)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Cap at 200 rows for performance — most recent first.
                    string sql = @"
                        SELECT TOP 200
                            a.LogID,
                            a.ActionType,
                            a.TargetTable,
                            a.TargetID,
                            a.Details,
                            a.CreatedAt,
                            u.FullName AS PerformedBy
                        FROM AuditLogs a
                        INNER JOIN Users u ON u.UserID = a.PerformedByUserID
                        WHERE (@Search = ''
                               OR a.ActionType LIKE '%' + @Search + '%'
                               OR u.FullName   LIKE '%' + @Search + '%')
                          AND (@Table = '' OR a.TargetTable = @Table)
                        ORDER BY a.CreatedAt DESC";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@Search", SqlDbType.NVarChar, 100).Value = search      ?? "";
                        cmd.Parameters.Add("@Table",  SqlDbType.NVarChar, 100).Value = targetTable ?? "";

                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                            da.Fill(dt);

                        litCount.Text = dt.Rows.Count.ToString();

                        if (dt.Rows.Count > 0)
                        {
                            rptLogs.DataSource = dt;
                            rptLogs.DataBind();
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
                // Show empty state on failure — do not expose SQL errors.
                pnlList.Visible  = false;
                pnlEmpty.Visible = true;
            }
        }
    }
}
