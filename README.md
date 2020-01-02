# Lambda / API Gateway deployment through Terraform

This is a very basic example of deploying lambda and API gateway using terraform. We are going to use terraform for this, as it becomes quite easy to create/update/destroy the infrastructure. This example can be extended as required.

# Step 1: Create a simple lambda function

Create a very simple lambda function with a 'hello, world' json response.

```
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

