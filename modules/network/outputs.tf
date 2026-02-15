output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_vcn.main.id
}

output "public_subnet_id" {
  description = "OCID of the public subnet"
  value       = oci_core_subnet.public.id
}

output "private_subnet_id" {
  description = "OCID of the private (backend) subnet"
  value       = oci_core_subnet.backend.id
}

output "database_subnet_id" {
  description = "OCID of the database subnet"
  value       = var.enable_database ? oci_core_subnet.database[0].id : null
}

output "internet_gateway_id" {
  description = "OCID of the Internet Gateway"
  value       = oci_core_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "OCID of the NAT Gateway"
  value       = oci_core_nat_gateway.main.id
}

output "service_gateway_id" {
  description = "OCID of the Service Gateway"
  value       = oci_core_service_gateway.main.id
}

output "vcn_cidr" {
  description = "CIDR block of the VCN"
  value       = var.vcn_cidr
}