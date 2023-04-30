

locals {
    secret_name = "cert-manager-secret-access-key" # Needs to be from var
    secret_key = "svc-cert-manager-secret-key" # Needs to be from var
    cert_manager_namespace = "cert-manager" # Needs to be from var
    aws_region = "us-west-2" # Needs to be from var
    cluster_issuer_name = "letsencrypt-prod" # Needs to be from var
    
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    annotations = {
      name = local.cert_manager_namespace
    }
    name = local.cert_manager_namespace
  }
}

resource "kubernetes_secret" "cert_manager_secret" {
    depends_on = [
      kubernetes_namespace.cert_manager
    ]
    metadata {
      name = local.secret_name
      namespace = local.cert_manager_namespace
    }
    type = "Opaque"
    data = {
        "${local.secret_key}": aws_iam_access_key.my_access_key.secret
    }
}


resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  namespace = "cert-manager"
  version = "1.11.1"
  create_namespace = true

  set {
    name = "installCRDs"
    value = true
  }
}

resource "time_sleep" "wait" {
  create_duration = "60s"

  depends_on = [helm_release.cert_manager]
}


resource "kubectl_manifest" "cluster_issuer_prod" {
    depends_on = [
      kubernetes_secret.cert_manager_secret,
      kubernetes_namespace.cert_manager, 
      helm_release.cert_manager,
      time_sleep.wait
    ]
    yaml_body = yamlencode({
        "kind": "ClusterIssuer", 
        "spec": {
            "acme": {
                "privateKeySecretRef": {
                    "name": "prod-route53-tls-key" # Needs to be from var
                }, 
                "server": "https://acme-v02.api.letsencrypt.org/directory",  # Needs to be from var
                "email": var.acme_email, 
                "solvers": [{
                    "dns01": { # Needs to be from var - we would want to add support for acme
                        "route53": {
                            "region": local.aws_region, 
                            "secretAccessKeySecretRef": {
                                "name": local.secret_name, 
                                "key": local.secret_key
                            }, 
                            "accessKeyID": aws_iam_access_key.my_access_key.id
                        }
                    }, 
                    "selector": {
                        "dnsZones": [
                            "${var.aws_domain}"
                        ]
                    }
                }]
            }
        }, 
        "apiVersion": "cert-manager.io/v1", 
        "metadata": {
            "name": local.cluster_issuer_name
        }
    })
}