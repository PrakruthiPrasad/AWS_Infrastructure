
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

// VPC
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

// // Subnet
// resource "aws_subnet" "subnet" {

//   depends_on = [aws_vpc.vpc]

//   for_each = local.subnet_az_cidr

//   vpc_id                  = aws_vpc.vpc.id
//   cidr_block              = each.value
//   availability_zone       = each.key
//   map_public_ip_on_launch = local.map_public_ip_on_launch
//   //subnet_id               = each.key.id


//   tags = {
//     Name = var.subnet_name
//   }
// }

// Subnet
resource "aws_subnet" "subnet1" {

  depends_on = [aws_vpc.vpc]

  //for_each = local.subnet_az_cidr

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr_block1
  availability_zone       = format("%s%s", var.regionName, "a")
  map_public_ip_on_launch = local.map_public_ip_on_launch
  tags = {
    Name = format("%s-%s", var.vpc_name, "subnet1")
  }
}

// Subnet2
resource "aws_subnet" "subnet2" {

  depends_on = [aws_vpc.vpc]

  //for_each = local.subnet_az_cidr

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr_block2
  availability_zone       = format("%s%s", var.regionName, "b")
  map_public_ip_on_launch = local.map_public_ip_on_launch
  tags = {
    Name = format("%s-%s", var.vpc_name, "subnet2")
  }
}

// Subnet2
resource "aws_subnet" "subnet3" {

  depends_on = [aws_vpc.vpc]

  //for_each = local.subnet_az_cidr

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr_block3
  availability_zone       = format("%s%s", var.regionName, "c")
  map_public_ip_on_launch = local.map_public_ip_on_launch
  tags = {
    Name = format("%s-%s", var.vpc_name, "subnet3")
  }
}


// Subnet group
resource "aws_db_subnet_group" "subnet_group" {
  description = "Terraform RDS subnet group"
  subnet_ids  = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id]
  tags = {
    Name = var.subnetGroup
  }
}

resource "random_string" "rs" {
  length  = 6
  special = false
  lower   = true
  upper   = false
  number  = true
}

locals {
  BUCKET_NAME = [
    random_string.rs.id,
    var.envName,
    var.bucketname
  ]
}

resource "aws_s3_bucket" "bucket" {
  bucket        = "${random_string.rs.id}.${var.profileName}.csye6225dnsbagur.me"
  force_destroy = true
  acl           = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  cors_rule {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET", "POST", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  lifecycle_rule {
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

// RDS instance
resource "aws_db_instance" "rds_instance" {

  depends_on = [aws_db_subnet_group.subnet_group]

  identifier                = var.identifier
  allocated_storage         = var.allocated_storage
  multi_az                  = var.multi_az
  engine                    = var.engine
  engine_version            = var.engine_version
  instance_class            = var.instance_class
  name                      = var.database_name
  username                  = var.username
  password                  = var.password
  db_subnet_group_name      = aws_db_subnet_group.subnet_group.id
  vpc_security_group_ids    = ["${aws_security_group.database_security_group.id}"]
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier
  publicly_accessible       = var.publicly_accessible
}

output "rds_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}

//RDS parameter group
resource "aws_db_parameter_group" "rds_parameter_group" {

  name   = var.name
  family = var.family

  parameter {
    name         = var.parameter1_name
    value        = var.value1
    apply_method = var.apply_method
  }
  parameter {
    name         = var.parameter2_name
    value        = var.value2
    apply_method = var.apply_method
  }
}


//IAM role
resource "aws_iam_role" "ec2_iam_role" {
  name               = var.IAMRoleName
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    name = var.IAMRoleName
  }
}


resource "aws_iam_policy" "WebAppS3" {
  name   = aws_s3_bucket.bucket.bucket
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:ListBucketVersions",
                "s3:GetBucketLocation",
                "s3:Get*",
                "s3:Put*",
                "s3:Delete*"
            ],
            "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}"
        }
    ]
}
POLICY
}

// IAM policy attachment
resource "aws_iam_policy_attachment" "iam-policy-attach" {
  name       = "Iam_policy_attachment"
  roles      = ["${aws_iam_role.ec2_iam_role.name}"]
  policy_arn = aws_iam_policy.WebAppS3.arn
}

// IAM instance profile
resource "aws_iam_instance_profile" "ec2_iam_role_profile" {
  name = var.IAMRoleProfile
  role = "EC2-CSYE6225"
  //aws_iam_role.ec2_iam_role.name
}
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = file("${var.PUBLIC_KEY_PATH}")

}

data "aws_ami" "ami_image" {
  most_recent = true

  owners = [var.owners]
  //  filter {
  //   name = "name"
  //   values = ["csye6225_1635818160"]
    
  // }
}


//EC2 instance
resource "aws_instance" "EC2_instance" {
  subnet_id               = aws_subnet.subnet3.id
  ami                     = data.aws_ami.ami_image.id
  instance_type           = var.instance_type
  key_name                = aws_key_pair.key_pair.id
  disable_api_termination = var.disable_api_termination
  vpc_security_group_ids  = ["${aws_security_group.application_security_group.id}"]
  iam_instance_profile    = aws_iam_instance_profile.ec2_iam_role_profile.name

  ebs_block_device {
    device_name = var.device_name
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo echo "export DB_URL=${aws_db_instance.rds_instance.endpoint}" >> /etc/environment
              sudo echo "export DB_PORT=${var.db_port}" >> /etc/environment
              sudo echo "export S3_BUCKET_NAME=${aws_s3_bucket.bucket.bucket}" >> /etc/environment
              sudo echo "export DB_NAME=${aws_db_instance.rds_instance.name}" >> /etc/environment
              sudo echo "export DB_USER=${aws_db_instance.rds_instance.username}" >> /etc/environment
              sudo echo "export DB_PWD=${aws_db_instance.rds_instance.password}" >> /etc/environment
              sudo echo "export S3_ENDPOINT=${var.S3_ENDPOINT}" >> /etc/environment
              sudo echo "export REGION=${var.regionName}" >> /etc/environment
              sudo echo "export accessKeyId=${var.accessKey}" >> /etc/environment
              sudo echo "export secretKey=${var.secretAccessKey}" >> /etc/environment
              EOF


  tags = {
    name = var.ec2name
  }
}




