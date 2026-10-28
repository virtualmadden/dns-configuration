variable "domain" {
  description = "Fully qualified domain name (e.g. example.com)."
  type        = string
}

variable "records" {
  description = "Static DNS records to create in the Route53 hosted zone."
  type = list(object({
    name    = string
    type    = string
    ttl     = optional(number, 300)
    records = list(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags for the Route53 hosted zone."
  type        = map(string)
  default     = {}
}
