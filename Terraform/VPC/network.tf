resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.internet_gateway
  }
}

resource "aws_route_table" "public_crt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.dest_cidr_block

    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.public_rt
  }
}

resource "aws_route_table_association" "crta_public_subnet" {

  for_each = local.subnet_az_cidr

  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.public_crt.id
}
