# Get availability domains data
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Cloud-init configuration
data "cloudinit_config" "vm_config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = var.cloud_init_config
  }
}

# VM Instances - Both in PRIVATE subnet
resource "oci_core_instance" "vm" {
  count               = var.vm_count
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[count.index % length(data.oci_identity_availability_domains.ads.availability_domains)].name
  display_name        = "${var.project_name}-${var.environment}-vm-${count.index + 1}"
  shape               = var.vm_shape

  shape_config {
    ocpus         = var.vm_ocpus
    memory_in_gbs = var.vm_memory_gb
  }

  source_details {
    source_type             = "image"
    source_id               = var.instance_image_ocid
    boot_volume_size_in_gbs = var.vm_boot_volume_size_gb
  }

  launch_options {
    is_pv_encryption_in_transit_enabled = var.is_pv_encryption_in_transit_enabled
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = var.are_legacy_imds_endpoints_disabled
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = false
    display_name     = "${var.project_name}-${var.environment}-vnic-${count.index + 1}"
  }

  # Enable Oracle Cloud Agent plugins including Bastion
  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false

    plugins_config {
      name          = "Bastion"
      desired_state = var.bastion
    }

    plugins_config {
      name          = "OS Management Service Agent"
      desired_state = var.os_manegement_service_agent
    }
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.cloudinit_config.vm_config.rendered
  }

  freeform_tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-vm-${count.index + 1}"
    }
  )

  preserve_boot_volume = false
}
# resource "oci_core_instance" "vm" {
#   count               = var.vm_count
#   compartment_id      = var.compartment_id
#   availability_domain = data.oci_identity_availability_domains.ads.availability_domains[count.index % length(data.oci_identity_availability_domains.ads.availability_domains)].name
#   display_name        = "${var.project_name}-${var.environment}-vm-${count.index + 1}"
#   shape               = var.vm_shape
#
#   shape_config {
#     ocpus         = var.vm_ocpus
#     memory_in_gbs = var.vm_memory_gb
#   }
#
#   source_details {
#     source_type             = "image"
#     source_id               = var.instance_image_ocid #data.oci_core_images.ubuntu_lts.images[0].id // *** CHANGED: Use the Ubuntu image ID ***
#     boot_volume_size_in_gbs = var.vm_boot_volume_size_gb
#   }
#
#   create_vnic_details {
#     subnet_id        = var.subnet_id
#     assign_public_ip = false
#     display_name     = "${var.project_name}-${var.environment}-vnic-${count.index + 1}"
#   }
#
#   # Enable Oracle Cloud Agent plugins including Bastion
#   agent_config {
#     are_all_plugins_disabled = false
#     is_management_disabled   = false
#     is_monitoring_disabled   = false
#
#     plugins_config {
#       name          = "Bastion"
#       desired_state = var.bastion #"ENABLED"
#     }
#
#     plugins_config {
#       name          = "OS Management Service Agent"
#       desired_state = var.os_manegement_service_agent #"ENABLED"
#     }
#   }
#
#   metadata = {
#     ssh_authorized_keys = var.ssh_public_key
#     user_data           = data.cloudinit_config.vm_config.rendered
#   }
#
#   freeform_tags = merge(
#     var.tags,
#     {
#       Name = "${var.project_name}-${var.environment}-vm-${count.index + 1}"
#     }
#   )
#
#   preserve_boot_volume = false
# }