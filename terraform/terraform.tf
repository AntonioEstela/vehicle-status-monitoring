terraform {
  backend "s3" {
    bucket = "vehicle-status-monitoring-terraform-state"
    key    = "global/s3/terraform.tfstate"
    region = "sa-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}
