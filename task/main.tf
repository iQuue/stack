/**
 * The task module creates an ECS task definition.
 *
 * Usage:
 *
 *     module "nginx" {
 *       source = "github.com/segmentio/stack/task"
 *       name   = "nginx"
 *     }
 *
 */

/**
 * Required Variables.
 */

variable "name" {
  description = "The worker name, if empty the service name is defaulted to the image name"
}

variable "container_definitions" {
  description = "JSON container definition."
}

/**
 * Resources.
 */

# The ECS task definition.

resource "aws_ecs_task_definition" "main" {
  family = "${var.name}"

  lifecycle {
    ignore_changes        = ["image"]
    create_before_destroy = true
  }

  container_definitions = "${var.container_definitions}"
}

/**
 * Outputs.
 */

// The created task definition name
output "name" {
  value = "${aws_ecs_task_definition.main.family}"
}

// The created task definition ARN
output "arn" {
  value = "${aws_ecs_task_definition.main.arn}"
}
