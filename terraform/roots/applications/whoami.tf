variable "whoami_domains" {
    type = list(string)
}

module "whoami_site" {
    for_each = toset(var.whoami_domains)
    source = "../../modules/whoami_site"
    domain_name = each.key
    cert_manager_secret_name = "cert-manager-secret-access-key"
}
