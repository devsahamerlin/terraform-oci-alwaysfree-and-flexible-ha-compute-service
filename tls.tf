# Self-signed certificate for the private backend load balancer (internal traffic only)
resource "tls_private_key" "backend_lb_private_key" {
  count     = var.enable_backend_lb ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "backend_lb_cert" {
  count           = var.enable_backend_lb ? 1 : 0
  private_key_pem = tls_private_key.backend_lb_private_key[0].private_key_pem

  subject {
    common_name  = coalesce(var.backend_domain_name, "${var.project_name}.internal")
    organization = var.project_name
  }

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}
