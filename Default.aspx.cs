using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

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

            if (!IsPostBack)
            {
                LoadGuestPathways();
            }
        }

        private void LoadGuestPathways()
        {
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT p.PathwayID, p.PathwayName, p.Description, p.IsFoundation,
                          (SELECT COUNT(*) FROM Modules m WHERE m.PathwayID=p.PathwayID AND m.IsPublished=1) AS ModuleCount
                          FROM Pathways p ORDER BY p.IsFoundation DESC, p.PathwayID", conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        da.Fill(dt);

                    var sb = new System.Text.StringBuilder();
                    string[] icons = { "&#x2601;", "&#x1F527;", "&#x1F6E1;", "&#x1F4BB;", "&#x1F4CA;", "&#x1F916;", "&#x1F310;" };

                    int idx = 0;
                    foreach (DataRow row in dt.Rows)
                    {
                        string name = HttpUtility.HtmlEncode(row["PathwayName"].ToString());
                        string desc = row["Description"] != DBNull.Value ? row["Description"].ToString() : "";
                        if (desc.Length > 100) desc = desc.Substring(0, 100) + "...";
                        desc = HttpUtility.HtmlEncode(desc);
                        int moduleCount = Convert.ToInt32(row["ModuleCount"]);
                        bool isFree = Convert.ToBoolean(row["IsFoundation"]);
                        int pathwayID = Convert.ToInt32(row["PathwayID"]);
                        string icon = icons[idx % icons.Length];

                        sb.AppendFormat(
                            "<div style='background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.08);" +
                            "border-radius:14px;padding:24px;'>" +
                            "<div style='font-size:32px;margin-bottom:12px;'>{0}</div>" +
                            "<h3 style='font-size:16px;font-weight:700;margin:0 0 6px;color:#fff;'>{1}</h3>" +
                            "<p style='font-size:13px;color:rgba(255,255,255,0.5);margin:0 0 12px;line-height:1.5;'>{2}</p>" +
                            "<div style='font-size:12px;color:rgba(255,255,255,0.35);margin-bottom:12px;'>" +
                            "&#x1F4D6; {3} modules {4}</div>",
                            icon, name, desc, moduleCount,
                            isFree ? "<span style='background:rgba(34,197,94,0.15);color:#22C55E;padding:2px 8px;border-radius:8px;font-size:10px;font-weight:600;margin-left:8px;'>Free</span>"
                                   : "<span style='background:rgba(99,102,241,0.15);color:#A78BFA;padding:2px 8px;border-radius:8px;font-size:10px;font-weight:600;margin-left:8px;'>Pro</span>");

                        // Load modules for this pathway
                        DataTable dtMods = new DataTable();
                        using (SqlCommand modCmd = new SqlCommand(
                            @"SELECT ModuleName, DifficultyLevel, XPReward
                              FROM Modules WHERE PathwayID=@PID AND IsPublished=1 ORDER BY ModuleID", conn))
                        {
                            modCmd.Parameters.Add("@PID", SqlDbType.Int).Value = pathwayID;
                            using (SqlDataAdapter da = new SqlDataAdapter(modCmd)) da.Fill(dtMods);
                        }

                        if (dtMods.Rows.Count > 0)
                        {
                            sb.Append("<div style='border-top:1px solid rgba(255,255,255,0.06);padding-top:10px;margin-top:4px;'>");
                            int mIdx = 1;
                            foreach (DataRow mRow in dtMods.Rows)
                            {
                                string mName = HttpUtility.HtmlEncode(mRow["ModuleName"].ToString());
                                string diff = mRow["DifficultyLevel"].ToString();
                                string diffColor = diff == "Easy" ? "#22C55E" : diff == "Medium" ? "#F59E0B" : "#EF4444";
                                sb.AppendFormat(
                                    "<div style='display:flex;align-items:center;gap:8px;padding:6px 0;font-size:12px;'>" +
                                    "<span style='color:rgba(255,255,255,0.25);width:16px;'>{0}.</span>" +
                                    "<span style='color:rgba(255,255,255,0.7);flex:1;'>{1}</span>" +
                                    "<span style='color:{2};font-size:10px;font-weight:600;'>{3}</span></div>",
                                    mIdx, mName, diffColor, diff);
                                mIdx++;
                                if (mIdx > 5) { sb.Append("<div style='font-size:11px;color:rgba(255,255,255,0.3);padding:4px 0 0 24px;'>+" + (dtMods.Rows.Count - 5) + " more...</div>"); break; }
                            }
                            sb.Append("</div>");
                        }

                        sb.Append("</div>");
                        idx++;
                    }

                    litGuestPathways.Text = sb.ToString();
                }
            }
            catch (SqlException)
            {
                litGuestPathways.Text = "<p style='color:rgba(255,255,255,0.4);text-align:center;'>Could not load pathways.</p>";
            }
        }
    }
}
