output "route53_zone_id" {
  description = "Route53 hosted zone ID."
  value       = aws_route53_zone.this.zone_id
}

output "route53_name_servers" {
  description = "Route53 delegation nameservers (set at Porkbun)."
  value       = aws_route53_zone.this.name_servers
}

output "record_fqdns" {
  description = "FQDNs of managed Route53 records."
  value       = [for key, rec in aws_route53_record.this : rec.fqdn]
}
