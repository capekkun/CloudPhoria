using System;
using System.Configuration;
using System.Data;
<<<<<<< HEAD
using System.Web;
=======
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Admin
{
    public partial class AuditLogs : System.Web.UI.Page
    {
<<<<<<< HEAD
=======
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString; }
        }

>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

<<<<<<< HEAD
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
=======
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
>>>>>>> 726bdf5aeacf983cac6697131a8d378b065b2cac
    }
}
