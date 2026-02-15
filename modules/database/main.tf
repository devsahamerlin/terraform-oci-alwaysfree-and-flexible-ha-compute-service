resource "oci_database_autonomous_database" "atp" {
  compartment_id          = var.compartment_id
  db_name                 = var.db_name
  display_name            = "${var.project_name}-${var.environment}-atp"
  admin_password          = var.admin_password
  db_version              = "19c"
  db_workload             = "OLTP"
  is_auto_scaling_enabled = false
  is_free_tier            = true
  license_model           = "LICENSE_INCLUDED"

  # Always Free tier specs
  cpu_core_count           = 1
  data_storage_size_in_tbs = 1

  # Network access
  subnet_id = var.subnet_id
  nsg_ids   = []

  freeform_tags = var.tags
}

# Create database wallet
resource "oci_database_autonomous_database_wallet" "atp_wallet" {
  autonomous_database_id = oci_database_autonomous_database.atp.id
  password               = var.admin_password
  base64_encode_content  = true
}