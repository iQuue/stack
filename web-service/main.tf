/**
 * The web-service is similar to the `service` module, but the
 * it provides a __public__ ALB instead.
 *
 * Usage:
 *
 *      module "auth_service" {
 *        source    = "github.com/segmentio/stack/service"
 *        name      = "auth-service"
 *        cluster   = "default"
 *      }
 *
 */

/**
 * Required Variables.
 */

variable "environment" {
  description = "Environment tag, e.g prod"
}

variable "name" {
  description = "The service name."
}

variable "subnet_ids" {
  description = "Comma separated list of subnet IDs that will be passed to the ALB module"
}

variable "security_groups" {
  description = "Comma separated list of security group IDs that will be passed to the ALB module"
}

variable "external_port" {
  description = "The external port"
}

variable "cluster" {
  description = "The cluster name or ARN"
}

variable "log_bucket" {
  description = "The S3 bucket ID to use for the ALB"
}

variable "ssl_certificate_id" {
  description = "SSL Certificate ID to use"
}

variable "iam_role" {
  description = "IAM Role ARN to use"
}

variable "external_dns_name" {
  description = "The subdomain under which the ALB is exposed externally, defaults to the task name"
  default     = ""
}

variable "internal_dns_name" {
  description = "The subdomain under which the ALB is exposed internally, defaults to the task name"
  default     = ""
}

variable "external_zone_id" {
  description = "The zone ID to create the record in"
}

variable "internal_zone_id" {
  description = "The zone ID to create the record in"
}

/**
 * Options.
 */

variable "healthcheck" {
  description = "Path to a healthcheck endpoint"
  default     = "/"
}

variable "container_port" {
  description = "The container port"
  default     = 3000
}

variable "desired_count" {
  description = "The desired count"
  default     = 2
}

variable "deployment_minimum_healthy_percent" {
  description = "lower limit (% of desired_count) of # of running tasks during a deployment"
  default     = 100
}

variable "deployment_maximum_percent" {
  description = "upper limit (% of desired_count) of # of running tasks during a deployment"
  default     = 200
}

variable "load_balancer_container_name" {
  description = "The name of the container to attach to the load balancer."
}

variable "container_definitions" {
  description = "JSON container definitions."
}

variable vpc_id {}

/**
 * Resources.
 */

resource "aws_ecs_service" "main" {
  name                               = "${module.task.name}"
  cluster                            = "${var.cluster}"
  task_definition                    = "${module.task.arn}"
  desired_count                      = "${var.desired_count}"
  iam_role                           = "${var.iam_role}"
  deployment_minimum_healthy_percent = "${var.deployment_minimum_healthy_percent}"
  deployment_maximum_percent         = "${var.deployment_maximum_percent}"

  load_balancer {
    target_group_arn = "${module.alb.target_group}"
    container_name   = "${var.load_balancer_container_name}"
    container_port   = "${var.container_port}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "task" {
  source = "../task"

  name                  = "${var.name}"
  container_definitions = "${var.container_definitions}"
}

module "alb" {
  source = "./alb"

  name               = "${module.task.name}"
  port               = "${var.external_port}"
  environment        = "${var.environment}"
  subnet_ids         = "${var.subnet_ids}"
  external_dns_name  = "${coalesce(var.external_dns_name, module.task.name)}"
  internal_dns_name  = "${coalesce(var.internal_dns_name, module.task.name)}"
  healthcheck        = "${var.healthcheck}"
  external_zone_id   = "${var.external_zone_id}"
  internal_zone_id   = "${var.internal_zone_id}"
  security_groups    = "${var.security_groups}"
  log_bucket         = "${var.log_bucket}"
  ssl_certificate_id = "${var.ssl_certificate_id}"
  vpc_id             = "${var.vpc_id}"
}

/**
 * Outputs.
 */

// The name of the ALB
output "name" {
  value = "${module.alb.name}"
}

// The DNS name of the ALB
output "dns" {
  value = "${module.alb.dns}"
}

// The id of the ALB
output "alb" {
  value = "${module.alb.id}"
}

// The zone id of the ALB
output "zone_id" {
  value = "${module.alb.zone_id}"
}

// FQDN built using the zone domain and name (external)
output "external_fqdn" {
  value = "${module.alb.external_fqdn}"
}

// FQDN built using the zone domain and name (internal)
output "internal_fqdn" {
  value = "${module.alb.internal_fqdn}"
}
