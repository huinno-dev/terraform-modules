terraform {
  required_version = ">= 1.5"

  required_providers {
    # `kubernetes_annotations` was added in 2.10.0.
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
  }
}
