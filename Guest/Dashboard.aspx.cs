using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Guest
{
    public partial class Dashboard : System.Web.UI.Page
    {
        private static readonly string[] PwAccents =
        {
            "linear-gradient(90deg,#0EA5E9,#6366F1)",
            "linear-gradient(90deg,#6366F1,#8B5CF6)",
            "linear-gradient(90deg,#0EA5E9,#06B6D4)",
            "linear-gradient(90deg,#F59E0B,#F97316)",
            "linear-gradient(90deg,#22C55E,#16A34A)",
            "linear-gradient(90deg,#EF4444,#DC2626)",
            "linear-gradient(90deg,#A855F7,#7C3AED)"
        };
        private static readonly string[] PwIcons =
        {
            "&#x2601;","&#x1F527;","&#x1F6E1;","&#x1F4BB;","&#x1F4CA;","&#x1F916;","&#x1F310;"
        };

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadStats();
                LoadPathways();
                LoadFeaturedModules();
            }
        }

        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

        private void LoadStats()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    string sql = @"SELECT
                        (SELECT COUNT(*) FROM Pathways)                         AS PathwayCount,
                        (SELECT COUNT(*) FROM Modules  WHERE IsPublished = 1)   AS ModuleCount,
                        (SELECT COUNT(*) FROM PracticeQuestions
                             INNER JOIN Modules ON Modules.ModuleID = PracticeQuestions.ModuleID
                             WHERE Modules.IsPublished = 1)                     AS PracticeCount";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            litPathwayCount.Text  = dr["PathwayCount"].ToString();
                            litModuleCount.Text   = dr["ModuleCount"].ToString();
                            litPracticeCount.Text = dr["PracticeCount"].ToString();
                        }
                    }
                }
            }
            catch (SqlException) { /* defaults in markup are fine */ }
        }

        private void LoadPathways()
        {
            DataTable dt = new DataTable();
            try
            {
                string sql = @"SELECT p.PathwayID, p.PathwayName, p.Description, p.IsFoundation,
                                      (SELECT COUNT(*) FROM Modules m
                                       WHERE m.PathwayID = p.PathwayID AND m.IsPublished = 1) AS ModCount
                               FROM   Pathways p
                               ORDER  BY p.IsFoundation DESC, p.PathwayID";

                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (var da = new SqlDataAdapter(sql, conn))
                    da.Fill(dt);
            }
            catch (SqlException) { return; }

            var sb = new StringBuilder();
            int idx = 0;
            foreach (DataRow row in dt.Rows)
            {
                string name    = row["PathwayName"].ToString();
                string desc    = row["Description"] != DBNull.Value ? row["Description"].ToString() : "";
                bool   isFree  = Convert.ToBoolean(row["IsFoundation"]);
                int    mods    = Convert.ToInt32(row["ModCount"]);
                string accent  = idx < PwAccents.Length ? PwAccents[idx] : PwAccents[0];
                string icon    = idx < PwIcons.Length   ? PwIcons[idx]   : "&#x2601;";
                string shortD  = desc.Length > 90 ? desc.Substring(0, 90) + "…" : desc;
                string tag     = isFree
                    ? "<span class='gd-tag-free'>&#x2713; Free access</span>"
                    : "<span class='gd-tag-lock'>&#x1F512; Sign in required</span>";

                sb.AppendFormat(
                    "<div class='gd-pw-card'>" +
                    "<div class='gd-pw-accent' style='background:{0};'></div>" +
                    "<div class='gd-pw-icon'>{1}</div>" +
                    "<h3>{2}</h3>" +
                    "<p>{3}</p>" +
                    "<div class='gd-pw-meta'><span>&#x1F4D6; {4} module{5}</span></div>" +
                    "{6}</div>",
                    accent, icon,
                    HttpUtility.HtmlEncode(name),
                    HttpUtility.HtmlEncode(shortD),
                    mods, mods == 1 ? "" : "s", tag);
                idx++;
            }
            pnlPathways.Controls.Add(new LiteralControl(sb.ToString()));
        }

        private void LoadFeaturedModules()
        {
            DataTable dt = new DataTable();
            try
            {
                string sql = @"SELECT TOP 6 m.ModuleID, m.ModuleName, m.DifficultyLevel,
                                      m.XPReward, m.IsFoundationOnly, p.PathwayName
                               FROM   Modules m
                               INNER  JOIN Pathways p ON p.PathwayID = m.PathwayID
                               WHERE  m.IsPublished = 1
                               ORDER  BY p.IsFoundation DESC, m.ModuleID";

                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (var da = new SqlDataAdapter(sql, conn))
                    da.Fill(dt);
            }
            catch (SqlException) { return; }

            var sb = new StringBuilder();
            foreach (DataRow row in dt.Rows)
            {
                string name   = row["ModuleName"].ToString();
                string diff   = row["DifficultyLevel"].ToString();
                int    xp     = Convert.ToInt32(row["XPReward"]);
                bool   isFree = Convert.ToBoolean(row["IsFoundationOnly"]);
                string pname  = row["PathwayName"].ToString();
                string dc     = DiffColour(diff);
                string tag    = isFree
                    ? "<span style='font-size:11px;color:#22C55E;font-weight:700;'>Free</span>"
                    : "<span style='font-size:11px;color:rgba(255,255,255,0.35);'>&#x1F512;</span>";

                sb.AppendFormat(
                    "<div class='gd-mod-row'>" +
                    "<span class='gd-mod-ico'>&#x1F4D6;</span>" +
                    "<div style='flex:1;min-width:0;'>" +
                    "<div class='gd-mod-name'>{0}</div>" +
                    "<div class='gd-mod-sub'>{1} &bull; <span style='color:{2};font-weight:600;'>{3}</span> &bull; +{4} XP</div>" +
                    "</div>{5}</div>",
                    HttpUtility.HtmlEncode(name),
                    HttpUtility.HtmlEncode(pname),
                    dc, HttpUtility.HtmlEncode(diff), xp, tag);
            }

            if (sb.Length == 0)
                sb.Append("<p style='color:rgba(255,255,255,0.35);font-size:13px;'>No published modules yet.</p>");

            pnlFeaturedModules.Controls.Add(new LiteralControl(sb.ToString()));
        }

        private string DiffColour(string d)
        {
            switch (d)
            {
                case "Easy":   return "#22C55E";
                case "Medium": return "#F59E0B";
                case "Hard":   return "#EF4444";
                default:       return "#64748B";
            }
        }
    }
}
