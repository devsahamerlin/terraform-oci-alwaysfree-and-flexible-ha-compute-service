# Network Module

Sets up the Virtual Cloud Network (VCN) with public, private (backend), and database subnets, along with necessary gateways and security lists.

## Resources
- `oci_core_vcn`: The Virtual Cloud Network.
- `oci_core_subnet`: Public, Private, and Database subnets.
- `oci_core_internet_gateway`: For public access.
- `oci_core_nat_gateway`: For private outbound access.
- `oci_core_service_gateway`: For access to OCI services.
- `oci_core_security_list`: Security rules for subnets.

## Inputs
- `vcn_cidr`, `public_subnet_cidr`, `private_subnet_cidr`, `database_subnet_cidr`: CIDR blocks.
- `enable_database`: Flag to create database subnet.
- `public/private_security_list_ingress_security_rules`: Custom ingress rules.

## Outputs
- `vcn_id`, `vcn_cidr`
- `public_subnet_id`, `private_subnet_id`, `database_subnet_id`
- Gateway IDs.
