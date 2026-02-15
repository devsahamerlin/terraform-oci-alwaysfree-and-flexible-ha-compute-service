resource "oci_dns_zone" "dns-zone" {
  #Required
  compartment_id = var.compartment_id
  name           = var.name
  zone_type      = var.zone_type

}