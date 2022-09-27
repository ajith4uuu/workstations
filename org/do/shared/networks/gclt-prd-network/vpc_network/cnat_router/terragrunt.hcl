# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
locals {
}

terraform {
  source = "github.com/colt-net/terraform-modules//modules/router?ref=v1.0.12"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("org.hcl")
}

dependency "parent" {
  config_path = "../../../gclt-prd-network/"
  mock_outputs = {
    project = {
      project_id = "gclt-prd-network"
    }
    labels = {
      resource_name = "gclt-prd-network"
    }
  }
}

dependency "network" {
  config_path = "../../../gclt-prd-network/vpc_network"
  mock_outputs = {
    vpc = {
      "network" = {
        "network_name" = "gclt-prd-network-vpc"
      }
    }
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  project_id   = dependency.parent.outputs.project.project_id
  region       = "europe-west1"
  network_name = dependency.network.outputs.vpc.network.network_name
  router_name  = "${dependency.parent.outputs.labels.resource_name}-cnat-router"
  nats = [{
    name = "${dependency.parent.outputs.labels.resource_name}-cnat-gw"
  }]

  router_advertise_config = {
    groups = ["ALL_SUBNETS"]
    mode   = "CUSTOM"
    ip_ranges = {
      "10.110.4.0/24" : "gclt-prd-network-eu-west1-1-pods"
      "10.110.5.0/24" : "gclt-prd-network-eu-west1-1-services"
      "10.110.12.0/23" : "gclt-prd-network-eu-west1-2-pods"
      "10.110.14.0/23" : "gclt-prd-network-eu-west1-2-services"
    }
  }

}
