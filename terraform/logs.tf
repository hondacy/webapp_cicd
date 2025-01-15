# logs.tf

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "webapp_log_group" {
  name              = "/ecs/webapp"
  retention_in_days = 30

  tags = {
    Name = "webapp-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "cb_log_stream" {
  name           = "webapp-log-stream"
  log_group_name = aws_cloudwatch_log_group.webapp_log_group.name
}