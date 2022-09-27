# VPC Service Controls

## Prerequisites

- Ensure you have the prerequisites covered [here](../CONTRIBUTING.MD) in order
  to run infrastructure code

## VPC Service Controls guide

- Get logged in via `gcloud`:

```bash
gcloud init
gcloud auth application-default login
```

with a user having the following roles:

```text
Service Account Token Creator
```

and a service account having the following roles:

```text
Access Context Manager Admin
Cloud Asset Owner at organization level
Storage Admin in the gclt-shr-terraform-4df7 project (where the state is kept)
```

The terraform is already configure to use
the `gclt-shr-terraform@gclt-shr-terraform-4df7.iam.gserviceaccount.com`
service account which has the required roles.

- Create VPC Service Controls resources:
  - Run `terraform init` and then `terraform plan` to see what changes are
    pending (should be the creation of the access level and perimeters,
    terraform state bucket)
  - Run `terraform apply` if the above plan looks good and confirm with `yes`

- Changing IPs that are allowed GCP access:
  - Open the `main.tf` file
  - Updated the `access_level` module `ip_subnetworks` property with the
    new/updated IPs
  - Run `terraform plan` to see what changes are pending
  - Run `terraform apply` if the above plan looks good and confirm with `yes`

- Adding/Removing projects from a perimeter:
  - Open the `main.tf` file
  - Updated the desired perimeters module `resources_dry_run` property and
    add/remove the desired projects
  - Run `terraform plan` to see what changes are pending
  - Run `terraform apply` if the above plan looks good and confirm with `yes`

Note:

- All perimeters are created in dry run mode. In order to enforce the rules
  the `_dry_run` suffix should be removed from the following property
  names: `restricted_services_dry_run`, `resources_dry_run`
  and `ingress_policies_dry_run`
- At the moment we cannot create the bridges using terraform because
  there is an issue with the [API][4]

### Useful links/resources

- Documentation for terraform modules used for creating the access level and perimeters:

  - [Access level][1]
  - [Perimeter][2]
  - [Bridge][3]

## VPC Service Controls perimeters list

| Terraform perimeter     | Inbound access context |
|:------------------------|:----------------------:|
| gclt-shr-terraform-4df7 | Colt IPs               |

| Bootstrap perimeter     | Inbound access context |
|:------------------------|:----------------------:|
| gclt-shr-terraform-4df7 | SA: gclt-shr-github-data@gclt-shr-bootstrap-data-2ca0.iam.gserviceaccount.com|
| gclt-shr-terraform-4df7 | Colt IPs               |

| dev-data perimeter      | Inbound access context |
|:------------------------|:----------------------:|
| gclt-dev-data-49e8      | Colt IPs               |
| gclt-dev-sandvoice-28418| Colt IPs               |
| colt-bogdana-test-vpc1  | Colt IPs               |
| gclt-dev-sandbox-11c8   | Colt IPs               |
| gclt-dev-sandcolt-45903 | Colt IPs               |
| gclt-dev-sandland-00c4  | Colt IPs               |
| gclt-dev-sandlane-29c3  | Colt IPs               |

| dev-logs perimeter      | Inbound access context |
|:------------------------|:----------------------:|
| gclt-dev-auditlogs-ac84 | Colt IPs               |

| dev-logs-it perimeter   | Inbound access context |
|:------------------------|:----------------------:|
| gclt-dev-auditlogs-175b | Colt IPs               |

| prd-data perimeter      | Inbound access context |
|:------------------------|:----------------------:|
| gclt-prd-data-3148      | Colt IPs               |

| prd-logs perimeter      | Inbound access context |
|:------------------------|:----------------------:|
| gclt-prd-auditlogs-ed9c | Colt IPs               |

| prd-logs-it perimeter   | Inbound access context |
|:------------------------|:----------------------:|
| gclt-prd-auditlogs-0c77 | Colt IPs               |

| tst-data perimeter      | Inbound access context |
|:------------------------|:----------------------:|
| gclt-tst-data-d89d      | Colt IPs               |

| tst-logs perimeter      | Inbound access context |
|:------------------------|:----------------------:|
| gclt-tst-auditlogs-6b4b | Colt IPs               |

| tst-logs-it perimeter   | Inbound access context |
|:------------------------|:----------------------:|
| gclt-tst-auditlogs-a8e8 | Colt IPs               |

| transit-network perimeter| Inbound access context |
|:-------------------------|:-----------------------:|
| gclt-dev-network-7ec8    | Colt IPs               |

| dev-network perimeter   | Inbound access context |
|:------------------------|:----------------------:|
| gclt-dev-network-7ec8   | Colt IPs               |

| prd-network perimeter   | Inbound access context |
|:------------------------|:----------------------:|
| gclt-prd-network-9bfc   | Colt IPs               |

| tst-network perimeter   | Inbound access context |
|:------------------------|:----------------------:|
| gclt-tst-network-3332   | Colt IPs               |

[1]: <https://github.com/terraform-google-modules/terraform-google-vpc-service-controls/tree/master/modules/access_level>
[2]: <https://github.com/terraform-google-modules/terraform-google-vpc-service-controls/tree/master/modules/regular_service_perimeter>
[3]: <https://github.com/terraform-google-modules/terraform-google-vpc-service-controls/tree/master/modules/bridge_service_perimeter>
[4]: <https://github.com/terraform-google-modules/terraform-google-vpc-service-controls/issues/80>
