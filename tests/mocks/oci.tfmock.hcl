# Fake OCI values for terraform test: no credentials, no API call.
# Only the attributes the module indexes need a value; Terraform generates the others.

mock_data "oci_identity_availability_domains" {
  defaults = {
    availability_domains = [
      { name = "mock:EU-MARSEILLE-1-AD-1" },
    ]
  }
}

mock_data "oci_core_services" {
  defaults = {
    services = [
      { id = "ocid1.service.oc1.eu-marseille-1.mock", cidr_block = "all-mrs-services-in-oracle-services-network" },
    ]
  }
}

mock_resource "oci_load_balancer_load_balancer" {
  defaults = {
    ip_address_details = [
      { ip_address = "203.0.113.10", is_public = true },
    ]
  }
}
