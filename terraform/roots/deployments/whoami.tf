locals {
    hostname = "whoami" # Needs to be from var
    domain = "bub.ninja" # Needs to be from var
    whoami_tls_port = 5678 # Needs to be from var
    whoami_target_port = 80 # Needs to be from var
    whoami_service_type = "ClusterIP" # Needs to be from var
    redirect_middleware_namespace = "default" # Needs to be from var
    redirect_middleware_name = "redirect-https" # Needs to be from var

}

resource "kubernetes_manifest" "whoami_redirect_middleware" {
  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "Middleware"
    "metadata" = {
      "name"      = local.redirect_middleware_name
      "namespace" = local.redirect_middleware_namespace
    }
    "spec" = {
      "redirectScheme" = {
        "scheme" = "https"
        "permanent" = "true"
      }
    }
  }
}

resource "kubernetes_service" "whoami_service" {
  metadata {
    name = local.hostname
  }
  spec {
    selector = {
      app = local.hostname
    }
    port {
      port        = local.whoami_tls_port
      target_port = local.whoami_target_port
    }
    type = local.whoami_service_type
  }
}

resource "kubernetes_ingress_v1" "whoami_ingress_tls" {
  metadata {
    name = "${local.hostname}-tls-ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "traefik"
      "cert-manager.io/cluster-issuer" = var.cluster_issuer_name
      "traefik.ingress.kubernetes.io/router.middlewares" = "${local.redirect_middleware_namespace}-${local.redirect_middleware_name}@kubernetescrd"
    }
  }

  spec {
    rule {
        host = "${local.hostname}.${local.domain}"
        http {
            path {
                path = "/"
                path_type = "ImplementationSpecific"
                backend {
                    service {
                        name = local.hostname
                        port { 
                            number = local.whoami_tls_port
                        }
                    }
                }
            }
        }
    }

    tls {
        secret_name = "${local.hostname}-tls"
        hosts = [
            "${local.hostname}.${local.domain}"
        ]
    }
  }
}


resource "kubernetes_deployment" "whoami_deployment" {
    metadata {
        name = local.hostname
    }

    spec {
        replicas = 3
        selector {
            match_labels = {
                app = local.hostname
            }
        }

        template {
            metadata {
                labels = {
                    app = local.hostname
                }
            }

            spec {
                container {
                    image = "containous/whoami:v1.5.0"
                    name  = local.hostname
                    port {
                        container_port = local.whoami_target_port
                    }
                    
                }
            }
        }
    }
}
