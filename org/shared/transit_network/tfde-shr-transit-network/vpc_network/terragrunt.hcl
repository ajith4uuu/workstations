# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
locals {
}

terraform {
  source = "github.com/ajith4uuu/terraform-modules//stacks/vpc_network"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("org.hcl")
}

dependency "parent" {
  config_path = "../../tfde-shr-transit-network/"
  mock_outputs = {
    project = {
      project_id = "tfde-shr-transit-network"
    }
    labels = {
      resource_name = "tfde-shr-transit-network"
    }
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  project_id   = dependency.parent.outputs.project.project_id
  network_name = "${dependency.parent.outputs.labels.resource_name}-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "${dependency.parent.outputs.labels.resource_name}-eu-west1-1"
      subnet_ip             = "10.110.64.0/27"
      subnet_region         = "europe-west1"
      subnet_private_access = true
      subnet_flow_logs      = false
    },
    {
      subnet_name           = "${dependency.parent.outputs.labels.resource_name}-eu-west3-1"
      subnet_ip             = "10.110.66.0/27"
      subnet_region         = "europe-west3"
      subnet_private_access = true
      subnet_flow_logs      = false
    },
    {
      subnet_name           = "${dependency.parent.outputs.labels.resource_name}-eu-west2-1"
      subnet_ip             = "10.110.66.192/27"
      subnet_region         = "europe-west2"
      subnet_private_access = true
      subnet_flow_logs      = false
    }
  ]

  secondary_ranges = {}

  routes = [
    {
      name              = "private-google-access"
      description       = "Private Google Access for on-premises hosts"
      destination_range = "199.36.153.8/30"
      next_hop_internet = "true"
    }
  ]

}
