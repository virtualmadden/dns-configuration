variable "shared_domains" {
  description = "Domains whose Route53 zones live in the shared services account."
  type        = list(string)
  default     = []
}

variable "mail_domains" {
  description = "Shared domains that send or receive mail. Every other shared domain publishes records refusing all mail, so it can't be spoofed."
  type        = list(string)
  default     = []
}

variable "domain_records" {
  description = "Static records for shared services zones, keyed by domain."
  type = map(list(object({
    name    = string
    type    = string
    ttl     = optional(number, 300)
    records = optional(list(string))
    # Alias to an AWS resource (CloudFront, ALB, ...) in any account, in place of records.
    alias = optional(object({
      name    = string
      zone_id = string
    }))
  })))
  default = {}

  validation {
    condition     = alltrue([for rec in flatten(values(var.domain_records)) : (rec.records == null) != (rec.alias == null)])
    error_message = "Each record sets exactly one of records or alias."
  }
}

variable "project_domains" {
  description = "Domains whose Route53 zones live in project accounts, keyed by domain. Porkbun nameservers are set to the listed values."
  type = map(object({
    project     = optional(string)
    nameservers = list(string)
  }))
  default = {}

  validation {
    condition     = alltrue([for d in values(var.project_domains) : length(d.nameservers) >= 2])
    error_message = "Each project domain needs at least two nameservers (Route53 assigns four)."
  }
}

variable "tags" {
  description = "Tags applied to AWS resources."
  type        = map(string)
  default = {
    ManagedBy = "dns-configuration"
  }
}
