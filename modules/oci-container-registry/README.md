# OCIR Module

Configures OCI Container Registry (OCIR) and IAM policies for access.

## Resources
- `oci_artifacts_container_repository`: The container repo.
- `oci_identity_user/group/policy`: IAM setup for GitHub Actions/VM access.
- `oci_identity_auth_token`: Token for docker login.

## Inputs
- `compartment_id`, `tenancy_ocid`: OCI identifiers.
- `github_actions_email`: Email for CI/CD user.
- `create_vault_secret`: Option to store token in Vault.

## Outputs
- `ocir_repository_url`: Repo URL.
- `ocir_username`, `ocir_auth_token`: Credentials.
