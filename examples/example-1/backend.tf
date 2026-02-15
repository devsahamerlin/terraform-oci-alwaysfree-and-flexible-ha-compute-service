# Default: Local Backend
terraform {
  backend "local" {
    path = "states/dev/terraform.tfstate"
  }
}

# ------------------------------------------------------------------------------
# Remote Backend Options (Uncomment one and configure)
# ------------------------------------------------------------------------------

# Option 1: Terraform Cloud / Remote
# terraform {
#   cloud {
#     organization = "your-organization"
#     workspaces {
#       name = "your-workspace"
#     }
#   }
# }

# Option 2: OCI Object Storage (S3 Compatible)
# terraform {
#   backend "s3" {
#     bucket   = "terraform-states"
#     key      = "dev/terraform.tfstate"
#     region   = "us-phoenix-1"
#     endpoint = "https://<namespace>.compat.objectstorage.<region>.oraclecloud.com"
#
#     # Shared credentials file
#     shared_credentials_file = "~/.oci/credentials"
#     profile                 = "oci"
#
#     skip_region_validation      = true
#     skip_credentials_validation = true
#     skip_metadata_api_check     = true
#     force_path_style            = true
#   }
# }

# Option 3: Google Cloud Storage (GCS)
# terraform {
#   backend "gcs" {
#     bucket  = "your-terraform-state-bucket"
#     prefix  = "terraform/state"
#     credentials = "path/to/your/service-account-key.json"
#   }
# }

# Option 4: AWS S3
# terraform {
#   backend "s3" {
#     bucket = "your-terraform-state-bucket"
#     key    = "path/to/my/key"
#     region = "us-east-1"
#   }
# }

# Option 5: Azure Blob Storage
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "tfstate"
#     storage_account_name = "tfstate"
#     container_name       = "tfstate"
#     key                  = "terraform.tfstate"
#   }
# }