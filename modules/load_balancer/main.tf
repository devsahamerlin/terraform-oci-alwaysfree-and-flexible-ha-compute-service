# Flexible Load Balancer (Always Free Tier - 10 Mbps)
resource "oci_load_balancer_load_balancer" "app_lb" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-${var.environment}-${var.name}-lb"
  shape          = "flexible"

  # Always Free tier configuration
  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 10
  }

  subnet_ids = var.subnet_id

  is_private = var.is_private_lb

  freeform_tags = var.tags
}

# Backend Set for Application
resource "oci_load_balancer_backend_set" "app_backend_set" {
  load_balancer_id        = oci_load_balancer_load_balancer.app_lb.id
  name                    = "app-${var.name}-set"
  policy                  = "ROUND_ROBIN" #"LEAST_CONNECTIONS"
  backend_max_connections = var.backend_set_backend_max_connections

  health_checker {
    protocol          = "HTTP"
    port              = var.app_backend_set_health_checker_port
    url_path          = var.app_backend_set_health_checker_url_path
    return_code       = 200
    interval_ms       = 15000
    timeout_in_millis = 5000
    retries           = 5
  }

  session_persistence_configuration {
    cookie_name = "APP_SESSION"
  }
}

# Backend servers (VMs running containers)
resource "oci_load_balancer_backend" "app_backends" {
  count            = length(var.backend_vm_ips)
  load_balancer_id = oci_load_balancer_load_balancer.app_lb.id
  backendset_name  = oci_load_balancer_backend_set.app_backend_set.name
  ip_address       = var.backend_vm_ips[count.index]
  port             = var.app_backends_port
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# # Redirect Rule Set (HTTP -> HTTPS)
# resource "oci_load_balancer_rule_set" "http_to_https_redirect" {
#   count            = var.is_ssl_enabled ? 1 : 0
#   load_balancer_id = oci_load_balancer_load_balancer.app_lb.id
#   name             = "http_to_https_redirect"
#
#   items {
#     action = "REDIRECT"
#     conditions {
#       attribute_name  = "PATH"
#       attribute_value = "/"
#       operator        = "PREFIX_MATCH"
#     }
#     description = "Redirect HTTP to HTTPS"
#     redirect_uri {
#       protocol = "https"
#       port     = var.lb_listener_port
#       host     = "{host}"
#       path     = "{path}"
#       query    = "{query}"
#     }
#     response_code = 301
#   }
# }
#
# # HTTP Listener (redirects to HTTPS)
# resource "oci_load_balancer_listener" "http_listener" {
#   load_balancer_id         = oci_load_balancer_load_balancer.app_lb.id
#   name                     = "http-${var.name}-listener"
#   default_backend_set_name = oci_load_balancer_backend_set.app_backend_set.name
#   port                     = 80
#   protocol                 = "HTTP"
#   path_route_set_name      = oci_load_balancer_path_route_set.app_path_routes.name
#   rule_set_names           = var.is_ssl_enabled ? [oci_load_balancer_rule_set.http_to_https_redirect[0].name] : []
#
#   connection_configuration {
#     idle_timeout_in_seconds = 300
#   }
# }

# HTTPS Listener (requires SSL certificate)
resource "oci_load_balancer_listener" "https_listener" {
  count                    = var.is_ssl_enabled ? 1 : 0
  load_balancer_id         = oci_load_balancer_load_balancer.app_lb.id
  name                     = "https-${var.name}-listener"
  default_backend_set_name = oci_load_balancer_backend_set.app_backend_set.name
  port                     = var.lb_listener_port
  protocol                 = "HTTP"
  path_route_set_name      = oci_load_balancer_path_route_set.app_path_routes.name

  connection_configuration {
    idle_timeout_in_seconds = 300
  }

  ssl_configuration {
    certificate_name        = oci_load_balancer_certificate.certificate[0].certificate_name
    verify_peer_certificate = false
  }
}

# Path Route Set for different application paths
resource "oci_load_balancer_path_route_set" "app_path_routes" {
  load_balancer_id = oci_load_balancer_load_balancer.app_lb.id
  name             = "app-${var.name}-path-routes"

  # ACME challenge route - goes to your backend
  path_routes {
    path = "/.well-known/acme-challenge/*"
    path_match_type {
      match_type = "PREFIX_MATCH"
    }
    backend_set_name = oci_load_balancer_backend_set.app_backend_set.name
  }

  path_routes {
    path = var.path_routes_2
    path_match_type {
      match_type = "EXACT_MATCH"
    }
    backend_set_name = oci_load_balancer_backend_set.app_backend_set.name
  }

  path_routes {
    path = var.path_routes_1
    path_match_type {
      match_type = "PREFIX_MATCH"
    }
    backend_set_name = oci_load_balancer_backend_set.app_backend_set.name
  }
}

resource "oci_load_balancer_certificate" "certificate" {
  count              = var.is_ssl_enabled ? 1 : 0
  load_balancer_id   = oci_load_balancer_load_balancer.app_lb.id
  certificate_name   = var.certificate_name
  private_key        = var.certificate_private_key
  public_certificate = var.certificate_public_cert

  lifecycle {
    create_before_destroy = true
  }
}
