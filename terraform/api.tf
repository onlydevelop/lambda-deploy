locals {
    name        = "api_example"
    description = "This is an example api"
}

# This creates an empty API Gateway without any resources
resource "aws_api_gateway_rest_api" "api_example" {
    name        = local.name
    description = local.description
}
