# Get tenancy namespace for OCIR
data "oci_objectstorage_namespace" "tenancy_namespace" {
  compartment_id = var.compartment_id
}

# Create Container Repository in OCIR (Optional - repositories are auto-created on first push)
resource "oci_artifacts_container_repository" "backend_repository" {
  compartment_id = var.compartment_id
  display_name   = "${data.oci_objectstorage_namespace.tenancy_namespace.namespace}/${var.project_name}"

  is_immutable = false
  is_public    = false

  readme {
    content = "Container repository for ${var.project_name} ${var.environment}"
    format  = "text/plain"
  }

  freeform_tags = var.tags
}

#resource "oci_artifacts_container_repository" "frontend_repository" {
#  compartment_id = var.compartment_id
#  display_name   = "${data.oci_objectstorage_namespace.tenancy_namespace.namespace}/${var.project_name}-${var.environment}/angular-frontend"
#
#  is_immutable = false
#  is_public    = false
#
#  readme {
#    content = "Container repository for ${var.project_name} ${var.environment} Angular frontend"
#    format  = "text/plain"
#  }
#
#  freeform_tags = var.tags
#}

# Create IAM user for GitHub Actions (Optional - only if GitHub Actions integration needed)
resource "oci_identity_user" "github_actions_user" {
  count          = var.user_email != "" ? 1 : 0
  compartment_id = var.tenancy_ocid
  name           = "${var.project_name}-${var.environment}-github-actions"
  description    = "Service user for GitHub Actions CI/CD pipeline"
  email          = var.user_email

  freeform_tags = var.tags
}

# Create auth token for GitHub Actions user
resource "oci_identity_auth_token" "github_actions_token" {
  count       = var.user_email != "" ? 1 : 0
  user_id     = oci_identity_user.github_actions_user[0].id
  description = "Auth token for GitHub Actions to push to OCIR"
}

# Create API key for GitHub Actions user (only if public key provided)
resource "oci_identity_api_key" "github_actions_api_key" {
  count     = var.github_actions_public_key != "" && var.user_email != "" ? 1 : 0
  user_id   = oci_identity_user.github_actions_user[0].id
  key_value = var.github_actions_public_key
}

# Create IAM group for GitHub Actions
resource "oci_identity_group" "github_actions_group" {
  count          = var.user_email != "" ? 1 : 0
  compartment_id = var.tenancy_ocid
  name           = "${var.project_name}-${var.environment}-github-actions-group"
  description    = "Group for GitHub Actions with OCIR push permissions"

  freeform_tags = var.tags
}

# Add GitHub Actions user to the group
resource "oci_identity_user_group_membership" "github_actions_membership" {
  count    = var.user_email != "" ? 1 : 0
  user_id  = oci_identity_user.github_actions_user[0].id
  group_id = oci_identity_group.github_actions_group[0].id
}

# Create dynamic group for VMs to pull images
resource "oci_identity_dynamic_group" "vm_dynamic_group" {
  compartment_id = var.tenancy_ocid
  name           = "${var.project_name}-${var.environment}-vm-dg"
  description    = "Dynamic group for VM instances to access OCIR"

  matching_rule = "ALL {instance.compartment.id = '${var.compartment_id}'}"

  freeform_tags = var.tags
}

# IAM Policy for VMs to pull from OCIR (root compartment level)
resource "oci_identity_policy" "ocir_pull_policy" {
  compartment_id = var.tenancy_ocid
  name           = "${var.project_name}-${var.environment}-ocir-pull-policy"
  description    = "Allow VMs to pull images from OCIR"

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.vm_dynamic_group.name} to read repos in tenancy",
    "Allow dynamic-group ${oci_identity_dynamic_group.vm_dynamic_group.name} to read objectstorage-namespaces in tenancy",
  ]

  freeform_tags = var.tags
}

# IAM Policy for GitHub Actions (only if user created)
resource "oci_identity_policy" "github_actions_policy" {
  count          = var.user_email != "" ? 1 : 0
  compartment_id = var.tenancy_ocid
  name           = "${var.project_name}-${var.environment}-github-actions-policy"
  description    = "Allow GitHub Actions to push images to OCIR"

  statements = [
    "Allow group ${oci_identity_group.github_actions_group[0].name} to read repos in tenancy",
    "Allow group ${oci_identity_group.github_actions_group[0].name} to manage repos in compartment id ${var.compartment_id}",
    "Allow group ${oci_identity_group.github_actions_group[0].name} to read objectstorage-namespaces in tenancy",
  ]

  freeform_tags = var.tags
}

# Store auth token in Vault (optional)
resource "oci_vault_secret" "github_actions_token" {
  count          = var.create_vault_secret && var.user_email != "" ? 1 : 0
  compartment_id = var.compartment_id
  vault_id       = var.vault_id
  key_id         = var.vault_key_id

  secret_name = "${var.project_name}-${var.environment}-github-actions-token"
  description = "Auth token for GitHub Actions OCIR access"

  secret_content {
    content_type = "BASE64"
    content      = base64encode(oci_identity_auth_token.github_actions_token[0].token)
  }

  freeform_tags = var.tags
}
