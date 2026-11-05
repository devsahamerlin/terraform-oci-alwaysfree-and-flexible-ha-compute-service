terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.33.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.3.7"
    }
  }
  required_version = ">= 1.5.0"
}