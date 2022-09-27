locals {
  policy_name               = 381074895184
  terraform_service_account = "gclt-shr-terraform@gclt-shr-terraform-4df7.iam.gserviceaccount.com"
  restricted_services = [
    "apigee.googleapis.com",
    "apigeeconnect.googleapis.com",
    "bigquery.googleapis.com",
    "bigquerydatatransfer.googleapis.com",
    "binaryauthorization.googleapis.com",
    "privateca.googleapis.com",
    "connectgateway.googleapis.com",
    "assuredworkloads.googleapis.com",
    "bigtable.googleapis.com",
    "containerfilesystem.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudasset.googleapis.com",
    "datacatalog.googleapis.com",
    "dataflow.googleapis.com",
    "datastream.googleapis.com",
    "dataproc.googleapis.com",
    "dlp.googleapis.com",
    "clouddebugger.googleapis.com",
    "clouddeploy.googleapis.com",
    "dialogflow.googleapis.com",
    "datamigration.googleapis.com",
    "documentai.googleapis.com",
    "cloudfunctions.googleapis.com",
    "gameservices.googleapis.com",
    "healthcare.googleapis.com",
    "lifesciences.googleapis.com",
    "cloudkms.googleapis.com",
    "language.googleapis.com",
    "logging.googleapis.com",
    "memcache.googleapis.com",
    "osconfig.googleapis.com",
    "oslogin.googleapis.com",
    "recommender.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "run.googleapis.com",
    "pubsub.googleapis.com",
    "pubsublite.googleapis.com",
    "cloudsearch.googleapis.com",
    "secretmanager.googleapis.com",
    "sts.googleapis.com",
    "spanner.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "storagetransfer.googleapis.com",
    "cloudtrace.googleapis.com",
    "translate.googleapis.com",
    "texttospeech.googleapis.com",
    "speech.googleapis.com",
    "networksecurity.googleapis.com",
    "networkservices.googleapis.com",
    "cloudprofiler.googleapis.com",
    "vision.googleapis.com",
    "compute.googleapis.com",
    "contactcenterinsights.googleapis.com",
    "container.googleapis.com",
    "containeranalysis.googleapis.com",
    "containerregistry.googleapis.com",
    "meshca.googleapis.com",
    "meshconfig.googleapis.com",
    "gkeconnect.googleapis.com",
    "gkehub.googleapis.com",
    "monitoring.googleapis.com",
    "composer.googleapis.com",
    "tpu.googleapis.com",
    "redis.googleapis.com",
    "automl.googleapis.com",
    "ml.googleapis.com",
    "notebooks.googleapis.com",
    "datafusion.googleapis.com",
    "opsconfigmonitoring.googleapis.com",
    "videointelligence.googleapis.com",
    "managedidentities.googleapis.com",
    "accessapproval.googleapis.com",
    "artifactregistry.googleapis.com",
    "servicecontrol.googleapis.com",
    "servicedirectory.googleapis.com",
    "vpcaccess.googleapis.com",
    "metastore.googleapis.com",
    "dataplex.googleapis.com",
    "iaptunnel.googleapis.com",
    "aiplatform.googleapis.com",
    "networkmanagement.googleapis.com",
    "transcoder.googleapis.com",
    "iam.googleapis.com",
    "recaptchaenterprise.googleapis.com",
    "adsdatahub.googleapis.com",
    "networkconnectivity.googleapis.com",
    "dns.googleapis.com",
    "trafficdirector.googleapis.com",
    "file.googleapis.com",
    "containerthreatdetection.googleapis.com",
    "eventarc.googleapis.com",
    "speakerid.googleapis.com",
    "firebaseappcheck.googleapis.com",
    "firebaserules.googleapis.com",
    "kmsinventory.googleapis.com",
    "firestore.googleapis.com",
    "gkebackup.googleapis.com",
    "vmmigration.googleapis.com",
    "workflows.googleapis.com",
    "webrisk.googleapis.com",
    "retail.googleapis.com",
  ]

}

data "google_service_account_access_token" "default" {
  provider               = google.impersonation
  target_service_account = local.terraform_service_account
  scopes                 = ["userinfo-email", "cloud-platform"]
  lifetime               = "1200s"
}

module "access_level" {
  source = "github.com/terraform-google-modules/terraform-google-vpc-service-controls//modules/access_level?ref=v4.0.1"
  name   = "perimeters_access_level"
  policy = local.policy_name
  ip_subnetworks = [
    "103.158.226.250",
    "103.158.227.250",
    "217.111.167.233",
    "61.120.195.60"
  ]
}

module "terraform_perimeter" {
  source         = "github.com/terraform-google-modules/terraform-google-vpc-service-controls//modules/regular_service_perimeter?ref=v4.0.1"
  policy         = local.policy_name
  perimeter_name = "terraform_perimeter"
  description    = "Terraform perimeter"

  restricted_services_dry_run = local.restricted_services

  resources_dry_run = [
    "509659306013" # gclt-shr-terraform-4df7
  ]

  ingress_policies_dry_run = [
    {
      "from" = {
        "sources" = {
          "access_levels" = [
            module.access_level.name
          ]
        },
        "identity_type" = "ANY_IDENTITY"
      }
      "to" = {
        "resources" = ["*"],
        "operations" = {
          "*" = {
            "methods" = ["*"]
          }
        }
      }
    },
  ]
  shared_resources = {
    all = ["509659306013"]
  }
}

module "bootstrap_perimeter" {
  source         = "github.com/terraform-google-modules/terraform-google-vpc-service-controls//modules/regular_service_perimeter?ref=v4.0.1"
  policy         = local.policy_name
  perimeter_name = "bootstrap_perimeter"
  description    = "Bootstrap perimeter"

  restricted_services_dry_run = local.restricted_services

  resources_dry_run = [
    "290402413416" # gclt-shr-bootstrap-data-2ca0
  ]

  ingress_policies_dry_run = [
    {
      "from" = {
        "sources" = {
          "access_levels" = [
            module.access_level.name
          ]
        },
        "identity_type" = "ANY_IDENTITY"
        "identities"    = [""]
      }
      "to" = {
        "resources" = ["*"],
        "operations" = {
          "*" = {
            "methods" = ["*"]
          }
        }
      }
    },
    {
      "from" = {
        "sources" = {
          "access_levels" = ["*"]
        },
        "identity_type" = "IDENTITY_TYPE_UNSPECIFIED"
        "identities"    = ["serviceAccount:gclt-shr-github-data@gclt-shr-bootstrap-data-2ca0.iam.gserviceaccount.com"]
      }
      "to" = {
        "resources" = ["*"],
        "operations" = {
          "*" = {
            "methods" = ["*"]
          }
        }
      }
    },
  ]
  shared_resources = {
    all = ["290402413416"]
  }
}

module "dev_data_perimeter" {
  source         = "github.com/terraform-google-modules/terraform-google-vpc-service-controls//modules/regular_service_perimeter?ref=v4.0.1"
  policy         = local.policy_name
  perimeter_name = "dev_data_perimeter"
  description    = "Dev data perimeter"

  resources_dry_run = [
    "995266140210", # gclt-dev-data-49e8
    "562785644407", # gclt-dev-sandvoice-28418
    "411347008907", # gclt-dev-sandbox-11c8
    "774168718402", # gclt-dev-sandcolt-45903
    "54731519695",  # gclt-dev-sandland-00c4
    "207471620955"  # gclt-dev-sandlane-29c3
  ]

  restricted_services_dry_run = local.restricted_services

  ingress_policies_dry_run = [
    {
      "from" = {
        "sources" = {
          "access_levels" = [
            module.access_level.name
          ]
        },
        "identity_type" = "ANY_IDENTITY"
      }
      "to" = {
        "resources" = ["*"],
        "operations" = {
          "*" = {
            "methods" = ["*"]
          }
        }
      }
    },
  ]
  shared_resources = {
    all = [
      "995266140210",
      "562785644407",
      "284101603217",
      "411347008907",
      "774168718402",
      "54731519695",
      "207471620955"
    ]
  }
}

module "dev_logs_perimeter" {
  source         = "github.com/terraform-google-modules/terraform-google-vpc-service-controls//modules/regular_service_perimeter?ref=v4.0.1"
  policy         = local.policy_name
  perimeter_name = "dev_logs_perimeter"
  description    = "Dev logs perimeter"

  resources_dry_run = [
    "490067441898" # gclt-dev-auditlogs-ac84
  ]

  restricted_services_dry_run = local.restricted_services

  ingress_policies_dry_run = [
    {
      "from" = {
        "sources" = {
          "access_levels" = [
            module.access_level.name
          ]
        },
        "identity_type" = "ANY_IDENTITY"
      }
      "to" = {
        "resources" = ["*"],
        "operations" = {
          "*" = {
            "methods" = ["*"]
          }
        }
      }
    },
  ]

  shared_resources = {
    all = ["490067441898"]
  }
}

module "dev_logs_it_perimeter" {
  source         = "github.com/terraform-google-modules/terraform-google-vpc-service-controls//modules/regular_service_perimeter?ref=v4.0.1"
  policy         = local.policy_name
  perimeter_name = "dev_logs_it_perimeter"
  description    = "Dev logs it perimeter"

  resources_dry_run = [
    "920317306248" # gclt-dev-auditlogs-175b
  ]

  restricted_services_dry_run = local.restricted_services

  ingress_policies_dry_run = [
    {
      "from" = {
        "sources" = {
          "access_levels" = [
            module.access_level.name
          ]
        },
        "identity_type" = "ANY_IDENTITY"
      }
      "to" = {
        "resources" = ["*"],
        "operations" = {
          "*" = {
            "methods" = ["*"]
          }
        }
      }
    },
  ]

  shared_resources = {
    all = ["920317306248"]
  }
}

module "prd_data_perimeter" {
  source         = "github.com/terraform-google-modules/terraform-google-vpc-service-controls//modules/regular_service_perimeter?ref=v4.0.1"
  policy         = local.policy_name
  perimeter_name = "prd_data_perimeter"
  description    = "Prod data perimeter"

  restricted_services_dry_run = local.restricted_services

  resources_dry_run = [
    "683960339005" # gclt-prd-data-3148
  ]

  ingress_policies_dry_run = [
    {
      "from" = {
        "sources" = {
          "access_levels" = [
            module.access_level.name
          ]
        },
        "identity_type" = "ANY_IDENTITY"
      }
      "to" = {
        "resources" = ["*"],
        "operations" = {
          "*" = {
            "methods" = ["*"]
          }
        }
      }
    },
  ]
  shared_resources = {
    all = ["683960339005"]
  }
}

module "prd_logs_perimeter" {
  source         = "github.com/terraform-google-modules/terraform-google-vpc-service-controls//modules/regular_service_perimeter?ref=v4.0.1"
  policy         = local.policy_name
  perimeter_name = "prd_logs_perimeter"
  description    = "Prod logs perimeter"

  resources_dry_run = [
    "954028938975" # gclt-prd-auditlogs-ed9c
  ]

  restricted_services_dry_run = local.restricted_services

  ingress_policies_dry_run = [
    {
      "from" = {
        "sources" = {
          "access_levels" = [
            module.access_level.name
          ]
        },
        "identity_type" = "ANY_IDENTITY"
      }
      "to" = {
        "resources" = ["*"],
        "operations" = {
          "*" = {
            "methods" = ["*"]
          }
        }
      }
    },
  ]

  shared_resources = {
    all = ["954028938975"]
  }
}

module "prd_logs_it_perimeter" {
  source         = "github.com/terraform-google-modules/terraform-google-vpc-service-controls//modules/regular_service_perimeter?ref=v4.0.1"
  policy         = local.policy_name
  perimeter_name = "prd_logs_it_perimeter"
  description    = "Prod logs it perimeter"

  resources_dry_run = [
    "594863348881" # gclt-prd-auditlogs-0c77
  ]

  restricted_services_dry_run = local.restricted_services

  ingress_policies_dry_run = [
    {
      "from" = {
        "sources" = {
          "access_levels" = [
            module.access_level.name
          ]
        },
        "identity_type" = "ANY_IDENTITY"
      }
      "to" = {
        "resources" = ["*"],
        "operations" = {
          "*" = {
            "methods" = ["*"]
          }
        }
      }
    },
  ]

  shared_resources = {
    all = ["594863348881"]
  }
}

module "tst_data_perimeter" {
  source         = "github.com/terraform-google-modules/terraform-google-vpc-service-controls//modules/regular_service_perimeter?ref=v4.0.1"
  policy         = local.policy_name
  perimeter_name = "tst_data_perimeter"
  description    = "Test data perimeter"

  restricted_services_dry_run = local.restricted_services

  resources_dry_run = [
    "704600422002" # gclt-tst-data-d89d
  ]

  ingress_policies_dry_run = [
    {
      "from" = {
        "sources" = {
          "access_levels" = [
            module.access_level.name
          ]
        },
        "identity_type" = "ANY_IDENTITY"
      }
      "to" = {
        "resources" = ["*"],
        "operations" = {
          "*" = {
            "methods" = ["*"]
          }
        }
      }
    },
  ]
  shared_resources = {
    all = ["704600422002"]
  }
}

module "tst_logs_perimeter" {
  source         = "github.com/terraform-google-modules/terraform-google-vpc-service-controls//modules/regular_service_perimeter?ref=v4.0.1"
  policy         = local.policy_name
  perimeter_name = "tst_logs_perimeter"
  description    = "Test logs perimeter"

  resources_dry_run = [
    "687269795163" # gclt-tst-auditlogs-6b4b
  ]

  restricted_services_dry_run = local.restricted_services

  ingress_policies_dry_run = [
    {
      "from" = {
        "sources" = {
          "access_levels" = [
            module.access_level.name
          ]
        },
        "identity_type" = "ANY_IDENTITY"
      }
      "to" = {
        "resources" = ["*"],
        "operations" = {
          "*" = {
            "methods" = ["*"]
          }
        }
      }
    },
  ]

  shared_resources = {
    all = ["687269795163"]
  }
}

module "tst_logs_it_perimeter" {
  source         = "github.com/terraform-google-modules/terraform-google-vpc-service-controls//modules/regular_service_perimeter?ref=v4.0.1"
  policy         = local.policy_name
  perimeter_name = "tst_logs_it_perimeter"
  description    = "Test logs it perimeter"

  resources_dry_run = [
    "1021297158518" # gclt-tst-auditlogs-a8e8
  ]

  restricted_services_dry_run = local.restricted_services

  ingress_policies_dry_run = [
    {
      "from" = {
        "sources" = {
          "access_levels" = [
            module.access_level.name
          ]
        },
        "identity_type" = "ANY_IDENTITY"
      }
      "to" = {
        "resources" = ["*"],
        "operations" = {
          "*" = {
            "methods" = ["*"]
          }
        }
      }
    },
  ]

  shared_resources = {
    all = ["1021297158518"]
  }
}

module "transit_network_perimeter" {
  source         = "github.com/terraform-google-modules/terraform-google-vpc-service-controls//modules/regular_service_perimeter?ref=v4.0.1"
  policy         = local.policy_name
  perimeter_name = "transit_network_perimeter"
  description    = "Transit network perimeter"

  restricted_services_dry_run = local.restricted_services

  resources_dry_run = [
    "937432298127" # gclt-shr-transit-network-f636
  ]

  ingress_policies_dry_run = [
    {
      "from" = {
        "sources" = {
          "access_levels" = [
            module.access_level.name
          ]
        },
        "identity_type" = "ANY_IDENTITY"
      }
      "to" = {
        "resources" = ["*"],
        "operations" = {
          "*" = {
            "methods" = ["*"]
          }
        }
      }
    },
  ]
  shared_resources = {
    all = ["937432298127"]
  }
}

module "dev_network_perimeter" {
  source         = "github.com/terraform-google-modules/terraform-google-vpc-service-controls//modules/regular_service_perimeter?ref=v4.0.1"
  policy         = local.policy_name
  perimeter_name = "dev_network_perimeter"
  description    = "Dev network perimeter"

  restricted_services_dry_run = local.restricted_services

  resources_dry_run = [
    "805865274527" # gclt-dev-network-7ec8
  ]

  ingress_policies_dry_run = [
    {
      "from" = {
        "sources" = {
          "access_levels" = [
            module.access_level.name
          ]
        },
        "identity_type" = "ANY_IDENTITY"
      }
      "to" = {
        "resources" = ["*"],
        "operations" = {
          "*" = {
            "methods" = ["*"]
          }
        }
      }
    },
  ]
  shared_resources = {
    all = ["805865274527"]
  }
}

module "tst_network_perimeter" {
  source         = "github.com/terraform-google-modules/terraform-google-vpc-service-controls//modules/regular_service_perimeter?ref=v4.0.1"
  policy         = local.policy_name
  perimeter_name = "tst_network_perimeter"
  description    = "Test network perimeter"

  restricted_services_dry_run = local.restricted_services

  resources_dry_run = [
    "736003361866" # gclt-tst-network-3332
  ]

  ingress_policies_dry_run = [
    {
      "from" = {
        "sources" = {
          "access_levels" = [
            module.access_level.name
          ]
        },
        "identity_type" = "ANY_IDENTITY"
      }
      "to" = {
        "resources" = ["*"],
        "operations" = {
          "*" = {
            "methods" = ["*"]
          }
        }
      }
    },
  ]
  shared_resources = {
    all = ["736003361866"]
  }
}

module "prd_network_perimeter" {
  source         = "github.com/terraform-google-modules/terraform-google-vpc-service-controls//modules/regular_service_perimeter?ref=v4.0.1"
  policy         = local.policy_name
  perimeter_name = "prd_network_perimeter"
  description    = "Prod network perimeter"

  restricted_services_dry_run = local.restricted_services

  resources_dry_run = [
    "326566428770" # gclt-prd-network-9bfc
  ]

  ingress_policies_dry_run = [
    {
      "from" = {
        "sources" = {
          "access_levels" = [
            module.access_level.name
          ]
        },
        "identity_type" = "ANY_IDENTITY"
      }
      "to" = {
        "resources" = ["*"],
        "operations" = {
          "*" = {
            "methods" = ["*"]
          }
        }
      }
    },
  ]
  shared_resources = {
    all = ["326566428770"]
  }
}
