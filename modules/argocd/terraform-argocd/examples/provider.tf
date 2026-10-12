provider "argocd" {
  server_addr = "argocd-devops.example.com:443"
  username    = var.argocd_username
  password    = var.argocd_password
  insecure    = false
  grpc_web    = true
}