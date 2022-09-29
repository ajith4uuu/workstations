terraform {
  backend "gcs" {
    bucket = "tfde-shr-terraform-state"
    prefix = "bootstrap"
  }
}
