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

variable "rapidpro_public_domain" {
  type = string
}
