output "lb_id" {
  description = "Load Balancer ID"
  value       = oci_load_balancer_load_balancer.app_lb.id
}

output "lb_public_ip" {
  description = "Load Balancer Public IP Address"
  value       = oci_load_balancer_load_balancer.app_lb.ip_address_details[0].ip_address
}

output "lb_details" {
  description = "Load Balancer Public IP Address"
  value       = oci_load_balancer_load_balancer.app_lb
}

output "lb_shape" {
  description = "Load Balancer Shape"
  value       = oci_load_balancer_load_balancer.app_lb.shape
}

output "backend_set_name" {
  description = "Backend Set Name"
  value       = oci_load_balancer_backend_set.app_backend_set.name
}