# Terratest

## CI/CD
**⚠️ Attention au multiline PEM** — GitHub Actions tronque parfois les secrets multilignes. Pour éviter ça, encoder en base64 avant de stocker, puis decode dans le workflow :
```shell
base64 -i ~/.oci/oci_api_key.pem

# Ou copier directement dans le clipboard pour coller dans GitHub Secrets
base64 -i ~/.oci/oci_api_key.pem | pbcopy

# Même chose pour la clé SSH
base64 -i ~/.ssh/id_rsa.pub | pbcopy
```


```shell
export TF_VAR_tenancy_ocid=""
export TF_VAR_user_ocid=""
export TF_VAR_fingerprint=""
export TF_VAR_private_key_path=""
export TF_VAR_region=""
export TF_VAR_ssh_public_key_path=""

# Requis seulement pour TestStagingFullStack

export TF_VAR_atp_admin_password="YourSecurePassword123"
export TF_VAR_backend_domain_name="backend.example.com"
export TF_VAR_frontend_domain_name="frontend.example.com"

```

## Init Go modules (première fois)
```shell
cd test
go mod tidy # Downloads the dependencies (Terratest, etc.)
```

## Lancer un test spécifique

# Smoke — rapide, chaque PR
```shell
go test -v -run TestSmokeNetworkAndCompute -timeout 20m
# ou pour Voir les logs Terraform en temps réel
go test -v -run TestSmokeNetworkAndCompute -timeout 20m 2>&1 | tee smoke.log
```

# Staging full stack — avant merge main
```shell
go test -v -run TestStagingFullStack -timeout 30m
```

# Idempotency — avant promo prod
```shell
go test -v -run TestIdempotency -timeout 20m
```

## Lancer tous les tests

# Séquentiel (plus safe pour les quotas OCI)
```shell
go test -v -timeout 30m
```

# Parallèle (les tests ont t.Parallel() — attention aux limits OCI)
```shell
go test -v -parallel 3 -timeout 30m
```

