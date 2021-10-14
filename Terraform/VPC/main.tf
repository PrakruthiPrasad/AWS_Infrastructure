
locals {
  enable_dns_support               = true
  enable_dns_hostnames             = true
  enable_classiclink_dns_support   = false
  assign_generated_ipv6_cidr_block = false
  map_public_ip_on_launch          = true
  //instance_tenancy = default  

  subnet_az_cidr = {
    "us-east-1a" = var.subnet_cidr_block1,
    "us-east-1b" = var.subnet_cidr_block2,
    "us-east-1c" = var.subnet_cidr_block3,
  }
}

resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_cidr_block
  enable_dns_support               = local.enable_dns_support
  enable_dns_hostnames             = local.enable_dns_hostnames
  enable_classiclink_dns_support   = local.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = local.assign_generated_ipv6_cidr_block

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "subnet" {

  depends_on = [aws_vpc.vpc]

  for_each = local.subnet_az_cidr

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = local.map_public_ip_on_launch


  tags = {
    Name = var.subnet_name
  }
}

