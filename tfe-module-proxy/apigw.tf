resource "aws_apigatewayv2_api" "this" {
  name          = "tfe-module-proxy"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "example" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
}
