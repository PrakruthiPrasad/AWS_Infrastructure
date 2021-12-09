
data "aws_ami" "ami_image" {
  most_recent = true

  owners = [var.owners]
}

# KMS key for EBS
resource "aws_kms_key" "ebs_kms_key" {
  description = "ebs_encryption"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Id": "key-consolepolicy-3",
  "Statement": [
    {
      "Sid": "Allow administration of the key",
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::655530355528:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow ServiceLinked Role CMK",
      "Effect": "Allow",
      "Principal": {
          "AWS": [
              "arn:aws:iam::655530355528:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
      },
      "Action": [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:Update*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow attachment of persistent resources",
      "Effect": "Allow",
      "Principal": {
          "AWS": [
              "arn:aws:iam::655530355528:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
      },
      "Action": [
          "kms:CreateGrant"
      ],
      "Resource": "*"
    }
  ]}
EOF
}

resource "aws_kms_alias" "ebs_kms_key_alias" {
  name          = "alias/ebsKey"
  target_key_id = aws_kms_key.ebs_kms_key.key_id
}

resource "aws_ebs_encryption_by_default" "ebs_encryption_default" {
  enabled = true
}

resource "aws_ebs_default_kms_key" "ebs_encryption_kms_key" {
  key_arn = aws_kms_key.ebs_kms_key.arn
}


resource "aws_launch_configuration" "asg_launch_config" {
  //subnet_id               = aws_subnet.subnet3.id
  name          = "asg_launch_config"
  image_id      = data.aws_ami.ami_image.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.key_pair.id
  //disable_api_termination = var.disable_api_termination
  security_groups      = ["${aws_security_group.application_security_group.id}"]
  iam_instance_profile = aws_iam_instance_profile.ec2_iam_role_profile.name

  lifecycle {
    create_before_destroy = true
  }

  ebs_block_device {
    //kms_key_id            = aws_kms_key.ebs_kms_key.arn
    encrypted             = true
    device_name           = var.device_name
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = "true"
  }


  user_data = <<-EOF
              #!/bin/bash
              sudo echo "export DB_URL=${aws_db_instance.rds_instance.endpoint}" >> /etc/environment
              sudo echo "export DB_URL_REPLICA=${aws_db_instance.rds_instance_Replica.endpoint}" >> /etc/environment
              sudo echo "export DB_PORT=${var.db_port}" >> /etc/environment
              sudo echo "export S3_BUCKET_NAME=${aws_s3_bucket.bucket.bucket}" >> /etc/environment
              sudo echo "export DB_NAME=${aws_db_instance.rds_instance.name}" >> /etc/environment
              sudo echo "export DB_USER=${aws_db_instance.rds_instance.username}" >> /etc/environment
              sudo echo "export DB_PWD=${aws_db_instance.rds_instance.password}" >> /etc/environment
              sudo echo "export S3_ENDPOINT=${var.S3_ENDPOINT}" >> /etc/environment
              sudo echo "export REGION=${var.regionName}" >> /etc/environment
              sudo echo "export SSN_ARN=${aws_sns_topic.EmailNotification.arn}" >> /etc/environment
              wget https://s3.amazonaws.com/rds-downloads/rds-ca-2019-root.pem
              sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
              keytool -import -alias springboot -file rds-ca-2019-root.pem -keystore springboot.p12 -storepass prakruthi
              EOF


  // tags = {
  //   name = var.ec2name
  // }
}

//Auto scaling group
resource "aws_autoscaling_group" "asg" {
  name                 = "auto_scaling_group"
  max_size             = 5
  min_size             = 3
  desired_capacity     = 3
  default_cooldown     = 60
  target_group_arns    = ["${aws_lb_target_group.loadBalancerTargetGroup.arn}"]
  launch_configuration = aws_launch_configuration.asg_launch_config.id
  vpc_zone_identifier  = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id]
  //   health_check_type    = "EC2"
  //   load_balancers = [
  //     aws_lb.webappLB.name
  //   ]
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
  // metrics_granularity = "1Minute"
  //   # Required to redeploy without an outage.
  //   lifecycle {
  //     create_before_destroy = true
  //   }
  tag {
    key                 = "name"
    propagate_at_launch = true
    value               = "CSYE6225_AutoScaling_Group"
  }
}
