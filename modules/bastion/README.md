# Bastion Module

Creates an OCI Bastion service to provide secure, ephemeral SSH access to private resources.

## Resources
- `oci_bastion_bastion`: The Bastion service instance.

## Inputs
- `compartment_id`: OCID of the compartment.
- `subnet_id`: OCID of the subnet where the Bastion is located.
- `allowed_ssh_cidrs`: List of CIDR blocks allowed to connect.
- `project_name`, `environment`: Naming identifiers.
- `tags`: Resource tags.

## Outputs
- `bastion_id`: OCID of the Bastion.
- `bastion_public_ip`: Public endpoint info.
