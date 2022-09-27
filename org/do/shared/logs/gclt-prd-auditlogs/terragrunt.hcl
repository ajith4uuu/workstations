# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
locals {
}

terraform {
  source = "github.com/colt-net/terraform-modules//stacks/project?ref=v1.0.0"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("org.hcl")
}

dependency "parent" {
  config_path = "../../logs/"
  mock_outputs = {
    folder_id = "logs"
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  folder_id = dependency.parent.outputs.folder_id

  # Labels
  labels = {
    email       = "platform.support@colt.net"
    costid      = ""
    live        = "yes"
    environment = "prd"
    servicename = "auditlogs"
  }

}
