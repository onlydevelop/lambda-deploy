# Lambda / API Gateway deployment through Terraform

This is a very basic example of deploying lambda and API gateway using terraform. We are going to use terraform for this, as it becomes quite easy to create/update/destroy the infrastructure. This example can be extended as required.

# Step 1: Create a simple lambda function

Create a very simple lambda function with a 'hello, world' json response.

```javascript
'use strict'

exports.handler = function(event, context, callback) {
  var response = {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json; charset=utf-8'
    },
    body: '{"msg": "hello, world"}'
  }
  callback(null, response)
}
```

# Step 2: Create a local profile and use in terraform

Create an user with AWSLambdaFullAccess, with programmatic access and then configure your ~/.aws files as follows.

```
$ cat ~/.aws/config
[lambda-deploy]
output = json
region = ap-south-1

$ cat ~/.aws/credentials
[lambda-deploy]
aws_access_key_id = <put_your_access_key>
aws_secret_access_key = <put_your_secret_access_key>
```

Note: There is a Makefile in the root directory to have a easy use of the command.

```
$ make init
$ make plan
$ make apply
$ make destroy
```

# Step 3: Create zip archive of the lambda source code

We have a single file lambda function. So, we have just used the simple syntax of creating the zip archive. Terraform also supports archiving multiple files. Running plan will create a zip archive from the lambda source.

The code looks like:

`terraform/lambda.tf`
```HCL
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
```

To test, run the plan which will create the zip file in the terraform/tmp directory.

```
$ make plan
cd terraform && terraform plan -var-file='main.tfvars'
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.archive_file.lambda_example: Refreshing state...

------------------------------------------------------------------------

No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your
configuration and real physical resources that exist. As a result, no
actions need to be performed.
$ ls ./terraform/tmp
lambda_example.zip
```
