terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.14.1"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.25.0"
    }
  }
  required_version = ">= 0.13"
}

provider "google" {
  project = var.project_id
}

provider "postgresql" {
  host = var.instance_host
  port = var.instance_port

  username = var.instance_user
  password = var.instance_password

  sslmode   = "require"
  superuser = false
}
