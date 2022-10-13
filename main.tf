terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = ">= 3.0.0"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {

 
resource "aws_lambda_function" "this" {
  count = module.this.enabled ? 1 : 0

  architectures                  = var.architectures
  description                    = var.description
  filename                       = var.filename
  function_name                  = var.app_name
  handler                        = var.handler
  image_uri                      = var.image_uri
  kms_key_arn                    = var.kms_key_arn
  layers                         = var.layers
  memory_size                    = var.memory_size
  package_type                   = var.package_type
  publish                        = var.publish
  reserved_concurrent_executions = var.reserved_concurrent_executions
  role                           = aws_iam_role.this[0].arn
  runtime                        = var.runtime
  s3_bucket                      = var.s3_bucket
  s3_key                         = var.s3_key
  s3_object_version              = var.s3_object_version
  source_code_hash               = var.source_code_hash
  tags                           = var.tags
  timeout                        = var.timeout

}
environment = [
        for key in keys(def.environment_variables != null ? def.environment_variables : {}) :
        {
          name  = key
          value = lookup(def.environment_variables, key)
        }
      ]
secrets = [
        for key in keys(def.secrets != null ? def.secrets : {}) :
        {
          name      = key
          valueFrom = "${local.ssm_parameter_arn_base}${replace(lookup(def.secrets, key), "/^//", "")}"
        }
      ]

resource "aws_iam_role" "this" {
  count = local.enabled ? 1 : 0

  name                 = "${var.function_name}-${local.region_name}"
  assume_role_policy   = join("", data.aws_iam_policy_document.assume_role_policy.*.json)
  permissions_boundary = var.permissions_boundary_arn
  tags                 = var.tags
}

resource "aws_iam_role_policy_attachment" "execution_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.execution_role.arn
}


data "aws_iam_policy_document" "assume_role_policy" {
  count = local.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = concat(["lambda.amazonaws.com"], var.lambda_at_edge_enabled ? ["edgelambda.amazonaws.com"] : [])
    }
  }
}



resource "aws_iam_role_policy_attachment" "vpc_access" {
  count = local.enabled && var.vpc_config != null ? 1 : 0

  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.this[0].name
}


resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  count = local.enabled ? 1 : 0

  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.this[0].name
}


data "aws_iam_policy_document" "secrets_access" {
  count = try((local.enabled && var.ssm_parameter_names != null && length(var.ssm_parameter_names) > 0), false) ? 1 : 0

  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]

    resources = formatlist("arn:${local.partition}:ssm:${local.region_name}:${local.account_id}:parameter%s", var.ssm_parameter_names)
  }
}

resource "aws_iam_policy" "secrets_access" {
  count      = local.has_secrets ? 1 : 0
  name        = "${var.function_name}_secrets-access"
  description = var.iam_policy_description
  policy      = data.aws_iam_policy_document.ssm[count.index].json
}


resource "aws_iam_role_policy_attachment" "secrets_policy" {
  count      = local.has_secrets ? 1 : 0
  policy_arn = aws_iam_policy.secrets_access[0].arn
  role       = aws_iam_role.this[0].name
}




resource "aws_cloudwatch_event_rule" "scheduled" {
  count = var.enabled == true ? 1 : 0

  name                = module.labels.id
  description         = var.description
  event_pattern       = var.event_pattern
  schedule_expression = var.schedule_expression
  role_arn            = var.role_arn
  is_enabled          = var.is_enabled
  tags                = module.labels.tags
}

resource "aws_cloudwatch_event_target" "scheduled" {
  count      = var.enabled == true ? 1 : 0
  rule       = aws_cloudwatch_event_rule.default.*.name[0]
  target_id  = var.target_id
  arn        = var.arn
  input_path = var.input_path != "" ? var.input_path : null
  role_arn   = var.target_role_arn

  input_transformer {

    input_paths    = var.input_path == "" ? var.input_paths : null
    input_template = var.input_path == "" ? var.input_template : null
  }


}

resource "aws_lambda_permission" "cloudwatch_invoke" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled.arn
}
