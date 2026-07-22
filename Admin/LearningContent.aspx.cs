using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Admin
{
    public partial class LearningContent : System.Web.UI.Page
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
                LoadPathwayFilter();
                LoadModules(0, "", "");
            }
        }

        private void LoadPathwayFilter()
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT PathwayID, PathwayName FROM Pathways ORDER BY PathwayName", conn))
                    {
                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                            da.Fill(dt);

                        ddlPathway.Items.Clear();
                        ddlPathway.Items.Add(new ListItem("All Pathways", "0"));
                        foreach (DataRow row in dt.Rows)
                            ddlPathway.Items.Add(new ListItem(row["PathwayName"].ToString(),
                                                              row["PathwayID"].ToString()));
                    }
                }
            }
            catch (SqlException) { }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            int.TryParse(ddlPathway.SelectedValue, out int pathwayID);
            LoadModules(pathwayID, ddlPublished.SelectedValue, txtSearch.Text.Trim());
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ddlPathway.SelectedIndex  = 0;
            ddlPublished.SelectedIndex = 0;
            txtSearch.Text            = "";
            LoadModules(0, "", "");
        }

        private void LoadModules(int pathwayID, string published, string search)
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    string sql = @"
                        SELECT
                            m.ModuleID,
                            m.ModuleName,
                            m.DifficultyLevel,
                            m.XPReward,
                            m.IsPublished,
                            m.CreatedAt,
                            p.PathwayName,
                            (SELECT COUNT(*) FROM SubTopics st
                             WHERE st.ModuleID = m.ModuleID) AS SubTopicCount
                        FROM Modules m
                        INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
                        WHERE (@PathwayID = 0 OR m.PathwayID = @PathwayID)
                          AND (@Published = '' OR m.IsPublished = @PublishedBit)
                          AND (@Search = '' OR m.ModuleName LIKE '%' + @Search + '%')
                        ORDER BY p.PathwayName, m.ModuleName";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@PathwayID",   SqlDbType.Int).Value           = pathwayID;
                        cmd.Parameters.Add("@Published",   SqlDbType.NVarChar, 2).Value   = published ?? "";
                        cmd.Parameters.Add("@PublishedBit",SqlDbType.Bit).Value           =
                            published == "1" ? 1 : (published == "0" ? 0 : (object)DBNull.Value);
                        cmd.Parameters.Add("@Search",      SqlDbType.NVarChar, 100).Value = search ?? "";

                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                            da.Fill(dt);

                        litCount.Text = dt.Rows.Count.ToString();

                        if (dt.Rows.Count > 0)
                        {
                            rptModules.DataSource = dt;
                            rptModules.DataBind();
                            pnlModules.Visible = true;
                            pnlEmpty.Visible   = false;
                        }
                        else
                        {
                            pnlModules.Visible = false;
                            pnlEmpty.Visible   = true;
                        }
                    }
                }
            }
            catch (SqlException)
            {
                ShowMessage("Could not load modules. Please try again.", false);
            }
        }

        protected void rptModules_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument.ToString(), out int moduleID) || moduleID <= 0)
            {
                ShowMessage("Invalid module ID.", false);
                return;
            }

            bool publish = e.CommandName == "Publish";
            if (e.CommandName != "Publish" && e.CommandName != "Unpublish")
            {
                ShowMessage("Unknown action.", false);
                return;
            }

            int    adminID    = Convert.ToInt32(Session["UserID"]);
            string actionType = publish ? "PUBLISH_MODULE" : "UNPUBLISH_MODULE";
            string cs         = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Verify module exists.
                    string verifySQL = "SELECT ModuleName FROM Modules WHERE ModuleID = @MID";
                    string moduleName = "";
                    using (SqlCommand verifyCmd = new SqlCommand(verifySQL, conn))
                    {
                        verifyCmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                        object r = verifyCmd.ExecuteScalar();
                        if (r == null || r == DBNull.Value)
                        {
                            ShowMessage("Module not found.", false);
                            return;
                        }
                        moduleName = r.ToString();
                    }

                    using (SqlTransaction tx = conn.BeginTransaction())
                    {
                        try
                        {
                            string updateSQL = "UPDATE Modules SET IsPublished = @Published WHERE ModuleID = @MID";
                            using (SqlCommand updateCmd = new SqlCommand(updateSQL, conn, tx))
                            {
                                updateCmd.Parameters.Add("@Published", SqlDbType.Bit).Value = publish ? 1 : 0;
                                updateCmd.Parameters.Add("@MID",       SqlDbType.Int).Value = moduleID;
                                updateCmd.ExecuteNonQuery();
                            }

                            string auditSQL = @"
                                INSERT INTO AuditLogs
                                    (PerformedByUserID, ActionType, TargetTable, TargetID, Details, CreatedAt)
                                VALUES
                                    (@AdminID, @ActionType, 'Modules', @TargetID, @Details, GETDATE())";
                            using (SqlCommand auditCmd = new SqlCommand(auditSQL, conn, tx))
                            {
                                auditCmd.Parameters.Add("@AdminID",    SqlDbType.Int).Value           = adminID;
                                auditCmd.Parameters.Add("@ActionType", SqlDbType.NVarChar, 100).Value = actionType;
                                auditCmd.Parameters.Add("@TargetID",   SqlDbType.Int).Value           = moduleID;
                                auditCmd.Parameters.Add("@Details",    SqlDbType.NVarChar, -1).Value  =
                                    $"Admin UserID {adminID} {(publish ? "published" : "unpublished")} Module '{moduleName}' (ID: {moduleID}).";
                                auditCmd.ExecuteNonQuery();
                            }

                            tx.Commit();
                            ShowMessage($"Module '{HttpUtility.HtmlEncode(moduleName)}' {(publish ? "published" : "unpublished")} successfully.", true);
                        }
                        catch
                        {
                            tx.Rollback();
                            throw;
                        }
                    }
                }
            }
            catch (SqlException)
            {
                ShowMessage("Could not update module. Please try again.", false);
            }

            int.TryParse(ddlPathway.SelectedValue, out int pathwayID);
            LoadModules(pathwayID, ddlPublished.SelectedValue, txtSearch.Text.Trim());
        }

        protected string GetDifficultyBadge(string level)
        {
            switch (level)
            {
                case "Easy":   return "<span class='cp-badge cp-badge-green'>Easy</span>";
                case "Hard":   return "<span class='cp-badge cp-badge-red'>Hard</span>";
                default:       return "<span class='cp-badge cp-badge-amber'>Medium</span>";
            }
        }

        private void ShowMessage(string message, bool success)
        {
            string cssClass    = success ? "cp-alert cp-alert-success" : "cp-alert cp-alert-danger";
            litMessage.Text    = $"<div class='{cssClass}'>{HttpUtility.HtmlEncode(message)}</div>";
            pnlMessage.Visible = true;
        }
    }
}
