using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Guest
{
    public partial class Learn : System.Web.UI.Page
    {
        private static readonly string[] ColAccents = {
            "#6366F1","#0EA5E9","#F59E0B","#22C55E","#EF4444","#A855F7"
        };
        private static readonly string[] IconBg = {
            "#2D2060","#0C3554","#3D2800","#0B3020","#3D0C0C","#2A0D42"
        };

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCounts();
                LoadRoadmap();
                LoadPathwayCards();
                LoadModuleList();
            }
        }

        // ----------------------------------------------------------
        // Hero stat counters
        // ----------------------------------------------------------
        private void LoadCounts()
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM Modules WHERE IsPublished = 1", conn))
                    {
                        object r = cmd.ExecuteScalar();
                        if (r != null && r != DBNull.Value) litModuleCount.Text = r.ToString();
                    }
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM Pathways", conn))
                    {
                        object r = cmd.ExecuteScalar();
                        if (r != null && r != DBNull.Value) litPathwayCount.Text = r.ToString();
                    }
                }
            }
            catch (SqlException) { /* defaults already set in markup */ }
        }

        // ----------------------------------------------------------
        // Roadmap – pathway columns + module cards
        // ----------------------------------------------------------
        private void LoadRoadmap()
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            DataTable dtP = new DataTable();
            DataTable dtM = new DataTable();
            DataTable dtC = new DataTable();

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();
                    using (var da = new SqlDataAdapter(
                        "SELECT PathwayID, PathwayName, Description, IsFoundation " +
                        "FROM Pathways ORDER BY IsFoundation DESC, PathwayID", conn))
                        da.Fill(dtP);

                    using (var da = new SqlDataAdapter(
                        "SELECT ModuleID, PathwayID, ModuleName, DifficultyLevel, " +
                        "XPReward, IsFoundationOnly FROM Modules " +
                        "WHERE IsPublished = 1 ORDER BY PathwayID, ModuleID", conn))
                        da.Fill(dtM);

                    using (var da = new SqlDataAdapter(
                        "SELECT CertificationID, PathwayID, CertificateName " +
                        "FROM Certifications ORDER BY PathwayID", conn))
                        da.Fill(dtC);
                }
            }
            catch (SqlException)
            {
                RenderPlaceholderRoadmap();
                return;
            }

            BuildRoadmapHtml(dtP, dtM, dtC);
        }

        private void BuildRoadmapHtml(DataTable dtP, DataTable dtM, DataTable dtC)
        {
            int specCount = 0;
            foreach (DataRow r in dtP.Rows)
                if (!Convert.ToBoolean(r["IsFoundation"])) specCount++;

            if (specCount == 0)
            {
                pnlRoadmapColumns.Controls.Add(new LiteralControl(
                    "<div style='text-align:center;padding:40px;color:rgba(255,255,255,0.35);'>" +
                    "No pathways published yet.</div>"));
                return;
            }

            var sb = new StringBuilder();
            // Horizontal branch bar
            sb.Append("<div style='position:relative;height:2px;margin-bottom:0;" +
                      "background:rgba(255,255,255,0.09);width:80%;margin-left:auto;" +
                      "margin-right:auto;'></div>");

            // Columns grid
            sb.AppendFormat(
                "<div class='rm-cols' style='grid-template-columns:repeat({0},1fr);'>",
                specCount);

            int ci = 0;
            foreach (DataRow pw in dtP.Rows)
            {
                if (Convert.ToBoolean(pw["IsFoundation"])) continue;

                int    pid    = Convert.ToInt32(pw["PathwayID"]);
                string pname  = pw["PathwayName"].ToString();
                string pdesc  = pw["Description"] != DBNull.Value ? pw["Description"].ToString() : "";
                string accent = ci < ColAccents.Length ? ColAccents[ci] : "#0EA5E9";
                string ibg    = ci < IconBg.Length ? IconBg[ci] : "#1E3A5F";

                sb.Append("<div class='rm-col'>");

                // Column header
                string shortDesc = pdesc.Length > 85 ? pdesc.Substring(0, 85) + "…" : pdesc;
                sb.AppendFormat(
                    "<div class='rm-col-hdr'>" +
                    "<h3>{0}</h3>" +
                    "<p>{1}</p>" +
                    "</div>" +
                    "<div class='rm-col-stem'></div>",
                    HttpUtility.HtmlEncode(pname),
                    HttpUtility.HtmlEncode(shortDesc));

                // Module cards
                DataRow[] mods = dtM.Select("PathwayID = " + pid);
                if (mods.Length == 0)
                {
                    sb.Append("<div class='rm-empty'>Modules coming soon</div>");
                }
                else
                {
                    foreach (DataRow mod in mods)
                    {
                        string mname  = mod["ModuleName"].ToString();
                        string diff   = mod["DifficultyLevel"].ToString();
                        int    xp     = Convert.ToInt32(mod["XPReward"]);
                        bool   isFree = Convert.ToBoolean(mod["IsFoundationOnly"]);
                        string lockClass = isFree ? "" : " locked";
                        string lockTag   = isFree ? ""
                            : "<span class='rm-lock' aria-hidden='true'>&#x1F512;</span>";
                        string dc = DiffColour(diff);

                        sb.AppendFormat(
                            "<div class='rm-card{0}' style='border-top:2.5px solid {1};'>",
                            lockClass, accent);

                        sb.AppendFormat(
                            "<div class='rm-card-icon' style='background:{0};'>&#x1F4D6;</div>",
                            ibg);

                        sb.Append("<div style='flex:1;min-width:0;'>");
                        sb.AppendFormat(
                            "<span class='rm-card-name'>{0}</span>",
                            HttpUtility.HtmlEncode(mname));
                        sb.AppendFormat(
                            "<div class='rm-card-meta'>" +
                            "<span class='rm-card-dot'></span>" +
                            "<span>Module &bull; <span style='color:{0};font-weight:600;'>{1}</span>" +
                            " &bull; +{2} XP</span></div>",
                            dc, HttpUtility.HtmlEncode(diff), xp);
                        sb.Append("</div>");
                        sb.Append(lockTag);
                        sb.Append("</div>");
                    }
                }

                // Certification card
                DataRow[] certs = dtC.Select("PathwayID = " + pid);
                if (certs.Length > 0)
                {
                    sb.AppendFormat(
                        "<div class='rm-cert'>" +
                        "<div class='rm-cert-badge'>&#x1F3C5;</div>" +
                        "<div style='flex:1;min-width:0;'>" +
                        "<span class='rm-cert-name'>{0}</span>" +
                        "<span class='rm-cert-lbl'>Professional Certification</span>" +
                        "</div>" +
                        "<span class='rm-lock' aria-hidden='true'>&#x1F512;</span>" +
                        "</div>",
                        HttpUtility.HtmlEncode(certs[0]["CertificateName"].ToString()));
                }

                sb.Append("</div>"); // end column
                ci++;
            }

            sb.Append("</div>"); // end grid
            pnlRoadmapColumns.Controls.Add(new LiteralControl(sb.ToString()));
        }

        // ----------------------------------------------------------
        // Placeholder roadmap (DB unavailable)
        // ----------------------------------------------------------
        private void RenderPlaceholderRoadmap()
        {
            string[][] pw = {
                new[]{"DevOps Engineering",  "Build and deploy with CI/CD pipelines."},
                new[]{"Cloud Security",      "Protect cloud environments and data."},
                new[]{"Cloud Architecture",  "Design scalable cloud solutions."},
                new[]{"Data Engineering",    "Cloud data pipelines and analytics."},
                new[]{"AI & Machine Learning","Deploy AI on cloud infrastructure."},
                new[]{"Multi-Cloud",         "Operate across AWS, Azure, and GCP."}
            };
            var sb = new StringBuilder();
            sb.Append("<div style='text-align:center;padding:12px;margin-bottom:16px;" +
                      "font-size:12px;color:rgba(255,255,255,0.35);'>" +
                      "Database not connected — showing sample structure</div>");
            sb.AppendFormat(
                "<div style='display:grid;grid-template-columns:repeat({0},1fr);gap:16px;'>",
                pw.Length);

            for (int i = 0; i < pw.Length; i++)
            {
                string accent = i < ColAccents.Length ? ColAccents[i] : "#0EA5E9";
                string ibg    = i < IconBg.Length ? IconBg[i] : "#1E3A5F";
                sb.AppendFormat(
                    "<div style='display:flex;flex-direction:column;gap:10px;'>" +
                    "<div style='text-align:center;padding:20px 10px 14px;'>" +
                    "<div style='font-size:13.5px;font-weight:700;color:#fff;margin-bottom:6px;'>{0}</div>" +
                    "<div style='font-size:11.5px;color:rgba(255,255,255,0.4);line-height:1.55;'>{1}</div>" +
                    "</div>" +
                    "<div style='width:2px;height:24px;background:rgba(255,255,255,0.09);margin:0 auto -4px;'></div>" +
                    "<div style='display:flex;align-items:center;gap:10px;background:#1F2D45;" +
                    "border:1px solid rgba(255,255,255,0.07);border-top:2.5px solid {2};" +
                    "border-radius:9px;padding:11px 12px;'>" +
                    "<div style='width:40px;height:40px;border-radius:8px;background:{3};" +
                    "display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0;'>&#x1F4D6;</div>" +
                    "<div><div style='font-size:12.5px;font-weight:600;color:#fff;'>Sample Module</div>" +
                    "<div style='font-size:11px;color:rgba(255,255,255,0.4);margin-top:4px;'>" +
                    "Module &bull; Easy &bull; +100 XP</div></div></div>" +
                    "<div style='display:flex;align-items:center;gap:10px;" +
                    "background:rgba(99,102,241,0.1);border:1px solid rgba(99,102,241,0.25);" +
                    "border-radius:9px;padding:11px 12px;opacity:0.6;'>" +
                    "<div style='width:40px;height:40px;border-radius:8px;" +
                    "background:linear-gradient(135deg,#4F46E5,#6366F1);" +
                    "display:flex;align-items:center;justify-content:center;font-size:18px;'>&#x1F3C5;</div>" +
                    "<div><div style='font-size:12.5px;font-weight:600;color:#fff;'>{0} Certificate</div>" +
                    "<div style='font-size:11px;color:#A5B4FC;margin-top:3px;font-weight:700;" +
                    "text-transform:uppercase;letter-spacing:0.04em;'>Professional Certification</div>" +
                    "</div></div></div>",
                    HttpUtility.HtmlEncode(pw[i][0]),
                    HttpUtility.HtmlEncode(pw[i][1]),
                    accent, ibg);
            }
            sb.Append("</div>");
            pnlRoadmapColumns.Controls.Add(new LiteralControl(sb.ToString()));
        }

        // ----------------------------------------------------------
        // Pathway cards grid
        // ----------------------------------------------------------
        private void LoadPathwayCards()
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            string sql = @"SELECT p.PathwayID, p.PathwayName, p.Description, p.IsFoundation,
                                  (SELECT COUNT(*) FROM Modules m
                                   WHERE m.PathwayID=p.PathwayID AND m.IsPublished=1) AS ModCount,
                                  (SELECT COUNT(*) FROM Certifications c
                                   WHERE c.PathwayID=p.PathwayID) AS CertCount
                           FROM   Pathways p
                           ORDER  BY p.IsFoundation DESC, p.PathwayID";
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                using (var da = new SqlDataAdapter(sql, conn))
                    da.Fill(dt);
            }
            catch (SqlException) { RenderPlaceholderPathways(); return; }

            if (dt.Rows.Count == 0) { RenderPlaceholderPathways(); return; }

            string[] icons   = {"&#x2601;","&#x1F527;","&#x1F6E1;","&#x1F4BB;","&#x1F4CA;","&#x1F916;","&#x1F310;"};
            string[] accents = {
                "linear-gradient(90deg,#0EA5E9,#6366F1)",
                "linear-gradient(90deg,#6366F1,#8B5CF6)",
                "linear-gradient(90deg,#0EA5E9,#06B6D4)",
                "linear-gradient(90deg,#F59E0B,#F97316)",
                "linear-gradient(90deg,#22C55E,#16A34A)",
                "linear-gradient(90deg,#EF4444,#DC2626)",
                "linear-gradient(90deg,#A855F7,#7C3AED)"
            };
            var sb = new StringBuilder();
            int idx = 0;
            foreach (DataRow row in dt.Rows)
            {
                string name     = row["PathwayName"].ToString();
                string desc     = row["Description"] != DBNull.Value ? row["Description"].ToString() : "";
                bool   isFound  = Convert.ToBoolean(row["IsFoundation"]);
                int    modCount = Convert.ToInt32(row["ModCount"]);
                int    certs    = Convert.ToInt32(row["CertCount"]);
                string icon     = idx < icons.Length ? icons[idx] : "&#x2601;";
                string accent   = idx < accents.Length ? accents[idx] : accents[0];
                string shortDesc = desc.Length > 100 ? desc.Substring(0, 100) + "…" : desc;
                string tag = isFound
                    ? "<span class='gl-pw-free'>&#x2713; Free access</span>"
                    : "<span class='gl-pw-lock'>&#x1F512; Sign in required</span>";
                string certLine = certs > 0
                    ? "<span style='font-size:12px;color:rgba(255,255,255,0.35);'>&#x1F3C5; Certification</span>" : "";

                sb.AppendFormat(
                    "<div class='gl-pw-card'>" +
                    "<div class='gl-pw-accent' style='background:{0};'></div>" +
                    "<span class='gl-pw-icon'>{1}</span>" +
                    "<h3>{2}</h3>" +
                    "<p>{3}</p>" +
                    "<div class='gl-pw-meta'><span>&#x1F4D6; {4} module{5}</span>{6}</div>" +
                    "{7}</div>",
                    accent, icon,
                    HttpUtility.HtmlEncode(name),
                    HttpUtility.HtmlEncode(shortDesc),
                    modCount, modCount == 1 ? "" : "s",
                    certLine, tag);
                idx++;
            }
            pnlPathwayCards.Controls.Add(new LiteralControl(sb.ToString()));
        }

        private void RenderPlaceholderPathways()
        {
            string[][] data = {
                new[]{"Cloud Foundations","&#x2601;","Core cloud concepts for all skill levels.","Free"},
                new[]{"DevOps Engineering","&#x1F527;","CI/CD and infrastructure automation.",""},
                new[]{"Cloud Security","&#x1F6E1;","Protecting cloud environments.",""},
                new[]{"Cloud Architecture","&#x1F4BB;","Designing scalable solutions.",""},
                new[]{"Data Engineering","&#x1F4CA;","Cloud data and analytics platforms.",""},
                new[]{"AI & Machine Learning","&#x1F916;","Deploying AI on cloud.",""},
                new[]{"Multi-Cloud","&#x1F310;","AWS, Azure and GCP skills.",""}
            };
            string[] acc = {
                "linear-gradient(90deg,#0EA5E9,#6366F1)",
                "linear-gradient(90deg,#6366F1,#8B5CF6)",
                "linear-gradient(90deg,#0EA5E9,#06B6D4)",
                "linear-gradient(90deg,#F59E0B,#F97316)",
                "linear-gradient(90deg,#22C55E,#16A34A)",
                "linear-gradient(90deg,#EF4444,#DC2626)",
                "linear-gradient(90deg,#A855F7,#7C3AED)"
            };
            var sb = new StringBuilder();
            for (int i = 0; i < data.Length; i++)
            {
                string tag = data[i][3] == "Free"
                    ? "<span style='background:rgba(34,197,94,0.1);color:#16A34A;border:1px solid rgba(34,197,94,0.2);border-radius:20px;font-size:11px;font-weight:700;padding:2px 10px;'>&#x2713; Free access</span>"
                    : "<span style='background:rgba(100,116,139,0.08);color:#94A3B8;border:1px solid rgba(100,116,139,0.15);border-radius:20px;font-size:11px;padding:2px 10px;'>&#x1F512; Sign in required</span>";
                sb.AppendFormat(
                    "<div style='background:#fff;border:1px solid #E2E8F0;border-radius:12px;" +
                    "padding:22px;display:flex;flex-direction:column;gap:10px;" +
                    "position:relative;overflow:hidden;'>" +
                    "<div style='position:absolute;top:0;left:0;right:0;height:3px;background:{0};'></div>" +
                    "<span style='font-size:28px;margin-top:6px;'>{1}</span>" +
                    "<div style='font-size:15px;font-weight:700;color:#172033;'>{2}</div>" +
                    "<div style='font-size:13px;color:#64748B;line-height:1.6;'>{3}</div>" +
                    "{4}</div>",
                    acc[i], data[i][1],
                    HttpUtility.HtmlEncode(data[i][0]),
                    HttpUtility.HtmlEncode(data[i][2]),
                    tag);
            }
            pnlPathwayCards.Controls.Add(new LiteralControl(sb.ToString()));
        }

        // ----------------------------------------------------------
        // Module list
        // ----------------------------------------------------------
        private void LoadModuleList()
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            string sql = @"SELECT m.ModuleID, m.ModuleName, m.DifficultyLevel, m.XPReward,
                                  m.IsFoundationOnly, p.PathwayName
                           FROM   Modules m
                           INNER  JOIN Pathways p ON p.PathwayID = m.PathwayID
                           WHERE  m.IsPublished = 1
                           ORDER  BY p.IsFoundation DESC, m.PathwayID, m.ModuleID";
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                using (var da = new SqlDataAdapter(sql, conn))
                    da.Fill(dt);
            }
            catch (SqlException)
            {
                pnlModuleList.Controls.Add(new LiteralControl(
                    "<p style='color:#64748B;'>Connect to the database to view modules.</p>"));
                return;
            }

            if (dt.Rows.Count == 0)
            {
                pnlModuleList.Controls.Add(new LiteralControl(
                    "<p style='color:#64748B;'>No modules published yet.</p>"));
                return;
            }

            var sb = new StringBuilder();
            sb.Append("<div style='display:flex;flex-direction:column;gap:10px;'>");
            foreach (DataRow row in dt.Rows)
            {
                string mname  = row["ModuleName"].ToString();
                string diff   = row["DifficultyLevel"].ToString();
                int    xp     = Convert.ToInt32(row["XPReward"]);
                bool   isFree = Convert.ToBoolean(row["IsFoundationOnly"]);
                string pname  = row["PathwayName"].ToString();
                string dc     = DiffColour(diff);
                string lockTag = isFree
                    ? "<span class='gl-mod-free'>Free</span>"
                    : "<span class='gl-mod-lock'>&#x1F512; Sign in</span>";
                sb.AppendFormat(
                    "<div class='gl-mod-row'>" +
                    "<span class='gl-mod-ico'>&#x1F4D6;</span>" +
                    "<div style='flex:1;min-width:0;'>" +
                    "<div class='gl-mod-name'>{0}</div>" +
                    "<div class='gl-mod-sub'>{1} &bull; <span style='color:{2};font-weight:600;'>{3}</span> &bull; +{4} XP</div>" +
                    "</div>{5}</div>",
                    HttpUtility.HtmlEncode(mname),
                    HttpUtility.HtmlEncode(pname),
                    dc, HttpUtility.HtmlEncode(diff), xp, lockTag);
            }
            sb.Append("</div>");
            pnlModuleList.Controls.Add(new LiteralControl(sb.ToString()));
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

        private void ShowError(string msg)
        {
            litError.Text    = HttpUtility.HtmlEncode(msg);
            pnlError.Visible = true;
        }
    }
}
