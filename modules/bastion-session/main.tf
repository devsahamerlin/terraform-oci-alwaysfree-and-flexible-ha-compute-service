resource "oci_bastion_session" "managed_ssh" {
  bastion_id = var.bastion_id

  key_details {
    public_key_content = var.ssh_public_key
  }

  target_resource_details {
    session_type                               = "MANAGED_SSH"
    target_resource_id                         = var.target_resource_id
    target_resource_operating_system_user_name = var.target_resource_operating_system_user_name
    target_resource_port                       = 22
    target_resource_private_ip_address         = var.target_resource_private_ip_address
  }

  display_name           = "${var.project_name}-${var.environment}-bastion-session-${var.vm_name}"
  key_type               = "PUB"
  session_ttl_in_seconds = 10800 # 3 hours
}