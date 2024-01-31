resource "aws_apigatewayv2_api" "notification_api" {
  name          = "notification-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "integration" {
  api_id           = aws_apigatewayv2_api.notification_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.notification_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.notification_api.id
  route_key = "POST /notify"

  target = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.notification_api.id
  name        = "dev"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_log_group.arn

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

resource "aws_cloudwatch_log_group" "api_log_group" {
  name = "/aws/api-gw/${aws_apigatewayv2_api.notification_api.name}"

  retention_in_days = 30
}

resource "aws_apigatewayv2_deployment" "notification_api_deployment" {
  depends_on = [aws_apigatewayv2_route.route]
  api_id     = aws_apigatewayv2_api.notification_api.id
}

output "api_gateway_invoke_url" {
  value = aws_apigatewayv2_stage.stage.invoke_url
}
