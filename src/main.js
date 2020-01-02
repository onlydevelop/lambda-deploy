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
