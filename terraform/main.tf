provider "digitalocean" {
  token = var.digitalocean_token
}

terraform {
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.5"
    }
  }

  backend "s3" {
    bucket     = "hummingbot-terraform"
    key        = "terraform.tfstate"
    region     = "auto"
    endpoint   = "https://622586854078fb4b8547f4d2289c15ab.r2.cloudflarestorage.com/hummingbot-terraform"
    access_key = var.r2_access_key
    secret_key = var.r2_secret_key

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}

data "secrets" {
  source_file = "secrets.yaml"
}
