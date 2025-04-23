resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "serverless_lambda_stage"
  auto_deploy = true

# CloudWatch log group whith retension period of 30 days
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.main_api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_cloudwatch_log_group" "main_api_gw" {
  name = "/aws/api-gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

#API Gateway v2 route that invokes our Lambda function

resource "aws_apigatewayv2_integration" "lambda_handler" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.lambda_docker.invoke_arn
}

resource "aws_apigatewayv2_route" "post_handler" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "POST /handler"

  target = "integrations/${aws_apigatewayv2_integration.lambda_handler.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_docker.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
