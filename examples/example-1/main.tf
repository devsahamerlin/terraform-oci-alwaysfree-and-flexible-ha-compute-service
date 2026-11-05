module "oci_ha_stack" {
  # From the Terraform Registry:
  # source  = "devsahamerlin/alwaysfree-and-flexible-ha-compute-service/oci"
  # version = "~> 1.0"
  source = "../../"

  # Resources Type: Always Free Compute Or Paid ?
  free_tier_mode = var.free_tier_mode

  # OCI Authentication is configured in providers.tf
  tenancy_ocid = var.tenancy_ocid
  region       = var.region

  vm_ocpus               = var.vm_ocpus
  vm_memory_gb           = var.vm_memory_gb
  vm_boot_volume_size_gb = var.vm_boot_volume_size_gb
  allowed_ssh_cidrs      = var.allowed_ssh_cidrs

  # Project Settings
  project_name              = var.project_name
  environment               = var.environment
  compartment_enable_delete = var.compartment_enable_delete

  # Network Configuration (security list rules use the module defaults)
  vcn_cidr             = var.vcn_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidr  = var.private_subnet_cidr
  database_subnet_cidr = var.database_subnet_cidr

  # Feature Flags
  enable_database    = var.enable_database
  enable_frontend_lb = var.enable_frontend_lb
  enable_backend_lb  = var.enable_backend_lb
  enable_bastion     = var.enable_bastion
  enable_dns         = var.enable_dns
  enable_storage     = var.enable_storage
  enable_ocir        = var.enable_ocir

  # Compute Settings
  vm_count       = var.vm_count
  vm_shape       = var.vm_shape
  ssh_public_key = file(var.ssh_public_key_path)

  # Database Settings
  atp_db_name        = var.atp_db_name
  atp_admin_password = var.atp_admin_password

  # Domain Settings
  frontend_domain_name = var.frontend_domain_name
  backend_domain_name  = var.backend_domain_name

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
  namespace             = var.namespace
}
