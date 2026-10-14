variable "name" {
  description = "Ingress name"
  type        = string
  default     = "traefik-alb"
}

variable "namespace" {
  description = "Ingress namespace. Must be the backend Service's namespace"
  type        = string
}

variable "backend_service" {
  description = "Service receiving every request (the ingress controller behind the ALB). Must be NodePort"
  type        = string
  default     = "traefik"
}

variable "backend_port" {
  description = "Service port of `backend_service`"
  type        = number
  default     = 80
}

variable "ingress_class_name" {
  description = "IngressClass of the NKS ALB Ingress Controller"
  type        = string
  default     = "alb"
}

variable "unset_default_ingress_class" {
  description = "Mark `ingress_class_name` as not default. Its install manifest makes it the default class"
  type        = bool
  default     = true
}

variable "lb_name" {
  description = "ALB name (3-30 chars, letters, digits, `-`). Applied on creation only"
  type        = string
  default     = null
}

variable "network_type" {
  description = "`public` or `private`. Changing it recreates the ALB on the gov site"
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private"], var.network_type)
    error_message = "network_type must be public or private."
  }
}

variable "certificate_no" {
  description = "Certificate Manager certificate number(s), comma separated. Null serves HTTP only"
  type        = string
  default     = null
}

variable "ssl_min_version" {
  description = "Minimum TLS version for the HTTPS listener"
  type        = string
  default     = "TLSV12"
}

variable "public_ip_instance_no" {
  description = "Instance number of a pre-created public IP, to keep the ALB address fixed"
  type        = string
  default     = null
}

variable "retain_public_ip" {
  description = "Keep the public IP when the ALB is deleted"
  type        = bool
  default     = true
}

variable "healthcheck_path" {
  description = "Target group health check path"
  type        = string
  default     = "/ping"
}

variable "extra_annotations" {
  description = "Additional annotations; keys are used as is and override the generated ones"
  type        = map(string)
  default     = {}
}

variable "wait_for_load_balancer" {
  description = "Wait until the ALB address is published on the Ingress"
  type        = bool
  default     = true
}
