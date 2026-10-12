module "helm" {
  source = "../"

  defaults = {
    atomic          = true
    cleanup_on_fail = true
    wait            = true
    timeout         = 600
  }

  apps = {
    traefik = {
      name             = "traefik"
      repository       = "https://traefik.github.io/charts"
      chart            = "traefik"
      version          = "41.6.1"
      namespace        = "traefik"
      create_namespace = true

      values = [
        file("charts/traefik.yaml")
      ]

      set = [
        {
          name  = "log.format"
          value = "json"
        },
      ]
    }
  }
}
