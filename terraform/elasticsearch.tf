resource "aws_iam_service_linked_role" "es" {
  count            = var.create_iam_service_linked_role ? 1 : 0
  aws_service_name = "es.amazonaws.com"
}

resource "aws_opensearch_domain" "main" {
  domain_name    = "rapidpro"
  engine_version = "Elasticsearch_7.10"

  cluster_config {
    instance_type            = "t3.small.search"
    instance_count           = 2
    dedicated_master_count   = 0
    dedicated_master_enabled = false
    zone_awareness_enabled   = false
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp3"
    volume_size = 10
  }

  vpc_options {
    subnet_ids         = [aws_subnet.private.0.id]
    security_group_ids = [aws_security_group.opensearch.id]
  }

  access_policies = data.aws_iam_policy_document.opensearch.json

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

data "aws_iam_policy_document" "opensearch" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["es:*"]
    resources = ["arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/rapidpro/*"]
  }
}

resource "aws_security_group" "opensearch" {
  name   = "${local.namespace}-opensearch"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.networking.cidr_block]
  }
}
