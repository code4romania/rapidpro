variable "name" {
  description = "Name to be used throughout the resources"
  type        = string
}

variable "price_class" {
  description = "Price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100."
  type        = string
  default     = "PriceClass_100"
}

variable "http_version" {
  description = "Maximum HTTP version to support on the distribution. Allowed values are http1.1, http2, http2and3 and http3. The default is http2."
  type        = string
  default     = "http2"
}

variable "bucket" {
  description = "Name of the bucket"
  type        = string
}
