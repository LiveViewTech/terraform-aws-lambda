# Terraform AWS Lambda Function


Terraform AWS Lambda Function  module  to build a Lambda Function with Docker Container Image.

This module creates a Lambda Fucntion which will trigger by Cloud Watch Events.


## Usage
```hcl
module "lambda" {
  source = "bitbucket.org/liveviewtech/terraform-aws-fargate-component.git?ref=v"

  image_uri     = "${module.base.ecr_repository.repository_url}:${var.image_tag}"
  package_type  = "Image"
  function_name = local.project.id
  tags = {
       env       = "dev"
    }
  private_subnet_ids = module.acs.private_subnet_ids
  security_groups = [
    module.acs.message_store_security_group.id,
    module.acs.horus_security_group.id,
  ]
  vpc_id = module.acs.vpc.id
  environment_variables = {
    LOG_LEVEL = "info"
    LOG_TAGS  = "_untagged,-data,messaging,entity_projection,entity_store,ignored,settings,cloudwatch"
    SSM_PARAMETER    = aws_ssm_parameter.message_store_url.name
   
  }
  role_permissions_boundary_arn = module.acs.role_permissions_boundary.arn
}



## Created Resources
Lambda Function (if not provided)
with security group
with IAM role, policy to attach Secrets
Creates Cloud Watch Event Trigger to trigger the lambda Function
CloudWatch Log Group
CloudWatch Metric Alarms (one for stepping up and one for stepping down)
- Lambda Function (if not provided)
  - with security group,IAM role, policy to attach Secrets
- CloudWatch Log Group


Requirement:

Inputs:

## Outputs

| Name                           | Type                                                                                                                | Description                                                      |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| lambda_function_arn               | [object](https://www.terraform.io/docs/providers/aws/r/ecs_service.html#attributes-reference)                       | The ARN of the Lambda Function                                      |
| lambda_function_name                  | [object](https://www.terraform.io/docs/providers/aws/r/ecs_cluster.html#attributes-reference)                       | The name of the Lambda Function |
| lambda_role_arn               | [object](https://www.terraform.io/docs/providers/aws/r/security_group.html#attributes-reference)                    | The ARN of the IAM role created for the Lambda Function            |
| lambda_role_name               | [object](https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html#attributes-reference)               | The name of the IAM role created for the Lambda Function                |
| autoscaling_step_up_policy     | [object](https://www.terraform.io/docs/providers/aws/r/autoscaling_policy.html#attributes-reference)                | Autoscaling policy to step up                                    |
| autoscaling_step_down_policy   | [object](https://www.terraform.io/docs/providers/aws/r/autoscaling_policy.html#attributes-reference)                | Autoscaling policy to step down                                  |
| task_role                      | [object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role#attributes-reference) | IAM role created for the tasks.                                  |
| task_execution_role            | [object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role#attributes-reference) | IAM role created for the execution of tasks.                     |


