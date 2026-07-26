using System;
using System.Data;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Data.SqlClient;

namespace CloudPhoria
{
    public static class Utils
    {
        // Same hash used at registration (to store) and login (to verify),
        // so accounts created through Register.aspx never touch plaintext.
        public static string ComputeSHA256(string plainText)
        {
            using (SHA256 sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(plainText));
                StringBuilder sb = new StringBuilder(64);
                foreach (byte b in bytes)
                {
                    sb.Append(b.ToString("x2"));
                }
                return sb.ToString();
            }
        }

        // Swallows failures - an audit log write shouldn't take down the admin action
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
            catch (SqlException) { /* don't let audit failures break the caller */ }
        }

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

        // Null means no cert image for this pathway (e.g. Cloud Foundations)
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
            catch (SqlException) { /* don't let notification failures break the caller */ }
        }
    }
}
