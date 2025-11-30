data "aws_region" "current" {}

resource "aws_api_gateway_rest_api" "vehicle_api" {
  name = "vehicle-status-api"
}

# Vehicle POST method
resource "aws_api_gateway_resource" "vehicle" {
  rest_api_id = aws_api_gateway_rest_api.vehicle_api.id
  parent_id   = aws_api_gateway_rest_api.vehicle_api.root_resource_id
  path_part   = "vehicle"
}

resource "aws_api_gateway_method" "vehicle_post" {
  rest_api_id   = aws_api_gateway_rest_api.vehicle_api.id
  resource_id   = aws_api_gateway_resource.vehicle.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "vehicle_lambda" {
  rest_api_id = aws_api_gateway_rest_api.vehicle_api.id
  resource_id = aws_api_gateway_resource.vehicle.id
  http_method = aws_api_gateway_method.vehicle_post.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.vehicle_status.arn}/invocations"
}

resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.vehicle_api.id
  parent_id   = aws_api_gateway_rest_api.vehicle_api.root_resource_id
  path_part   = "health"
}

# Health GET method

resource "aws_api_gateway_method" "health_get" {
  rest_api_id   = aws_api_gateway_rest_api.vehicle_api.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "health_mock" {
  rest_api_id = aws_api_gateway_rest_api.vehicle_api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_get.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "health_ok" {
  rest_api_id = aws_api_gateway_rest_api.vehicle_api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_get.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "health_mock_ok" {
  rest_api_id = aws_api_gateway_rest_api.vehicle_api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_get.http_method
  status_code = aws_api_gateway_method_response.health_ok.status_code

  response_templates = {
    "application/json" = jsonencode({
      message = "ok"
    })
  }
}

resource "aws_api_gateway_deployment" "vehicle" {
  rest_api_id = aws_api_gateway_rest_api.vehicle_api.id

  depends_on = [
    aws_api_gateway_integration.vehicle_lambda,
    aws_api_gateway_integration_response.health_mock_ok,
  ]
}

resource "aws_api_gateway_stage" "dev" {
  rest_api_id   = aws_api_gateway_rest_api.vehicle_api.id
  deployment_id = aws_api_gateway_deployment.vehicle.id
  stage_name    = "dev"
}

output "api_gateway_invoke_url" {
  value       = aws_api_gateway_stage.dev.invoke_url
  description = "Invoke URL for the vehicle status API"
}
