# Static records for zones hosted in the shared services account, keyed by domain.
# Every domain here must also be in shared-domains.auto.tfvars.

# Domains here publish their own mail records instead of the no-mail defaults.
mail_domains = ["virtualmadden.dev"]

# Addresses that may send through SES (mail.tf). Receiving is separate: Porkbun forwards
# virtualmadden.dev's mail.
sending_addresses = ["hello@virtualmadden.dev"]

domain_records = {
  # virtualmadden-dev-prod (502869771296). Values come from that project's Terraform:
  # the CloudFront distribution's domain and the ACM certificate's validation records.
  "virtualmadden.dev" = [
    { name = "@", type = "A", alias = { name = "d1hp90nzgrdrzs.cloudfront.net", zone_id = "Z2FDTNDATAQYW2" } },
    { name = "@", type = "AAAA", alias = { name = "d1hp90nzgrdrzs.cloudfront.net", zone_id = "Z2FDTNDATAQYW2" } },
    { name = "www", type = "A", alias = { name = "d1hp90nzgrdrzs.cloudfront.net", zone_id = "Z2FDTNDATAQYW2" } },
    { name = "www", type = "AAAA", alias = { name = "d1hp90nzgrdrzs.cloudfront.net", zone_id = "Z2FDTNDATAQYW2" } },
    {
      name    = "_722b089ed83f648c2a3048c187abb75d"
      type    = "CNAME"
      records = ["_5da8cc16167d1990836df7ac9250e6a5.wzccmgtwzk.acm-validations.aws."]
    },
    {
      name    = "_fc0ac3dca90c4d9d8f0b6c540e5be351.www"
      type    = "CNAME"
      records = ["_8f115760a76baad8213b5f21a0dfa4ba.wzccmgtwzk.acm-validations.aws."]
    },
    # Porkbun email forwarding, receive only: replies come from the destination mailbox, so
    # nothing else may send as the domain, and DMARC still rejects anything that tries.
    { name = "@", type = "MX", ttl = 3600, records = ["10 fwd1.porkbun.com.", "20 fwd2.porkbun.com."] },
    { name = "@", type = "TXT", ttl = 3600, records = ["v=spf1 include:_spf.porkbun.com -all"] },
    { name = "_dmarc", type = "TXT", ttl = 3600, records = ["v=DMARC1; p=reject;"] },
  ]
}
