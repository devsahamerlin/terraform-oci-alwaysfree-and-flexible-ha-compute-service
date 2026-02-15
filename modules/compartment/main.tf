resource "oci_identity_compartment" "compartment" {
  compartment_id = var.tenancy_ocid
  description    = var.description
  name           = var.name
  enable_delete  = var.enable_delete
}