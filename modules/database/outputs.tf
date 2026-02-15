output "atp_id" {
  description = "OCID of the Autonomous Database"
  value       = oci_database_autonomous_database.atp.id
}

output "atp_connection_urls" {
  description = "Connection URLs for the Autonomous Database"
  value       = oci_database_autonomous_database.atp.connection_urls
}

output "atp_connection_strings" {
  description = "Connection strings for the Autonomous Database"
  value       = oci_database_autonomous_database.atp.connection_strings
}

output "atp_wallet_content" {
  description = "Base64 encoded content of the database wallet"
  value       = oci_database_autonomous_database_wallet.atp_wallet.content
  sensitive   = true
}