variable "domain_name" {
  type      = string
}

variable "cert_manager_secret_name" {
  type      = string
}

variable "host_name" {
    type = string
    default = "whoami"
}

variable "whoami_tls_port" {
    type = number
    default = 5678
}

variable "whoami_target_port" {
    type = number
    default = 80
}

variable "whoami_service_type" {
    type = string
    default = "ClusterIP"
}

variable "https_redirect_middleware_namespace" {
    type = string
    default = "default"
}

variable "https_redirect_middleware_name" {
    type = string
    default = "redirect-https"
}

variable "cluster_issuer_name" {
    type = string
    default = "letsencrypt-prod"
}

