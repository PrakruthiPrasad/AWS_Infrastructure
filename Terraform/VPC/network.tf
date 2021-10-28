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
  timeouts {
    create = "5m"
  }

  tags = {
    Name = var.public_rt
  }
}

// resource "aws_route_table_association" "crta_public_subnet" {

//   for_each = local.subnet_az_cidr

//   subnet_id      = aws_subnet.subnet[each.key].id
//   route_table_id = aws_route_table.public_crt.id
// }

resource "aws_route_table_association" "crta_public_subnet1" {

  //depends_on = [aws_vpc.subnet1]
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.public_crt.id
}

resource "aws_route_table_association" "crta_public_subnet2" {

  //depends_on = [aws_vpc.subnet2]
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.public_crt.id
}

resource "aws_route_table_association" "crta_public_subnet3" {

  //depends_on = [aws_vpc.subnet3]
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.public_crt.id
}


resource "aws_security_group" "application_security_group" {
  depends_on = [aws_vpc.vpc]
  vpc_id     = aws_vpc.vpc.id

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = var.protocol
    description = "PORT 22"
    cidr_blocks = [var.dest_cidr_block]
  }

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = var.protocol
    description = "PORT 80"
    cidr_blocks = [var.dest_cidr_block]
  }

  ingress {
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = var.protocol
    description = "PORT 443"
    cidr_blocks = [var.dest_cidr_block]
  }

  ingress {
    from_port   = var.custom_tcp_port
    to_port     = var.custom_tcp_port
    protocol    = var.protocol
    description = "PORT 8080"
    cidr_blocks = [var.dest_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.dest_cidr_block]
  }

  tags = {
    Name = var.SG_name
  }
}


resource "aws_security_group" "database_security_group" {
  depends_on = [aws_vpc.vpc]

  vpc_id      = aws_vpc.vpc.id
  description = "Allow application traffic"

  ingress {
    from_port       = var.http_port
    to_port         = var.db_port
    protocol        = var.protocol
    description     = "PORT 3306"
    security_groups = ["${aws_security_group.application_security_group.id}"]
    cidr_blocks     = [var.dest_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.dest_cidr_block]
  }

  tags = {
    Name = var.db_sg_name
  }
}
