output "bastion_id" {
  description = "OCID of the Bastion service"
  value       = oci_bastion_bastion.main.id
}

output "bastion_public_ip" {
  description = "Public IP/Target VCN ID of the Bastion service"
  value       = oci_bastion_bastion.main.target_vcn_id
}

output "bastion_name" {
  description = "Name of the Bastion service"
  value       = oci_bastion_bastion.main.name
}