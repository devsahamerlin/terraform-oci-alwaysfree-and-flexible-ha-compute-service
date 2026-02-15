module "oci_ha_stack" {
  source = "../../"

  # Resources Type: Always Free Compute Or Paid ?
  free_tier_mode = var.free_tier_mode

  # OCI Authentication (Passed from parent module or environment variables)
  tenancy_ocid = var.tenancy_ocid
  # user_ocid        = var.user_ocid
  # fingerprint      = var.fingerprint
  # private_key_path = var.private_key_path
  region = var.region

  vm_ocpus               = var.vm_ocpus
  vm_memory_gb           = var.vm_memory_gb
  vm_boot_volume_size_gb = var.vm_boot_volume_size_gb
  allowed_ssh_cidrs      = var.allowed_ssh_cidrs


  # Project Settings
  project_name = var.project_name
  environment  = var.environment

  # Network Configuration
  vcn_cidr                                     = var.vcn_cidr
  public_subnet_cidr                           = var.public_subnet_cidr
  private_subnet_cidr                          = var.private_subnet_cidr
  database_subnet_cidr                         = var.database_subnet_cidr
  public_security_list_ingress_security_rules  = var.public_security_list_ingress_security_rules
  private_security_list_ingress_security_rules = var.private_security_list_ingress_security_rules

  # Feature Flags
  enable_database    = var.enable_database
  enable_frontend_lb = var.enable_frontend_lb
  enable_backend_lb  = var.enable_backend_lb
  enable_bastion     = var.enable_bastion
  enable_dns         = var.enable_dns
  enable_storage     = var.enable_storage
  enable_ocir        = var.enable_ocir

  # Compute Settings
  vm_count            = var.vm_count
  vm_shape            = var.vm_shape
  ssh_public_key_path = file("${path.module}/id_rsa.pub")
  instance_image_ocid = var.instance_image_ocid

  # Database Settings
  atp_db_name        = var.atp_db_name
  atp_admin_password = var.atp_admin_password

  # Domain Settings
  frontend_domain_name = var.frontend_domain_name
  backend_domain_name  = var.backend_domain_name
  # common_name          = var.frontend_domain_name # Assuming common_name is needed if defined in root variables

  # Other
  github_actions_email      = var.github_actions_email
  github_actions_public_key = var.github_actions_public_key
  cloud_init_config         = file("${path.module}/cloud-init.yaml")

  # Tags
  tags = var.tags

  # Security
  is_pv_encryption_in_transit_enabled = var.is_pv_encryption_in_transit_enabled
  are_legacy_imds_endpoints_disabled  = var.are_legacy_imds_endpoints_disabled

  # Storage
  enable_backups        = var.enable_backups
  object_events_enabled = var.object_events_enabled

}
