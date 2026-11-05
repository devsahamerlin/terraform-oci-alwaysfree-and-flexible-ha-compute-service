resource "oci_bastion_bastion" "main" {
  compartment_id               = var.compartment_id
  bastion_type                 = "STANDARD"
  target_subnet_id             = var.subnet_id
  name                         = "${var.project_name}-${var.environment}-bastion"
  client_cidr_block_allow_list = var.allowed_ssh_cidrs
  max_session_ttl_in_seconds   = 10800

  freeform_tags = var.tags
}