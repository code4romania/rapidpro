variable "env" {
  description = "Environment"
  type        = string

  validation {
    condition     = contains(["production", "staging", "development"], var.env)
    error_message = "Allowed values for env are \"production\", \"staging\" or \"development\"."
  }
}

variable "enable_execute_command" {
  description = "Enable aws ecs execute_command"
  type        = bool
  default     = false
}

variable "region" {
  description = "Region"
  type        = string
}

variable "create_iam_service_linked_role" {
  description = "Whether to create `AWSServiceRoleForAmazonElasticsearchService` service-linked role. Set it to `false` if you already have an ElasticSearch cluster created in the AWS account and AWSServiceRoleForAmazonElasticsearchService already exists."
  type        = bool
  default     = true
}

variable "domain_name" {
  type = string
}

variable "mailroom_fcm_key" {
  description = "Firebase Cloud Messaging key used to sync Android channels"
  type        = string
  default     = ""
}

variable "run_migration" {
  description = "Whether to run migrations on rapidpro and ureport-web container init."
  type        = bool
  default     = true
}

variable "allow_signups" {
  description = "Whether to allow signups on rapidpro."
  type        = bool
  default     = false
}

variable "use_load_balancer" {
  type    = bool
  default = true
}
