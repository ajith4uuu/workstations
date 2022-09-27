# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
locals {
}

terraform {
  source = "github.com/colt-net/terraform-modules//stacks/interconnect?ref=v1.0.7"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("org.hcl")
}

dependency "parent" {
  config_path = "../../../gclt-shr-transit-network/"
  mock_outputs = {
    project = {
      project_id = "gclt-shr-transit-network"
    }
    labels = {
      resource_name = "gclt-shr-transit-network"
    }
  }
}

dependency "prv_srv" {
  config_path = "../prv_serv_access/"
  mock_outputs = {
    main_ip_alloc = {
      address       = "1.2.3.4",
      prefix_length = "24"
    }
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  labels = {
    email       = "platform.support@colt.net"
    costid      = ""
    live        = "yes"
    environment = "shr"
    servicename = "interconnect"
  }

  project_id   = dependency.parent.outputs.project.project_id
  network_name = "${dependency.parent.outputs.labels.resource_name}-vpc"
  region1      = "europe-west1"
  region2      = "europe-west3"
  activate     = true

  router_advertise_config = {
    mode   = "CUSTOM"
    groups = ["ALL_SUBNETS"]
    ip_ranges = {
      "${dependency.prv_srv.outputs.main_ip_alloc.address}/${dependency.prv_srv.outputs.main_ip_alloc.prefix_length}" : "private-services"
      "10.110.0.0/22" : "prd-net-1"
      "10.110.16.0/22" : "prd-net-2"
      "10.110.20.0/24" : "prd-net-3"
      "10.110.21.0/24" : "prd-net-4"
      "10.110.5.0/24" : "prd-net-5"
      "10.110.4.0/24" : "prd-net-6"
      "10.110.32.0/22" : "dev-net-1"
      "10.110.36.0/24" : "dev-net-2"
      "10.110.37.0/24" : "dev-net-3"
      "10.110.48.0/22" : "tst-net-1"
      "10.110.52.0/24" : "tst-net-2"
      "10.110.53.0/24" : "tst-net-3"
      "199.36.153.8/30" : "private-google-access"
      "10.156.0.0/20" : "apigee-frankfurt-nw"
      "10.55.40.0/22" : "apigee-tenant-network"
      "10.100.4.106" : "onprem-dns-server"
      "10.100.4.107" : "onprem-dns-server"
      "10.99.20.117" : "onprem-loadbalancer"
      "35.199.192.0/19" : "google-dns-ip"
      "10.110.68.0/24" : "apigee-vpc"
      "10.15.216.0/22" : "apigee-tenant-old"
      "10.129.161.208/28" : "google-allow-access"
      "10.99.12.109" : "dev-netiq"
      "10.99.219.249" : "sit-netiq"
      "10.99.219.204" : "uat-netiq"
      "10.99.20.24" : "rfs-netiq"
      "10.100.17.43" : "net-iq-prod"
      "10.100.17.167" : "webmethod-prod"
      "10.154.0.0/20" : "apigee-london-nw"
    }
  }

}
