
# Trigger workflows 3

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "Default vpc_cidr for the web app"
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "public.ecr.aws/aws-containers/hello-app-runner:latest" ## "bradfordhamilton/crystal_blockchain:latest"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 8000

}

variable "ec2_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "myEcsTaskExecutionRole"
}

variable "ecs_auto_scale_role_name" {
  description = "ECS auto scale role name"
  default     = "webapp_ECS_Auto_Scale_Role"
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

# variable "debug_value" {
#   description = "Printout the values for debugging"
#   type        = string
#   default     = "No debugging values"
# }

# output "debugging_value" {
#   value = "Debugging Values: ${var.debug_value}"
#   # value = templatefile("${path.module}/templates/ecs_policy.tftpl", { port = 8080, ip = "1.1.1.1" })
# }