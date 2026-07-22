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
                    cmd.Parameters.Add("@UID",  SqlDbType.Int).Value          = userID;
                    cmd.Parameters.Add("@Msg",  SqlDbType.NVarChar, 500).Value = message;
                    cmd.Parameters.Add("@Type", SqlDbType.NVarChar, 100).Value = notificationType;
                    cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException) { /* notification logging must not break the main action */ }
        }
    }
}
