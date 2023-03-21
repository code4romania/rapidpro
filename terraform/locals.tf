locals {
  namespace = var.env

  # Target AZ
  availability_zone = data.aws_availability_zones.current.names[0]

  elasticache_url = "redis://${aws_elasticache_cluster.main.cache_nodes.0.address}:${aws_elasticache_cluster.main.port}/15"

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
