# ==============================================================================
# Network Outputs
# ==============================================================================

output "vcn_id" {
  description = "OCID of the Virtual Cloud Network (VCN)"
  value       = module.network.vcn_id
}
output "vcn_cidr" {
  description = "CIDR block of the VCN"
  value       = module.network.vcn_cidr
}

output "public_subnet_id" {
  description = "OCID of the Public Subnet"
  value       = module.network.public_subnet_id
}

output "private_subnet_id" {
  description = "OCID of the Private (Backend) Subnet"
  value       = module.network.private_subnet_id
}

output "database_subnet_id" {
  description = "OCID of the Database Subnet"
  value       = module.network.database_subnet_id
}

output "backend_load_balancer_public_ip" {
  description = "Public IP of the Backend Load Balancer"
  value       = var.enable_backend_lb ? module.backend_load_balancer[0].lb_public_ip : null
}

output "frontend_load_balancer_public_ip" {
  description = "Public IP of the Frontent Load Balancer"
  value       = var.enable_backend_lb ? module.frontend_load_balancer[0].lb_public_ip : null
}

# ==============================================================================
# Compute Outputs
# ==============================================================================

output "instance_ids" {
  description = "OCIDs of the Compute Instances"
  value       = module.compute.instance_ids
}

output "instance_private_ips" {
  description = "Private IP addresses of the Compute Instances"
  value       = module.compute.instance_private_ips
}

output "instance_names" {
  description = "Display names of the Compute Instances"
  value       = module.compute.instance_names
}

# ==============================================================================
# Database Outputs
# ==============================================================================

output "autonomous_database_id" {
  description = "OCID of the Autonomous Database"
  value       = var.enable_database ? try(module.database[0].atp_id, null) : null
}

output "database_connection_strings" {
  description = "Connection strings for the Autonomous Database"
  value       = var.enable_database ? try(module.database[0].atp_connection_strings, null) : null
}

output "atp_wallet_content" {
  description = "Base64 encoded content of the ATP wallet (Sensitive)"
  value       = var.enable_database ? try(module.database[0].atp_wallet_content, null) : null
  sensitive   = true
}

# ==============================================================================
# Storage Outputs
# ==============================================================================

output "object_storage_bucket_name" {
  description = "Name of the Object Storage Bucket"
  value       = var.enable_storage ? try(module.storage[0].bucket_name, null) : null
}

output "object_storage_namespace" {
  description = "Object Storage Namespace"
  value       = var.enable_storage ? try(module.storage[0].bucket_namespace, null) : null
}

output "block_volume_ids" {
  description = "OCIDs of the Block Volumes"
  value       = var.enable_storage ? try(module.storage[0].block_volume_ids, null) : null
}

# ==============================================================================
# Bastion Outputs
# ==============================================================================

output "bastion_id" {
  description = "OCID of the Bastion Service"
  value       = var.enable_bastion ? try(module.bastion[0].bastion_id, null) : null
}

output "bastion_ssh_metadata" {
  description = "Metadata for Bastion sessions (if any)"
  value       = var.enable_bastion ? module.bastion_sessions : null
}

# ==============================================================================
# OCIR (Container Registry) Outputs
# ==============================================================================

output "ocir_repository_url" {
  description = "URL of the OCIR Repository"
  value       = var.enable_ocir ? try(module.ocir[0].ocir_repository_url, null) : null
}

output "ocir_username" {
  description = "Username for OCIR login (e.g. for GitHub Actions)"
  value       = var.enable_ocir ? try(module.ocir[0].github_actions_username, null) : null
}

output "ocir_auth_token" {
  description = "Auth token for OCIR login (Sensitive)"
  value       = var.enable_ocir ? try(module.ocir[0].github_actions_auth_token, null) : null
  sensitive   = true
}