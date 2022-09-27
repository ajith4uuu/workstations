# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
locals {
}

terraform {
  source = "github.com/colt-net/terraform-modules//stacks/iam_org?ref=v1.0.14"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("org.hcl")
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  org_admin_members = [
    "group:gcp-orgadmins@colt.net",
  ]

  sec_admin_members = [
    "group:gcp-secadmins@colt.net",
  ]

  billing_admin_members = [
    "group:gcp-billingadmin@colt.net",
  ]

  billing_user_members = [
    "group:gcp-billingusers@colt.net",
  ]

  network_admin_members = [
    "group:gcp-netadmins@colt.net",
  ]

  support_account_admin_members = [
    "user:ritesh.manktala@colt.net",
  ]

  tech_support_editor_members = [
    "user:ritesh.manktala@colt.net",
    "user:akhilesh.tewari@colt.net",
    "user:kiran.verma@colt.net",
    "user:anugrah.gupta@colt.net",
    "user:raguraman.ganesan@colt.net",
  ]

}
