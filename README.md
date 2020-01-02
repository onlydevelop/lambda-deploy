# Lambda / API Gateway deployment through Terraform

This is a very basic example of deploying lambda and API gateway using terraform. We are going to use terraform for this, as it becomes quite easy to create/update/destroy the infrastructure. This example can be extended as required.

## Step 1: Create a simple lambda function

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

## Step 2: Create a local profile and use in terraform

Create an user with AWSLambdaFullAccess and IAM::CreateRole, IAM::ListInstanceProfilesForRole, IAM::DeleteRole with programmatic access and then configure your ~/.aws files as follows.

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

## Step 3: Create zip archive of the lambda source code

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
## Step 4: Adding the lambda function

Add the lambda function and the asscociated role as below.

```HCL
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
  role             = "${aws_iam_role.lambda_example_role.arn}"
  handler          = "main.handler"
  source_code_hash = "${filebase64sha256(local.output_path)}"
  runtime          = "nodejs12.x"
}
```

The plan looks like:

```$ make plan
cd terraform && terraform plan -var-file='main.tfvars'
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.archive_file.lambda_example: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_role.lambda_example_role will be created
  + resource "aws_iam_role" "lambda_example_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "lambda.amazonaws.com"
                        }
                      + Sid       = ""
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + max_session_duration  = 3600
      + name                  = "lambda_example_role"
      + path                  = "/"
      + unique_id             = (known after apply)
    }

  # aws_lambda_function.lambda_example will be created
  + resource "aws_lambda_function" "lambda_example" {
      + arn                            = (known after apply)
      + filename                       = "./tmp/lambda_example.zip"
      + function_name                  = "example_lambda"
      + handler                        = "main.handler"
      + id                             = (known after apply)
      + invoke_arn                     = (known after apply)
      + last_modified                  = (known after apply)
      + memory_size                    = 128
      + publish                        = false
      + qualified_arn                  = (known after apply)
      + reserved_concurrent_executions = -1
      + role                           = (known after apply)
      + runtime                        = "nodejs12.x"
      + source_code_hash               = "EwPB9TIJnwBggaMgFATnuefYr/FnF3e22R+SBeD0pHM="
      + source_code_size               = (known after apply)
      + timeout                        = 3
      + version                        = (known after apply)

      + tracing_config {
          + mode = (known after apply)
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------
```

So, let's apply it:

```
$ make apply
cd  terraform && terraform apply -var-file='main.tfvars'
data.archive_file.lambda_example: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_role.lambda_example_role will be created
  + resource "aws_iam_role" "lambda_example_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "lambda.amazonaws.com"
                        }
                      + Sid       = ""
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + max_session_duration  = 3600
      + name                  = "lambda_example_role"
      + path                  = "/"
      + unique_id             = (known after apply)
    }

  # aws_lambda_function.lambda_example will be created
  + resource "aws_lambda_function" "lambda_example" {
      + arn                            = (known after apply)
      + filename                       = "./tmp/lambda_example.zip"
      + function_name                  = "example_lambda"
      + handler                        = "main.handler"
      + id                             = (known after apply)
      + invoke_arn                     = (known after apply)
      + last_modified                  = (known after apply)
      + memory_size                    = 128
      + publish                        = false
      + qualified_arn                  = (known after apply)
      + reserved_concurrent_executions = -1
      + role                           = (known after apply)
      + runtime                        = "nodejs12.x"
      + source_code_hash               = "EwPB9TIJnwBggaMgFATnuefYr/FnF3e22R+SBeD0pHM="
      + source_code_size               = (known after apply)
      + timeout                        = 3
      + version                        = (known after apply)

      + tracing_config {
          + mode = (known after apply)
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_iam_role.lambda_example_role: Creating...
aws_iam_role.lambda_example_role: Creation complete after 3s [id=lambda_example_role]
aws_lambda_function.lambda_example: Creating...
aws_lambda_function.lambda_example: Still creating... [10s elapsed]
aws_lambda_function.lambda_example: Creation complete after 16s [id=example_lambda]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

Now, to test use `make test`:

```
$ make test
aws lambda invoke --profile=lambda-deploy --region=ap-south-1 --function-name=example_lambda  lambda_response.txt
{
    "StatusCode": 200,
    "ExecutedVersion": "$LATEST"
}
{"statusCode":200,"headers":{"Content-Type":"application/json; charset=utf-8"},"body":"{\"msg\": \"hello, world\"}"}
```

## Step 5: Add API Gateway integration

We will now add API Gateway to access the lambda function. So, we will add the following code to the terraform/api.tf.

```HCL
variable "account_id" {}

locals {
    name        = "api_example"
    description = "This is an example api"
    path_part   = "example"
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
    path_part   = local.path_part
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
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  content_handling        = "CONVERT_TO_TEXT"
  passthrough_behavior    = "WHEN_NO_MATCH"
  uri                     = aws_lambda_function.lambda_example.invoke_arn
}

# This gives permission to API Gateway to execute lambda
resource "aws_lambda_permission" "api_example_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_example.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api_example.id}/*/${aws_api_gateway_method.api_example_method.http_method}${aws_api_gateway_resource.api_example_resource.path}"
}

# This adds the deployment to expose the API
resource "aws_api_gateway_deployment" "api_example_deployment" {
    depends_on  = ["aws_api_gateway_integration.api_example_integration"]
    rest_api_id = aws_api_gateway_rest_api.api_example.id
    stage_name  = "test"
}

# Prints the output URL
output "get_url" {
  value = "${aws_api_gateway_deployment.api_example_deployment.invoke_url}/${local.path_part}"
}
```

Now, let's apply the change. As I was doing incremental changes, so, it was showing me 2 resources to be destroyed. However, on a fresh run there should not be any destroy.

```
$ make apply
cd  terraform && terraform apply -var-file='main.tfvars'
var.account_id
  Enter a value: <REDACTED>

data.archive_file.lambda_example: Refreshing state...
aws_iam_role.lambda_example_role: Refreshing state... [id=lambda_example_role]
aws_api_gateway_rest_api.api_example: Refreshing state... [id=m7vkjps7wj]
aws_api_gateway_resource.api_example_resource: Refreshing state... [id=2w4ib0]
aws_api_gateway_method.api_example_method: Refreshing state... [id=agm-m7vkjps7wj-2w4ib0-GET]
aws_lambda_function.lambda_example: Refreshing state... [id=example_lambda]
aws_lambda_permission.api_example_permission: Refreshing state... [id=AllowExecutionFromAPIGateway]
aws_api_gateway_integration.api_example_integration: Refreshing state... [id=agi-m7vkjps7wj-2w4ib0-GET]
aws_api_gateway_deployment.api_example_deployment: Refreshing state... [id=equrks]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_api_gateway_deployment.api_example_deployment must be replaced
-/+ resource "aws_api_gateway_deployment" "api_example_deployment" {
      ~ created_date  = "2020-01-02T05:24:07Z" -> (known after apply)
      ~ execution_arn = "arn:aws:execute-api:ap-south-1:<REDACTED>:m7vkjps7wj/test" -> (known after apply)
      ~ id            = "equrks" -> (known after apply)
      ~ invoke_url    = "https://m7vkjps7wj.execute-api.ap-south-1.amazonaws.com/test" -> (known after apply)
      ~ rest_api_id   = "m7vkjps7wj" -> (known after apply) # forces replacement
        stage_name    = "test"
    }

  # aws_api_gateway_integration.api_example_integration will be created
  + resource "aws_api_gateway_integration" "api_example_integration" {
      + cache_namespace         = (known after apply)
      + connection_type         = "INTERNET"
      + content_handling        = "CONVERT_TO_TEXT"
      + http_method             = "GET"
      + id                      = (known after apply)
      + integration_http_method = "POST"
      + passthrough_behavior    = "WHEN_NO_MATCH"
      + resource_id             = (known after apply)
      + rest_api_id             = (known after apply)
      + timeout_milliseconds    = 29000
      + type                    = "AWS_PROXY"
      + uri                     = "arn:aws:apigateway:ap-south-1:lambda:path/2015-03-31/functions/arn:aws:lambda:ap-south-1:<REDACTED>:function:example_lambda/invocations"
    }

  # aws_api_gateway_method.api_example_method will be created
  + resource "aws_api_gateway_method" "api_example_method" {
      + api_key_required = false
      + authorization    = "NONE"
      + http_method      = "GET"
      + id               = (known after apply)
      + resource_id      = (known after apply)
      + rest_api_id      = (known after apply)
    }

  # aws_api_gateway_resource.api_example_resource will be created
  + resource "aws_api_gateway_resource" "api_example_resource" {
      + id          = (known after apply)
      + parent_id   = (known after apply)
      + path        = (known after apply)
      + path_part   = "example"
      + rest_api_id = (known after apply)
    }

  # aws_api_gateway_rest_api.api_example will be created
  + resource "aws_api_gateway_rest_api" "api_example" {
      + api_key_source           = "HEADER"
      + arn                      = (known after apply)
      + created_date             = (known after apply)
      + description              = "This is an example api"
      + execution_arn            = (known after apply)
      + id                       = (known after apply)
      + minimum_compression_size = -1
      + name                     = "api_example"
      + root_resource_id         = (known after apply)

      + endpoint_configuration {
          + types = (known after apply)
        }
    }

  # aws_lambda_permission.api_example_permission must be replaced
-/+ resource "aws_lambda_permission" "api_example_permission" {
        action        = "lambda:InvokeFunction"
        function_name = "example_lambda"
      ~ id            = "AllowExecutionFromAPIGateway" -> (known after apply)
        principal     = "apigateway.amazonaws.com"
      ~ source_arn    = "arn:aws:execute-api:ap-south-1:<REDACTED>:m7vkjps7wj/*/GET/example" -> (known after apply) # forces replacement
        statement_id  = "AllowExecutionFromAPIGateway"
    }

Plan: 6 to add, 0 to change, 2 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_lambda_permission.api_example_permission: Destroying... [id=AllowExecutionFromAPIGateway]
aws_api_gateway_deployment.api_example_deployment: Destroying... [id=equrks]
aws_api_gateway_rest_api.api_example: Creating...
aws_lambda_permission.api_example_permission: Destruction complete after 3s
aws_api_gateway_deployment.api_example_deployment: Destruction complete after 3s
aws_api_gateway_rest_api.api_example: Creation complete after 3s [id=dp8bl6ywuh]
aws_api_gateway_resource.api_example_resource: Creating...
aws_api_gateway_resource.api_example_resource: Creation complete after 1s [id=cjr9hy]
aws_api_gateway_method.api_example_method: Creating...
aws_api_gateway_method.api_example_method: Creation complete after 0s [id=agm-dp8bl6ywuh-cjr9hy-GET]
aws_lambda_permission.api_example_permission: Creating...
aws_api_gateway_integration.api_example_integration: Creating...
aws_lambda_permission.api_example_permission: Creation complete after 1s [id=AllowExecutionFromAPIGateway]
aws_api_gateway_integration.api_example_integration: Creation complete after 1s [id=agi-dp8bl6ywuh-cjr9hy-GET]
aws_api_gateway_deployment.api_example_deployment: Creating...
aws_api_gateway_deployment.api_example_deployment: Creation complete after 1s [id=u7ha7k]

Apply complete! Resources: 6 added, 0 changed, 2 destroyed.

Outputs:

get_url = https://mp8bl7ywuh.execute-api.ap-south-1.amazonaws.com/test/example
```

To test:

```
$ curl https://mp8bl7ywuh.execute-api.ap-south-1.amazonaws.com/test/example
{"msg": "hello, world"}%
```
