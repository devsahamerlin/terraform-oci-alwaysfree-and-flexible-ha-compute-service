resource "tls_private_key" "public_private_key_pair" {
  algorithm = "RSA"
}

resource "tls_private_key" "backend_lb_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "backend_lb_cert" {
  private_key_pem = tls_private_key.backend_lb_private_key.private_key_pem

  subject {
    common_name  = var.backend_domain_name
    organization = var.project_name
  }

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}