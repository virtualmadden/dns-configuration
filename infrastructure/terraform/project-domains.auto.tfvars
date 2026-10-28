# Domains whose Route53 zones live in project accounts.
# A project creates its own hosted zone, then opens a PR here adding the zone's
# four nameservers. Applying sets the domain's nameservers at Porkbun.
#
# Get the nameservers from the project account:
#   aws route53 get-hosted-zone --id ZONE_ID --query 'DelegationSet.NameServers'

project_domains = {
  # virtualmadden-dev-prod (502869771296), zone Z0426664394IQEBVGX8ZP
  "virtualmadden.dev" = {
    project = "virtualmadden-dev"
    nameservers = [
      "ns-1018.awsdns-63.net",
      "ns-1241.awsdns-27.org",
      "ns-145.awsdns-18.com",
      "ns-1851.awsdns-39.co.uk",
    ]
  }

  # "otherdomain.com" = {
  #   project = "my-app"
  #   nameservers = [
  #     "ns-123.awsdns-15.com",
  #     "ns-456.awsdns-57.net",
  #     "ns-789.awsdns-34.org",
  #     "ns-1234.awsdns-12.co.uk",
  #   ]
  # }
}
