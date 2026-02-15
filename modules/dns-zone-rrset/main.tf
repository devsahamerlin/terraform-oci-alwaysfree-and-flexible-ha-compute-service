resource "oci_dns_rrset" "rrset" {

  domain          = var.domain_name
  rtype           = var.rtype
  zone_name_or_id = var.zone_name_or_id

  items {
    #Required
    domain = var.domain_name
    rdata  = var.public_ip
    rtype  = var.rtype
    ttl    = var.ttl
  }
}