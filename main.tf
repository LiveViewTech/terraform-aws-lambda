terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = ">= 3.0.0"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  secrets =[for k,v in var.environment_variables: v if length(regexall("^SSM", k)) > 0 ]
  ssm_parameters = distinct(flatten((local.secrets)))
  has_secrets            = length(local.ssm_parameters) > 0
  ssm_parameter_arn_base = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/"
  secrets_arns = [
    for param in local.ssm_parameters :
    "${local.ssm_parameter_arn_base}${replace(param, "/^//", "")}"
  ]
  
  cloudwatch_log_group_name = "/lambda/${var.function_name}"
}


# == Lambda Function == #
resource "aws_lambda_function" "lambda" {

  architectures                  = var.architectures
  description                    = var.description
  filename                       = var.filename
  function_name                  = var.function_name
  handler                        = var.handler
  image_uri                      = var.image_uri
  kms_key_arn                    = var.kms_key_arn
  layers                         = var.layers
  memory_size                    = var.memory_size
  package_type                   = var.package_type
  # publish                        = var.publish
  # reserved_concurrent_executions = var.reserved_concurrent_executions
  role                           = aws_iam_role.lambda.arn
  tags                           = var.tags
  timeout                        = var.timeout


  dynamic "vpc_config" {
    for_each = var.private_subnet_ids == null ? [] : [var.private_subnet_ids]
    content {
      subnet_ids        = var.private_subnet_ids
      security_group_ids  = concat([aws_security_group.this.id], var.security_groups)
    }
  }


dynamic "environment" {
    for_each = var.environment_variables != null ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

}


resource "aws_security_group" "this" {
  name_prefix = "var.function_name-lambda"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  lifecycle {
    create_before_destroy = true
  }
}
# == IAM == #

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}
 
resource "aws_iam_role" "lambda" {
  name                 = "${var.function_name}"
  assume_role_policy   = data.aws_iam_policy_document.lambda_assume_role.json
  permissions_boundary = var.role_permissions_boundary_arn
  tags                 = var.tags
}

data "aws_iam_policy_document" "execution_role" {
  count   = local.has_secrets ? 1 : 0
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:GetParemetersByPath"
    ]
     resources = flatten([local.secrets_arns,
     ])
  }
}

resource "aws_iam_policy" "execution_role" {
   count  = local.has_secrets ? 1 : 0
  name   = var.function_name
  path   = "/"
  policy = data.aws_iam_policy_document.execution_role[0].json
}
resource "aws_iam_role_policy_attachment" "execution_role" {
   count  = local.has_secrets ? 1 : 0
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.execution_role[0].arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
   role       = aws_iam_role.lambda.name
   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_cloudwatch_event_rule" "scheduled" { 
 name = "${var.function_name}-scheduled"
 schedule_expression = "rate(${var.interval})"
}
resource "aws_cloudwatch_event_target" "scheduled" {
  target_id = "${var.function_name}-scheduled"
  rule = aws_cloudwatch_event_rule.scheduled.name
  arn  = aws_lambda_function.lambda.arn
}
resource "aws_lambda_permission" "cloudwatch_invoke" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled.arn
}
resource "aws_cloudwatch_log_group" "this" {
  name              = local.cloudwatch_log_group_name
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}
