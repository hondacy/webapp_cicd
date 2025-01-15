
output "alb_hostname" {
  value = aws_alb.webapp_alb.dns_name
}