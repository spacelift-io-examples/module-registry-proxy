data "archive_file" "terraform-json" {
  type             = "zip"
  source_file      = "${path.module}/terraform-json.mjs"
  output_path      = "${var.artifacts_path}/terraform-json.zip"
  output_file_mode = "0644"
}

resource "aws_lambda_function" "terraform-json" {
  filename         = data.archive_file.terraform-json.output_path
  function_name    = "tfe-module-proxy-terraform-json"
  role             = aws_iam_role.this.arn
  handler          = "terraform-json.handler"
  runtime          = "nodejs20.x"
  source_code_hash = data.archive_file.terraform-json.output_base64sha256
  timeout          = 30

  environment {
    variables = {
      # TODO
    }
  }
}

resource "aws_lambda_permission" "terraform-json" {
  statement_id  = "AllowExecutionByAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform-json.function_name
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/GET/.well-known/terraform.json"
  principal     = "apigateway.amazonaws.com"
}

resource "aws_apigatewayv2_integration" "terraform-json" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.terraform-json.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "terraform-json" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /.well-known/terraform.json"
  target    = "integrations/${aws_apigatewayv2_integration.terraform-json.id}"
}
