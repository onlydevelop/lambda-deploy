locals {
  source_file   = "${path.module}/../src/main.js"
  output_path   = "${path.module}/tmp/lambda_example.zip"
  function_name = "example_lambda" 
}

data "archive_file" "lambda_example" {
  type        = "zip"
  source_file = local.source_file
  output_path = local.output_path
}

resource "aws_iam_role" "lambda_example_role" {
  name = "lambda_example_role"

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
}

resource "aws_lambda_function" "lambda_example" {
  filename         = local.output_path
  function_name    = local.function_name
  role             = aws_iam_role.lambda_example_role.arn
  handler          = "main.handler"
  source_code_hash = data.archive_file.lambda_example.output_base64sha256
  runtime          = "nodejs12.x"
}
