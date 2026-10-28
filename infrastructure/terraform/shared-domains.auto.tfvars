# Domains whose Route53 zones live in shared services. This repo creates each zone,
# manages its static records (domain_records), and points Porkbun at it.
# A domain belongs here or in project-domains.auto.tfvars, never both.

shared_domains = [
  # "example.com",
]
