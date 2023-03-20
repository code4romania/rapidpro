resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.networking.public_subnet
  availability_zone       = data.aws_availability_zone.current.name
  map_public_ip_on_launch = true

  tags = {
    Name   = "${local.namespace}-public"
    access = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.networking.private_subnet
  availability_zone       = data.aws_availability_zone.current.name
  map_public_ip_on_launch = false

  tags = {
    Name   = "${local.namespace}-private"
    access = "private"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${local.namespace}-db-private"
  subnet_ids = [aws_subnet.private.id]

  tags = {
    access = "private"
  }
}

resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  name       = "${local.namespace}-elasticache-private"
  subnet_ids = [aws_subnet.private.id]

  tags = {
    access = "private"
  }
}
