module "compartment" {
  source        = "./modules/compartment"
  description   = "${var.project_name} IaC team"
  name          = var.project_name
  tenancy_ocid  = var.tenancy_ocid
  enable_delete = false
}

# Network Module
module "network" {
  source = "./modules/network"

  compartment_id                               = module.compartment.compartment_id
  vcn_cidr                                     = var.vcn_cidr
  public_subnet_cidr                           = var.public_subnet_cidr
  private_subnet_cidr                          = var.private_subnet_cidr
  database_subnet_cidr                         = var.database_subnet_cidr
  enable_database                              = var.enable_database
  project_name                                 = var.project_name
  environment                                  = var.environment
  tags                                         = local.common_tags
  public_security_list_ingress_security_rules  = var.public_security_list_ingress_security_rules
  private_security_list_ingress_security_rules = var.private_security_list_ingress_security_rules
  enable_egress_security_rules_stateless       = var.enable_egress_security_rules_stateless
}

# Compute Module
module "compute" {
  source = "./modules/compute-ubuntu"

  compartment_id = module.compartment.compartment_id
  subnet_id      = module.network.private_subnet_id
  //public_subnet_id        = module.network.public_subnet_id
  vm_count                            = var.vm_count
  vm_shape                            = var.vm_shape
  vm_ocpus                            = var.vm_ocpus
  vm_memory_gb                        = var.vm_memory_gb
  vm_boot_volume_size_gb              = var.vm_boot_volume_size_gb
  ssh_public_key                      = var.ssh_public_key_path
  project_name                        = var.project_name
  environment                         = var.environment
  tags                                = local.common_tags
  cloud_init_config                   = var.cloud_init_config
  depends_on                          = [module.network]
  bastion                             = var.enable_bastion ? "ENABLED" : "DISABLED"
  os_manegement_service_agent         = "ENABLED"
  instance_image_ocid                 = var.instance_image_ocid[var.region]
  is_pv_encryption_in_transit_enabled = var.is_pv_encryption_in_transit_enabled
  are_legacy_imds_endpoints_disabled  = var.are_legacy_imds_endpoints_disabled
}

# Load Balancer Module
module "frontend_load_balancer" {
  source         = "./modules/load_balancer"
  count          = var.enable_frontend_lb ? 1 : 0
  depends_on     = [module.compute]
  compartment_id = module.compartment.compartment_id
  subnet_id      = [module.network.public_subnet_id]
  backend_vm_ips = module.compute.instance_private_ips
  project_name   = var.project_name
  environment    = var.environment
  tags           = local.common_tags

  app_backend_set_health_checker_port     = "8080"
  app_backend_set_health_checker_url_path = "/"
  app_backends_port                       = "8080"
  backend_set_backend_max_connections     = "256" # min 256, max 65535
  is_private_lb                           = false
  name                                    = "frontend"
  path_routes_1                           = "/"
  path_routes_2                           = "/health"
}

module "backend_load_balancer" {
  source         = "./modules/load_balancer"
  count          = var.enable_backend_lb ? 1 : 0
  depends_on     = [module.compute]
  compartment_id = module.compartment.compartment_id
  subnet_id      = [module.network.private_subnet_id]
  backend_vm_ips = module.compute.instance_private_ips
  project_name   = var.project_name
  environment    = var.environment
  tags           = local.common_tags

  app_backend_set_health_checker_port     = "8000"
  app_backend_set_health_checker_url_path = "/uptime"
  app_backends_port                       = "8000"
  backend_set_backend_max_connections     = "256" # min 256, max 65535
  is_private_lb                           = true
  name                                    = "backend"
  path_routes_1                           = "/uptime"
  path_routes_2                           = "/"

  is_ssl_enabled          = true
  certificate_name        = "${var.project_name}-backend-cert"
  certificate_private_key = tls_private_key.backend_lb_private_key.private_key_pem
  certificate_public_cert = tls_self_signed_cert.backend_lb_cert.cert_pem
  lb_listener_port        = 443
}

module "frontend_dns_zone" {
  source         = "./modules/dns-zone"
  count          = var.enable_dns ? 1 : 0
  compartment_id = module.compartment.compartment_id
  name           = var.frontend_domain_name
  zone_type      = "PRIMARY"
}

module "frontend_dns_rrset" {
  source          = "./modules/dns-zone-rrset"
  count           = var.enable_dns && var.enable_frontend_lb ? 1 : 0
  domain_name     = var.frontend_domain_name
  public_ip       = module.frontend_load_balancer[0].lb_public_ip
  rtype           = "A"
  ttl             = "3600"
  zone_name_or_id = module.frontend_dns_zone[0].zone_id
}

module "backend_dns_zone" {
  source         = "./modules/dns-zone"
  count          = var.enable_backend_lb && var.enable_dns ? 1 : 0
  compartment_id = module.compartment.compartment_id
  name           = var.backend_domain_name
  zone_type      = "PRIMARY"
}

module "backend_dns_rrset" {
  source          = "./modules/dns-zone-rrset"
  count           = var.enable_backend_lb && var.enable_dns ? 1 : 0
  domain_name     = var.backend_domain_name
  public_ip       = module.backend_load_balancer[0].lb_public_ip
  rtype           = "A"
  ttl             = "3600"
  zone_name_or_id = module.backend_dns_zone[0].zone_id
}

# Database Module
module "database" {
  source = "./modules/database"
  count  = var.enable_database ? 1 : 0

  compartment_id = module.compartment.compartment_id
  subnet_id      = module.network.database_subnet_id
  db_name        = var.atp_db_name
  admin_password = var.atp_admin_password
  project_name   = var.project_name
  environment    = var.environment
  tags           = local.common_tags

  depends_on = [module.network]
}

# Storage Module
module "storage" {
  source = "./modules/storage"
  count  = var.enable_storage ? 1 : 0

  compartment_id        = module.compartment.compartment_id
  project_name          = var.project_name
  environment           = var.environment
  tags                  = local.common_tags
  vm_count              = var.vm_count
  enable_backups        = var.enable_backups
  object_events_enabled = var.object_events_enabled
}

# Bastion Module
module "bastion" {
  source = "./modules/bastion"
  count  = var.enable_bastion ? 1 : 0

  compartment_id    = module.compartment.compartment_id
  subnet_id         = module.network.public_subnet_id
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
  project_name      = var.project_name
  environment       = var.environment
  tags              = local.common_tags

  depends_on = [module.network]
}

# OCIR Module (for Container Registry setup)
module "ocir" {
  source = "./modules/oci-container-registry"
  count  = var.enable_ocir ? 1 : 0

  compartment_id = var.tenancy_ocid
  tenancy_ocid   = var.tenancy_ocid
  project_name   = var.project_name
  environment    = var.environment
  tags           = local.common_tags

  # Optional: Set these if you want GitHub Actions integration
  user_email                = var.github_actions_email
  github_actions_public_key = var.github_actions_public_key

  # Optional: Vault integration
  create_vault_secret = false
  region_key          = var.region
}

resource "time_sleep" "wait_for_instance" {
  count = var.vm_count

  depends_on = [module.compute]

  create_duration = "10m" # Wait for Oracle Cloud Agent to initialize
}

module "bastion_sessions" {
  depends_on                                 = [time_sleep.wait_for_instance]
  source                                     = "./modules/bastion-session"
  count                                      = var.enable_bastion ? var.vm_count : 0
  bastion_id                                 = module.bastion[0].bastion_id
  environment                                = var.environment
  project_name                               = var.project_name
  ssh_public_key                             = var.ssh_public_key_path
  target_resource_id                         = module.compute.instance_ids[count.index]
  target_resource_operating_system_user_name = "opc"
  target_resource_private_ip_address         = module.compute.instance_private_ips[count.index]
  vm_name                                    = "vm${count.index + 1}"
}

resource "time_sleep" "wait_for_instance_configuration" {
  count = var.vm_count

  depends_on = [module.bastion_sessions]

  create_duration = "3m"
}
