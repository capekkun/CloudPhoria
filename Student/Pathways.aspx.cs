using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class Pathways : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Learning Pathways";

            if (!IsPostBack)
            {
                LoadPathways();
            }
        }

        private void LoadPathways()
        {
            int studentID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;

            // Determine whether the student is on a Foundation-only plan.
            bool isFoundationOnly = false;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Check active subscription for CanAccessFoundationOnly.
                    string subSql = @"
                        SELECT TOP 1 sp.CanAccessFoundationOnly
                        FROM UserSubscriptions us
                        INNER JOIN SubscriptionPlans sp ON sp.PlanID = us.PlanID
                        WHERE us.StudentID = @StudentID
                          AND us.IsActive  = 1
                        ORDER BY us.StartDate DESC";

                    using (SqlCommand cmd = new SqlCommand(subSql, conn))
                    {
                        cmd.Parameters.Add("@StudentID", SqlDbType.Int).Value = studentID;
                        object r = cmd.ExecuteScalar();
                        // If no subscription record, default to foundation only (Free behaviour).
                        isFoundationOnly = (r == null || r == DBNull.Value)
                                           ? true
                                           : Convert.ToBoolean(r);
                    }

                    if (isFoundationOnly)
                    {
                        pnlFreeNotice.Visible = true;
                    }

                    // Load all pathways with module count and cert count.
                    string pathwaySql = @"
                        SELECT p.PathwayID, p.PathwayName, p.Description, p.IsFoundation,
                               (SELECT COUNT(*) FROM Modules m
                                WHERE m.PathwayID = p.PathwayID AND m.IsPublished = 1) AS ModuleCount,
                               (SELECT COUNT(*) FROM Certifications c
                                WHERE c.PathwayID = p.PathwayID) AS CertCount
                        FROM Pathways p
                        ORDER BY p.IsFoundation DESC, p.PathwayID ASC";

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(pathwaySql, conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        pnlEmpty.Visible = true;
                        return;
                    }

                    // Add computed columns for display.
                    dt.Columns.Add("IsLocked", typeof(bool));
                    dt.Columns.Add("AccentColour", typeof(string));

                    string[] accents = {
                        "linear-gradient(90deg,#0EA5E9,#6366F1)",
                        "linear-gradient(90deg,#6366F1,#8B5CF6)",
                        "linear-gradient(90deg,#0EA5E9,#06B6D4)",
                        "linear-gradient(90deg,#F59E0B,#F97316)",
                        "linear-gradient(90deg,#22C55E,#16A34A)",
                        "linear-gradient(90deg,#EF4444,#DC2626)",
                        "linear-gradient(90deg,#A855F7,#7C3AED)"
                    };

                    int idx = 0;
                    foreach (DataRow row in dt.Rows)
                    {
                        bool isFoundation = Convert.ToBoolean(row["IsFoundation"]);
                        // Locked if the student has foundation-only plan AND this is not a foundation pathway.
                        row["IsLocked"]     = isFoundationOnly && !isFoundation;
                        row["AccentColour"] = accents[idx % accents.Length];
                        idx++;
                    }

                    rptPathways.DataSource = dt;
                    rptPathways.DataBind();
                    pnlPathways.Visible = true;
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load pathways. Please try again.";
                pnlError.Visible = true;
            }
        }
    }
}
