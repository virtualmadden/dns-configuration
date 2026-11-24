# Incoming mail through Porkbun forwarding, for the addresses in forwarding_addresses, and
# outgoing mail through SES, for the addresses in sending_addresses.
#
# Mail is signed with the domain's DKIM key and sent from a custom MAIL FROM subdomain, so it
# passes SPF and DKIM aligned with the domain and the domain's DMARC policy can stay at reject.

locals {
  forwarding_addresses = toset([for a in var.forwarding_addresses : lower(trimspace(a))])

  sending_addresses = toset([for a in var.sending_addresses : lower(trimspace(a))])
  sending_domains   = toset([for a in local.sending_addresses : split("@", a)[1]])

  # SES always issues three DKIM tokens; keying on their index keeps for_each known at plan.
  dkim_records = {
    for pair in setproduct(local.sending_domains, range(3)) : "${pair[0]}/${pair[1]}" => {
      domain = pair[0]
      index  = pair[1]
    }
  }
}

# Porkbun also writes forwarding MX and SPF records into its own DNS for the domain, which
# is unused because the domain is delegated to Route53. The records that matter are in
# domain_records.
resource "porkbun_email_forward" "this" {
  for_each = local.forwarding_addresses

  domain     = split("@", each.key)[1]
  address    = split("@", each.key)[0]
  forward_to = var.email_forward_to

  lifecycle {
    precondition {
      condition     = contains(local.mail_domains, split("@", each.key)[1])
      error_message = "${each.key} receives mail, so its domain must be in mail_domains or its MX refuses all mail."
    }

    precondition {
      condition     = var.email_forward_to != null
      error_message = "Set email_forward_to (TF_VAR_email_forward_to) to forward mail."
    }
  }
}

data "aws_region" "current" {}

resource "aws_sesv2_email_identity" "domain" {
  for_each = local.sending_domains

  email_identity = each.key

  dkim_signing_attributes {
    next_signing_key_length = "RSA_2048_BIT"
  }

  lifecycle {
    precondition {
      condition     = contains(local.shared_domains, each.key)
      error_message = "${each.key} sends mail, so it must be a shared domain whose zone this repo manages."
    }
  }
}

resource "aws_route53_record" "dkim" {
  for_each = local.dkim_records

  zone_id = module.zone[each.value.domain].route53_zone_id
  name    = "${aws_sesv2_email_identity.domain[each.value.domain].dkim_signing_attributes[0].tokens[each.value.index]}._domainkey.${each.value.domain}"
  type    = "CNAME"
  ttl     = 3600
  records = ["${aws_sesv2_email_identity.domain[each.value.domain].dkim_signing_attributes[0].tokens[each.value.index]}.dkim.amazonses.com"]
}

resource "aws_sesv2_email_identity_mail_from_attributes" "domain" {
  for_each = local.sending_domains

  email_identity         = aws_sesv2_email_identity.domain[each.key].email_identity
  mail_from_domain       = "mail.${each.key}"
  behavior_on_mx_failure = "REJECT_MESSAGE"
}

resource "aws_route53_record" "mail_from_mx" {
  for_each = local.sending_domains

  zone_id = module.zone[each.key].route53_zone_id
  name    = aws_sesv2_email_identity_mail_from_attributes.domain[each.key].mail_from_domain
  type    = "MX"
  ttl     = 3600
  records = ["10 feedback-smtp.${data.aws_region.current.region}.amazonses.com"]
}

resource "aws_route53_record" "mail_from_spf" {
  for_each = local.sending_domains

  zone_id = module.zone[each.key].route53_zone_id
  name    = aws_sesv2_email_identity_mail_from_attributes.domain[each.key].mail_from_domain
  type    = "TXT"
  ttl     = 3600
  records = ["v=spf1 include:amazonses.com -all"]
}

# Mail clients such as Gmail's "Send mail as" need SMTP credentials, which SES only issues
# for an IAM user. This user can do nothing but send as the listed addresses. Its access key
# is created outside Terraform (scripts/ses-smtp-credentials.sh), so the secret never
# reaches state.
resource "aws_iam_user" "ses_smtp" {
  count = length(local.sending_addresses) > 0 ? 1 : 0

  name = "ses-smtp"
  path = "/mail/"
}

data "aws_iam_policy_document" "ses_smtp" {
  count = length(local.sending_addresses) > 0 ? 1 : 0

  statement {
    actions   = ["ses:SendRawEmail"]
    resources = [for identity in aws_sesv2_email_identity.domain : identity.arn]

    condition {
      test     = "StringEquals"
      variable = "ses:FromAddress"
      values   = local.sending_addresses
    }
  }
}

resource "aws_iam_user_policy" "ses_smtp" {
  count = length(local.sending_addresses) > 0 ? 1 : 0

  name   = "send-as-listed-addresses"
  user   = aws_iam_user.ses_smtp[0].name
  policy = data.aws_iam_policy_document.ses_smtp[0].json
}
