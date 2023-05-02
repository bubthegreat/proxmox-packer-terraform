resource "kubernetes_service" "whoami_service" {
  metadata {
    name = replace("${var.host_name}.${var.domain_name}", ".", "-")
  }
  spec {
    selector = {
      name = replace("${var.host_name}.${var.domain_name}", ".", "-")
    }
    port {
      port        = var.whoami_tls_port
      target_port = var.whoami_target_port
    }
    type = var.whoami_service_type
  }
}

resource "kubernetes_ingress_v1" "whoami_ingress_tls" {
  metadata {
    name = replace("${var.host_name}-${var.domain_name}-tls-ingress", ".", "-")
    annotations = {
      "kubernetes.io/ingress.class" = "traefik"
      "cert-manager.io/cluster-issuer" = var.cluster_issuer_name
      "traefik.ingress.kubernetes.io/router.middlewares" = "${var.https_redirect_middleware_namespace}-${var.https_redirect_middleware_name}@kubernetescrd"
    }
  }

  spec {
    rule {
        host = "${var.host_name}.${var.domain_name}"
        http {
            path {
                path = "/"
                path_type = "ImplementationSpecific"
                backend {
                    service {
                        name = replace("${var.host_name}.${var.domain_name}", ".", "-")
                        port { 
                            number = var.whoami_tls_port
                        }
                    }
                }
            }
        }
    }

    tls {
        secret_name = replace("${var.host_name}-${var.domain_name}-tls", ".", "-")
        hosts = [
            "${var.host_name}.${var.domain_name}",
            "${var.domain_name}"
        ]
    }
  }
}


resource "kubernetes_deployment" "whoami_deployment" {
    metadata {
        name = replace("${var.host_name}.${var.domain_name}", ".", "-")
    }

    spec {
        replicas = 3
        selector {
            match_labels = {
                name = replace("${var.host_name}.${var.domain_name}", ".", "-")
            }
        }

        template {
            metadata {
                labels = {
                    name = replace("${var.host_name}.${var.domain_name}", ".", "-")
                }
            }

            spec {
                container {
                    image = "containous/whoami:v1.5.0"
                    name  = var.host_name
                    port {
                        container_port = var.whoami_target_port
                    }
                    
                }
            }
        }
    }
}
