locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
    }
  )
  max_free_ocpus  = 4
  max_free_memory = 24

  total_requested_ocpus  = var.vm_count * var.vm_ocpus
  total_requested_memory = var.vm_count * var.vm_memory_gb
}