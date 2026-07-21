using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Guest
{
    public partial class Pathways : System.Web.UI.Page
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
                LoadPathways();
        }

        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

        private void LoadPathways()
        {
            DataTable dt = new DataTable();
            try
            {
                string sql = @"SELECT p.PathwayID, p.PathwayName, p.Description, p.IsFoundation,
                                      (SELECT COUNT(*) FROM Modules m
                                       WHERE m.PathwayID = p.PathwayID AND m.IsPublished = 1)   AS ModCount,
                                      (SELECT COUNT(*) FROM Certifications c
                                       WHERE c.PathwayID = p.PathwayID)                         AS CertCount
                               FROM   Pathways p
                               ORDER  BY p.IsFoundation DESC, p.PathwayID";

                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (var da = new SqlDataAdapter(sql, conn))
                    da.Fill(dt);
            }
            catch (SqlException ex)
            {
                ShowError("Unable to load pathways. Please try again later.");
                return;
            }

            if (dt.Rows.Count == 0)
            {
                pnlPathwayGrid.Controls.Add(new LiteralControl(
                    "<p style='color:rgba(255,255,255,0.35);font-size:14px;'>No pathways are available yet.</p>"));
                return;
            }

            var sb = new StringBuilder();
            int idx = 0;
            foreach (DataRow row in dt.Rows)
            {
                int    pid     = Convert.ToInt32(row["PathwayID"]);
                string name    = row["PathwayName"].ToString();
                string desc    = row["Description"] != DBNull.Value ? row["Description"].ToString() : "";
                bool   isFree  = Convert.ToBoolean(row["IsFoundation"]);
                int    modCount= Convert.ToInt32(row["ModCount"]);
                int    certs   = Convert.ToInt32(row["CertCount"]);
                string accent  = idx < PwAccents.Length ? PwAccents[idx] : PwAccents[0];
                string icon    = idx < PwIcons.Length   ? PwIcons[idx]   : "&#x2601;";

                string tag = isFree
                    ? "<span class='gp-tag-free'>&#x2713; Free access</span>"
                    : "<span class='gp-tag-lock'>&#x1F512; Sign in required</span>";
                string certChip = certs > 0
                    ? "<span class='gp-cert-chip'>&#x1F3C5; Certification available</span>"
                    : "";

                sb.AppendFormat(
                    "<div class='gp-card'>" +
                    "<div class='gp-card-accent' style='background:{0};'></div>" +
                    "<div class='gp-card-body'>" +
                    "<div class='gp-card-icon'>{1}</div>" +
                    "<h3>{2}</h3>" +
                    "<p>{3}</p>" +
                    "<div class='gp-card-meta'>" +
                    "<span>&#x1F4D6; {4} module{5}</span>" +
                    "{6}{7}" +
                    "</div></div>" +
                    "<div class='gp-card-footer'>" +
                    "<a href='Modules.aspx?pathwayID={8}'>Browse Modules &#x2192;</a>" +
                    "</div></div>",
                    accent, icon,
                    HttpUtility.HtmlEncode(name),
                    HttpUtility.HtmlEncode(desc),
                    modCount, modCount == 1 ? "" : "s",
                    tag, certChip,
                    pid);

                idx++;
            }
            pnlPathwayGrid.Controls.Add(new LiteralControl(sb.ToString()));
        }

        private void ShowError(string msg)
        {
            litError.Text    = HttpUtility.HtmlEncode(msg);
            pnlError.Visible = true;
        }
    }
}
