terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.1.0"
    }

    tls = {
      source = "hashicorp/tls"
      version = "~>3.1.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile                 = "default"
  region                  = "us-west-2"
  shared_credentials_file = "/home/mk/.aws/credentials"
}

