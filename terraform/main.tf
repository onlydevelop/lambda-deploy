variable "region" {}
variable "profile" {}

provider "aws" {
  region  = var.region
  profile = var.profile
  version = "2.43.0"
}

provider "archive" {
    version = "1.3.0"
}
