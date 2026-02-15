# ==============================================================================
# Network Outputs
# ==============================================================================

output "vcn_id" {
  description = "OCID of the Virtual Cloud Network (VCN)"
  value       = module.oci_ha_stack.vcn_id
}

output "vcn_cidr" {
  description = "CIDR block of the VCN"
  value       = module.oci_ha_stack.vcn_cidr
}

output "public_subnet_id" {
  description = "OCID of the Public Subnet"
  value       = module.oci_ha_stack.public_subnet_id
}

output "private_subnet_id" {
  description = "OCID of the Private (Backend) Subnet"
  value       = module.oci_ha_stack.private_subnet_id
}

output "database_subnet_id" {
  description = "OCID of the Database Subnet"
  value       = module.oci_ha_stack.database_subnet_id
}

output "frontend_load_balancer_public_ip" {
  description = "Public IP of the Frontend Load Balancer"
  value       = module.oci_ha_stack.frontend_load_balancer_public_ip
}

output "backend_load_balancer_public_ip" {
  description = "Public IP of the Backend Load Balancer"
  value       = module.oci_ha_stack.backend_load_balancer_public_ip
}

# ==============================================================================
# Compute Outputs
# ==============================================================================

output "instance_ids" {
  description = "OCIDs of the Compute Instances"
  value       = module.oci_ha_stack.instance_ids
}

output "instance_private_ips" {
  description = "Private IP addresses of the Compute Instances"
  value       = module.oci_ha_stack.instance_private_ips
}

output "instance_names" {
  description = "Display names of the Compute Instances"
  value       = module.oci_ha_stack.instance_names
}

# ==============================================================================
# Database Outputs
# ==============================================================================

output "autonomous_database_id" {
  description = "OCID of the Autonomous Database"
  value       = module.oci_ha_stack.autonomous_database_id
}

output "database_connection_strings" {
  description = "Connection strings for the Autonomous Database"
  value       = module.oci_ha_stack.database_connection_strings
}

output "atp_wallet_content" {
  description = "Base64 encoded content of the ATP wallet (Sensitive)"
  value       = module.oci_ha_stack.atp_wallet_content
  sensitive   = true
}

# ==============================================================================
# Storage Outputs
# ==============================================================================

output "object_storage_bucket_name" {
  description = "Name of the Object Storage Bucket"
  value       = module.oci_ha_stack.object_storage_bucket_name
}

output "object_storage_namespace" {
  description = "Object Storage Namespace"
  value       = module.oci_ha_stack.object_storage_namespace
}

output "block_volume_ids" {
  description = "OCIDs of the Block Volumes"
  value       = module.oci_ha_stack.block_volume_ids
}

output "backup_policy_id" {
  description = "OCID of the assigned backup policy"
  value       = module.oci_ha_stack.backup_policy_id
}
#

# ==============================================================================
# Bastion Outputs
# ==============================================================================

output "bastion_id" {
  description = "OCID of the Bastion Service"
  value       = module.oci_ha_stack.bastion_id
}

output "bastion_connection_metadata" {
  description = "Connection metadata for Bastion sessions (if any)"
  value       = module.oci_ha_stack.bastion_connection_metadata
}



# ==============================================================================
# OCIR (Container Registry) Outputs
# ==============================================================================

output "ocir_repository_url" {
  description = "URL of the OCIR Repository"
  value       = module.oci_ha_stack.ocir_repository_url
}

output "ocir_username" {
  description = "Username for OCIR login (e.g. for GitHub Actions)"
  value       = module.oci_ha_stack.ocir_username
}

output "ocir_auth_token" {
  description = "Auth token for OCIR login (Sensitive)"
  value       = module.oci_ha_stack.ocir_auth_token
  sensitive   = true
}
