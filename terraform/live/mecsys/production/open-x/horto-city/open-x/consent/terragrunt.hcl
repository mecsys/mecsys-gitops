# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

locals {
  account_vars           = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars            = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  default_tags           = local.account_vars.locals.default_tags
  profile                = local.account_vars.locals.profile
  environment            = local.account_vars.locals.environment  
  region                 = local.region_vars.locals.region
  bucket_name            = "mecsys-bucket-3"
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git//?ref=tags/v4.1.2"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
  # Providers config
  provider "aws" {
    profile = "${local.profile}"
    region  = "${local.region}"
  }

  terraform {
    required_version = "~> 1.8.3"
  }
EOF
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  # General  
  version     = "2024061401"

  bucket                                = local.bucket_name
  create_bucket                         = true  
  attach_deny_insecure_transport_policy = true
  block_public_acls                     = true
  block_public_policy                   = true
  ignore_public_acls                    = true
  restrict_public_buckets               = true
  force_destroy                         = false

  versioning = {
    enabled = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  # General tags
  tags = merge(
    local.default_tags
  )
}
