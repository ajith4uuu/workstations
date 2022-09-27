# General description

The purpose of this IaC is to get you started on setting up Framework for a customer which does not have any GCP
presence.

## Deployment steps

Because there is no project, folder or policy setup a new fresh GCP
Organisation, we need to establish a bootstrap which will spin up the minimum
required resources in GCP in order to configure everything else. This is located
under the [bootstrap](./bootstrap) folder. It takes care of creating the
following:

- a folder at the root of the GCP organisation
- a project in this folder, which will store the automation resources
- Terraform service account which is going to be used later in the
  infrastructure deployment process, along with its IAM roles needed in order
  to perform the required operations (like creating projects, assigning Billing
  accounts, etc.)
- Terraform state bucket where Terraform will store its remote state
- Cloud Build bucket for storing Cloud Build artifacts
- Proper permissions for the Cloud Build Service Account in order to
  impersonate and make use of the previously created Terraform SA
- Build and deploy image with all the needed tools installed (GCP SDK,
  Terraform, Terragrunt, code checking and linting)
- Cloud Build triggers connected to the GitHub repo where IaC will sit.

The bootstrap part needs to be run manually and once that is done, we can
continue with the regular development. Follow the link for more details about
[bootstrap config process](./bootstrap/README.md)

Once we have the base build and deploy image ready from the bootstrap, we can
then use a more structured way of development. The purpose is for everyone in
the team to use the same tools, same versions of Terraform / Terragrunt, shell,
development extensions so that we have consistency and an easy local setup.
Visual Studio Code will be the development GUI tool as it supports remote
development containers. Check [the devcontainer
readme](./docs/vs_code_dev_container.md) on how to set this up and [devcontainer
config](./.devcontainer/devcontainer.json)

All of the developed IaC is heavily using Terraform modules and stacks.
Modules are the smaller units used in order to create one generic resource (or
combination of resources but for the same purpose).
Stacks are a combination of modules for creating AEF specific resources in
order to achieve a higher level of purpose (like a project with labels, VPN
tunnels between two projects, etc.).
Both, the modules and the stacks are placed in [second][1] repo.

Terragrunt is being used in order to connect these units. Both modules and
stacks can be seen as plugins (or pieces of legos), which can be combined via
Terragrunt in order to form a desired state for the customer. Let's say the
customer wants to have a project with some labels, some Service Accounts in
order to use them for VMs, give users some IAM permissions in the project and a
VPC network. In this case we will need the following lego parts: from the
modules box we'll use the `labels` part, and from the stacks box we'll use
`folder`, `iam_project`, `sa_project` and `vpc_network`.

Furthermore, each module and stack has its own readme where you can find out
more about them. Read them carefully as some require manual steps.

So, just to get you started, follow these steps:

- Go to `bootstrap` folder and perform the steps in the [README](./bootstrap/README.md)
- Provision the bootstrap by running `terraform init` and `terraform apply`
- Write down the outputs of the bootstrap setup
- Configure [org.hcl](./org/org.hcl) with the proper values
- Go into each org subfolders and run `terragrunt init` and `terragrunt apply`

## Documentation links

- [Generic](CONTRIBUTING.MD)
- [Initial setup for IaC](bootstrap/README.md)
- [GCP folder setup with Terragrunt](org/README.md)

<!-- markdown-link-check-disable -->
[1]: https://github.com/ajith4uuu/terraform-modules
<!-- markdown-link-check-enable -->
