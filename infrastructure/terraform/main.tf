module "zone" {
  source   = "./modules/zone"
  for_each = local.shared_domains

  domain  = each.key
  records = lookup(var.domain_records, each.key, [])
  tags    = var.tags
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
