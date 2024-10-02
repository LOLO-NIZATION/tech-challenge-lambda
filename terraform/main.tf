provider "aws" {
  region = "us-east-1" # ajuste para sua região preferida
}

resource "aws_lambda_function" "cpf_validation_lambda" {
  function_name = "validate_cpf_lambda"
  role          = "arn:aws:iam::060254399214:role/LabRole"
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  filename         = "${path.module}/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")

}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "cpf_validation_api" {
  name        = "cpf-validation-api"
  description = "API Gateway para validar CPF"
}

# Recurso /validate (Caminho da API)
resource "aws_api_gateway_resource" "validate_resource" {
  rest_api_id = aws_api_gateway_rest_api.cpf_validation_api.id
  parent_id   = aws_api_gateway_rest_api.cpf_validation_api.root_resource_id
  path_part   = "validate"
}

# Método POST no caminho /validate
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.cpf_validation_api.id
  resource_id   = aws_api_gateway_resource.validate_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.cpf_validation_api.id
  resource_id = aws_api_gateway_resource.validate_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.cpf_validation_lambda.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cpf_validation_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.cpf_validation_api.execution_arn}/*/*"
}


