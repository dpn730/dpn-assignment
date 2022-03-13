terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.39.0"
      # # declares both aws and aws.mgmt
      # # TODO: requires TF 0.15
      # configuration_aliases = [ aws.mgmt ]
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}
