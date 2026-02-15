output "instance_ids" {
  description = "OCIDs of the created instances"
  value       = oci_core_instance.vm[*].id
}

output "instance_names" {
  description = "Display names of the created instances"
  value       = oci_core_instance.vm[*].display_name
}

output "instance_private_ips" {
  description = "Private IP addresses of the created instances"
  value       = oci_core_instance.vm[*].private_ip
}

output "instance_public_ips" {
  description = "Public IP addresses of the created instances (empty as they are private)"
  value       = []
}