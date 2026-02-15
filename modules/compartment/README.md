# Compartment Module

Creates an OCI Compartment to organize resources.

## Resources
- `oci_identity_compartment`: The compartment resource.

## Inputs
- `tenancy_ocid`: Root tenancy OCID.
- `name`, `description`: Compartment details.
- `enable_delete`: Allow deletion (default false).

## Outputs
- `compartment_id`: OCID of the created compartment.
