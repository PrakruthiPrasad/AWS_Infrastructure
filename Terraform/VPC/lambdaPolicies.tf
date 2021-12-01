data "aws_caller_identity" "current" {}

resource "aws_iam_role" "CodeDeployAWSLambdaRole" {
  name               = var.lambdaRoleName
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    Name = "CodeDeployAWSLambdaRole"
  }
}

resource "aws_iam_policy" "EC2-To-SNS" {
  name        = "EC2-To-SNS"
  description = "A Upload policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
   "Statement": [
            {
              "Sid": "AllowEC2ToPublishToSNSTopic",
              "Effect": "Allow",
              "Action": ["sns:Publish",
              "sns:CreateTopic"],
              "Resource": "${aws_sns_topic.EmailNotification.arn}"
            }
          ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "sns_policy_attach" {
  role       = var.IAMRoleName
  policy_arn = aws_iam_policy.EC2-To-SNS.arn
}

resource "aws_iam_policy" "lambda_policy" {
  name       = "lambda"
  depends_on = [aws_sns_topic.EmailNotification]
  policy     = <<EOF
{
          "Version" : "2012-10-17",
          "Statement": [
            {
        "Sid" : "LambdaDynamoDBAccess",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ],
         "Resource" : "arn:aws:dynamodb:${var.regionName}:${data.aws_caller_identity.current.account_id}:table/csye6225"
      },
      {
        "Sid" : "LambdaSESAccess",
        "Effect": "Allow",
        "Action": [
          "ses:VerifyEmailAddress",
          "ses:SendEmail",
          "ses:SendRawEmail"
        ],
          "Resource": "arn:aws:ses:${var.regionName}:${data.aws_caller_identity.current.account_id}:identity/*"
      },
      {
        "Sid" : "LambdaS3Access",
        "Effect": "Allow",
        "Action": [ "s3:GetObject"],
       "Resource": "arn:aws:s3:::${var.lambdabucketName}/*"
      },
      {
        "Sid" : "LambdaSNSAccess",
        "Effect": "Allow",
        "Action": [ "sns:ConfirmSubscription"],
       "Resource": "${aws_sns_topic.EmailNotification.arn}"
      }
          ]
        }
EOF
}

resource "aws_iam_policy" "topic_policy" {
  name        = "Topic"
  description = ""
  depends_on  = [aws_sns_topic.EmailNotification]
  policy      = <<EOF
{
          "Version" : "2012-10-17",
          "Statement": [
          {
        "Sid"     : "AllowEC2ToPublishToSNSTopic",
        "Effect"  : "Allow",
        "Action"  : [
            "sns:Publish",
            "sns:CreateTopic"
        ],
        "Resource": "${aws_sns_topic.EmailNotification.arn}"
      }
          ]
        }
  EOF
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attach_role" {
  role       = aws_iam_role.CodeDeployAWSLambdaRole.name
  depends_on = [aws_iam_role.CodeDeployAWSLambdaRole]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach_role" {
  role       = aws_iam_role.CodeDeployAWSLambdaRole.name
  depends_on = [aws_iam_role.CodeDeployAWSLambdaRole]
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "topic_policy_attach_role" {
  role       = aws_iam_role.CodeDeployAWSLambdaRole.name
  depends_on = [aws_iam_role.CodeDeployAWSLambdaRole]
  policy_arn = aws_iam_policy.topic_policy.arn
}