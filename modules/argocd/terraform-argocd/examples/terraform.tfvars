defaults = {
  argocd_namespace = "devops"
}

repos = {
  gitops = {
    repo     = "https://github.com/example/gitops.git"
    name     = "gitops"
    username = "changeme"
    password = "changeme"
    insecure = false
  }
}

projects = {
  kube-system = {
    project_name = "kube-system"
    description  = "cluster add-ons"
    source_repos = ["https://github.com/example/gitops.git"]
    destinations = [
      {
        server    = "https://kubernetes.default.svc"
        namespace = "kube-system"
      }
    ]
  }

  monitor = {
    project_name = "monitor"
    description  = "monitoring stack"
    source_repos = ["https://github.com/example/gitops.git"]
    destinations = [
      {
        server    = "https://kubernetes.default.svc"
        namespace = "monitor"
      },
      {
        server    = "https://kubernetes.default.svc"
        namespace = "kube-system"
      }
    ]

    # Prometheus CRDs are cluster scoped, everything else stays namespaced.
    namespace_resource_blacklist = [
      {
        group = "apiextensions.k8s.io"
        kind  = "CustomResourceDefinition"
      }
    ]

    orphaned_resources = {
      warn = true
    }

    roles = [
      {
        name     = "readonly"
        policies = ["p, proj:monitor:readonly, applications, get, monitor/*, allow"]
        groups   = ["monitor-viewers"]
      }
    ]
  }
}

apps = {
  prometheus = {
    name            = "prometheus"
    project         = "monitor"
    repo_url        = "https://github.com/example/gitops.git"
    path            = "app/monitor/prometheus"
    target_revision = "main"
    namespace       = "kube-system"

    prune        = true
    self_heal    = true
    sync_options = ["CreateNamespace=true", "ServerSideApply=true"]

    retry = {
      limit = "5"
      backoff = {
        duration     = "30s"
        factor       = "2"
        max_duration = "5m"
      }
    }

    ignore_differences = [
      {
        group         = "apps"
        kind          = "Deployment"
        json_pointers = ["/spec/replicas"]
      }
    ]
  }

  # Multi-source application: a chart from one repo, values from another.
  grafana = {
    name    = "grafana"
    project = "monitor"

    sources = [
      {
        repo_url        = "https://grafana.github.io/helm-charts"
        chart           = "grafana"
        target_revision = "9.4.7"
        helm = {
          value_files = ["$values/app/monitor/grafana/values.yaml"]
        }
      },
      {
        repo_url        = "https://github.com/example/gitops.git"
        target_revision = "main"
        ref             = "values"
      }
    ]

    namespace = "monitor"
    prune     = true
    self_heal = true
  }
}
