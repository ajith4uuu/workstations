# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
locals {
}

terraform {
  source = "github.com/colt-net/terraform-modules//stacks/iam_project?ref=v1.0.13"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("org.hcl")
}

dependency "parent" {
  config_path = "../../gclt-shr-transit-network/"
  mock_outputs = {
    project = {
      project_id = "gclt-shr-transit-network"
    }
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  project_id = dependency.parent.outputs.project.project_id

  viewer_members = [
    "user:ritesh.manktala@colt.net",
    "user:akhilesh.tewari@colt.net",
    "user:devrim.ozdemir@colt.net",
  ]

}
