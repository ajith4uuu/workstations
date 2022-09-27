# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
locals {
}

terraform {
  source = "github.com/ajith4uuu/terraform-modules//stacks/iam_org"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("org.hcl")
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  org_admin_members = [
    "group:gcp-orgadmins@indexofscience.com",
  ]

  sec_admin_members = [
    "group:gcp-secadmins@indexofscience.com",
  ]

  billing_admin_members = [
    "group:gcp-billingadmin@indexofscience.com",
  ]

  billing_user_members = [
    "group:gcp-billingusers@indexofscience.com",
  ]

  network_admin_members = [
    "group:gcp-netadmins@indexofscience.com",
  ]

  support_account_admin_members = [
    "user:ritesh.manktala@indexofscience.com",
  ]

  tech_support_editor_members = [
    "user:ajith@indexofscience.com",
  ]

}
