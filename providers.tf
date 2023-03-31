terraform {
  required_version = ">= 1.3.0, < 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.50.0"
    }
  }

}

provider "aws" {
  region = "ap-northeast-1"
}
