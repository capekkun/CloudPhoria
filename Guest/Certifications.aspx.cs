using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Guest
{
    public partial class Certifications : System.Web.UI.Page
    {
        private static readonly string[] CertIcons =
        {
            "&#x1F4BB;","&#x1F6E1;","&#x2699;","&#x1F4CA;","&#x1F916;","&#x1F310;"
        };
        private static readonly string[] CertBgColors =
        {
            "#0C3554","#2D2060","#3D2800","#0B3020","#3D0C0C","#2A0D42"
        };
        private static readonly string[] CertAccents =
        {
            "#0EA5E9","#6366F1","#F59E0B","#22C55E","#EF4444","#A855F7"
        };

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                LoadCertifications();
        }

        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

        private void LoadCertifications()
        {
            DataTable dt = new DataTable();
            try
            {
                string sql = @"SELECT c.CertificationID, c.CertificateName, c.PathwayID,
                                      p.PathwayName, p.Description AS PathwayDesc,
                                      (SELECT COUNT(*) FROM Modules m
                                       WHERE m.PathwayID = p.PathwayID AND m.IsPublished = 1) AS ModCount
                               FROM   Certifications c
                               INNER  JOIN Pathways p ON p.PathwayID = c.PathwayID
                               ORDER  BY c.PathwayID";

                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (var da = new SqlDataAdapter(sql, conn))
                    da.Fill(dt);
            }
            catch (SqlException)
            {
                ShowError("Unable to load certifications. Please try again later.");
                return;
            }

            if (dt.Rows.Count == 0)
            {
                pnlCertCards.Controls.Add(new LiteralControl(
                    "<p style='color:rgba(255,255,255,0.35);font-size:14px;'>No certifications listed yet.</p>"));
                return;
            }

            var sb  = new StringBuilder();
            int idx = 0;

            foreach (DataRow row in dt.Rows)
            {
                string certName  = row["CertificateName"].ToString();
                string pwName    = row["PathwayName"].ToString();
                string pwDesc    = row["PathwayDesc"] != DBNull.Value ? row["PathwayDesc"].ToString() : "";
                int    modCount  = Convert.ToInt32(row["ModCount"]);
                int    pathwayID = Convert.ToInt32(row["PathwayID"]);
                string icon      = idx < CertIcons.Length    ? CertIcons[idx]    : "&#x1F4BB;";
                string bg        = idx < CertBgColors.Length ? CertBgColors[idx] : "#0C3554";
                string accent    = idx < CertAccents.Length  ? CertAccents[idx]  : "#0EA5E9";

                string shortDesc = pwDesc.Length > 90 ? pwDesc.Substring(0, 90) + "…" : pwDesc;

                sb.AppendFormat(
                    "<div class='gc-card' style='border-color:rgba({0},0.25);'>",
                    HexToRgb(accent));

                // Badge
                sb.AppendFormat(
                    "<div class='gc-cert-badge' style='background:{0};border:1.5px solid {1};'>{2}</div>",
                    bg, accent, icon);

                sb.AppendFormat("<div class='gc-cert-name'>{0}</div>", HttpUtility.HtmlEncode(certName));
                sb.AppendFormat("<div class='gc-cert-pathway'>&#x25B6; {0}</div>", HttpUtility.HtmlEncode(pwName));

                if (!string.IsNullOrWhiteSpace(shortDesc))
                    sb.AppendFormat("<div style='font-size:12.5px;color:rgba(255,255,255,0.45);line-height:1.55;'>{0}</div>",
                        HttpUtility.HtmlEncode(shortDesc));

                sb.AppendFormat(
                    "<div class='gc-cert-meta'>" +
                    "<span>&#x1F4D6; {0} module{1} required</span></div>",
                    modCount, modCount == 1 ? "" : "s");

                sb.Append("<span class='gc-lock-note'>&#x1F512; Sign in required</span>");

                sb.AppendFormat(
                    "<a class='gc-unlock-btn' href='../LogIn.aspx'>Unlock Pathway &#x2192;</a>");

                sb.Append("</div>");
                idx++;
            }

            pnlCertCards.Controls.Add(new LiteralControl(sb.ToString()));
        }

        /// <summary>Converts a hex colour like #0EA5E9 to "r,g,b" for rgba() usage.</summary>
        private static string HexToRgb(string hex)
        {
            if (string.IsNullOrEmpty(hex) || hex.Length < 7) return "14,165,233";
            try
            {
                int r = Convert.ToInt32(hex.Substring(1, 2), 16);
                int g = Convert.ToInt32(hex.Substring(3, 2), 16);
                int b = Convert.ToInt32(hex.Substring(5, 2), 16);
                return string.Format("{0},{1},{2}", r, g, b);
            }
            catch { return "14,165,233"; }
        }

        private void ShowError(string msg)
        {
            litError.Text    = HttpUtility.HtmlEncode(msg);
            pnlError.Visible = true;
        }
    }
}
