# What each enable_* flag creates, and the module outputs, against a mocked OCI provider:
# no credentials, so it runs on every pull request, forks included.

mock_provider "oci" {
  source = "./tests/mocks"
}

# Skips the 10-minute wait for the Bastion plugin in apply runs
mock_provider "time" {}

variables {
  tenancy_ocid      = "ocid1.tenancy.oc1..mock"
  ssh_public_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMockKeyForTerraformTestsOnly0000000000 mock@terraform-test"
  region            = "eu-marseille-1" # listed in instance_image_ocid: no image lookup
  allowed_ssh_cidrs = ["203.0.113.1/32"]
}

# Same profile as the Terratest smoke test: network and one VM only
run "minimal_profile_creates_network_and_one_vm" {
  command = plan

  variables {
    vm_count           = 1
    enable_frontend_lb = false
    enable_backend_lb  = false
    enable_storage     = false
    enable_bastion     = false
    enable_database    = false
    enable_dns         = false
    enable_ocir        = false
  }

  assert {
    condition     = output.instance_names == ["ha-backend-dev-vm-1"]
    error_message = "Expected exactly one VM named ha-backend-dev-vm-1."
  }

  assert {
    condition     = output.vcn_cidr == "10.0.0.0/16"
    error_message = "vcn_cidr output must match the input."
  }

  assert {
    condition = (
      length(module.frontend_load_balancer) + length(module.backend_load_balancer) + length(module.storage) +
      length(module.bastion) + length(module.bastion_sessions) + length(time_sleep.wait_for_bastion_plugin) +
      length(module.database) + length(module.frontend_dns_zone) + length(module.backend_dns_zone) + length(module.ocir)
    ) == 0
    error_message = "With every enable_* flag off, no optional module may be created."
  }

  assert {
    condition = alltrue([
      output.frontend_load_balancer_public_ip == null,
      output.backend_load_balancer_ip == null,
      output.object_storage_bucket_name == null,
      output.bastion_id == null,
      output.bastion_connection_metadata == null,
      output.autonomous_database_id == null,
      output.database_subnet_id == null,
      output.ocir_url == null,
    ])
    error_message = "Outputs of disabled features must be null."
  }
}

run "defaults_create_two_vms_lb_storage_and_bastion" {
  command = plan

  assert {
    condition     = output.instance_names == ["ha-backend-dev-vm-1", "ha-backend-dev-vm-2"]
    error_message = "Defaults must create 2 VMs for high availability."
  }

  assert {
    condition     = length(module.frontend_load_balancer) == 1 && length(module.backend_load_balancer) == 0
    error_message = "Defaults must create the frontend load balancer only (Always Free includes one)."
  }

  assert {
    condition     = length(module.bastion) == 1 && length(module.bastion_sessions) == 2
    error_message = "The Bastion must get one session per VM."
  }

  # The root output wraps the list in try(), which hides its length until apply: read the module output instead
  assert {
    condition     = output.object_storage_bucket_name == "ha-backend-dev-bucket" && length(module.storage[0].block_volume_ids) == 2
    error_message = "Storage must create the bucket and one block volume per VM."
  }

  assert {
    condition     = output.backup_policy_id == null
    error_message = "Backups are off by default."
  }
}

run "free_tier_database_has_no_private_subnet" {
  command = plan

  variables {
    enable_database    = true
    atp_admin_password = "MockPassw0rd123"
  }

  assert {
    condition     = length(module.database) == 1 && output.database_subnet_id == null
    error_message = "Always Free ATP has no private endpoint: the database subnet must not be created."
  }
}

# Every feature on, applied against the mocks (nothing is created) to check the outputs end to end
run "paid_full_stack_outputs" {
  command = apply

  variables {
    free_tier_mode       = false
    enable_backend_lb    = true
    enable_database      = true
    atp_admin_password   = "MockPassw0rd123"
    enable_dns           = true
    frontend_domain_name = "app.example.com"
    backend_domain_name  = "api.example.com"
    enable_backups       = true
    enable_ocir          = true
  }

  assert {
    condition     = output.database_subnet_id != null && output.autonomous_database_id != null
    error_message = "Paid mode must create the database and its private subnet."
  }

  assert {
    condition     = output.frontend_load_balancer_public_ip == "203.0.113.10" && output.backend_load_balancer_ip == "203.0.113.10"
    error_message = "Load balancer IP outputs must come from ip_address_details."
  }

  assert {
    condition     = length(module.frontend_dns_zone) == 1 && length(module.backend_dns_zone) == 1
    error_message = "enable_dns must create both zones when both load balancers are on."
  }

  assert {
    condition     = output.backup_policy_id != null
    error_message = "enable_backups must create the backup policy."
  }

  assert {
    condition     = keys(output.bastion_connection_metadata) == output.instance_names
    error_message = "bastion_connection_metadata must have one entry per VM, keyed by instance name."
  }

  assert {
    condition     = output.ocir_url != null
    error_message = "enable_ocir must expose the registry URL."
  }
}
