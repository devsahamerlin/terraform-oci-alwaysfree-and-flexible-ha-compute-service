# Changelog: Terraform OCI Always Free & Flexible HA Compute Stack (IaC)

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - Unreleased

First public release on the Terraform Registry (`devsahamerlin/alwaysfree-and-flexible-ha-compute-service/oci`).

### Added

- Modular OCI infrastructure stack:
    - Compartment
    - Network (VCN, public and private subnets, internet / NAT / service gateways, security lists)
    - Compute (Ubuntu on Ampere A1 Flex by default, no public IP, IMDSv1 disabled, in-transit encryption)
    - Flexible Load Balancer (public frontend over HTTP, or private backend over HTTPS)
    - Bastion service with one managed SSH session per VM
    - Object Storage bucket and one block volume attached per VM
    - Optional Autonomous Database, DNS zones and records, Container Registry (OCIR)
- `free_tier_mode` (default `true`) with plan-time guardrails, one error message per rule:
    - `VM.Standard.A1.Flex` shape only
    - At most 2 OCPUs and 12 GB of memory in total (Oracle's current Always Free A1 allowance: 1,500 OCPU hours and 9,000 GB hours per month)
    - At most 1 load balancer
    - At most 200 GB of boot + block volumes
    - No scheduled block volume backups (they exceed the 5 Always Free backups)
- Input checks: `atp_admin_password` required with `enable_database`, domain names required with `enable_dns`
- Warning (`check` block) when `allowed_ssh_cidrs` contains `0.0.0.0/0`
- Image lookup fallback: regions missing from `instance_image_ocid` use the latest Canonical Ubuntu image (`ubuntu_version`, default `24.04`) compatible with `vm_shape`
- New inputs: `ssh_user`, `ubuntu_version`, `block_volume_size_gb`, `compartment_enable_delete`
- New outputs: `ocir_url`
- CI: format check, validate, TFLint, Checkov with SARIF upload, Checkov results as a PR comment, Terratest smoke test on `main` and on demand
- Pre-commit hooks: terraform fmt, validate, tflint, terraform-docs, checkov
- terraform-docs generated reference for the root module, submodules and example
- Documentation rewritten: problem statement, design goals, architecture, measured results, design decisions and trade-offs

### Changed

- Defaults that stay inside the Always Free tier: `vm_count = 2`, `vm_ocpus = 1`, `vm_memory_gb = 6`, `enable_dns = false`, `enable_ocir = false`, `enable_backups = false`
- The compartment is named `<project_name>-<environment>`, so several environments can share a tenancy
- The database subnet is only created in paid mode, since Always Free ATP has no private endpoint
- `frontend_domain_name` and `backend_domain_name` are optional (default `""`)
- Minimum versions: Terraform `>= 1.5.0`; providers use `>=` constraints so consumers can pin them
- The OCIR repository, dynamic group and policies target the stack's compartment
- A single 10-minute wait for the Bastion plugin, only when `enable_bastion = true`

### Breaking

- `ssh_public_key_path` is renamed `ssh_public_key` and expects the key **content** (e.g. `file("~/.ssh/id_rsa.pub")`)
- The `backend_load_balancer_public_ip` output is renamed `backend_load_balancer_ip` (the backend LB is private)
- The default public security list no longer opens port 22 (SSH goes through Bastion)

### Fixed

- The frontend load balancer had no listener when SSL was disabled: an HTTP listener is now created
- The default private security list did not open the load balancer backend ports 8080 and 8000
- Bastion sessions used the `opc` user on Ubuntu images: `ssh_user` (default `ubuntu`) is used for sessions and the connection command
- `is_free_tier` was hard-coded to `true` in the database module, which broke paid mode
- The OCIR dynamic group targeted the tenancy root, so the VMs could not pull images; the repository URL contained the namespace twice
- Block volumes were created but never attached to the VMs
- The `backup_policy_id` output returned assignment IDs instead of the policy ID
- The `ocir_url` output returned a service CIDR block

### Removed

- Unused `tls_private_key.public_private_key_pair` resource and `random` provider
- Per-VM `time_sleep` resources and the extra 2-minute wait

### Security

- Bastion-only SSH access, no public IP on compute
- Checkov exceptions documented in `.checkov.yaml` and in the README
- Oracle-managed encryption by default
