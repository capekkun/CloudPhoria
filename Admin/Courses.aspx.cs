using System;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Data.SqlClient;

namespace CloudPhoria.Admin
{
    public partial class Courses : System.Web.UI.Page
    {
        private string ConnStr
        {
            get { return ConfigurationManager.ConnectionStrings["CloudPhoria"].ConnectionString; }
        }

        private int AdminID
        {
            get { return Convert.ToInt32(Session["UserID"]); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null ||
                Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/LogIn.aspx", true);
                return;
            }

            ((SiteMaster)Master).PageHeading = "Manage Courses";

            if (!IsPostBack) LoadCourses();
        }

        private void LoadCourses()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    DataTable dtPathways = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT p.PathwayID, p.PathwayName, p.IsFoundation,
                          (SELECT COUNT(*) FROM Modules m WHERE m.PathwayID=p.PathwayID) AS ModuleCount
                          FROM Pathways p ORDER BY p.IsFoundation DESC, p.PathwayName", conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtPathways);
                    rptPathwaysAdmin.DataSource = dtPathways;
                    rptPathwaysAdmin.DataBind();

                    DataTable dtModules = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT m.ModuleID, m.ModuleName, m.IsPublished, m.CreatedByInstructorID,
                                 p.PathwayName
                          FROM Modules m
                          INNER JOIN Pathways p ON p.PathwayID = m.PathwayID
                          ORDER BY p.PathwayName, m.ModuleName", conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtModules);
                    rptModulesAdmin.DataSource = dtModules;
                    rptModulesAdmin.DataBind();
                }
            }
            catch (SqlException)
            {
                ShowError("Could not load courses.");
            }
        }

        protected void rptModulesAdmin_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            DropDownList ddl = (DropDownList)e.Item.FindControl("ddlAssignInstructor");
            DataRowView row = (DataRowView)e.Item.DataItem;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    DataTable dtInst = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT i.InstructorID, u.FullName FROM Instructors i
                          INNER JOIN Users u ON u.UserID = i.InstructorID
                          WHERE i.LicenseStatus='Approved' ORDER BY u.FullName", conn))
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dtInst);

                    ddl.DataSource = dtInst;
                    ddl.DataTextField = "FullName";
                    ddl.DataValueField = "InstructorID";
                    ddl.DataBind();
                    ddl.Items.Insert(0, new ListItem("-- Unassigned --", "0"));

                    object currentInstructor = row["CreatedByInstructorID"];
                    if (currentInstructor != DBNull.Value)
                    {
                        ListItem item = ddl.Items.FindByValue(currentInstructor.ToString());
                        if (item != null) ddl.SelectedValue = currentInstructor.ToString();
                    }
                }
            }
            catch (SqlException) { }
        }

        protected void rptModulesAdmin_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int moduleID = Convert.ToInt32(e.CommandArgument);

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    if (e.CommandName == "Assign")
                    {
                        DropDownList ddl = (DropDownList)e.Item.FindControl("ddlAssignInstructor");
                        int instructorID = Convert.ToInt32(ddl.SelectedValue);

                        if (instructorID > 0)
                        {
                            // Full ownership transfer: reassigning a module hands over
                            // management of everything inside it (subtopics, questions,
                            // materials, practice/exam questions) to the new instructor.
                            // Wrapped in one transaction since this touches several tables.
                            using (SqlTransaction tx = conn.BeginTransaction())
                            {
                                using (SqlCommand cmd = new SqlCommand(
                                    "UPDATE Modules SET CreatedByInstructorID=@IID WHERE ModuleID=@MID", conn, tx))
                                {
                                    cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                                    cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                                    cmd.ExecuteNonQuery();
                                }

                                using (SqlCommand cmd = new SqlCommand(
                                    "UPDATE SubTopics SET CreatedByInstructorID=@IID WHERE ModuleID=@MID", conn, tx))
                                {
                                    cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                                    cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                                    cmd.ExecuteNonQuery();
                                }

                                using (SqlCommand cmd = new SqlCommand(
                                    @"UPDATE q SET q.CreatedByInstructorID=@IID
                                      FROM Questions q
                                      INNER JOIN SubTopics st ON st.SubTopicID = q.SubTopicID
                                      WHERE st.ModuleID=@MID", conn, tx))
                                {
                                    cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                                    cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                                    cmd.ExecuteNonQuery();
                                }

                                using (SqlCommand cmd = new SqlCommand(
                                    @"UPDATE lm SET lm.InstructorID=@IID
                                      FROM LearningMaterials lm
                                      INNER JOIN SubTopics st ON st.SubTopicID = lm.SubTopicID
                                      WHERE st.ModuleID=@MID", conn, tx))
                                {
                                    cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                                    cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                                    cmd.ExecuteNonQuery();
                                }

                                using (SqlCommand cmd = new SqlCommand(
                                    "UPDATE PracticeQuestions SET CreatedByInstructorID=@IID WHERE ModuleID=@MID", conn, tx))
                                {
                                    cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                                    cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                                    cmd.ExecuteNonQuery();
                                }

                                using (SqlCommand cmd = new SqlCommand(
                                    "UPDATE ExamQuestions SET CreatedByInstructorID=@IID WHERE ModuleID=@MID", conn, tx))
                                {
                                    cmd.Parameters.Add("@IID", SqlDbType.Int).Value = instructorID;
                                    cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                                    cmd.ExecuteNonQuery();
                                }

                                tx.Commit();
                            }

                            LogAction(conn, "ASSIGN_MODULE_INSTRUCTOR", "Modules", moduleID);
                            ShowSuccess("Module and all its content (subtopics, questions, materials, practice/exam questions) reassigned to the selected instructor.");
                        }
                        else
                        {
                            // Unassigning: Modules.CreatedByInstructorID is nullable, but
                            // Questions/LearningMaterials/PracticeQuestions/ExamQuestions
                            // are NOT NULL and require a real owner — so we only clear the
                            // module-level label here. The underlying content keeps its
                            // current instructor rather than being orphaned.
                            using (SqlCommand cmd = new SqlCommand(
                                "UPDATE Modules SET CreatedByInstructorID=NULL WHERE ModuleID=@MID", conn))
                            {
                                cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                                cmd.ExecuteNonQuery();
                            }
                            LogAction(conn, "UNASSIGN_MODULE_INSTRUCTOR", "Modules", moduleID);
                            ShowSuccess("Module unassigned. Existing subtopics/questions/materials keep their current instructor.");
                        }
                    }
                    else if (e.CommandName == "TogglePublish")
                    {
                        bool currentlyPublished;
                        using (SqlCommand cmd = new SqlCommand("SELECT IsPublished FROM Modules WHERE ModuleID=@MID", conn))
                        {
                            cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                            currentlyPublished = Convert.ToBoolean(cmd.ExecuteScalar());
                        }
                        using (SqlCommand cmd = new SqlCommand("UPDATE Modules SET IsPublished=@Val WHERE ModuleID=@MID", conn))
                        {
                            cmd.Parameters.Add("@Val", SqlDbType.Bit).Value = !currentlyPublished;
                            cmd.Parameters.Add("@MID", SqlDbType.Int).Value = moduleID;
                            cmd.ExecuteNonQuery();
                        }
                        LogAction(conn, currentlyPublished ? "UNPUBLISH_MODULE" : "PUBLISH_MODULE", "Modules", moduleID);
                        ShowSuccess(currentlyPublished ? "Module unpublished." : "Module published.");
                    }
                }
                LoadCourses();
            }
            catch (SqlException)
            {
                ShowError("Could not update module.");
            }
        }

        private void LogAction(SqlConnection conn, string actionType, string targetTable, int? targetID)
        {
            try
            {
                using (SqlCommand cmd = new SqlCommand(
                    @"INSERT INTO AuditLogs (PerformedByUserID, ActionType, TargetTable, TargetID, CreatedAt)
                      VALUES (@UID, @Action, @Table, @TargetID, GETDATE())", conn))
                {
                    cmd.Parameters.Add("@UID", SqlDbType.Int).Value = AdminID;
                    cmd.Parameters.Add("@Action", SqlDbType.NVarChar, 100).Value = actionType;
                    cmd.Parameters.Add("@Table", SqlDbType.NVarChar, 100).Value = targetTable;
                    cmd.Parameters.Add("@TargetID", SqlDbType.Int).Value = targetID.HasValue ? (object)targetID.Value : DBNull.Value;
                    cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException) { }
        }

        private void ShowSuccess(string msg)
        {
            litSuccess.Text = HttpUtility.HtmlEncode(msg);
            pnlSuccess.Visible = true;
            pnlError.Visible = false;
        }

        private void ShowError(string msg)
        {
            litError.Text = HttpUtility.HtmlEncode(msg);
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
        }
    }
}
