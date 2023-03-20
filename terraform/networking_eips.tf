
resource "aws_eip" "nat_gateway" {
  vpc = true
  tags = {
    Name = "${local.namespace}-nat-gateway"
  }
}

# resource "aws_eip" "bastion" {
#   instance = aws_instance.bastion.id
#   vpc      = true
#   tags = {
#     Name = "${local.namespace}-bastion"
#   }
# }
