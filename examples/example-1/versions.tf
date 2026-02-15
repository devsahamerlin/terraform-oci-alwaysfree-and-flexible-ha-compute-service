terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.33.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.6"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.13.1"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.4"
    }
  }
  required_version = ">= 1.2.0"
}
