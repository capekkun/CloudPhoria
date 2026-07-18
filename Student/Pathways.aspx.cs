using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Student
{
    public partial class Pathways : System.Web.UI.Page
    {
        private static readonly string[] Icons = {"&#x2601;","&#x1F527;","&#x1F6E1;","&#x1F4BB;","&#x1F4CA;","&#x1F916;","&#x1F310;"};
        private static readonly string[] Accents = {
            "linear-gradient(90deg,#0EA5E9,#6366F1)","linear-gradient(90deg,#6366F1,#8B5CF6)",
            "linear-gradient(90deg,#0EA5E9,#06B6D4)","linear-gradient(90deg,#F59E0B,#F97316)",
            "linear-gradient(90deg,#22C55E,#16A34A)","linear-gradient(90deg,#EF4444,#DC2626)",
            "linear-gradient(90deg,#A855F7,#7C3AED)"};
        private static readonly string[] IconBgs = {
            "rgba(14,165,233,0.1)","rgba(99,102,241,0.1)","rgba(245,158,11,0.1)",
            "rgba(34,197,94,0.1)","rgba(239,68,68,0.1)","rgba(168,85,247,0.1)","rgba(6,182,212,0.1)"};

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Student")
            { Response.Redirect("~/LogIn.aspx", true); return; }

            if (!IsPostBack) { LoadAll(); }
        }

        private void LoadAll()
        {
            int studentID = Convert.ToInt32(Session["UserID"]);
            string cs = ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString;
            bool isFoundationOnly = false;

            try
            {
                using (SqlConnection conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Subscription check
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT TOP 1 sp.CanAccessFoundationOnly FROM UserSubscriptions us
                          INNER JOIN SubscriptionPlans sp ON sp.PlanID=us.PlanID
                          WHERE us.StudentID=@SID AND us.IsActive=1 ORDER BY us.StartDate DESC", conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        object r = cmd.ExecuteScalar();
                        isFoundationOnly = (r == null || r == DBNull.Value) ? true : Convert.ToBoolean(r);
                    }
                    if (isFoundationOnly) pnlFreeNotice.Visible = true;

                    // Counts
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Pathways", conn))
                        litPathwayCount.Text = cmd.ExecuteScalar().ToString();
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Modules WHERE IsPublished=1", conn))
                        litModuleCount.Text = cmd.ExecuteScalar().ToString();

                    // Pathways
                    DataTable dtP = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT p.PathwayID, p.PathwayName, p.Description, p.IsFoundation,
                          (SELECT COUNT(*) FROM Modules m WHERE m.PathwayID=p.PathwayID AND m.IsPublished=1) AS ModuleCount,
                          (SELECT COUNT(*) FROM Certifications c WHERE c.PathwayID=p.PathwayID) AS CertCount
                          FROM Pathways p ORDER BY p.IsFoundation DESC, p.PathwayID", conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtP);

                    dtP.Columns.Add("IsLocked", typeof(bool));
                    dtP.Columns.Add("AccentColour", typeof(string));
                    dtP.Columns.Add("Icon", typeof(string));
                    dtP.Columns.Add("ShortDesc", typeof(string));

                    int idx = 0;
                    foreach (DataRow row in dtP.Rows)
                    {
                        bool isF = Convert.ToBoolean(row["IsFoundation"]);
                        row["IsLocked"] = isFoundationOnly && !isF;
                        row["AccentColour"] = Accents[idx % Accents.Length];
                        row["Icon"] = Icons[idx % Icons.Length];
                        string desc = row["Description"] != DBNull.Value ? row["Description"].ToString() : "";
                        row["ShortDesc"] = desc.Length > 100 ? desc.Substring(0,100) + "..." : desc;
                        idx++;
                    }

                    if (dtP.Rows.Count > 0)
                    { rptPathways.DataSource = dtP; rptPathways.DataBind(); pnlPathways.Visible = true; }
                    else { pnlEmpty.Visible = true; }

                    // Modules (all published)
                    DataTable dtM = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT m.ModuleID, m.ModuleName, m.DifficultyLevel, m.XPReward,
                          p.PathwayName, p.PathwayID,
                          (SELECT COUNT(*) FROM SubTopics st WHERE st.ModuleID=m.ModuleID AND st.IsPublished=1) AS SubTopicCount
                          FROM Modules m INNER JOIN Pathways p ON p.PathwayID=m.PathwayID
                          WHERE m.IsPublished=1 ORDER BY p.IsFoundation DESC, m.PathwayID, m.ModuleID", conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtM);

                    dtM.Columns.Add("DiffColour", typeof(string));
                    dtM.Columns.Add("IconBg", typeof(string));
                    dtM.Columns.Add("ModIcon", typeof(string));
                    foreach (DataRow row in dtM.Rows)
                    {
                        row["DiffColour"] = DiffCol(row["DifficultyLevel"].ToString());
                        int pid = Convert.ToInt32(row["PathwayID"]);
                        row["IconBg"] = IconBgs[pid % IconBgs.Length];
                        row["ModIcon"] = "&#x1F4D6;";
                    }

                    if (dtM.Rows.Count > 0)
                    { rptModules.DataSource = dtM; rptModules.DataBind(); pnlModules.Visible = true; }

                    // Progress
                    DataTable dtProg = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT m.ModuleName, p.PathwayName, mp.Status,
                          CASE WHEN ISNULL(t.Total,0)=0 THEN 0
                               ELSE CAST(ISNULL(d.Done,0) AS INT)*100/t.Total END AS ProgressPct
                          FROM ModuleProgress mp
                          INNER JOIN Modules m ON m.ModuleID=mp.ModuleID
                          INNER JOIN Pathways p ON p.PathwayID=m.PathwayID
                          CROSS APPLY (SELECT COUNT(*) AS Total FROM SubTopics st WHERE st.ModuleID=m.ModuleID AND st.IsPublished=1) t
                          CROSS APPLY (SELECT COUNT(*) AS Done FROM SubTopicProgress stp
                              INNER JOIN SubTopics st2 ON st2.SubTopicID=stp.SubTopicID
                              WHERE stp.StudentID=@SID AND st2.ModuleID=m.ModuleID AND stp.Status='Completed') d
                          WHERE mp.StudentID=@SID
                          ORDER BY mp.Status, mp.ProgressID DESC", conn))
                    {
                        cmd.Parameters.Add("@SID", SqlDbType.Int).Value = studentID;
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtProg);
                    }

                    if (dtProg.Rows.Count > 0)
                    { rptProgress.DataSource = dtProg; rptProgress.DataBind(); pnlProgress.Visible = true; }
                    else { pnlNoProgress.Visible = true; }
                }
            }
            catch (SqlException)
            {
                litError.Text = "Could not load learning data. Please try again.";
                pnlError.Visible = true;
            }
        }

        private string DiffCol(string d)
        {
            switch(d){ case "Easy":return "#22C55E"; case "Medium":return "#F59E0B"; case "Hard":return "#EF4444"; default:return "#64748B"; }
        }
    }
}
