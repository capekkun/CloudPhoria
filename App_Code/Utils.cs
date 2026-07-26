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
        /// Sends a notification to a user. Never throws — notification
        /// failures must not break the calling action.
        /// </summary>
        public static void SendNotification(SqlConnection conn, int userID, string message, string notificationType)
        {
            try
            {
                using (SqlCommand cmd = new SqlCommand(
                    @"INSERT INTO Notifications (UserID, Message, NotificationType, IsRead, CreatedAt)
                      VALUES (@UID, @Msg, @Type, 0, GETDATE())", conn))
                {
                    cmd.Parameters.Add("@UID", SqlDbType.Int).Value = userID;
                    cmd.Parameters.Add("@Msg", SqlDbType.NVarChar, 500).Value =
                        string.IsNullOrEmpty(message) ? (object)DBNull.Value : message;
                    cmd.Parameters.Add("@Type", SqlDbType.NVarChar, 50).Value =
                        string.IsNullOrEmpty(notificationType) ? (object)DBNull.Value : notificationType;
                    cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException) { /* notification must not break the main action */ }
        }

        /// <summary>
        /// Returns the background image path for a pathway based on its name.
        /// </summary>
        public static string GetPathwayBgImage(string pathwayName)
        {
            if (string.IsNullOrEmpty(pathwayName)) return "/uploads/modules/cloud-foundations.png";

            string name = pathwayName.ToLowerInvariant();

            if (name.Contains("security"))         return "/uploads/modules/cloud-security.png";
            if (name.Contains("network"))          return "/uploads/modules/cloud-networking.png";
            if (name.Contains("architect"))        return "/uploads/modules/cloud-architecture.png";
            if (name.Contains("devops"))           return "/uploads/modules/devops-engineering.png";
            if (name.Contains("data"))             return "/uploads/modules/data-engineering.png";
            if (name.Contains("serverless") || name.Contains("container"))
                                                   return "/uploads/modules/serverless-containers.png";

            return "/uploads/modules/cloud-foundations.png";
        }

        /// <summary>
        /// Returns the certification image path based on the pathway name.
        /// </summary>
        public static string GetCertificationImage(string pathwayName)
        {
            if (string.IsNullOrEmpty(pathwayName)) return "/uploads/Certification/cloud-architecture-cert.png";

            string name = pathwayName.ToLowerInvariant();

            if (name.Contains("security"))         return "/uploads/Certification/cloud-security-cert.png";
            if (name.Contains("network"))          return "/uploads/Certification/cloud-networking-cert.png";
            if (name.Contains("architect"))        return "/uploads/Certification/cloud-architecture-cert.png";
            if (name.Contains("devops"))           return "/uploads/Certification/devops-engineering-cert.png";
            if (name.Contains("data"))             return "/uploads/Certification/data-engineering-cert.png";
            if (name.Contains("serverless") || name.Contains("container"))
                                                   return "/uploads/Certification/serverless-containers-cert.png";

            return "/uploads/Certification/cloud-architecture-cert.png";
        }
    }
}
