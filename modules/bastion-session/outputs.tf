output "bastion_session_id" {
  description = "Bastion session ID for SSH access"
  value       = oci_bastion_session.managed_ssh.id
}

output "bastion_session_ssh_metadata" {
  description = "Bastion session IDs for SSH access"
  value       = oci_bastion_session.managed_ssh.ssh_metadata
}