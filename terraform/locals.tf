locals {
  namespace = "rapidpro-${var.env}"

  archiver = {
    namespace = "archiver-${var.env}"
  }

  courier = {
    namespace = "courier-${var.env}"
  }

  indexer = {
    namespace = "indexer-${var.env}"
  }

  mailroom = {
    namespace = "mailroom-${var.env}"
  }

  vpc = {
    cidr_block = "10.0.0.0/16"

    public_subnets = [
      "10.0.1.0/24",
      "10.0.2.0/24",
      "10.0.3.0/24"
    ]

    private_subnets = [
      "10.0.4.0/24",
      "10.0.5.0/24",
      "10.0.6.0/24"
    ]
  }
}
