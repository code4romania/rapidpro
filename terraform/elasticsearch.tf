resource "aws_iam_service_linked_role" "es" {
  count            = var.create_iam_service_linked_role ? 1 : 0
  aws_service_name = "es.amazonaws.com"
}

resource "aws_elasticsearch_domain" "rapidpro" {
  domain_name           = "rapidpro"
  elasticsearch_version = "7.10"


  cluster_config {
    instance_type            = "t3.small.elasticsearch"
    instance_count           = 1
    dedicated_master_count   = 0
    dedicated_master_enabled = false
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp3"
    volume_size = 10
  }

  vpc_options {
    subnet_ids = [
      element(aws_subnet.private.*.id, 0)
    ]

    security_group_ids = [aws_security_group.elasticsearch.id]
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/rapidpro/*"
        }
    ]
}
CONFIG

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags = {
    Domain = "production"
  }

  depends_on = [aws_iam_service_linked_role.es]
}


resource "aws_security_group" "elasticsearch" {
  name   = "${local.namespace}-elasticsearch-rapidpro"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.vpc.cidr_block]
  }
}
