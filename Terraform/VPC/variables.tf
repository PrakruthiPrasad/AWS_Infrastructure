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

variable "accessKey" {
  type        = string
  description = "access Key"
}

variable "secretAccessKey" {
  type        = string
  description = "secretAccessKey"
}

variable "subnetGroup" {
  type        = string
  description = "RDS subnet group"
}


//Variables for Security group
variable "SG_name" {
  type        = string
  description = "Security group name"
}

variable "db_sg_name" {
  type        = string
  description = "Security group name"
}

variable "protocol" {
  type        = string
  description = "Protocol for the security group"
}

variable "ssh_port" {
  type        = number
  description = "ssh port number"
}

variable "http_port" {
  type        = number
  description = "http port number"
}

variable "https_port" {
  type        = number
  description = "https port number"
}

variable "custom_tcp_port" {
  type        = number
  description = "custom tcp port number"
}

variable "db_port" {
  type        = number
  description = "db port number"
}

//Variables for RDS instance
variable "identifier" { type = string }
variable "allocated_storage" { type = number }
variable "multi_az" { type = bool }
variable "engine" { type = string }
variable "engine_version" { type = string }
variable "instance_class" { type = string }
variable "database_name" { type = string }
variable "username" { type = string }
variable "password" { type = string }
variable "db_subnet_group_name" { type = string }
variable "skip_final_snapshot" { type = bool }
variable "final_snapshot_identifier" { type = string }
variable "publicly_accessible" { type = bool }


//Variables for RDS parameter group
variable "name" { type = string }
variable "family" { type = string }
variable "parameter1_name" { type = string }
variable "value1" { type = string }
variable "parameter2_name" { type = string }
variable "value2" { type = string }
variable "apply_method" { type = string }


//Variables for EC2 instance
variable "ami" { type = string }
variable "owners" { type = string }
variable "instance_type" { type = string }
variable "disable_api_termination" { type = bool }
variable "user_data" { type = string }
variable "device_name" { type = string }
variable "volume_size" { type = number }
variable "volume_type" { type = string }
variable "key_name" { type = string }
variable "PUBLIC_KEY_PATH" { type = string }
variable "ec2name" { type = string }

//Variables for IAM roles and policy
variable "IAMRoleName" { type = string }
variable "IAMRoleProfile" { type = string }
variable "bucketname" { type = string }
variable "envName" { type = string }
variable "iam_policy_attach" { type = string }
variable "S3_ENDPOINT" { type = string }
