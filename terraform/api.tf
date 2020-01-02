variable "account_id" {}

locals {
    name        = "api_example"
    description = "This is an example api"
}

# This creates an empty API Gateway without any resources
resource "aws_api_gateway_rest_api" "api_example" {
    name        = local.name
    description = local.description
}

# This creates the resource within api gateway
resource "aws_api_gateway_resource" "api_example_resource" {
    rest_api_id = aws_api_gateway_rest_api.api_example.id
    parent_id   = aws_api_gateway_rest_api.api_example.root_resource_id
    path_part   = "example"
}

# This creates the GET method to access the API
resource "aws_api_gateway_method" "api_example_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_example.id
  resource_id   = aws_api_gateway_resource.api_example_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# This creates the integration with lambda
resource "aws_api_gateway_integration" "api_example_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_example.id
  resource_id             = aws_api_gateway_resource.api_example_resource.id
  http_method             = aws_api_gateway_method.api_example_method.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_example.invoke_arn}"
}

# This gives permission to API Gateway to execute lambda
resource "aws_lambda_permission" "api_example_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_example.function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api_example.id}/*/${aws_api_gateway_method.api_example_method.http_method}${aws_api_gateway_resource.api_example_resource.path}"
}