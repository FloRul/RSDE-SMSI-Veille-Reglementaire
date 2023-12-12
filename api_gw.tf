resource "aws_apigatewayv2_api" "notification_api" {
  name          = "notification-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "this" {
  api_id           = aws_apigatewayv2_api.notification_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.this.invoke_arn
}

resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.notification_api.id
  route_key = "POST /notify"

  target = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.notification_api.id
  name        = "dev"
  auto_deploy = true
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
  name = "/aws/api-gw/${aws_apigatewayv2_api.notification_api.name}"

  retention_in_days = 30
}

resource "aws_apigatewayv2_deployment" "notification_api_deployment" {
  depends_on = [aws_apigatewayv2_route.this]
  api_id     = aws_apigatewayv2_api.notification_api.id
}

output "api_gateway_invoke_url" {
  value = aws_apigatewayv2_stage.this.invoke_url
}
