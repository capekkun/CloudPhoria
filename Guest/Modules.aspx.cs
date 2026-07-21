using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Guest
{
    public partial class Modules : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int filterPathwayID = 0;
                if (Request.QueryString["pathwayID"] != null)
                    int.TryParse(Request.QueryString["pathwayID"], out filterPathwayID);

                LoadModules(filterPathwayID);
            }
        }

        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

        private void LoadModules(int filterPathwayID)
        {
            DataTable dtPathways = new DataTable();
            DataTable dtModules  = new DataTable();

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    using (var da = new SqlDataAdapter(
                        "SELECT PathwayID, PathwayName, IsFoundation FROM Pathways ORDER BY IsFoundation DESC, PathwayID", conn))
                        da.Fill(dtPathways);

                    string modSql = @"SELECT m.ModuleID, m.PathwayID, m.ModuleName, m.Description,
                                             m.DifficultyLevel, m.XPReward, m.IsFoundationOnly,
                                             m.ExamDurationMinutes, p.PathwayName, p.IsFoundation
                                      FROM   Modules m
                                      INNER  JOIN Pathways p ON p.PathwayID = m.PathwayID
                                      WHERE  m.IsPublished = 1
                                      ORDER  BY p.IsFoundation DESC, m.PathwayID, m.ModuleID";

                    using (var da = new SqlDataAdapter(modSql, conn))
                        da.Fill(dtModules);
                }
            }
            catch (SqlException)
            {
                ShowError("Unable to load modules. Please try again later.");
                return;
            }

            // Build pathway filter buttons
            var fbSb = new StringBuilder();
            foreach (DataRow pw in dtPathways.Rows)
            {
                int    pid  = Convert.ToInt32(pw["PathwayID"]);
                string name = pw["PathwayName"].ToString();
                fbSb.AppendFormat(
                    "<button class='gm-filter-btn{0}' type='button' onclick=\"gmFilter('pw-{1}',this)\">{2}</button>",
                    filterPathwayID == pid ? " active" : "",
                    pid, HttpUtility.HtmlEncode(name));
            }
            pnlPathwayFilter.Controls.Add(new LiteralControl(fbSb.ToString()));

            if (dtModules.Rows.Count == 0)
            {
                pnlModuleList.Controls.Add(new LiteralControl(
                    "<p style='color:rgba(255,255,255,0.35);font-size:14px;'>No published modules yet.</p>"));
                return;
            }

            // Group by pathway
            var sb  = new StringBuilder();
            int lastPathwayID = -1;
            bool sectionOpen  = false;

            foreach (DataRow row in dtModules.Rows)
            {
                int    pid     = Convert.ToInt32(row["PathwayID"]);
                string pname   = row["PathwayName"].ToString();
                string mname   = row["ModuleName"].ToString();
                string desc    = row["Description"] != DBNull.Value ? row["Description"].ToString() : "";
                string diff    = row["DifficultyLevel"].ToString();
                int    xp      = Convert.ToInt32(row["XPReward"]);
                int    dur     = Convert.ToInt32(row["ExamDurationMinutes"]);
                bool   isFree  = Convert.ToBoolean(row["IsFoundationOnly"]);
                bool   pwFree  = Convert.ToBoolean(row["IsFoundation"]);

                if (pid != lastPathwayID)
                {
                    if (sectionOpen)
                        sb.Append("</div></div>"); // close list + section
                    sectionOpen = true;
                    lastPathwayID = pid;

                    sb.AppendFormat(
                        "<div class='gm-group-section' data-pw-section='{0}'>", pid);
                    sb.AppendFormat(
                        "<div class='gm-group-title'>{0}{1}</div>",
                        HttpUtility.HtmlEncode(pname),
                        pwFree ? " <span style='font-size:10px;color:#22C55E;font-weight:700;background:rgba(34,197,94,0.1);border:1px solid rgba(34,197,94,0.2);border-radius:10px;padding:1px 7px;'>FREE</span>" : "");
                    sb.Append("<div class='gm-list'>");
                }

                string diffClass = diff == "Easy" ? "gm-diff-easy" : diff == "Medium" ? "gm-diff-medium" : "gm-diff-hard";
                string accessTag = isFree || pwFree
                    ? "<span class='gm-tag-free'>Free</span>"
                    : "<span class='gm-tag-lock'>&#x1F512;</span>";
                string shortDesc = desc.Length > 100 ? desc.Substring(0, 100) + "…" : desc;

                sb.AppendFormat(
                    "<div class='gm-row' data-diff='{0}' data-free='{1}' data-pathway='{2}'>",
                    HttpUtility.HtmlEncode(diff),
                    isFree || pwFree ? "1" : "0",
                    pid);

                sb.AppendFormat("<span class='gm-ico'>&#x1F4D6;</span>");
                sb.Append("<div style='flex:1;min-width:0;'>");
                sb.AppendFormat("<div class='gm-name'>{0}</div>", HttpUtility.HtmlEncode(mname));
                sb.AppendFormat(
                    "<div class='gm-sub'>{0} &bull; {1} min exam</div>",
                    HttpUtility.HtmlEncode(shortDesc.Length > 0 ? shortDesc : pname), dur);
                sb.Append("</div>");
                sb.AppendFormat("<div class='gm-badges'><span class='gm-diff {0}'>{1}</span>{2}<span class='gm-xp'>+{3} XP</span></div>",
                    diffClass, HttpUtility.HtmlEncode(diff), accessTag, xp);
                sb.Append("</div>");
            }

            if (sectionOpen)
                sb.Append("</div></div>"); // close last list + section

            pnlModuleList.Controls.Add(new LiteralControl(sb.ToString()));
        }

        private void ShowError(string msg)
        {
            litError.Text    = HttpUtility.HtmlEncode(msg);
            pnlError.Visible = true;
        }
    }
}
