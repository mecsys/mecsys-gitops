# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

locals {
  account_vars           = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars            = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment            = local.account_vars.locals.environment
  profile                = local.account_vars.locals.profile
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.

terraform {
  source = "git::ssh://git@bitbucket.org/sensedia/open-finance-addon-integration-infra.git//consent/?ref=v0.10.0"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  # General
  region      = local.region
  environment = local.environment
  version     = "2024061404"

  # General tags
  tags = merge(
    local.default_tags
  )
}
