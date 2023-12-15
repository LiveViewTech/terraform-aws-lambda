terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = ">=3"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  secret_values          = [for k, v in var.secrets : v]
  has_secrets            = length(var.secrets) > 0
  ssm_parameter_arn_base = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/"
  secrets_arns = [
    for param in distinct(flatten((local.secret_values))) :
    "${local.ssm_parameter_arn_base}${replace(param, "/^//", "")}"
  ]
}

# === SECRETS LAYER === #

resource "local_file" "temp_wrapper" {
  filename = "${path.module}/retrieve-secret-layer/bin/secret-wrapper"
  content = (templatefile("${path.module}/retrieve-secret-layer/secret-wrapper.tftpl", {
    secrets  = var.secrets,
    role_arn = aws_iam_role.lambda.arn
  }))
}

data "archive_file" "this" {
  type        = "zip"
  output_path = "${path.module}/retrieve-secret-layer/target/secret-wrapper.zip"
  source_dir  = "${path.module}/retrieve-secret-layer/bin"
  depends_on  = [local_file.temp_wrapper]
}

resource "aws_lambda_layer_version" "this" {
  filename   = data.archive_file.this.output_path
  layer_name = "${var.name}-retrieve-ssm-secrets"

  description              = "Fetches Secrets from SSM and provides them as environment variables - Managed by Terraform"
  source_code_hash         = data.archive_file.this.output_base64sha256
  compatible_architectures = ["arm64"]
}

# === LAMBDA === #

resource "aws_lambda_function" "lambda" {
  description      = var.description
  filename         = var.filename
  source_code_hash = var.source_code_hash
  function_name    = var.name
  handler          = var.handler
  # image_uri        = var.image_uri
  memory_size   = var.memory_size
  package_type  = var.package_type
  role          = aws_iam_role.lambda.arn
  tags          = var.tags
  timeout       = var.timeout
  runtime       = var.runtime
  architectures = ["arm64"]

  layers = concat([aws_lambda_layer_version.this.arn], var.layers)

  dynamic "vpc_config" {
    for_each = var.private_subnet_ids == null ? [] : [var.private_subnet_ids]
    content {
      subnet_ids         = var.private_subnet_ids
      security_group_ids = concat([aws_security_group.this.id], var.security_groups)
    }
  }

  dynamic "environment" {
    for_each = var.environment_variables != null ? [1] : []
    content {
      variables = merge(var.environment_variables,
      { AWS_LAMBDA_EXEC_WRAPPER = "/opt/secret-wrapper" })
    }
  }
}

resource "aws_security_group" "this" {
  name_prefix = "lvt-"
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

resource "aws_cloudwatch_log_group" "this" {
  name              = "/lambda/${var.name}"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

# === IAM ROLE === #

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
  name                 = var.name
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
      "ssm:GetParametersByPath",
      "ssm:GetSecretValue",
      "kms:Decrypt"
    ]
    resources = local.secrets_arns
  }
}

resource "aws_iam_policy" "execution_role" {
  count  = local.has_secrets ? 1 : 0
  name   = var.name
  path   = "/"
  policy = data.aws_iam_policy_document.execution_role[0].json
}

resource "aws_iam_role_policy_attachment" "execution_role" {
  count      = local.has_secrets ? 1 : 0
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.execution_role[0].arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
