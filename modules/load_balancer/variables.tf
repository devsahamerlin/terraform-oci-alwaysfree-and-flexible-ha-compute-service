variable "name" {
  description = "Name of the load balancer"
  type        = string
}

variable "compartment_id" {
  description = "OCI Compartment OCID"
  type        = string
}

variable "subnet_id" {
  description = "List of subnet IDs for the load balancer"
  type        = list(string)
}

variable "backend_vm_ips" {
  description = "List of backend VM private IPs"
  type        = list(string)
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "app_backend_set_health_checker_port" {
  description = "Port for the health checker"
  type        = number
}

variable "app_backend_set_health_checker_url_path" {
  description = "URL path for the health checker"
  type        = string
}

variable "app_backends_port" {
  description = "Port for the backend servers"
  type        = number
}

variable "backend_set_backend_max_connections" {
  description = "Maximum connections for the backend set"
  type        = number
}

variable "is_private_lb" {
  description = "Whether the load balancer is private"
  type        = bool
}

variable "path_routes_1" {
  description = "Path route 1"
  type        = string
}

variable "path_routes_2" {
  description = "Path route 2"
  type        = string
}

variable "is_ssl_enabled" {
  description = "Enable SSL/HTTPS for the load balancer listener"
  type        = bool
  default     = false
}

variable "certificate_name" {
  description = "Name of the SSL certificate"
  type        = string
  default     = null
}

variable "certificate_private_key" {
  description = "Private key for the SSL certificate (PEM format)"
  type        = string
  default     = null
  sensitive   = true
}

variable "certificate_public_cert" {
  description = "Public certificate for the SSL certificate (PEM format)"
  type        = string
  default     = null
}

variable "lb_listener_port" {
  description = "Port for the load balancer listener"
  type        = number
  default     = 80
}
