# Terraform AWS Lambda Function


Terraform AWS Lambda Function  module  to build a Lambda Function with Docker Container Image.

This module creates a Lambda Fucntion which will trigger by Cloud Watch Events.


## Usage
```hcl
module "lambda" {
  source = "bitbucket.org/liveviewtech/terraform-aws-fargate-component.git?ref=v1"

  image_uri     = "${module.base.ecr_repository.repository_url}:${var.image_tag}"
  package_type  = "Image"
  name = local.project.id
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
```

#### Lambda Function
- **`name`** - (Required) Lambda Function Name
- **`iamgeuri`**(Required) the ecr_image_url with the tag like: `<acct_num>.dkr.ecr.us-west-2.amazonaws.com/myapp:dev` or the image URL from dockerHub or some other docker registry
- **`environment_variables`** - (Required) a map of environment variables to pass to the docker container
- **`secrets`** - (Required) a map of secrets from the parameter store to be assigned to env variables
## Created Resources
- Lambda Function (if not provided)
   with security group
- IAM role, policy to attach Secrets
- Creates Cloud Watch Event Trigger to trigger the lambda Function
- CloudWatch Log Group
- CloudWatch Metric Alarms (one for stepping up and one for stepping down)
- Lambda Function (if not provided)
  - with security group,IAM role, policy to attach Secrets
- CloudWatch Log Group


Requirement:

Inputs:

| Name                          | Type                                  | Description                                                                                                                                                                                              | Default |
| ----------------------------- | ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| name                   | string                   | Application name to name your Lambda Function                                                                                                                                   | null    |
| image_uri                          | string               |ECR Image URI containing the function's deployment package                 |                                                                                                                                           |         |
| filename              | string                                | File that contains your compiled or zipped                                                                                                               | <name>  |
| handler            | string                                  | The function entrypoint in your code.                                                                                                                                                    | true    |
| layers          | list(string)       | List of Lambda Layer Version ARNs (maximum of 5) to attach to the Lambda Function.
| memory_size    | number | Amount of memory in MB the Lambda Function can use at runtime.      | 512     |                                            | []      |
| package_type                 | string                          | The Lambda deployment package type. Valid values are Zip and Image.                                                                                                                                       | []      |
| role                      | string                                |Role created for the Lambda Function                                                                                                                                                                                                                                                                            
| timeout               | list(string)                          | List of extra security group IDs to attach to the fargate task                                                                                                                                           | []      |
| vpc_id                        | string                                | VPC ID to deploy the ECS fargate service and ALB                                                                                                                                                         |         |
| private_subnet_ids            | list(string)                          | List of subnet IDs for the fargate service                                                                                                                                                               |         |
| role_permissions_boundary_arn | string                                | ARN of the IAM Role permissions boundary to place on each IAM role created                                                                                                                                                                       |         |
| log_retention_in_days         | number                                | CloudWatch log group retention in days                                                                                                                                                                   | 120     |
| tags                          | map(string)                           | A map of AWS Tags to attach to each resource created                                                                                                                                                     | {}      |
 


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


