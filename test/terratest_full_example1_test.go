package test

import (
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// ─────────────────────────────────────────────
// Shared config helpers
// ─────────────────────────────────────────────

type ociAuthVars struct {
	TenancyOcid    string
	UserOcid       string
	Fingerprint    string
	PrivateKeyPath string
	Region         string
	Namespace      string
	SSHPublicKey   string
}

// loadAuthVars reads OCI auth env vars and skips the test if any are missing.
func loadAuthVars(t *testing.T) ociAuthVars {
	t.Helper()
	vars := ociAuthVars{
		TenancyOcid:    os.Getenv("TF_VAR_tenancy_ocid"),
		UserOcid:       os.Getenv("TF_VAR_user_ocid"),
		Fingerprint:    os.Getenv("TF_VAR_fingerprint"),
		PrivateKeyPath: os.Getenv("TF_VAR_private_key_path"),
		Region:         os.Getenv("TF_VAR_region"),
		Namespace:      os.Getenv("TF_VAR_namespace"),
		SSHPublicKey:   os.Getenv("TF_VAR_ssh_public_key_path"),
	}

	missing := []string{}
	if vars.TenancyOcid == "" { missing = append(missing, "TF_VAR_tenancy_ocid") }
	if vars.UserOcid == "" { missing = append(missing, "TF_VAR_user_ocid") }
	if vars.Fingerprint == "" { missing = append(missing, "TF_VAR_fingerprint") }
	if vars.PrivateKeyPath == "" { missing = append(missing, "TF_VAR_private_key_path") }
	if vars.Region == "" { missing = append(missing, "TF_VAR_region") }
	if vars.Namespace == "" { missing = append(missing, "TF_VAR_namespace") }
	if vars.SSHPublicKey == "" { missing = append(missing, "TF_VAR_ssh_public_key_path") }

	if len(missing) > 0 {
		t.Skipf("Skipping test: missing required env vars: %s", strings.Join(missing, ", "))
	}
	return vars
}

// requireEnv reads an env var or fails (not skips) the test — for secrets that MUST be set in CI.
func requireEnv(t *testing.T, key string) string {
	t.Helper()
	val := os.Getenv(key)
	require.NotEmptyf(t, val, "Required env var %s is not set", key)
	return val
}

// optionalEnv reads an env var with a fallback default.
func optionalEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

// ─────────────────────────────────────────────
// TEST: Minimal smoke test (fast, cheap, CI-safe)
// Validates networking + compute only.
// No DB, no LB, no DNS — equivalent to your "local" tfvars.
// ─────────────────────────────────────────────

func TestSmokeNetworkAndCompute(t *testing.T) {
	t.Parallel()

	auth := loadAuthVars(t)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/example-1",
		Vars: map[string]interface{}{
			// Auth
			"tenancy_ocid":     auth.TenancyOcid,
			"user_ocid":        auth.UserOcid,
			"fingerprint":      auth.Fingerprint,
			"private_key_path": auth.PrivateKeyPath,
			"region":           auth.Region,
			"namespace":        auth.Namespace,
			"ssh_public_key_path": auth.SSHPublicKey,

			// Project identity
			"environment":  "ci-smoke",
			"project_name": fmt.Sprintf("ha-backend-smoke-%d", time.Now().Unix()),

			// Network — use defaults from vars file
			"vcn_cidr":             "10.0.0.0/16",
			"public_subnet_cidr":   "10.0.1.0/24",
			"private_subnet_cidr":  "10.0.2.0/24",
			"database_subnet_cidr": "10.0.3.0/24",

			// Compute — 1 minimal instance to stay in Always Free tier
			"vm_count":               1,
			"vm_shape":               "VM.Standard.A1.Flex",
			"vm_ocpus":               1,
			"vm_memory_gb":           6,
			"vm_boot_volume_size_gb": 50,

			// All optional features OFF for speed
			"enable_database":    false,
			"enable_frontend_lb": false,
			"enable_backend_lb":  false,
			"enable_bastion":     false,
			"enable_dns":         false,
			"enable_storage":     false,
			"enable_ocir":        false,

			// Security
			"allowed_ssh_cidrs": []string{"0.0.0.0/0"},

			// Tags
			"tags": map[string]string{
				"ManagedBy":   "Terratest",
				"Environment": "ci-smoke",
				"CostCenter":  "AlwaysFree",
			},
		},
		NoColor: true,
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// ── Networking assertions ──
	vcnId := terraform.Output(t, terraformOptions, "vcn_id")
	vcnCidr := terraform.Output(t, terraformOptions, "vcn_cidr")
	assert.NotEmpty(t, vcnId, "VCN ID should not be empty")
	assert.Equal(t, "10.0.0.0/16", vcnCidr, "VCN CIDR should match input")

	publicSubnetId := terraform.Output(t, terraformOptions, "public_subnet_id")
	privateSubnetId := terraform.Output(t, terraformOptions, "private_subnet_id")
	assert.NotEmpty(t, publicSubnetId, "Public subnet should exist")
	assert.NotEmpty(t, privateSubnetId, "Private subnet should exist")

	// ── Compute assertions ──
	instanceIds := terraform.OutputList(t, terraformOptions, "instance_ids")
	assert.Equal(t, 1, len(instanceIds), "Smoke test should create exactly 1 instance")
	assert.True(t, strings.HasPrefix(instanceIds[0], "ocid1.instance"), "Instance OCID format mismatch")
}

// ─────────────────────────────────────────────
// TEST: Staging / pre-prod — full feature stack
// Mirrors prod flags with non-prod secrets.
// Run on PR merge to main, not on every commit.
// ─────────────────────────────────────────────

func TestStagingFullStack(t *testing.T) {
	t.Parallel()

	auth := loadAuthVars(t)

	// These MUST be set in CI secrets — no fallback for DB credentials
	atpAdminPassword := requireEnv(t, "TF_VAR_atp_admin_password")
	backendDomain := requireEnv(t, "TF_VAR_backend_domain_name")
	frontendDomain := requireEnv(t, "TF_VAR_frontend_domain_name")

	// Optional — GitHub Actions integration, empty string is valid default
	githubEmail := optionalEnv("TF_VAR_github_actions_email", "")
	githubPubKey := optionalEnv("TF_VAR_github_actions_public_key", "")

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/example-1",
		Vars: map[string]interface{}{
			// Auth
			"tenancy_ocid":     auth.TenancyOcid,
			"user_ocid":        auth.UserOcid,
			"fingerprint":      auth.Fingerprint,
			"private_key_path": auth.PrivateKeyPath,
			"region":           auth.Region,
			"namespace":        auth.Namespace,
			"ssh_public_key_path": auth.SSHPublicKey,

			// Project identity
			"environment":  "staging",
			"project_name": fmt.Sprintf("ha-backend-staging-%d", time.Now().Unix()),

			// Domains
			"backend_domain_name":  backendDomain,
			"frontend_domain_name": frontendDomain,

			// Network
			"vcn_cidr":             "10.0.0.0/16",
			"public_subnet_cidr":   "10.0.1.0/24",
			"private_subnet_cidr":  "10.0.2.0/24",
			"database_subnet_cidr": "10.0.3.0/24",

			// Compute — 2 VMs, prod-equivalent shape
			"vm_count":               2,
			"vm_shape":               "VM.Standard.A1.Flex",
			"vm_ocpus":               2,
			"vm_memory_gb":           12,
			"vm_boot_volume_size_gb": 50,

			// Database
			"atp_db_name":        "habackenddb",
			"atp_admin_password": atpAdminPassword,

			// GitHub Actions integration (optional)
			"github_actions_email":      githubEmail,
			"github_actions_public_key": githubPubKey,

			// Feature flags — mirrors prod posture
			"enable_database":       true,
			"enable_frontend_lb":    true,
			"enable_backend_lb":     false,
			"enable_bastion":        true,
			"enable_dns":            true,
			"enable_storage":        true,
			"enable_ocir":           true,
			"object_events_enabled": true,

			// Security — restrict SSH in staging
			"allowed_ssh_cidrs": []string{"10.0.0.0/8"},

			// Tags
			"tags": map[string]string{
				"ManagedBy":   "Terratest",
				"Environment": "staging",
				"CostCenter":  "AlwaysFree",
			},
		},
		// Extend default timeout — LB + ATP provisioning can take 10–15 min on OCI
		RetryableTerraformErrors: map[string]string{
			".*timeout.*":                   "OCI provisioning timeout, retrying",
			".*Service limit exceeded.*":    "Quota transient error, retrying",
			".*TooManyRequests.*":           "OCI API rate limit, retrying",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 30 * time.Second,
		NoColor:            true,
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// ── Networking ──
	vcnId := terraform.Output(t, terraformOptions, "vcn_id")
	require.NotEmpty(t, vcnId, "VCN ID must not be empty")

	publicSubnetId := terraform.Output(t, terraformOptions, "public_subnet_id")
	privateSubnetId := terraform.Output(t, terraformOptions, "private_subnet_id")
	dbSubnetId := terraform.Output(t, terraformOptions, "database_subnet_id")
	assert.NotEmpty(t, publicSubnetId, "Public subnet should exist")
	assert.NotEmpty(t, privateSubnetId, "Private subnet should exist")
	assert.NotEmpty(t, dbSubnetId, "Database subnet should exist when enable_database=true")

	// ── Compute ──
	instanceIds := terraform.OutputList(t, terraformOptions, "instance_ids")
	assert.Equal(t, 2, len(instanceIds), "Staging should create 2 instances")
	for _, id := range instanceIds {
		assert.True(t, strings.HasPrefix(id, "ocid1.instance"), "Instance OCID format: %s", id)
	}

	// ── Load Balancer ──
	lbIp := terraform.Output(t, terraformOptions, "frontend_load_balancer_public_ip")
	assert.NotEmpty(t, lbIp, "Frontend LB public IP should be set when enable_frontend_lb=true")

	// ── Bastion ──
	bastionId := terraform.Output(t, terraformOptions, "bastion_id")
	assert.NotEmpty(t, bastionId, "Bastion ID should be set when enable_bastion=true")

	// ── DNS ──
	//dnsZoneId := terraform.Output(t, terraformOptions, "dns_zone_id")
	//assert.NotEmpty(t, dnsZoneId, "DNS zone should be created when enable_dns=true")

	// ── Object Storage ──
	bucketName := terraform.Output(t, terraformOptions, "object_storage_bucket_name")
	assert.NotEmpty(t, bucketName, "Storage bucket should exist when enable_storage=true")

	storageNamespace := terraform.Output(t, terraformOptions, "object_storage_namespace")
	assert.NotEmpty(t, storageNamespace, "Object storage namespace should not be empty")

	// ── Block Volumes ──
	blockVolumeIds := terraform.OutputList(t, terraformOptions, "block_volume_ids")
	assert.Equal(t, 2, len(blockVolumeIds), "Should have 1 block volume per instance (vm_count=2)")

	// ── OCIR ──
	ocirRepoUrl := terraform.Output(t, terraformOptions, "ocir_repository_url")
	assert.NotEmpty(t, ocirRepoUrl, "OCIR repository URL should exist when enable_ocir=true")

	ocirUsername := terraform.Output(t, terraformOptions, "ocir_username")
	assert.NotEmpty(t, ocirUsername, "OCIR username should not be empty")

	// ── Database (ATP) — wait up to 15 min for provisioning ──
	dbId := retry.DoWithRetry(
		t,
		"Waiting for ATP database to be AVAILABLE",
		30,             // max attempts
		30*time.Second, // sleep between
		func() (string, error) {
			id := terraform.Output(t, terraformOptions, "autonomous_database_id")
			if id == "" {
				return "", fmt.Errorf("ATP DB not yet available")
			}
			return id, nil
		},
	)
	assert.NotEmpty(t, dbId, "ATP database OCID should not be empty")
	assert.True(t, strings.HasPrefix(dbId, "ocid1.autonomousdatabase"), "ATP OCID format mismatch")

	// ── DB Connection strings ──
	connStrings := terraform.Output(t, terraformOptions, "database_connection_strings")
	assert.NotEmpty(t, connStrings, "ATP connection strings should not be empty")

	// ── Backup policy ──
	backupPolicyId := terraform.Output(t, terraformOptions, "backup_policy_id")
	assert.NotEmpty(t, backupPolicyId, "Backup policy should be assigned")
}

// ─────────────────────────────────────────────
// TEST: Idempotency — apply twice, no diff
// Run this before any prod promotion.
// ─────────────────────────────────────────────

func TestIdempotency(t *testing.T) {
	t.Parallel()

	auth := loadAuthVars(t)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/example-1",
		Vars: map[string]interface{}{
			"tenancy_ocid":     auth.TenancyOcid,
			"user_ocid":        auth.UserOcid,
			"fingerprint":      auth.Fingerprint,
			"private_key_path": auth.PrivateKeyPath,
			"region":           auth.Region,
			"namespace":        auth.Namespace,
			"ssh_public_key_path": auth.SSHPublicKey,

			"environment":  "ci-idempotency",
			"project_name": fmt.Sprintf("ha-idempotency-%d", time.Now().Unix()),

			"vm_count":      1,
			"vm_ocpus":      1,
			"vm_memory_gb":  6,

			"enable_database":    false,
			"enable_frontend_lb": false,
			"enable_backend_lb":  false,
			"enable_bastion":     false,
			"enable_dns":         false,
			"enable_storage":     false,
			"enable_ocir":        false,

			"tags": map[string]string{
				"ManagedBy": "Terratest",
				"CostCenter": "AlwaysFree",
			},
		},
		NoColor: true,
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Second apply must produce zero changes
	exitCode := terraform.PlanExitCode(t, terraformOptions)
	assert.Equal(t, 0, exitCode, "Second plan should show no changes (idempotency check)")
}