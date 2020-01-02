# Lambda / API Gateway deployment through Terraform

This is a very basic example of deploying lambda and API gateway using terraform. We are going to use terraform for this, as it becomes quite easy to create/update/destroy the infrastructure. This example can be extended as required.

# Step 1: Create a simple lambda function

I have created a very simple lambda function with a 'hello, world' json response.

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