
resource "helm_release" "stakater_reloader" {
  name       = "reloader"
  chart      = "reloader"
  repository = "https://stakater.github.io/stakater-charts"
  namespace = "reloader"
  version = "1.0.24"
  create_namespace = true
}
