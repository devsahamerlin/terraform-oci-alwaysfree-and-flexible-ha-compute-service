# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog
and this project adheres to Semantic Versioning.

---

## [1.0.0] - 2026-02-15

### Added

- Initial stable release
- Modular OCI infrastructure stack:
    - Network (VCN, subnets, security lists)
    - Compute (A1 Flex default)
    - Bastion-based secure access
    - Load Balancer support
    - Object Storage
    - DNS Zone and RRSet
    - Container Registry
    - Database module
- Always Free optimized defaults
- Optional strict `free_tier_mode` validation
- Lifecycle preconditions enforcing:
    - A1 Flex shape in free tier mode
    - Maximum 4 OCPUs total
    - Maximum 24GB RAM total
- Pre-commit hooks:
    - terraform fmt
    - terraform validate
    - tflint
    - checkov
- SARIF upload to GitHub Code Scanning
- Version constraints added to all modules
- Production-ready module structure

### Security

- Bastion-only SSH access (no public IP on compute)
- Checkov security exceptions documented
- Oracle-managed encryption by default

---
