

data "external" "myipaddr" {
  program = ["bash", "-c", "curl -s 'https://ipinfo.io/json'"]
}

# module foreach var.cert_manager_managed_domains
module "cert_manager_managed_domain" {
    for_each = toset(var.cert_manager_managed_domains)
    source = "../../modules/cert_manager_managed_domain"
    domain_name = each.key
    public_cluster_ip = data.external.myipaddr.result.ip
}

resource "aws_iam_user" "cert_manager_user" {
  name = "svc-cert-manager" # Needs to be from var
}

resource "aws_iam_access_key" "my_access_key" {
  user = aws_iam_user.cert_manager_user.name
}

# TODO: This policy needs to be pared down to just the domain that this is for
# so you don't have a service account that can modify all your domains.
resource "aws_iam_user_policy" "cert_manager_user_policy" {
  name = "cert-manager-policy"
  user = aws_iam_user.cert_manager_user.name
policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/*"
    },
    {
      "Effect": "Allow",
      "Action": "route53:ListHostedZonesByName",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    annotations = {
      name = var.cert_manager_namespace
    }
    name = var.cert_manager_namespace
  }
}

resource "kubernetes_secret" "cert_manager_secret" {
    depends_on = [
      kubernetes_namespace.cert_manager
    ]
    metadata {
      name = var.cert_manager_secret_name
      namespace = var.cert_manager_namespace
    }
    type = "Opaque"
    data = {
        "${var.cert_manager_secret_name}": aws_iam_access_key.my_access_key.secret
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
                            "region": var.aws_region, 
                            "secretAccessKeySecretRef": {
                                "name": var.cert_manager_secret_name, 
                                "key": var.cert_manager_secret_name
                            }, 
                            "accessKeyID": aws_iam_access_key.my_access_key.id
                        }
                    }, 
                    "selector": {
                        "dnsZones": var.cert_manager_managed_domains
                    }
                }]
            }
        }, 
        "apiVersion": "cert-manager.io/v1", 
        "metadata": {
            "name": var.cluster_issuer_name
        }
    })
}

resource "kubernetes_manifest" "https_redirect_middleware" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata" = {
      "name"      = var.https_redirect_middleware_name
      "namespace" = var.https_redirect_middleware_namespace
    }
    "spec" = {
      "redirectScheme" = {
        "scheme" = "https"
        "permanent" = "true"
      }
    }
  }
}
