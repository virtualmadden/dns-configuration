terraform {
  # tfstate bucket from aws-organization's account-baseline for shared-services-prod.
  backend "s3" {
    bucket       = "tfstate-908209634721-us-west-2"
    key          = "dns-configuration/terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
