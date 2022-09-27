# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
locals {
}

terraform {
  source = "github.com/colt-net/terraform-modules//stacks/sa_project?ref=v1.0.9"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("org.hcl")
}

dependency "parent" {
  config_path = "../../gclt-bootstrap-data/"
  mock_outputs = {
    project = {
      project_id = "gclt-bootstrap-data"
    }
    labels = {
      resource_name = "gclt-bootstrap-data"
    }
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  project_id         = dependency.parent.outputs.project.project_id
  billing_account_id = "0138FE-468F00-64F90B"
  service_account_roles_map = [
    {
      sa_name      = dependency.parent.outputs.labels.resource_name
      sa_role      = "roles/iam.serviceAccountAdmin,roles/resourcemanager.projectIamAdmin,roles/compute.networkUser"
      display_name = dependency.parent.outputs.labels.resource_name
      description  = "SA for project DATA from DO"
    }
  ]

}
