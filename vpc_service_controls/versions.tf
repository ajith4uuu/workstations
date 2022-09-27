terraform {
  required_version = "~> 1.0.8"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.88.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 3.88.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.1.0"
    }
  }
}
