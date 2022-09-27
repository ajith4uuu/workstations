locals {
  org_id           = "310155770208"
  billing_account  = "01DA77-324950-976951"
  bucket_location  = "EU"
  package_versions = jsondecode(file("${path.module}/cloudbuild_builder/packageVersions.json"))
  replica_locations_for_secrets = toset([
    "europe-west1",
    "europe-west3"
  ])
}

### Core ###

# Create folder at root of org (eg. /shared)
resource "google_folder" "shared" {
  display_name = "shared"
  parent       = "organizations/${local.org_id}"
}

# Create sub-folder (eg. /shared/bootstrap)
resource "google_folder" "bootstrap" {
  display_name = "bootstrap"
  parent       = google_folder.shared.id
}

# Create project on sub-folder level (eg. /shared/bootstrap/gcp-shr-terraform-XXXX)
module "project" {
  source = "github.com/ajith4uuu/terraform-modules//stacks/project?ref=v1.0.0"

  folder_id       = google_folder.bootstrap.id
  billing_account = local.billing_account

  prefix_id = "gcp"
  labels = {
    email          = "editorial@indexofscience.com"
    costid         = ""
    live           = "yes"
    environment    = "shr"
    servicename    = "terraform"
    subservicename = "deploy"
  }
  services = [
    "appengine.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudscheduler.googleapis.com",
    "container.googleapis.com",
    "containerscanning.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com",
    "servicenetworking.googleapis.com",
  ]
}

### Terraform ###

# Create terraform service account
resource "google_service_account" "terraform" {
  project      = module.project.project.project_id
  account_id   = module.project.labels.resource_name
  display_name = module.project.labels.resource_name
  description  = "Terraform service account for GCP platform team's pipelines"
}

# Create terraform state bucket
module "state" {
  source     = "github.com/terraform-google-modules/terraform-google-cloud-storage///modules/simple_bucket?ref=v2.2.0"
  name       = "${module.project.labels.resource_name}-state"
  project_id = module.project.project.project_id
  location   = local.bucket_location
  labels     = module.project.labels.transformed_labels
}

# Terraform service account permissions
resource "google_organization_iam_member" "terraform_org" {
  for_each = toset([
    "roles/billing.admin",
    "roles/billing.costsManager",
    "roles/billing.projectManager",
    "roles/compute.networkAdmin",
    "roles/compute.xpnAdmin",
    "roles/iam.securityAdmin",
    "roles/logging.configWriter",
    "roles/orgpolicy.policyAdmin",
    "roles/resourcemanager.folderAdmin",
    "roles/resourcemanager.lienModifier",
    "roles/resourcemanager.projectCreator",
    "roles/resourcemanager.projectDeleter",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/storage.admin",
  ])
  org_id = local.org_id
  role   = each.value
  member = "serviceAccount:${google_service_account.terraform.email}"
}

resource "google_storage_bucket_iam_member" "terraform_state" {
  bucket = module.state.bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.terraform.email}"
}

### Cloud Build ###

# Bucket for artifacts e.g. plan and apply output files when terragrunt pipelines run, and staging area for container builds
module "artifacts" {
  source     = "github.com/terraform-google-modules/terraform-google-cloud-storage///modules/simple_bucket?ref=v2.2.0"
  name       = "${module.project.labels.resource_name}-artifacts"
  project_id = module.project.project.project_id
  location   = local.bucket_location
  labels     = module.project.labels.transformed_labels
}

# Cloud build service account IAM permissions
resource "google_storage_bucket_iam_member" "cloudbuild_artifacts" {
  bucket = module.artifacts.bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.project.project.project_number}@cloudbuild.gserviceaccount.com"
}
resource "google_storage_bucket_iam_member" "cloudbuild_state" {
  bucket = module.state.bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.project.project.project_number}@cloudbuild.gserviceaccount.com"
}

# Allow cloud build to impersonate terraform service account
resource "google_service_account_iam_member" "cloudbuild_terraform_impersonate" {
  service_account_id = google_service_account.terraform.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${module.project.project.project_number}@cloudbuild.gserviceaccount.com"
}

# Build and push our container in ./cloudbuild_builder
module "image_builder" {
  source = "github.com/terraform-google-modules/terraform-google-gcloud.git?ref=v3.0.1"

  module_depends_on = [
    module.project
  ]

  # If these change we want the command to run again
  create_cmd_triggers = {
    cloudbuild_project_id = module.project.project.project_id
    cloudbuild_yaml_sha1  = sha1(file("${path.module}/cloudbuild_builder/cloudbuild.yaml"))
    dockerfile_sha1       = sha1(file("${path.module}/cloudbuild_builder/Dockerfile"))
    tf_version_sha1       = sha1(chomp(file("${path.module}/../.terraform-version")))
    tg_version_sha1       = sha1(chomp(file("${path.module}/../.terragrunt-version")))
    package_version_sha1  = sha1(chomp(file("${path.module}/cloudbuild_builder/packageVersions.json")))
  }

  create_cmd_entrypoint = "gcloud"
  create_cmd_body       = <<EOT
      builds submit ${path.module}/cloudbuild_builder/ \
      --project ${module.project.project.project_id} \
      --gcs-source-staging-dir="gs://${module.artifacts.bucket.name}/staging" \
      --config=${path.module}/cloudbuild_builder/cloudbuild.yaml \
      --substitutions=_CHECKOV_VERSION="${local.package_versions.checkovVersion}",\
_MARKDOWNLINK_VERSION="${local.package_versions.markdownlinkVersion}",\
_MDL_VERSION="${local.package_versions.mdlVersion}",\
_PRECOMMIT_VERSION="${local.package_versions.precommitVersion}",\
_TF_DOCS_VERSION="${local.package_versions.tfdocsVersion}",\
_TERRAFORM_VERSION=${chomp(file("${path.module}/../.terraform-version"))},\
_TERRAGRUNT_VERSION=${chomp(file("${path.module}/../.terragrunt-version"))},\
_TFENV_VERSION="${local.package_versions.tfenvVersion}",\
_TFSEC_VERSION="${local.package_versions.tfsecVersion}",\
_TGENV_VERSION="${local.package_versions.tgenvVersion}"\
  EOT
}

# Cloud Build repo triggers

resource "google_cloudbuild_trigger" "master" {
  project     = module.project.project.project_name
  description = "terragrunt apply on push to master"

  github {
    owner = "ajith4uuu"
    name  = "cloudfoundation-iac-main"
    push {
      branch = "^main$"
    }
  }

  substitutions = {
    _TF_SA_EMAIL          = google_service_account.terraform.email
    _ARTIFACT_BUCKET_NAME = module.artifacts.bucket.name
    _GITHUB_TOKEN_ID      = google_secret_manager_secret.github_token_id.secret_id
  }

  filename = "cloudbuild-tg-apply.yaml"
  depends_on = [
    module.image_builder,
  ]
}

resource "google_cloudbuild_trigger" "pull_requests" {
  project     = module.project.project.project_name
  description = "terragrunt plan on pull requests"

  github {
    owner = "ajith4uuu"
    name  = "cloudfoundation-iac-main"
    pull_request {
      branch = "^main$"
    }
  }

  substitutions = {
    _TF_SA_EMAIL          = google_service_account.terraform.email
    _ARTIFACT_BUCKET_NAME = module.artifacts.bucket.name
    _GITHUB_TOKEN_ID      = google_secret_manager_secret.github_token_id.secret_id
  }

  filename = "cloudbuild-tg-plan.yaml"
  depends_on = [
    module.image_builder,
  ]
}

resource "google_secret_manager_secret" "github_token_id" {
  project   = module.project.project.project_id
  secret_id = "${module.project.labels.resource_name}-github_token_id"

  replication {
    user_managed {
      dynamic "replicas" {
        for_each = local.replica_locations_for_secrets
        content {
          location = replicas.value
        }
      }
    }
  }

  labels = module.project.labels.transformed_labels

}

# Allow Cloud Build Service Account to access the secret
resource "google_secret_manager_secret_iam_member" "cloudbuild_secretaccessor_member" {
  project   = module.project.project.project_id
  secret_id = google_secret_manager_secret.github_token_id.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${module.project.project.project_number}@cloudbuild.gserviceaccount.com"
}
