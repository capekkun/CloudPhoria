using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Guest
{
    public partial class Pricing : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                LoadPlans();
        }

        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

        private void LoadPlans()
        {
            DataTable dt = new DataTable();
            try
            {
                string sql = @"SELECT PlanID, PlanName, Price, CanAccessFoundationOnly, Description
                               FROM   SubscriptionPlans
                               ORDER  BY Price";

                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (var da = new SqlDataAdapter(sql, conn))
                    da.Fill(dt);
            }
            catch (SqlException)
            {
                ShowError("Unable to load pricing information. Please try again later.");
                RenderFallbackPlans();
                return;
            }

            if (dt.Rows.Count == 0)
            {
                RenderFallbackPlans();
                return;
            }

            BuildPlanCards(dt);
        }

        private void BuildPlanCards(DataTable dt)
        {
            // Icons and accents mapped by price tier
            string[] accentColors = { "#22C55E", "#0EA5E9", "#6366F1" };
            string[] planIcons    = { "&#x2601;", "&#x1F680;", "&#x1F393;" };

            var sb  = new StringBuilder();
            int idx = 0;

            foreach (DataRow row in dt.Rows)
            {
                int    planID   = Convert.ToInt32(row["PlanID"]);
                string planName = row["PlanName"].ToString();
                decimal price   = Convert.ToDecimal(row["Price"]);
                bool   freeOnly = Convert.ToBoolean(row["CanAccessFoundationOnly"]);
                string desc     = row["Description"] != DBNull.Value ? row["Description"].ToString() : "";
                bool   isFree   = price == 0;
                bool   isFeatured = !isFree && idx == 1; // middle card is featured
                string accent   = idx < accentColors.Length ? accentColors[idx] : "#0EA5E9";
                string icon     = idx < planIcons.Length    ? planIcons[idx]    : "&#x2601;";
                string priceStr = isFree ? "Free" : string.Format("{0:0.00}", price);
                string priceSub = isFree ? "forever" : "/month";

                sb.AppendFormat(
                    "<div class='gpi-card{0}' style='border-top:3px solid {1};'>",
                    isFeatured ? " featured" : "", accent);

                if (isFeatured)
                    sb.Append("<div class='gpi-card-badge'>Most Popular</div>");

                // Top
                sb.Append("<div class='gpi-card-top'>");
                sb.AppendFormat("<div class='gpi-plan-name'>{0}</div>", HttpUtility.HtmlEncode(planName));
                if (isFree)
                {
                    sb.Append("<div class='gpi-price'><span style='font-size:36px;'>Free</span></div>");
                }
                else
                {
                    sb.AppendFormat(
                        "<div class='gpi-price'><sup>RM</sup>{0}<sub>{1}</sub></div>",
                        priceStr, priceSub);
                }
                if (!string.IsNullOrWhiteSpace(desc))
                    sb.AppendFormat("<div class='gpi-desc'>{0}</div>", HttpUtility.HtmlEncode(desc));
                sb.Append("</div>");

                sb.Append("<div class='gpi-divider'></div>");

                // Features
                sb.Append("<div class='gpi-features'>");
                if (freeOnly)
                {
                    sb.Append(PlanFeature("&#x2713;", "Cloud Foundation pathway", false));
                    sb.Append(PlanFeature("&#x2713;", "Practice quizzes", false));
                    sb.Append(PlanFeature("&#x2713;", "Guest practice mode", false));
                    sb.Append(PlanFeature("&#x2713;", "Community discussions", false));
                    sb.Append(PlanFeature("&#x2715;", "Specialisation pathways", true));
                    sb.Append(PlanFeature("&#x2715;", "Module exams &amp; certifications", true));
                    sb.Append(PlanFeature("&#x2715;", "Boss Fight rooms", true));
                }
                else
                {
                    sb.Append(PlanFeature("&#x2713;", "All Foundation content", false));
                    sb.Append(PlanFeature("&#x2713;", "All specialisation pathways", false));
                    sb.Append(PlanFeature("&#x2713;", "Module exams &amp; XP rewards", false));
                    sb.Append(PlanFeature("&#x2713;", "Professional certifications", false));
                    sb.Append(PlanFeature("&#x2713;", "Boss Fight &amp; Challenge rooms", false));
                    sb.Append(PlanFeature("&#x2713;", "Instructor consultations", false));
                    sb.Append(PlanFeature("&#x2713;", "Instructor-led classrooms", false));
                }
                sb.Append("</div>");

                // CTA
                sb.Append("<div class='gpi-card-cta'>");
                if (isFree)
                    sb.Append("<a class='gpi-cta-btn outline' href='../LogIn.aspx'>Get Started for Free</a>");
                else if (isFeatured)
                    sb.Append("<a class='gpi-cta-btn primary' href='../LogIn.aspx'>Get Started</a>");
                else
                    sb.Append("<a class='gpi-cta-btn outline' href='../LogIn.aspx'>Sign Up</a>");
                sb.Append("</div>");

                sb.Append("</div>"); // end card
                idx++;
            }

            pnlPlanCards.Controls.Add(new LiteralControl(sb.ToString()));
        }

        private static string PlanFeature(string icon, string text, bool muted)
        {
            return string.Format(
                "<div class='gpi-feat-item{0}'>" +
                "<span class='gpi-feat-icon'>{1}</span><span>{2}</span></div>",
                muted ? " muted" : "", icon, text);
        }

        private void RenderFallbackPlans()
        {
            // Fallback cards matching the seeded subscription plans
            var plans = new[]
            {
                new { Name="Free",    Price="Free",  Featured=false, FoundOnly=true  },
                new { Name="Pro",     Price="RM29.00/month", Featured=true,  FoundOnly=false },
                new { Name="Student", Price="RM15.00/month", Featured=false, FoundOnly=false }
            };
            string[] accents = { "#22C55E","#0EA5E9","#6366F1" };
            var sb = new StringBuilder();
            int i  = 0;
            foreach (var p in plans)
            {
                sb.AppendFormat("<div class='gpi-card{0}' style='border-top:3px solid {1};'>",
                    p.Featured ? " featured" : "", accents[i]);
                if (p.Featured) sb.Append("<div class='gpi-card-badge'>Most Popular</div>");
                sb.AppendFormat("<div class='gpi-card-top'><div class='gpi-plan-name'>{0}</div>" +
                    "<div class='gpi-price'><span style='font-size:30px;'>{1}</span></div></div>" +
                    "<div class='gpi-divider'></div><div class='gpi-features'>",
                    p.Name, p.Price);
                if (p.FoundOnly)
                {
                    sb.Append(PlanFeature("&#x2713;","Cloud Foundation pathway",false));
                    sb.Append(PlanFeature("&#x2713;","Practice quizzes",false));
                    sb.Append(PlanFeature("&#x2715;","Specialisation pathways",true));
                }
                else
                {
                    sb.Append(PlanFeature("&#x2713;","All pathways",false));
                    sb.Append(PlanFeature("&#x2713;","Module exams &amp; XP",false));
                    sb.Append(PlanFeature("&#x2713;","Certifications",false));
                    sb.Append(PlanFeature("&#x2713;","Boss Fight rooms",false));
                }
                sb.Append("</div><div class='gpi-card-cta'>");
                sb.AppendFormat("<a class='gpi-cta-btn {0}' href='../LogIn.aspx'>Get Started</a>",
                    p.Featured ? "primary" : "outline");
                sb.Append("</div></div>");
                i++;
            }
            pnlPlanCards.Controls.Add(new LiteralControl(sb.ToString()));
        }

        private void ShowError(string msg)
        {
            litError.Text    = HttpUtility.HtmlEncode(msg);
            pnlError.Visible = true;
        }
    }
}
