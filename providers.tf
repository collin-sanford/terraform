#########################################################################################################
# Provider
#########################################################################################################

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.39.0"
    }
  }
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "us-east-1"
  default_tags {
    tags = {
      Name     = "${var.name}"
      Environment         = "${var.environment}"
    }
  }
}