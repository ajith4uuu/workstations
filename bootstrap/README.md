# Bootstrap

## Prerequisites

- Ensure you have the prerequisites covered [here](../CONTRIBUTING.MD) in order
  to run infrastructure code

## Bootstrap guide

- Get logged in via `gcloud`:

```bash
gcloud init
gcloud auth application-default login
```

with a user having the following roles:

```text
Folder Admin
Organization Administrator
Owner
Project Creator
Project Deleter
Service Account Admin
Service Account Token Creator
Storage Admin
```

- Create bootstrap resources:
  - Run `terraform init` and then `terraform plan` to see what changes are
    pending (should be the creation of the bootstrap folder and project,
    terraform state bucket, terraform service account, IAM permissions for the
    service account, development image)
  - Run `terraform apply` if the above plan looks good and confirm with `yes`
  - Take a note on the output `service_account` and `state\bucket` of the apply
    and save the output somewhere
  - Once the resources have been created, copy `backend.tf-example` file to
    `backend.tf` and set the bucket to the value of `state\bucket\name` from the
    terraform apply output
  - Run again `terraform init` which will ask if you want to copy the local
    Terraform state into the remote state bucket - confirm by typing `yes`
  - Remove `terraform.tfstate` and `terraform.tfstate.backup` files from your
    local drive. Run another terraform apply which should no longer need to
    create any new resources
  - Give Billing Admin permissions to the Terraform Service Account created in
    the bootstrap on the Billing Account intended to use. This is a manual step

- Create bootstrap with CI/CD pipeline
  - In case the customer uses GitHub as a version control system, then uncomment
    and configure the rows below "Cloud Build repo triggers" in the `main.tf`
    and `outputs.tf`
  - Ask the customer to create the link between the GCP project created in the
    initial bootstrap with the GitHub repo he has. See
    [this](https://cloud.google.com/build/docs/automating-builds/run-builds-on-github#installing_the_google_cloud_build_app)
    for more details
  - Run `terraform init` and then `terraform plan` to see what changes are
    pending (should be changes related only to Cloud Build)
  - Run `terraform apply` if the above plan looks good and confirm with `yes`
  - For the GitHub user that will be used by the pipelines generate a
    <!-- markdown-link-check-disable -->
    [PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
    and store the value in `github_token_id`
    <!-- markdown-link-check-enable -->
  - Make sure you target the correct built image inside
    `cloudbuild-tg-apply.yaml` and `cloudbuild-tg-plan.yaml`

Note: Once that bootstrap resources are created with success the
files [org.hcl](../org/org.hcl)
and [devcontainer.json](../.devcontainer/devcontainer.json) needs to be
updated with the appropiate values for: bucket, target_service_account,
billing_account, org_id, policy_allowed_domain_ids, image.
