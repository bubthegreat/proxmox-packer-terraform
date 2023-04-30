variable "aws_region" {
    type = string
}

variable "aws_domain" {
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