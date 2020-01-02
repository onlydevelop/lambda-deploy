variable "region" {}
variable "profile" {}

locals {
  source_file = "${path.module}/../src/main.js"
  output_path = "${path.module}/tmp/lambda_example.zip"
}

provider "aws" {
  region  = var.region
  profile = var.profile
  version = "2.43.0"
}

provider "archive" {
    version = "1.3.0"
}

data "archive_file" "lambda_example" {
  type        = "zip"
  source_file = local.source_file
  output_path = local.output_path
}
