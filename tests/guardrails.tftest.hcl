# Always Free and input guardrails (validations.tf) against a mocked OCI provider:
# no credentials, so it runs on every pull request, forks included.

mock_provider "oci" {
  source = "./tests/mocks"
}

variables {
  tenancy_ocid      = "ocid1.tenancy.oc1..mock"
  ssh_public_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMockKeyForTerraformTestsOnly0000000000 mock@terraform-test"
  region            = "eu-marseille-1" # listed in instance_image_ocid: no image lookup
  allowed_ssh_cidrs = ["203.0.113.1/32"]
}

# ── Always Free limits (free_tier_mode = true, the default) ──

run "defaults_fit_in_always_free" {
  command = plan
}

run "rejects_paid_shape" {
  command = plan

  variables {
    vm_shape = "VM.Standard.E4.Flex"
  }

  expect_failures = [null_resource.free_tier_guard]
}

run "rejects_more_than_2_ocpus" {
  command = plan

  variables {
    vm_ocpus = 2 # 2 VMs x 2 OCPUs = 4
  }

  expect_failures = [null_resource.free_tier_guard]
}

run "rejects_more_than_12_gb_memory" {
  command = plan

  variables {
    vm_memory_gb = 8 # 2 VMs x 8 GB = 16
  }

  expect_failures = [null_resource.free_tier_guard]
}

run "rejects_two_load_balancers" {
  command = plan

  variables {
    enable_backend_lb = true # the frontend one is on by default
  }

  expect_failures = [null_resource.free_tier_guard]
}

run "rejects_more_than_200_gb_block_storage" {
  command = plan

  variables {
    vm_boot_volume_size_gb = 100 # 2 VMs x (100 boot + 50 block) = 300
  }

  expect_failures = [null_resource.free_tier_guard]
}

run "rejects_scheduled_backups" {
  command = plan

  variables {
    enable_backups = true
  }

  expect_failures = [null_resource.free_tier_guard]
}

run "paid_mode_lifts_the_limits" {
  command = plan

  variables {
    free_tier_mode    = false
    vm_shape          = "VM.Standard.E4.Flex"
    vm_count          = 3
    vm_ocpus          = 2
    vm_memory_gb      = 16
    enable_backend_lb = true
    enable_backups    = true
  }
}

# ── Required inputs ──
# (enable_database without atp_admin_password is not tested: the wallet's required "password" argument fails
# the plan before the input_guard precondition, and terraform test cannot expect that kind of error)

run "dns_requires_frontend_domain" {
  command = plan

  variables {
    enable_dns = true
  }

  expect_failures = [null_resource.input_guard]
}

run "dns_with_backend_lb_requires_backend_domain" {
  command = plan

  variables {
    enable_dns           = true
    frontend_domain_name = "app.example.com"
    enable_frontend_lb   = false
    enable_backend_lb    = true
  }

  expect_failures = [null_resource.input_guard]
}

run "ssh_public_key_must_be_content_not_path" {
  command = plan

  variables {
    ssh_public_key = "~/.ssh/id_rsa.pub"
  }

  expect_failures = [var.ssh_public_key]
}

# ── Image lookup for regions missing from instance_image_ocid ──

run "unlisted_region_uses_latest_ubuntu_image" {
  command = plan

  variables {
    region = "ap-tokyo-1"
  }

  override_data {
    target = data.oci_core_images.ubuntu
    values = {
      images = [{ id = "ocid1.image.oc1.ap-tokyo-1.mock" }]
    }
  }

  assert {
    condition     = local.instance_image_id == "ocid1.image.oc1.ap-tokyo-1.mock"
    error_message = "A region missing from instance_image_ocid must fall back to the image lookup."
  }
}

run "unlisted_region_without_image_fails" {
  command = plan

  variables {
    region = "ap-tokyo-1"
  }

  override_data {
    target = data.oci_core_images.ubuntu
    values = {
      images = []
    }
  }

  expect_failures = [null_resource.input_guard]
}
