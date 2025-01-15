resource "aws_ecs_cluster" "webapp_cluster" {
  name = "webapp-cluster"
}



# output "debugging_value" {
#   value = templatefile("${path.module}/templates/ecs_policy.tftpl", {})
# }



resource "aws_ecs_task_definition" "app" {
  family                   = "webapp-app-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions = templatefile("${path.module}/templates/webapp.tftpl", {
    app_image      = var.app_image,
    app_port       = var.app_port,
    fargate_cpu    = var.fargate_cpu,
    fargate_memory = var.fargate_memory,
    aws_region     = var.aws_region
  })
}




resource "aws_ecs_service" "main" {
  name            = "webapp-service"
  cluster         = aws_ecs_cluster.webapp_cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = [aws_subnet.webapp_subnet_1.id, aws_subnet.webapp_subnet_2.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "webapp-app"
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment]
}