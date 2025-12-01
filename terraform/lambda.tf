data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "dist/index.js"
  output_path = "lambda.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "vehicle-status-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_ses_send" {
  name = "lambda-ses-send"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_sns_publish" {
  name = "lambda-sns-publish"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "vehicle_status" {
  function_name                  = "vehicle_status_function"
  handler                        = "index.handler"
  runtime                        = "nodejs22.x"
  role                           = aws_iam_role.lambda_role.arn
  filename                       = data.archive_file.lambda_zip.output_path
  source_code_hash               = data.archive_file.lambda_zip.output_base64sha256
  memory_size                    = 1024
  reserved_concurrent_executions = 10
}

resource "aws_cloudwatch_log_group" "vehicle_status" {
  name              = "/aws/lambda/${aws_lambda_function.vehicle_status.function_name}"
  retention_in_days = 14
}

resource "aws_lambda_permission" "apigateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.vehicle_status.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.vehicle_api.execution_arn}/*/*"
}


# Emergency Lambda Function
data "archive_file" "emergency_lambda_zip" {
  type        = "zip"
  source_file = "dist/emergency-lambda.js"
  output_path = "emergency-lambda.zip"
}

resource "aws_lambda_function" "emergency_alert" {
  function_name    = "emergency_alert_function"
  handler          = "emergency-lambda.handler"
  runtime          = "nodejs22.x"
  role             = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.emergency_lambda_zip.output_path
  source_code_hash = data.archive_file.emergency_lambda_zip.output_base64sha256
  memory_size      = 1024
}


resource "aws_cloudwatch_log_group" "emergency_alert" {
  name              = "/aws/lambda/${aws_lambda_function.emergency_alert.function_name}"
  retention_in_days = 14
}

resource "aws_lambda_permission" "sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.emergency_alert.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.vehicle_emergencies.arn
}

