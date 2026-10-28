output "shared_zones" {
  description = "Zones hosted in the shared services account."
  value = {
    for domain, mod in module.zone : domain => {
      route53_zone_id      = mod.route53_zone_id
      route53_name_servers = mod.route53_name_servers
      record_fqdns         = mod.record_fqdns
    }
  }
}

output "project_domains" {
  description = "Project-owned domains and the nameservers set at Porkbun."
  value = {
    for domain, cfg in local.project_domains : domain => {
      project     = cfg.project
      nameservers = porkbun_domain_nameservers.project[domain].nameservers
    }
  }
}
