resource "helm_release" "this" {
  for_each = local.apps

  name      = try(each.value.name, each.key)
  chart     = each.value.chart
  version   = try(each.value.version, null)
  namespace = try(each.value.namespace, null)

  repository           = try(each.value.repository, null)
  repository_key_file  = try(each.value.repository_key_file, null)
  repository_cert_file = try(each.value.repository_cert_file, null)
  repository_ca_file   = try(each.value.repository_ca_file, null)
  repository_username  = try(each.value.repository_username, null)
  repository_password  = try(each.value.repository_password, null)
  pass_credentials     = try(each.value.pass_credentials, null)
  devel                = try(each.value.devel, null)
  keyring              = try(each.value.keyring, null)
  verify               = try(each.value.verify, null)

  create_namespace           = try(each.value.create_namespace, null)
  description                = try(each.value.description, null)
  atomic                     = try(each.value.atomic, null)
  cleanup_on_fail            = try(each.value.cleanup_on_fail, null)
  dependency_update          = try(each.value.dependency_update, null)
  disable_crd_hooks          = try(each.value.disable_crd_hooks, null)
  disable_openapi_validation = try(each.value.disable_openapi_validation, null)
  disable_webhooks           = try(each.value.disable_webhooks, null)
  force_update               = try(each.value.force_update, null)
  lint                       = try(each.value.lint, null)
  max_history                = try(each.value.max_history, null)
  recreate_pods              = try(each.value.recreate_pods, null)
  render_subchart_notes      = try(each.value.render_subchart_notes, null)
  replace                    = try(each.value.replace, null)
  reset_values               = try(each.value.reset_values, null)
  reuse_values               = try(each.value.reuse_values, null)
  skip_crds                  = try(each.value.skip_crds, null)
  take_ownership             = try(each.value.take_ownership, null)
  timeout                    = try(each.value.timeout, null)
  upgrade_install            = try(each.value.upgrade_install, null)
  wait                       = try(each.value.wait, null)
  wait_for_jobs              = try(each.value.wait_for_jobs, null)

  values        = try(each.value.values, null)
  set           = local.set[each.key]
  set_list      = local.set_list[each.key]
  set_sensitive = local.set_sensitive[each.key]

  postrender = try(each.value.postrender, null)

  timeouts = try(each.value.timeouts, null)
}
