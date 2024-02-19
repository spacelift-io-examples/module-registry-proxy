data "archive_file" "list-versions" {
  type             = "zip"
  source_file      = "${path.module}/list-versions.mjs"
  output_path      = "${var.artifacts_path}/list-versions.zip"
  output_file_mode = "0644"
}

resource "aws_lambda_function" "list-versions" {
  filename         = data.archive_file.list-versions.output_path
  function_name    = "tfe-module-proxy-list-versions"
  role             = aws_iam_role.this.arn
  handler          = "list-versions.handler"
  runtime          = "nodejs20.x"
  source_code_hash = data.archive_file.list-versions.output_base64sha256
  timeout          = 30

  environment {
    variables = {
      "SPACELIFT_BASE_URL"     = var.spacelift_base_url
      "SPACELIFT_ACCOUNT_NAME" = var.spacelift_account_name
    }
  }
}

resource "aws_lambda_permission" "list-versions" {
  statement_id  = "AllowExecutionByAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list-versions.function_name
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/GET/registry/modules/v1/{namespace}/{name}/{provider}/versions"
  principal     = "apigateway.amazonaws.com"
}

resource "aws_apigatewayv2_integration" "list-versions" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.list-versions.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "list-versions" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /registry/modules/v1/{namespace}/{name}/{provider}/versions"
  target    = "integrations/${aws_apigatewayv2_integration.list-versions.id}"
}
