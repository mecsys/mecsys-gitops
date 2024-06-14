locals {
  environment       = "production"
  account_id        = "123456789"
  profile           = "mecsys-open-prd"
  shortname_profile = "open"

  default_tags = {
    Environment = local.environment
    Terraform   = "true"
    Scost       = "open-x"
  }
}
