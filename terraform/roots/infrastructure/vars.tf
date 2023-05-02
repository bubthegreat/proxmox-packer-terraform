variable "aws_region" {
    type = string
}

variable "aws_access_key" {
    type = string
    sensitive = true
}

variable "aws_secret_key" {
    type = string
    sensitive = true
}

variable "acme_email" {
    type = string
}

variable "cluster_issuer_name" {
    type = string
    default = "letsencrypt-prod"
}

variable "cert_manager_secret_key" {
    type = string
}

variable "cert_manager_secret_name" {
    type = string
}

variable "cert_manager_namespace" {
    type = string
    default = "cert-manager"
}

variable "cert_manager_managed_domains" {
    type = list(string)
}

variable "https_redirect_middleware_name" {
    type = string
    default = "redirect-https"
}

variable "https_redirect_middleware_namespace" {
    type = string
    default = "default"
}
