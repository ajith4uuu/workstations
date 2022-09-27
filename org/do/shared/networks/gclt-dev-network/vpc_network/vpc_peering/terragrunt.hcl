# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
locals {
}

terraform {
  source = "github.com/colt-net/terraform-modules//modules/vpc_peering?ref=v1.0.0"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("org.hcl")
}

dependency "localnet" {
  config_path = "../../../gclt-dev-network/vpc_network"
  mock_outputs = {
    vpc = {
      "network" = {
        "network_self_link" = "https://www.googleapis.com/compute/v1/projects/project/global/networks/localnet"
      }
    }
  }
}

dependency "remotenet" {
  config_path = "../../../../../../shared/transit_network/gclt-shr-transit-network/vpc_network"
  mock_outputs = {
    vpc = {
      "network" = {
        "network_self_link" = "https://www.googleapis.com/compute/v1/projects/project/global/networks/remotenet"
      }
    }
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  local_network              = dependency.localnet.outputs.vpc.network.network_self_link
  peer_network               = dependency.remotenet.outputs.vpc.network.network_self_link
  export_local_custom_routes = true
  export_peer_custom_routes  = true
}
