
variable "region" {}
variable "profile" {}

provider "aws" {
  region  = var.region
  profile = var.profile
  version = "2.43.0"
}