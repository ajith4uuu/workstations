# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
locals {
}

terraform {
  source = "github.com/colt-net/terraform-modules//stacks/log_sink?ref=v1.0.0"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("org.hcl")
}

dependency "parent" {
  config_path = "../../../../dev/"
  mock_outputs = {
    folder_id = "dev"
  }
}

dependency "project" {
  config_path = "../../gclt-dev-auditlogs/"
  mock_outputs = {
    project = {
      project_id = "gclt-dev-auditlogs"
    }
    labels = {
      raw_labels = {
        prefix_id   = "prefix_id"
        email       = "email"
        costid      = "costid"
        live        = "live"
        environment = "environment"
        servicename = "servicename"
      }
    }
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  sink_parent_resource_type = "folder"
  sink_parent_resource_id   = dependency.parent.outputs.folder_id

  project_id         = dependency.project.outputs.project.project_id
  log_project_member = "group:gcp-secadmins@colt.net"

  prefix_id = dependency.project.outputs.labels.raw_labels.prefix_id
  labels    = dependency.project.outputs.labels.raw_labels

}
