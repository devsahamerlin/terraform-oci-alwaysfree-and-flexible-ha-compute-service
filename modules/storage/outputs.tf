output "bucket_name" {
  description = "Name of the Object Storage bucket"
  value       = oci_objectstorage_bucket.main.name
}

output "bucket_namespace" {
  description = "Namespace of the Object Storage bucket"
  value       = data.oci_objectstorage_namespace.ns.namespace
}

output "block_volume_ids" {
  description = "OCIDs of the created block volumes"
  value       = oci_core_volume.block_volume[*].id
}

output "backup_policy_id" {
  description = "OCID of the block volume backup policy (null when backups are disabled)"
  value       = try(oci_core_volume_backup_policy.block_volume_backup[0].id, null)
}

output "volume_attachment_ids" {
  description = "OCIDs of the block volume attachments"
  value       = oci_core_volume_attachment.block_volume_attachment[*].id
}