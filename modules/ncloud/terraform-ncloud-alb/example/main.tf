module "alb" {
  source = "../"

  name           = "seoul-dev-example"
  description    = "tftest_lb description"
  network_type   = "PUBLIC"
  type           = "APPLICATION"
  subnet_no_list = ["20002"]
  idle_timeout   = 300

  listeners = {
    http = {
      protocol           = "HTTP"
      port               = 80
      target_group_index = 0
    }
  }

  target_groups = [
    {
      name        = "seoul-dev-example"
      vpc_no      = var.vpc_id
      protocol    = "HTTP"
      target_type = "VSVR"
      port        = 32000
      description = "for test"
      health_check = {
        protocol       = "HTTP"
        http_method    = "GET"
        port           = 32000
        url_path       = "/healthz"
        cycle          = 30
        up_threshold   = 3
        down_threshold = 3
      }
      algorithm_type = "RR"
    }
  ]
}