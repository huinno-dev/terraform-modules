module "argocd" {
  source = "../"

  defaults = var.defaults
  repos    = var.repos
  projects = var.projects
  apps     = var.apps
}
