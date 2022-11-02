terraform {
  required_version = ">=1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3"
    }
  }
}

provider "aws" {
  region  = "us-west-2"
  profile = "lvt-service-comms-dev"
}

module "acs" {
  source   = "bitbucket.org/liveviewtech/terraform-aws-acs-info.git?ref=v2.0.1"
  vpc_type = "non-edge"
  profile  = "lvt-service-comms-dev"
}

locals {
  project_id = "example-lambda-ssm"
}

resource "aws_ssm_parameter" "super_secret" {
  name  = "/${local.project_id}/super-secret"
  type  = "SecureString"
  value = "SSSSHHHH, it's a secret"
}

data "archive_file" "function" {
  type        = "zip"
  source_file = "${path.module}/function.py"
  output_path = "lambda.zip"
}

module "lambda" {
  source = "../"

  name = local.project_id

  filename         = data.archive_file.function.output_path
  source_code_hash = data.archive_file.function.output_base64sha256
  handler          = "function.handler"
  runtime          = "python3.9"

  private_subnet_ids = module.acs.private_subnet_ids
  security_groups    = []
  vpc_id             = module.acs.vpc.id

  environment_variables = {
    NAME = "Steve"
  }

  secrets = {
    SUPER_SECRET = aws_ssm_parameter.super_secret.name
  }


  role_permissions_boundary_arn = module.acs.role_permissions_boundary.arn
}


# resource "aws_cloudwatch_event_rule" "scheduled" {
#   name = "${local.project_id}-scheduled"

#   schedule_expression = "rate(${var.interval})"
# }

# resource "aws_cloudwatch_event_target" "scheduled" {
#   target_id = "${local.project_id}-scheduled"

#   rule = aws_cloudwatch_event_rule.scheduled.name
#   arn  = aws_lambda_function.main.arn
# }

# resource "aws_lambda_permission" "cloudwatch_invoke" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.main.function_name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.scheduled.arn
# }
