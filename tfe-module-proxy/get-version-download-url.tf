data "archive_file" "get-version-download-url" {
  type             = "zip"
  source_file      = "${path.module}/get-version-download-url.mjs"
  output_path      = "${var.artifacts_path}/get-version-download-url.zip"
  output_file_mode = "0644"
}

resource "aws_lambda_function" "get-version-download-url" {
  filename         = data.archive_file.get-version-download-url.output_path
  function_name    = "tfe-module-proxy-get-version-download-url"
  role             = aws_iam_role.this.arn
  handler          = "get-version-download-url.handler"
  runtime          = "nodejs20.x"
  source_code_hash = data.archive_file.get-version-download-url.output_base64sha256
  timeout          = 30

  environment {
    variables = {
      # TODO
    }
  }
}

resource "aws_lambda_permission" "get-version-download-url" {
  statement_id  = "AllowExecutionByAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get-version-download-url.function_name
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/GET/registry/modules/v1/{namespace}/{name}/{provider}/{version}/download"
  principal     = "apigateway.amazonaws.com"
}

resource "aws_apigatewayv2_integration" "get-version-download-url" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.get-version-download-url.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get-version-download-url" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /registry/modules/v1/{namespace}/{name}/{provider}/{version}/download"
  target    = "integrations/${aws_apigatewayv2_integration.get-version-download-url.id}"
}
