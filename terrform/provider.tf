provider "aws" {
  alias   = "source"
  region  = "${var.region}"
  profile = "hcltest"   #AWS profile to conneect to AWS Account/resources
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.65.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "hcltest-terraform-state-bucket"
    key            = "hcltest-terraform-state-bucket/key"
    region         = "us-east-1"
    dynamodb_table = "hcltest-terraform-lock-table"
    encrypt        = true
}
