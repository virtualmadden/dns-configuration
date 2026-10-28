resource "aws_route53_zone" "this" {
  name = var.domain

  tags = merge(var.tags, {
    Domain = var.domain
  })
}

resource "porkbun_domain_nameservers" "this" {
  domain      = var.domain
  nameservers = aws_route53_zone.this.name_servers
}
