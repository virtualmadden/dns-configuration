locals {
  records_by_key = {
    for rec in var.records :
    "${rec.name == "@" || rec.name == "" ? "apex" : rec.name}-${rec.type}" => rec
  }
}

resource "aws_route53_record" "this" {
  for_each = local.records_by_key

  zone_id = aws_route53_zone.this.zone_id
  name    = each.value.name == "@" || each.value.name == "" ? var.domain : "${each.value.name}.${var.domain}"
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records
}
