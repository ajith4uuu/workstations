# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
locals {
}

terraform {
  source = "github.com/terraform-google-modules/terraform-google-cloud-storage///modules/simple_bucket?ref=v2.2.0"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("org.hcl")
}

dependency "project" {
  config_path = "../../gclt-bootstrap-data/"
  mock_outputs = {
    project = {
      project_id = "gclt-bootstrap-data"
    }
    labels = {
      transformed_labels = {
        email       = "platform.support@colt.net"
        costid      = ""
        live        = "yes"
        iac         = "automatic"
        environment = "shr"
        servicename = "bootstrap-data"
      }
      resource_name = "resource_name"
    }
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  name       = "${dependency.project.outputs.labels.resource_name}-state"
  project_id = dependency.project.outputs.project.project_id
  location   = "EU"
  labels     = dependency.project.outputs.labels.transformed_labels

}
