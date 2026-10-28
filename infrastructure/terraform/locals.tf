locals {
  shared_domains = toset([for d in var.shared_domains : lower(trimspace(d))])

  # Route53 console and CLI output include a trailing dot that Porkbun does not accept.
  project_domains = {
    for domain, cfg in var.project_domains : lower(trimspace(domain)) => {
      project     = cfg.project
      nameservers = [for ns in cfg.nameservers : lower(trimsuffix(trimspace(ns), "."))]
    }
  }
}
