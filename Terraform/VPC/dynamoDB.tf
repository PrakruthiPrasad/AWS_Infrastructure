resource "aws_dynamodb_table" "csye6225" {
  name           = "csye6225"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "msg"

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  attribute {
    name = "msg"
    type = "S"
  }

}

resource "aws_dynamodb_table" "csye6225_Email" {
  name           = "csye6225_Email"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "user_name"


  attribute {
    name = "user_name"
    type = "S"
  }

}