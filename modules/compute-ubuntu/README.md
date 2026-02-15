# Compute Module (Ubuntu)

Deploys Ubuntu VM instances on OCI.

## Resources
- `oci_core_instance`: The compute instances.

## Inputs
- `vm_count`: Number of instances.
- `vm_shape`, `vm_ocpus`, `vm_memory_gb`: Instance sizing.
- `subnet_id`: Subnet for the instances.
- `ssh_public_key`: Key for access.
- `cloud_init_config`: User data script.
- `is_pv_encryption_in_transit_enabled`: Enable in-transit encryption for boot volumes. Protects data in transit between compute instance and boot volume. Prevents man-in-the-middle attacks on internal OCI network. Zero performance impact (hardware-accelerated). Required for many compliance frameworks (PCI-DSS, HIPAA, etc.). [default value is true]
- `are_legacy_imds_endpoints_disabled`: Disable legacy IMDS endpoints

## Outputs
- `instance_ids`: List of instance OCIDs.
- `instance_private_ips`: List of private IPs.
