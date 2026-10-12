locals {
  # Per-entry values with `var.defaults` underneath, so every argument below is
  # a single lookup instead of a two-level `try`.
  repos    = { for k, v in var.repos : k => merge(var.defaults, v) }
  projects = { for k, v in var.projects : k => merge(var.defaults, v) }
  apps     = { for k, v in var.apps : k => merge(var.defaults, v) }

  # An application may carry several sources. The flat `repo_url` / `path` /
  # `target_revision` keys stay supported as the single-source shorthand.
  app_sources = {
    for k, v in local.apps : k => try(v.sources, [{
      repo_url        = try(v.repo_url, null)
      path            = try(v.path, null)
      chart           = try(v.chart, null)
      target_revision = try(v.target_revision, null)
    }])
  }

  # A project restricted to one repo was the only option before; `source_repos`
  # now takes the full list.
  project_source_repos = {
    for k, v in local.projects : k => try(v.source_repos, [v.repo], null)
  }
}
