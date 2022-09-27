# Folder structure and policies

## Prerequisites

- Ensure you have run the bootstrap as covered [here](../bootstrap) in order to
  run infra code

## Folder guide

- Create folder resources:
  - Inside org folder, edit `org.hcl` file and set the appropiate values for the
    following: bucket, target_service_account, billing_account, org_id,
    policy_allowed_domain_ids
  - `shared` folder is used to configure resources shared by other environments
  - Inside `do` folder you can find various examples on how to setup folders,
    projects, Service Accounts, IAM permissions to projects, VPC network, Shared
    Host and Service projects, VPN between projects, VPC peering between
    projects, etc.
  - `_policies` is a virtual folder, meaning that it's not being created
    inside the GCP. Its role is to setup Organisation Policies
  - To create the environment GCP folder structure, go into each environment
    folder of the repo and perform the following commands:

<!-- markdownlint-disable -->
```bash
find . -not -path '*/.terragrunt-cache/*' -type f -name terragrunt.hcl -printf '%h\n' | sort | xargs -l -i sh -c 'cd {}; terragrunt init --terragrunt-non-interactive -input=false'
terragrunt plan-all
terragrunt apply-all
```
<!-- markdownlint-enable -->

- Controlling log sinks and organisation policies:
  - Inside each environment folder there is a `terragrunt.hcl` file from where
    you can control what policies to apply
  - For org policies, the following values can be set:
    policy_skip_default_network (true/false), policy_require_oslogin
    (true/false), policy_svc_acc_grants (true/false), policy_uniform_bucket
    (true/false), policy_svc_acc_key_creation (true/false), vm_external_ip
    (true/false), policy_resource_locations (list containining allowed
    locations), policy_vm_external_ip (true/false)
  - For log sinks, more specifically for Activity logs, System Event logs,
    Data Access logs, and Policy Denied logs you can control it by folder level
    via create_sink (true/false), project_id (the Project ID where
    BigQuery/Logging Bucket has been setup). Access Transparency logs can be
    enabled at organization or project level only if you have already one of
    the following customer support levels: Premium, Enterprise, Platinium,
    Gold or one of the following Role-Based Support packages - 4 or more
    Development roles, 4 or more Production roles, a combination of 4 or more
    Development or Production roles
  - An example of such config can be [found here](do/terragrunt.hcl)
  - The `unmanaged` folder is where all the projects in transition state sit or
    projects that do not require the same level of restriction. An example
    configuration with less restriction [is here](unmanaged/terragrunt.hcl)
