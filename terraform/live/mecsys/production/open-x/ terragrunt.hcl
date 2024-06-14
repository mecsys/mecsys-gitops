locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl", "i-dont-exist.hcl"),
    {
      locals = {
        region = "sa-east-1"
      }
  })

  # Extract the variables we need for easy access
  profile      = local.account_vars.locals.profile
  account_id   = local.account_vars.locals.account_id
  region       = local.region_vars.locals.region
  default_tags = local.account_vars.locals.default_tags
}

remote_state {
  backend = "s3"

  config = {
    bucket         = "terragrunt-remote-state-${local.profile}"
    dynamodb_table = "terragrunt-state-lock-dynamo-${local.profile}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    profile        = local.profile
    s3_bucket_tags = merge(
      local.default_tags,
    )
    dynamodb_table_tags = merge(
      local.default_tags,
    )
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}

terraform {
  # Force Terraform to keep trying to acquire a lock for
  # up to 30 minutes if someone else already has the lock
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=30m"]
  }
}

# Generate an AWS provider block
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
    required_version = "~> 1.3.0"
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 4.61.0"
      }
    }
  }
EOF
}
