output "ocir_namespace" {
  description = "OCIR namespace for this tenancy"
  value       = data.oci_objectstorage_namespace.tenancy_namespace.namespace != null ? data.oci_objectstorage_namespace.tenancy_namespace.namespace : ""
}

output "ocir_url" {
  description = "OCIR registry endpoint (docker login host)"
  value       = "${var.region_key}.ocir.io"
}

output "dynamic_group_id" {
  description = "Dynamic group OCID for VM instances"
  value       = oci_identity_dynamic_group.vm_dynamic_group.id
}

# Output the repository details
output "ocir_repository_url" {
  description = "Full backend URL for the container repository"
  value       = "${var.region_key}.ocir.io/${data.oci_objectstorage_namespace.tenancy_namespace.namespace}/${oci_artifacts_container_repository.backend_repository.display_name}"
}

output "ocir_repository_repository_id" {
  description = "OCID backend of the container repository"
  value       = oci_artifacts_container_repository.backend_repository.id
}

output "github_actions_user_ocid" {
  description = "OCID of the GitHub Actions user"
  value       = var.user_email != "" ? oci_identity_user.github_actions_user[0].id : ""
}

output "github_actions_username" {
  description = "Username for GitHub Actions (use with auth token for OCIR login)"
  value       = var.user_email != "" ? "${data.oci_objectstorage_namespace.tenancy_namespace.namespace}/${oci_identity_user.github_actions_user[0].name}" : ""
}

output "github_actions_auth_token" {
  description = "Auth token for GitHub Actions (sensitive - store in GitHub Secrets)"
  value       = var.user_email != "" ? oci_identity_auth_token.github_actions_token[0].token : ""
  sensitive   = true
}
