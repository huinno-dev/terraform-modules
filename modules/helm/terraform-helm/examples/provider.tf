# helm provider 3.x takes `kubernetes` as an attribute, not a block.
provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}
