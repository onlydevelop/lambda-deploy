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