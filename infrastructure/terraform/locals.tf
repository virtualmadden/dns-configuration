locals {
  shared_domains = toset([for d in var.shared_domains : lower(trimspace(d))])
  mail_domains   = toset([for d in var.mail_domains : lower(trimspace(d))])

  # Published for every shared domain not in mail_domains: it accepts no mail (null MX,
  # RFC 7505) and receivers reject anything claiming to come from it (SPF, DMARC).
  no_mail_records = [
    { name = "@", type = "MX", ttl = 3600, records = ["0 ."] },
    { name = "@", type = "TXT", ttl = 3600, records = ["v=spf1 -all"] },
    { name = "_dmarc", type = "TXT", ttl = 3600, records = ["v=DMARC1; p=reject;"] },
  ]

  # Route53 console and CLI output include a trailing dot that Porkbun does not accept.
  project_domains = {
    for domain, cfg in var.project_domains : lower(trimspace(domain)) => {
      project     = cfg.project
      nameservers = [for ns in cfg.nameservers : lower(trimsuffix(trimspace(ns), "."))]
    }
  }
}
