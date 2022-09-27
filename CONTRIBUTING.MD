# Prerequisites

- [tfenv](https://github.com/tfutils/tfenv#automatic)
- [tgenv](https://github.com/cunymatthieu/tgenv#installation)
- [gcloud](https://cloud.google.com/sdk/install)
- [pre-commit](https://pre-commit.com/)

## Use of tfenv and tgenv

Both `tfenv` and `tgenv` take away the toil of managing multiple versions of
terraform and terragrunt. In the root of this repo you will find a
[.terraform-version](/.terraform-version) file and
[.terragrunt-version](/.terraform-version) file. Both files specify a version to
ensure all operators and pipelines are using the same version of terraform and
terragrunt.

## Use of Terragrunt

[Terragrunt](https://terragrunt.gruntwork.io/) is a wrapper around `terraform`
with some extra features to help maintain a consistent and
[DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) terraform codebase.

Look over the
[quickstart](https://terragrunt.gruntwork.io/docs/getting-started/quick-start/)
if you are not familiar with terragrunt

## Use of pre-commit

pre-commit is a framework for managing and maintaining multi-language pre-commit
hooks i.e. help improve the quality of code by running some quick checks before
it's even pushed to a Git repo

## Setup scripts

In the [scripts](./scripts) directory you can find a setup and update script for
all prerequisites
