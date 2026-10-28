terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.71"
    }
    porkbun = {
      source  = "jianyuan/porkbun"
      version = "~> 0.3.4"
    }
  }
}
