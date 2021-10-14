variable "vpc_cidr_block" {
  type        = string
  description = "CIDR Block for VPC"
}

variable "subnet_cidr_block1" {
  type        = string
  description = "CIDR Block for Subnet1"
}

variable "subnet_cidr_block2" {
  type        = string
  description = "CIDR Block for Subnet2"
}

variable "subnet_cidr_block3" {
  type        = string
  description = "CIDR Block for Subnet3"
}

variable "vpc_name" {
  type        = string
  description = "name of vpc"
}
variable "dest_cidr_block" {
  type        = string
  description = "destination cidr block"
}


variable "subnet_name" {
  type        = string
  description = "name of subnet"
}
variable "internet_gateway" {
  type        = string
  description = "name of internet gateway"
}
variable "public_rt" {
  type        = string
  description = "name of public route table"
}
variable "regionName" {
  type        = string
  description = "region"
}

variable "profileName" {
  type        = string
  description = "Profile name"
}