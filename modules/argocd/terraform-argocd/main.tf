resource "argocd_repository" "this" {
  for_each = local.repos

  repo    = each.value.repo
  name    = try(each.value.name, null)
  project = try(each.value.project, null)
  type    = try(each.value.type, "git")

  insecure   = try(each.value.insecure, false)
  enable_lfs = try(each.value.enable_lfs, null)
  enable_oci = try(each.value.enable_oci, null)
  depth      = try(each.value.depth, null)

  username             = try(each.value.username, null)
  password             = try(each.value.password, null)
  bearer_token         = try(each.value.bearer_token, null)
  ssh_private_key      = try(each.value.ssh_private_key, null)
  tls_client_cert_data = try(each.value.tls_client_cert_data, null)
  tls_client_cert_key  = try(each.value.tls_client_cert_key, null)

  githubapp_id                  = try(each.value.githubapp_id, null)
  githubapp_installation_id     = try(each.value.githubapp_installation_id, null)
  githubapp_private_key         = try(each.value.githubapp_private_key, null)
  githubapp_enterprise_base_url = try(each.value.githubapp_enterprise_base_url, null)

  use_azure_workload_identity = try(each.value.use_azure_workload_identity, null)

  proxy    = try(each.value.proxy, null)
  no_proxy = try(each.value.no_proxy, null)
}

resource "argocd_project" "this" {
  for_each = local.projects

  metadata {
    name        = try(each.value.project_name, each.key)
    namespace   = try(each.value.argocd_namespace, null)
    labels      = try(each.value.labels, null)
    annotations = try(each.value.annotations, null)
  }

  spec {
    description       = try(each.value.description, null)
    source_repos      = local.project_source_repos[each.key]
    source_namespaces = try(each.value.source_namespaces, null)
    signature_keys    = try(each.value.signature_keys, null)

    dynamic "destination" {
      for_each = try(each.value.destinations, [])
      content {
        server    = try(destination.value.server, var.default_k8s_server)
        name      = try(destination.value.name, null)
        namespace = destination.value.namespace
      }
    }

    dynamic "destination_service_account" {
      for_each = try(each.value.destination_service_accounts, [])
      content {
        default_service_account = destination_service_account.value.default_service_account
        server                  = try(destination_service_account.value.server, null)
        namespace               = try(destination_service_account.value.namespace, null)
      }
    }

    dynamic "cluster_resource_whitelist" {
      for_each = try(each.value.cluster_resource_whitelist, [{ group = "*", kind = "*" }])
      content {
        group = try(cluster_resource_whitelist.value.group, null)
        kind  = try(cluster_resource_whitelist.value.kind, null)
        name  = try(cluster_resource_whitelist.value.name, null)
      }
    }

    dynamic "cluster_resource_blacklist" {
      for_each = try(each.value.cluster_resource_blacklist, [])
      content {
        group = try(cluster_resource_blacklist.value.group, null)
        kind  = try(cluster_resource_blacklist.value.kind, null)
        name  = try(cluster_resource_blacklist.value.name, null)
      }
    }

    dynamic "namespace_resource_whitelist" {
      for_each = try(each.value.namespace_resource_whitelist, [])
      content {
        group = try(namespace_resource_whitelist.value.group, null)
        kind  = try(namespace_resource_whitelist.value.kind, null)
      }
    }

    dynamic "namespace_resource_blacklist" {
      for_each = try(each.value.namespace_resource_blacklist, [])
      content {
        group = try(namespace_resource_blacklist.value.group, null)
        kind  = try(namespace_resource_blacklist.value.kind, null)
      }
    }

    dynamic "orphaned_resources" {
      for_each = try([each.value.orphaned_resources], [])
      content {
        warn = try(orphaned_resources.value.warn, null)

        dynamic "ignore" {
          for_each = try(orphaned_resources.value.ignore, [])
          content {
            group = try(ignore.value.group, null)
            kind  = try(ignore.value.kind, null)
            name  = try(ignore.value.name, null)
          }
        }
      }
    }

    dynamic "role" {
      for_each = try(each.value.roles, [])
      content {
        name        = role.value.name
        policies    = role.value.policies
        description = try(role.value.description, null)
        groups      = try(role.value.groups, null)
      }
    }

    dynamic "sync_window" {
      for_each = try(each.value.sync_windows, [])
      content {
        kind             = try(sync_window.value.kind, null)
        schedule         = try(sync_window.value.schedule, null)
        duration         = try(sync_window.value.duration, null)
        timezone         = try(sync_window.value.timezone, null)
        applications     = try(sync_window.value.applications, null)
        namespaces       = try(sync_window.value.namespaces, null)
        clusters         = try(sync_window.value.clusters, null)
        manual_sync      = try(sync_window.value.manual_sync, null)
        use_and_operator = try(sync_window.value.use_and_operator, null)
      }
    }
  }
}

resource "argocd_application" "this" {
  for_each = local.apps

  cascade  = try(each.value.cascade, null)
  wait     = try(each.value.wait, null)
  validate = try(each.value.validate, null)

  metadata {
    name        = try(each.value.name, each.key)
    namespace   = try(each.value.argocd_namespace, null)
    labels      = try(each.value.labels, null)
    annotations = try(each.value.annotations, null)
  }

  spec {
    project                = try(each.value.project, null)
    revision_history_limit = try(each.value.revision_history_limit, null)

    dynamic "source" {
      for_each = local.app_sources[each.key]
      content {
        repo_url        = source.value.repo_url
        path            = try(source.value.path, null)
        chart           = try(source.value.chart, null)
        target_revision = try(source.value.target_revision, null)
        ref             = try(source.value.ref, null)
        name            = try(source.value.name, null)

        dynamic "helm" {
          for_each = try([source.value.helm], [])
          content {
            release_name               = try(helm.value.release_name, null)
            values                     = try(helm.value.values, null)
            value_files                = try(helm.value.value_files, null)
            version                    = try(helm.value.version, null)
            pass_credentials           = try(helm.value.pass_credentials, null)
            skip_crds                  = try(helm.value.skip_crds, null)
            skip_schema_validation     = try(helm.value.skip_schema_validation, null)
            ignore_missing_value_files = try(helm.value.ignore_missing_value_files, null)

            dynamic "parameter" {
              for_each = try(helm.value.parameters, [])
              content {
                name         = try(parameter.value.name, null)
                value        = try(parameter.value.value, null)
                force_string = try(parameter.value.force_string, null)
              }
            }

            dynamic "file_parameter" {
              for_each = try(helm.value.file_parameters, [])
              content {
                name = file_parameter.value.name
                path = file_parameter.value.path
              }
            }
          }
        }

        dynamic "kustomize" {
          for_each = try([source.value.kustomize], [])
          content {
            version            = try(kustomize.value.version, null)
            name_prefix        = try(kustomize.value.name_prefix, null)
            name_suffix        = try(kustomize.value.name_suffix, null)
            images             = try(kustomize.value.images, null)
            common_labels      = try(kustomize.value.common_labels, null)
            common_annotations = try(kustomize.value.common_annotations, null)

            dynamic "patches" {
              for_each = try(kustomize.value.patches, [])
              content {
                patch   = try(patches.value.patch, null)
                path    = try(patches.value.path, null)
                options = try(patches.value.options, null)

                dynamic "target" {
                  for_each = try([patches.value.target], [])
                  content {
                    group               = try(target.value.group, null)
                    version             = try(target.value.version, null)
                    kind                = try(target.value.kind, null)
                    name                = try(target.value.name, null)
                    namespace           = try(target.value.namespace, null)
                    label_selector      = try(target.value.label_selector, null)
                    annotation_selector = try(target.value.annotation_selector, null)
                  }
                }
              }
            }
          }
        }

        dynamic "directory" {
          for_each = try([source.value.directory], [])
          content {
            recurse = try(directory.value.recurse, null)
            include = try(directory.value.include, null)
            exclude = try(directory.value.exclude, null)

            dynamic "jsonnet" {
              for_each = try([directory.value.jsonnet], [])
              content {
                libs = try(jsonnet.value.libs, null)

                dynamic "ext_var" {
                  for_each = try(jsonnet.value.ext_vars, [])
                  content {
                    name  = try(ext_var.value.name, null)
                    value = try(ext_var.value.value, null)
                    code  = try(ext_var.value.code, null)
                  }
                }

                dynamic "tla" {
                  for_each = try(jsonnet.value.tlas, [])
                  content {
                    name  = try(tla.value.name, null)
                    value = try(tla.value.value, null)
                    code  = try(tla.value.code, null)
                  }
                }
              }
            }
          }
        }

        dynamic "plugin" {
          for_each = try([source.value.plugin], [])
          content {
            name = try(plugin.value.name, null)

            dynamic "env" {
              for_each = try(plugin.value.env, [])
              content {
                name  = try(env.value.name, null)
                value = try(env.value.value, null)
              }
            }
          }
        }
      }
    }

    destination {
      server    = try(each.value.server, var.default_k8s_server)
      name      = try(each.value.destination_name, null)
      namespace = try(each.value.namespace, null)
    }

    dynamic "info" {
      for_each = try(each.value.info, [])
      content {
        name  = try(info.value.name, null)
        value = try(info.value.value, null)
      }
    }

    dynamic "ignore_difference" {
      for_each = try(each.value.ignore_differences, [])
      content {
        group                   = try(ignore_difference.value.group, null)
        kind                    = try(ignore_difference.value.kind, null)
        name                    = try(ignore_difference.value.name, null)
        namespace               = try(ignore_difference.value.namespace, null)
        json_pointers           = try(ignore_difference.value.json_pointers, null)
        jq_path_expressions     = try(ignore_difference.value.jq_path_expressions, null)
        managed_fields_managers = try(ignore_difference.value.managed_fields_managers, null)
      }
    }

    sync_policy {
      sync_options = try(each.value.sync_options, null)

      automated {
        prune       = try(each.value.prune, false)
        self_heal   = try(each.value.self_heal, false)
        allow_empty = try(each.value.allow_empty, false)
      }

      dynamic "retry" {
        for_each = try([each.value.retry], [])
        content {
          limit = try(retry.value.limit, null)

          dynamic "backoff" {
            for_each = try([retry.value.backoff], [])
            content {
              duration     = try(backoff.value.duration, null)
              factor       = try(backoff.value.factor, null)
              max_duration = try(backoff.value.max_duration, null)
            }
          }
        }
      }

      dynamic "managed_namespace_metadata" {
        for_each = try([each.value.managed_namespace_metadata], [])
        content {
          labels      = try(managed_namespace_metadata.value.labels, null)
          annotations = try(managed_namespace_metadata.value.annotations, null)
        }
      }
    }
  }

  timeouts {
    create = try(each.value.timeouts.create, null)
    update = try(each.value.timeouts.update, null)
    delete = try(each.value.timeouts.delete, null)
  }
}
