variable "env" {
  description = "Environment"
  type        = string

  validation {
    condition     = contains(["production", "staging", "development"], var.env)
    error_message = "Allowed values for env are \"production\", \"staging\" or \"development\"."
  }
}

variable "debug" {
  description = "Enable debug mode"
  type        = bool
  default     = false
}

variable "region" {
  description = "Region where to deploy resources"
  type        = string
  default     = "eu-central-1"
}

variable "create_iam_service_linked_role" {
  description = "Whether to create `AWSServiceRoleForAmazonElasticsearchService` service-linked role. Set it to `false` if you already have an ElasticSearch cluster created in the AWS account and AWSServiceRoleForAmazonElasticsearchService already exists."
  type        = bool
  default     = true
}

variable "rapidpro_public_domain" {
  type = string
}

variable "ses_domain" {
  type = string
}

variable "ses_domain_zone_id" {
  type = string
}

variable "mailroom_fcm_key" {
  description = "Firebase Cloud Messaging key used to sync Android channels"
  type        = string
  default     = ""
}
