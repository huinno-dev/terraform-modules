variable "defaults" {
  description = "Map of default values which will be used for each item of `repos`, `projects` and `apps`."
  type        = any
  default     = {}
}

variable "repos" {
  description = <<-EOT
    Map of repositories to register, keyed by an arbitrary name. `repo` is
    required. Optional: `name`, `project`, `type` (default `git`), `insecure`
    (default `false`), `enable_lfs`, `enable_oci`, `depth`, `username`,
    `password`, `bearer_token`, `ssh_private_key`, `tls_client_cert_data`,
    `tls_client_cert_key`, `githubapp_id`, `githubapp_installation_id`,
    `githubapp_private_key`, `githubapp_enterprise_base_url`,
    `use_azure_workload_identity`, `proxy`, `no_proxy`.
  EOT
  type        = any
  default     = {}
}

variable "projects" {
  description = <<-EOT
    Map of AppProjects to create, keyed by an arbitrary name. The key is used
    as the project name unless the entry sets `project_name`.

    Optional: `argocd_namespace`, `labels`, `annotations`, `description`,
    `source_repos` (list; falls back to `[repo]`), `source_namespaces`,
    `signature_keys`, `destinations`, `destination_service_accounts`,
    `cluster_resource_whitelist` (defaults to group/kind `*`),
    `cluster_resource_blacklist`, `namespace_resource_whitelist`,
    `namespace_resource_blacklist`, `orphaned_resources` (`warn`, `ignore`),
    `roles` (`name`, `policies`, `description`, `groups`) and `sync_windows`.
  EOT
  type        = any
  default     = {}
}

variable "apps" {
  description = <<-EOT
    Map of Applications to create, keyed by an arbitrary name. The key is used
    as the application name unless the entry sets `name`.

    A single source is declared with the flat `repo_url` / `path` / `chart` /
    `target_revision` keys. For multiple sources use `sources`, a list of
    objects taking the same keys plus `ref`, `name` and the nested `helm`,
    `kustomize`, `directory` and `plugin` configuration.

    Destination: `server` (defaults to `default_k8s_server`),
    `destination_name`, `namespace`.

    Sync: `prune`, `self_heal`, `allow_empty`, `sync_options`, `retry`
    (`limit` and `backoff`), `managed_namespace_metadata`.

    Also supported: `project`, `argocd_namespace`, `labels`, `annotations`,
    `revision_history_limit`, `info`, `ignore_differences`, `cascade`, `wait`,
    `validate`, `timeouts`.
  EOT
  type        = any
  default     = {}
}

variable "default_k8s_server" {
  description = "Cluster API address used when an application or project destination does not set `server`."
  type        = string
  default     = "https://kubernetes.default.svc"
}
