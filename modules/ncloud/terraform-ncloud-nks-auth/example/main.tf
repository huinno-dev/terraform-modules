module "nks_auth" {
  source = "../"

  accounts = [
    {
      sub_account_id_no = "<sub-account-id>"
      username          = "developer"
      groups            = ["developers"]
    },
  ]

  # Alternative: let every sub account in and grant access by Sub Account
  # group through RBAC on `ncp-sub-account-group:<group name>`.
  # authenticate_all = true
}
