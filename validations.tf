# Always Free guardrails: each rule fails the plan with its own message when free_tier_mode = true.
# Set free_tier_mode = false to deploy paid shapes and resources.
resource "null_resource" "free_tier_guard" {

  lifecycle {
    precondition {
      condition     = !var.free_tier_mode || var.vm_shape == "VM.Standard.A1.Flex"
      error_message = "Always Free validation failed: vm_shape must be VM.Standard.A1.Flex (requested ${var.vm_shape}). Set free_tier_mode = false to use paid shapes."
    }

    precondition {
      condition     = !var.free_tier_mode || local.total_requested_ocpus <= local.max_free_ocpus
      error_message = "Always Free validation failed: ${local.total_requested_ocpus} OCPUs requested (vm_count x vm_ocpus), the Always Free limit is ${local.max_free_ocpus} OCPUs. Set free_tier_mode = false to scale beyond it."
    }

    precondition {
      condition     = !var.free_tier_mode || local.total_requested_memory <= local.max_free_memory
      error_message = "Always Free validation failed: ${local.total_requested_memory} GB of memory requested (vm_count x vm_memory_gb), the Always Free limit is ${local.max_free_memory} GB. Set free_tier_mode = false to scale beyond it."
    }

    precondition {
      condition     = !var.free_tier_mode || local.total_requested_load_balancers <= local.max_free_load_balancers
      error_message = "Always Free validation failed: ${local.total_requested_load_balancers} load balancers requested, Always Free includes ${local.max_free_load_balancers}. Enable either enable_frontend_lb or enable_backend_lb, or set free_tier_mode = false."
    }

    precondition {
      condition     = !var.free_tier_mode || local.total_requested_block_storage_gb <= local.max_free_block_storage_gb
      error_message = "Always Free validation failed: ${local.total_requested_block_storage_gb} GB of boot + block volumes requested, the Always Free limit is ${local.max_free_block_storage_gb} GB. Reduce vm_count, vm_boot_volume_size_gb or block_volume_size_gb, or set free_tier_mode = false."
    }

    precondition {
      condition     = !var.free_tier_mode || !(var.enable_storage && var.enable_backups)
      error_message = "Always Free validation failed: daily block volume backups with 7-day retention exceed the 5 Always Free volume backups. Set enable_backups = false, or set free_tier_mode = false."
    }
  }
}

resource "null_resource" "input_guard" {

  lifecycle {
    precondition {
      condition     = !var.enable_database || var.atp_admin_password != null
      error_message = "atp_admin_password is required when enable_database = true."
    }

    precondition {
      condition     = !var.enable_dns || (var.frontend_domain_name != "" && (!var.enable_backend_lb || var.backend_domain_name != ""))
      error_message = "enable_dns = true requires frontend_domain_name (and backend_domain_name when enable_backend_lb = true)."
    }

    precondition {
      condition     = local.instance_image_id != null
      error_message = "No image found for region ${var.region}: add it to instance_image_ocid or check ubuntu_version / vm_shape."
    }
  }
}

check "bastion_client_cidrs" {
  assert {
    condition     = !var.enable_bastion || !contains(var.allowed_ssh_cidrs, "0.0.0.0/0")
    error_message = "allowed_ssh_cidrs contains 0.0.0.0/0: any IP can request Bastion sessions. Restrict it to your public IP (curl ifconfig.me) as x.x.x.x/32."
  }
}
