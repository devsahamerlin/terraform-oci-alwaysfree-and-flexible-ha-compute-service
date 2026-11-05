# Terratest: testing the Terraform IaC on real OCI

The tests deploy `examples/example-1` on a real OCI tenancy, run assertions, then destroy everything. They only use Always Free resources and set `compartment_enable_delete = true`, so no compartment is left behind.

| Test | What it covers | Timeout | When |
|---|---|---|---|
| `TestSmokeNetworkAndCompute` | Network + 1 VM, all optional features off (no Bastion wait) | 20 min | CI on `main` and on demand |
| `TestStagingFullStack` | 2 VMs, frontend LB with an HTTP check through it, Bastion, storage, DNS, OCIR, ATP | 60 min | Before a release |
| `TestIdempotency` | Apply, then a second plan must show no changes | 20 min | Before a release |

## Environment variables

```shell
export TF_VAR_tenancy_ocid=""
export TF_VAR_user_ocid=""
export TF_VAR_fingerprint=""
export TF_VAR_private_key_path=""      # absolute path to the OCI API private key
export TF_VAR_region=""                # your tenancy home region
export TF_VAR_namespace=""             # Object Storage namespace
export TF_VAR_ssh_public_key_path=""   # absolute path to an SSH public key

# Only required by TestStagingFullStack
export TF_VAR_atp_admin_password="YourSecurePassword123"
export TF_VAR_backend_domain_name="backend.example.com"
export TF_VAR_frontend_domain_name="frontend.example.com"

# Optional: Terraform is the default; run the same tests with OpenTofu
export TF_BINARY=tofu
```

You can also copy `.env.example` to `.env` and load it so the variables are **exported** to `go test`:

```shell
set -a; source .env; set +a
```

Locally, tests are **skipped** (and `go test` still prints `PASS`) when the authentication variables are missing; check for `--- SKIP` in the output. In CI (`CI=true`) they fail instead.

## CI/CD secrets

> [!WARNING]
> GitHub Actions can mangle multi-line secrets such as PEM keys. Store them base64-encoded and decode them in the workflow (already done in `.github/workflows/ci.yml`).

```shell
base64 -i ~/.oci/oci-terraform-module.pem | pbcopy   # paste as OCI_PRIVATE_KEY_B64
base64 -i ~/.ssh/id_rsa.pub | pbcopy        # paste as SSH_PUBLIC_KEY_B64
```

## Run the tests

First time only, download the Go dependencies:

```shell
cd test
go mod tidy
```

Smoke test (fast, run on every change to `main`):

```shell
go test -v -run TestSmokeNetworkAndCompute -timeout 20m
# stream the Terraform logs to a file
go test -v -run TestSmokeNetworkAndCompute -timeout 20m 2>&1 | tee smoke.log
```

Full stack (before a release):

```shell
go test -v -run TestStagingFullStack -timeout 60m
```

Idempotency (before a release):

```shell
go test -v -run TestIdempotency -timeout 20m
```

All tests, sequentially (safer for OCI quotas: the Always Free A1 quota fits a single stack at a time):

```shell
go test -v -p 1 -parallel 1 -timeout 90m
```
