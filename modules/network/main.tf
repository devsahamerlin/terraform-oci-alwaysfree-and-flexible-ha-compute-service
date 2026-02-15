# VCN
resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_id
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "${var.project_name}-${var.environment}-vcn"
  dns_label      = substr(replace("${var.project_name}${var.environment}", "-", ""), 0, 15)

  freeform_tags = var.tags
}

# Internet Gateway
resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-${var.environment}-igw"
  enabled        = true

  freeform_tags = var.tags
}

# NAT Gateway
resource "oci_core_nat_gateway" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-${var.environment}-nat"

  freeform_tags = var.tags
}

# Service Gateway
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-${var.environment}-sgw"

  services {
    service_id = data.oci_core_services.all_services.services[0].id
  }

  freeform_tags = var.tags
}

# Public Subnet
resource "oci_core_subnet" "public" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = var.public_subnet_cidr
  display_name               = "${var.project_name}-${var.environment}-public-subnet"
  dns_label                  = "public"
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]

  freeform_tags = var.tags
}

# Private Subnet (Backend)
resource "oci_core_subnet" "backend" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = var.private_subnet_cidr
  display_name               = "${var.project_name}-${var.environment}-backend-subnet"
  dns_label                  = "backend"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.private.id]

  freeform_tags = var.tags
}

# Database Subnet
resource "oci_core_subnet" "database" {
  count                      = var.enable_database ? 1 : 0
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = var.database_subnet_cidr
  display_name               = "${var.project_name}-${var.environment}-database-subnet"
  dns_label                  = "database"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.database[0].id]

  freeform_tags = var.tags
}

# Public Route Table
resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-${var.environment}-public-rt"

  route_rules {
    network_entity_id = oci_core_internet_gateway.main.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  freeform_tags = var.tags
}

# Private Route Table
resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-${var.environment}-private-rt"

  route_rules {
    network_entity_id = oci_core_nat_gateway.main.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  route_rules {
    network_entity_id = oci_core_service_gateway.main.id
    destination       = data.oci_core_services.all_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
  }

  freeform_tags = var.tags
}

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-${var.environment}-public-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = var.enable_egress_security_rules_stateless
  }

  dynamic "ingress_security_rules" {
    for_each = var.public_security_list_ingress_security_rules
    content {
      protocol  = ingress_security_rules.value.protocol
      source    = ingress_security_rules.value.source
      stateless = lookup(ingress_security_rules.value, "stateless", false)

      # Only add tcp_options when protocol is TCP (6)
      dynamic "tcp_options" {
        for_each = ingress_security_rules.value.protocol == "6" ? [1] : []
        content {
          min = lookup(ingress_security_rules.value, "port_min", null)
          max = lookup(ingress_security_rules.value, "port_max", null)
        }
      }

      #Support for UDP rules
      dynamic "udp_options" {
        for_each = ingress_security_rules.value.protocol == "17" ? [1] : []
        content {
          min = lookup(ingress_security_rules.value, "port_min", null)
          max = lookup(ingress_security_rules.value, "port_max", null)
        }
      }

      #Support for ICMP rules
      dynamic "icmp_options" {
        for_each = ingress_security_rules.value.protocol == "1" ? [1] : []
        content {
          type = lookup(ingress_security_rules.value, "icmp_type", null)
          code = lookup(ingress_security_rules.value, "icmp_code", null)
        }
      }
    }
  }

  freeform_tags = var.tags
}

# # Public Security List
# resource "oci_core_security_list" "public" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.main.id
#   display_name   = "${var.project_name}-${var.environment}-public-sl"
#
#   egress_security_rules {
#     destination = "0.0.0.0/0"
#     protocol    = "all"
#   }
#
#   dynamic "ingress_security_rules" {
#     for_each = var.public_security_list_ingress_security_rules
#     content {
#       protocol = ingress_security_rules.value.protocol
#       source   = ingress_security_rules.value.source
#       tcp_options {
#         min = ingress_security_rules.value.port_min
#         max = ingress_security_rules.value.port_max
#       }
#     }
#   }
#
#   freeform_tags = var.tags
# }

# Private Security List (Backend)
resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-${var.environment}-private-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = var.enable_egress_security_rules_stateless
  }

  dynamic "ingress_security_rules" {
    for_each = var.private_security_list_ingress_security_rules
    content {
      protocol  = ingress_security_rules.value.protocol
      source    = var.vcn_cidr
      stateless = lookup(ingress_security_rules.value, "stateless", false)

      # Only add tcp_options when protocol is TCP (6)
      dynamic "tcp_options" {
        for_each = ingress_security_rules.value.protocol == "6" ? [1] : []
        content {
          min = lookup(ingress_security_rules.value, "port_min", null)
          max = lookup(ingress_security_rules.value, "port_max", null)
        }
      }

      # Support for UDP rules
      dynamic "udp_options" {
        for_each = ingress_security_rules.value.protocol == "17" ? [1] : []
        content {
          min = lookup(ingress_security_rules.value, "port_min", null)
          max = lookup(ingress_security_rules.value, "port_max", null)
        }
      }

      # Support for ICMP rules
      dynamic "icmp_options" {
        for_each = ingress_security_rules.value.protocol == "1" ? [1] : []
        content {
          type = lookup(ingress_security_rules.value, "icmp_type", null)
          code = lookup(ingress_security_rules.value, "icmp_code", null)
        }
      }
    }
  }

  freeform_tags = var.tags
}
# resource "oci_core_security_list" "private" {
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.main.id
#   display_name   = "${var.project_name}-${var.environment}-private-sl"
#
#   egress_security_rules {
#     destination = "0.0.0.0/0"
#     protocol    = "all"
#   }
#
#   dynamic "ingress_security_rules" {
#     for_each = var.private_security_list_ingress_security_rules
#     content {
#       protocol = ingress_security_rules.value.protocol
#       source   = var.vcn_cidr
#       tcp_options {
#         min = ingress_security_rules.value.port_min
#         max = ingress_security_rules.value.port_max
#       }
#     }
#   }
#
#   freeform_tags = var.tags
# }

# Database Security List
resource "oci_core_security_list" "database" {
  count          = var.enable_database ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-${var.environment}-database-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = var.enable_egress_security_rules_stateless
  }

  # Allow ingress from Backend Subnet
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = var.private_subnet_cidr
    stateless = var.enable_egress_security_rules_stateless
    tcp_options {
      min = 1521
      max = 1522
    }
  }

  freeform_tags = var.tags
}
# resource "oci_core_security_list" "database" {
#   count          = var.enable_database ? 1 : 0
#   compartment_id = var.compartment_id
#   vcn_id         = oci_core_vcn.main.id
#   display_name   = "${var.project_name}-${var.environment}-database-sl"
#
#   egress_security_rules {
#     destination = "0.0.0.0/0"
#     protocol    = "all"
#   }
#
#   # Allow ingress from Backend Subnet
#   ingress_security_rules {
#     protocol = "6" # TCP
#     source   = var.private_subnet_cidr
#     tcp_options {
#       min = 1521
#       max = 1522
#     }
#   }
#
#   freeform_tags = var.tags
# }