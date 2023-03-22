locals {
  namespace = var.env

  # Target AZ
  availability_zone = data.aws_availability_zones.current.names[0]

  elasticache_url   = "redis://${aws_elasticache_cluster.main.cache_nodes.0.address}:${aws_elasticache_cluster.main.port}/15"
  elasticsearch_url = "https://${aws_opensearch_domain.main.endpoint}"

  domains = {
    rapidpro = "rapidpro.${var.domain_name}"

    ureport = {
      main = "ureport.${var.domain_name}"
      ro   = "ro.ureport.${var.domain_name}"
      uk   = "uk.ureport.${var.domain_name}"
    }
  }

  mail = {
    host = "email-smtp.${var.region}.amazonaws.com"
    port = 587
    from = "no-reply@${var.domain_name}"
  }

  networking = {
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
