terraform {
  required_version = ">= 1.5"

  required_providers {
    # The provider moved from the `oboukili` namespace to `argoproj-labs`.
    argocd = {
      source  = "argoproj-labs/argocd"
      version = ">= 7.0"
    }
  }
}
