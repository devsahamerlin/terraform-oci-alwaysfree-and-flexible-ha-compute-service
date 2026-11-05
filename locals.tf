locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
    }
  )

  # Always Free limits: https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm
  # Ampere A1: 1,500 OCPU hours and 9,000 GB hours per month = 2 OCPUs and 12 GB of memory
  max_free_ocpus            = 2
  max_free_memory           = 12
  max_free_load_balancers   = 1
  max_free_block_storage_gb = 200

  total_requested_ocpus          = var.vm_count * var.vm_ocpus
  total_requested_memory         = var.vm_count * var.vm_memory_gb
  total_requested_load_balancers = (var.enable_frontend_lb ? 1 : 0) + (var.enable_backend_lb ? 1 : 0)
  total_requested_block_storage_gb = var.vm_count * (
    var.vm_boot_volume_size_gb + (var.enable_storage ? var.block_volume_size_gb : 0)
  )

  instance_image_id = lookup(var.instance_image_ocid, var.region, try(data.oci_core_images.ubuntu[0].images[0].id, null))
}
