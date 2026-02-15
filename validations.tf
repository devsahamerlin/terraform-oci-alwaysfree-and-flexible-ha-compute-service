resource "null_resource" "free_tier_guard" {

  lifecycle {
    precondition {
      condition = (
        var.free_tier_mode == false ||
        (
          var.vm_shape == "VM.Standard.A1.Flex" &&
          local.total_requested_ocpus <= local.max_free_ocpus &&
          local.total_requested_memory <= local.max_free_memory
        )
      )

      error_message = <<EOT
Always Free validation failed.

Requested:
  Shape  = ${var.vm_shape}
  OCPUs  = ${local.total_requested_ocpus}
  Memory = ${local.total_requested_memory} GB

Compute Always Free limits:
  Shape  = VM.Standard.A1.Flex
  OCPUs  <= ${local.max_free_ocpus}
  Memory <= ${local.max_free_memory} GB

Disable free_tier_mode to allow paid scaling.
EOT
    }
  }
}



