# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
locals {
}

terraform {
  source = "github.com/colt-net/terraform-modules//stacks/iam_shared_network?ref=v1.0.0"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("org.hcl")
}

dependency "host_project" {
  config_path = "../../../gclt-dev-network/"
  mock_outputs = {
    project = {
      project_id = "gclt-dev-network"
    }
  }
}

dependency "network" {
  config_path = "../../../gclt-dev-network/vpc_network"
  mock_outputs = {
    vpc = {
      subnets = {
        "europe-west1/gclt-dev-network-eu-west1" = {
          "id" = "projects/gclt-dev-network/regions/europe-west1/subnetworks/gclt-dev-network-eu-west1"
        }
      }
    }
  }
}


# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  project_id = dependency.host_project.outputs.project.project_id

  sharedvpc_netadmin_members = [
    "group:gcp-netadmins@colt.net"
  ]

  # Filtering subnetworks based on the region they are in. In this case it will capture all subnets
  shared_vpc_subnets = [for x, z in dependency.network.outputs.vpc.subnets : z.id if length(regexall(".*", x)) > 0]

}
