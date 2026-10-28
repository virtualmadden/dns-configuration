provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = var.tags
  }
}

provider "porkbun" {
  # api_key and secret_key from PORKBUN_API_KEY and PORKBUN_SECRET_KEY
}
