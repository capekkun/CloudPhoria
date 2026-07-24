using System;
using System.Data;
using Microsoft.Data.SqlClient;

namespace CloudPhoria
{
    /// <summary>
    /// Shared helper methods used across Admin pages.
    /// Kept in App_Code so it compiles into the site assembly
    /// without needing a project reference change.
    /// </summary>
    public static class Utils
    {
        /// <summary>
        /// Writes a row to AuditLogs. Never throws — audit logging
        /// must not break the calling admin action.
        /// </summary>
        public static void LogAction(SqlConnection conn, int performedByUserID, string actionType,
            string targetTable, int? targetID, string details)
        {
            try
            {
                using (SqlCommand cmd = new SqlCommand(
                    @"INSERT INTO AuditLogs (PerformedByUserID, ActionType, TargetTable, TargetID, Details, CreatedAt)
                      VALUES (@UID, @Action, @Table, @TargetID, @Details, GETDATE())", conn))
                {
                    cmd.Parameters.Add("@UID", SqlDbType.Int).Value = performedByUserID;
                    cmd.Parameters.Add("@Action", SqlDbType.NVarChar, 100).Value = actionType;
                    cmd.Parameters.Add("@Table", SqlDbType.NVarChar, 100).Value =
                        string.IsNullOrEmpty(targetTable) ? (object)DBNull.Value : targetTable;
                    cmd.Parameters.Add("@TargetID", SqlDbType.Int).Value =
                        targetID.HasValue ? (object)targetID.Value : DBNull.Value;
                    cmd.Parameters.Add("@Details", SqlDbType.NVarChar, -1).Value =
                        string.IsNullOrEmpty(details) ? (object)DBNull.Value : details;
                    cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException) { /* audit logging must not break the main action */ }
        }

        /// <summary>
        /// Maps a Pathway name to its uploaded background image in /uploads/modules/.
        /// Falls back to the Cloud Foundations image if the name doesn't match.
        /// </summary>
        public static string GetPathwayBgImage(string pathwayName)
        {
            switch (pathwayName)
            {
                case "Cloud Foundations":       return "/uploads/modules/cloud-foundations.png";
                case "Cloud Architecture":       return "/uploads/modules/cloud-architecture.png";
                case "Cloud Security":           return "/uploads/modules/cloud-security.png";
                case "DevOps Engineering":       return "/uploads/modules/devops-engineering.png";
                case "Data Engineering":         return "/uploads/modules/data-engineering.png";
                case "Cloud Networking":         return "/uploads/modules/cloud-networking.png";
                case "Serverless & Containers":  return "/uploads/modules/serverless-containers.png";
                default:                          return "/uploads/modules/cloud-foundations.png";
            }
        }

        /// <summary>
        /// Maps a Pathway name to its uploaded certification image in /uploads/Certification/.
        /// Returns null if the pathway has no certification image (e.g. Cloud Foundations).
        /// </summary>
        public static string GetCertificationImage(string pathwayName)
        {
            switch (pathwayName)
            {
                case "Cloud Architecture":       return "/uploads/Certification/cloud-architecture-cert.png";
                case "Cloud Security":           return "/uploads/Certification/cloud-security-cert.png";
                case "DevOps Engineering":       return "/uploads/Certification/devops-engineering-cert.png";
                case "Data Engineering":         return "/uploads/Certification/data-engineering-cert.png";
                case "Cloud Networking":         return "/uploads/Certification/cloud-networking-cert.png";
                case "Serverless & Containers":  return "/uploads/Certification/serverless-containers-cert.png";
                default:                          return null;
            }
        }

        /// <summary>
        /// Inserts a notification row for a user. Never throws — notifications
        /// must not break the calling action.
        /// </summary>
        public static void SendNotification(SqlConnection conn, int userID,
            string message, string notificationType = "General")
        {
            try
            {
                using (SqlCommand cmd = new SqlCommand(
                    @"INSERT INTO Notifications (UserID, Message, NotificationType, IsRead, CreatedAt)
                      VALUES (@UID, @Msg, @Type, 0, GETDATE())", conn))
                {
                    cmd.Parameters.Add("@UID",  SqlDbType.Int).Value           = userID;
                    cmd.Parameters.Add("@Msg",  SqlDbType.NVarChar, 500).Value = message;
                    cmd.Parameters.Add("@Type", SqlDbType.NVarChar, 100).Value = notificationType;
                    cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException) { /* notification logging must not break the main action */ }
        }
    }
}
