output "zone_id" {
  description = "OCID of the DNS zone"
  value       = oci_dns_zone.dns-zone.id
}

output "zone_name" {
  description = "Name of the DNS zone"
  value       = oci_dns_zone.dns-zone.name
}