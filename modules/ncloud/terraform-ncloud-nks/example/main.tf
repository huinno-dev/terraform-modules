module "nks" {
  source = "../"

  name            = "seoul-dev-example"
  hypervisor_code = "KVM"
  cluster_type    = "250"
  cluster_version = "1.31"
  key_name        = "seoul-dev-example"
  vpc_id          = "10001"

  private_subnet_id   = "20001"
  lb_subnet_id        = "20002"
  public_lb_subnet_id = "20003"
  az                  = "KR-1"
  network_plugin      = "cilium"

  enable_asg = true
  node_count = 1
  min        = 1
  max        = 2

  server_image_name = "ubuntu-22.04"
  storage_size      = 100

  selectors = {
    filter1 = {
      name  = "product_type"
      value = ["STAND"]
    }
    filter2 = {
      name  = "cpu_count"
      value = ["2"]
    }
    filter3 = {
      name  = "memory_size"
      value = ["8GB"]
    }
  }

  node_labels = [
    {
      key   = "role"
      value = "worker"
    },
  ]
}
