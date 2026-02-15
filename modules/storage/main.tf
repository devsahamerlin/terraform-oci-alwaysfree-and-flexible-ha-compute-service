data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_id
}

# Object Storage Bucket
resource "oci_objectstorage_bucket" "main" {
  compartment_id = var.compartment_id
  namespace      = try(data.oci_objectstorage_namespace.ns.namespace, var.namespace)
  name           = "${var.project_name}-${var.environment}-bucket"
  access_type    = "NoPublicAccess"

  storage_tier          = "Standard"
  versioning            = "Enabled"
  object_events_enabled = var.object_events_enabled

  freeform_tags = var.tags
}

resource "oci_core_volume_backup_policy" "block_volume_backup" {
  count          = var.enable_backups ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-${var.environment}-block-backup-policy"

  schedules {
    backup_type       = "INCREMENTAL"
    period            = "ONE_DAY"
    retention_seconds = 604800 # 7 days
    time_zone         = "UTC"
    hour_of_day       = 2 # 2 AM UTC
  }

  freeform_tags = var.tags
}

# Block Volumes for VMs
resource "oci_core_volume" "block_volume" {
  count               = var.vm_count
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[count.index % length(data.oci_identity_availability_domains.ads.availability_domains)].name
  display_name        = "${var.project_name}-${var.environment}-volume-${count.index + 1}"
  size_in_gbs         = 50

  freeform_tags = var.tags
}

resource "oci_core_volume_backup_policy_assignment" "volume_backup_policy_assignment" {
  count     = var.enable_backups ? var.vm_count : 0
  asset_id  = oci_core_volume.block_volume[count.index].id
  policy_id = oci_core_volume_backup_policy.block_volume_backup[0].id
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}
