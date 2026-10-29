module "zone" {
  source   = "./modules/zone"
  for_each = local.shared_domains

  domain = each.key
  records = concat(
    lookup(var.domain_records, each.key, []),
    contains(local.mail_domains, each.key) ? [] : local.no_mail_records,
  )
  tags = var.tags
}

resource "porkbun_domain_nameservers" "project" {
  for_each = local.project_domains

  domain      = each.key
  nameservers = each.value.nameservers

  lifecycle {
    precondition {
      condition     = !contains(local.shared_domains, each.key)
      error_message = "${each.key} is in both shared_domains and project_domains. A domain's zone lives in either shared services or a project account, not both."
    }
  }
}

# virtualmadden.dev moved from its project account's zone to a shared zone; update its
# Porkbun nameservers in place rather than resetting and re-setting them.
moved {
  from = porkbun_domain_nameservers.project["virtualmadden.dev"]
  to   = module.zone["virtualmadden.dev"].porkbun_domain_nameservers.this
}
