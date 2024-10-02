provider "aws" {
  region = "us-east-1"
}

# Role da Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}


# Função Lambda
resource "aws_lambda_function" "validate_cpf_lambda" {
  function_name = "validate-cpf"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  filename         = "lambda_function.zip" # Zip do código da Lambda
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      DB_HOST     = "rds-endpoint.amazonaws.com" # Substitua pelo endpoint do seu RDS MySQL
      DB_USER     = "admin"
      DB_PASSWORD = "password123"
      DB_NAME     = "mydatabase"
    }
  }
}


# Zipando o código Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda_function.zip"
}