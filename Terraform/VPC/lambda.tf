// resource "aws_s3_bucket" "lambdaS3bucket" {
//   bucket        = var.lambdabucketName
//   force_destroy = true
//   acl           = "private"
//   server_side_encryption_configuration {
//     rule {
//       apply_server_side_encryption_by_default {
//         sse_algorithm = "AES256"
//       }
//     }
//   }

//   lifecycle_rule {
//     enabled = true

//     transition {
//       days          = 30
//       storage_class = "STANDARD_IA"
//     }
//   }
// }

data "archive_file" "snsFile" {
  type        = "zip"
  output_path = "${path.module}/lambda-1.0-SNAPSHOT.zip"
  source {
    content  = "hello"
    filename = "dummy.txt"
  }

}

resource "aws_lambda_function" "lambdaFunction" {

  function_name = "sns_lambda_function"
  role          = aws_iam_role.CodeDeployAWSLambdaRole.arn
  handler       = "com.neu.lambda.UserEvent::handleRequest"
  runtime       = "java11"
  filename      = data.archive_file.snsFile.output_path
  timeout       = 180
  memory_size   = 512
  environment {
    variables = {
      domain = var.domain
      table  = aws_dynamodb_table.csye6225_Email.name
    }
  }
  tags = {
    Name = "Lambda Email"
  }
}

resource "aws_lambda_permission" "lambda_permission_sns" {
  //depends_on    = [aws_lambda_function.lambdaFuntion]
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambdaFunction.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.EmailNotification.arn
}

resource "aws_sns_topic" "EmailNotification" {
  name = var.snsTopic
}

resource "aws_sns_topic_subscription" "sns_topic_subscription" {
  //depends_on = [aws_lambda_function.lambdaFunction]
  topic_arn = aws_sns_topic.EmailNotification.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambdaFunction.arn
}


