# Bastion Session Module

Creates a managed SSH session via the Bastion service.

## Resources
- `oci_bastion_session`: The session resource.

## Inputs
- `bastion_id`: OCID of the Bastion.
- `target_resource_id`: Target VM OCID.
- `ssh_public_key`: Key for the session.

## Outputs
- `bastion_session_id`: Session ID.
- `bastion_session_ssh_metadata`: Connection command info.
