variable "defaults" {
  description = "Map of default values applied underneath every entry of `apps`. Any key valid in an `apps` entry is valid here."
  type        = any
  default     = {}
}

variable "apps" {
  description = <<-EOT
    Map of Helm releases to manage, keyed by an arbitrary name. The map key is
    used as the release name unless the entry sets `name`.

    `chart` is required. Every other `helm_release` argument is optional and
    passed straight through: `version`, `namespace`, `create_namespace`,
    `repository` (plus `repository_username` / `repository_password` /
    `repository_ca_file` / `repository_cert_file` / `repository_key_file` /
    `pass_credentials`), `values`, `devel`, `keyring`, `verify`, `description`,
    `atomic`, `cleanup_on_fail`, `dependency_update`, `disable_crd_hooks`,
    `disable_openapi_validation`, `disable_webhooks`, `force_update`, `lint`,
    `max_history`, `recreate_pods`, `render_subchart_notes`, `replace`,
    `reset_values`, `reuse_values`, `skip_crds`, `take_ownership`, `timeout`,
    `upgrade_install`, `wait`, `wait_for_jobs`.

    `set`, `set_sensitive` and `set_list` take a list of objects (a map of
    objects is also accepted and flattened):

        set = [{ name = "controller.replicaCount", value = "2" }]

    `postrender` takes `{ binary_path, args }` and `timeouts` takes
    `{ create, read, update, delete }`.
  EOT
  type        = any
  default     = {}
}
