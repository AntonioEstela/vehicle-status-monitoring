resource "aws_sns_topic" "vehicle_emergencies" {
  name = "vehicle-emergencies"
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.vehicle_emergencies.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.emergency_alert.arn
}
