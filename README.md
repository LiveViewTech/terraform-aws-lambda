# Terraform AWS Lambda Function


Terraform module to create and manage a AWS Lambda function created through either a zip archive or docker container image

## Usage
```hcl
module "lambda" {
  source = "bitbucket.org/liveviewtech/terraform-aws-lambda.git?ref=v2"

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
```
## Created Resources
- Lambda Function
- Default Security Group
- Lambda Layer to fetch SSM parameters
- IAM Role
  - Includes policy to fetch SSM parameters if secrets are included
- CloudWatch Log Group

## Inputs:
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description of your Lambda Function (or Layer) | `string` | `""` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | A map that defines environment variables for the Lambda Function. | `map(string)` | `{}` | no |
| <a name="input_filename"></a> [filename](#input\_filename) | The path to the function's deployment package within the local filesystem. If defined, The s3\_-prefixed options and image\_uri cannot be used. | `string` | `""` | no |
| <a name="input_handler"></a> [handler](#input\_handler) | The function entrypoint in your code. | `string` | `""` | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | The ECR image URI containing the function's deployment package. | `string` | `""` | no |
| <a name="input_layers"></a> [layers](#input\_layers) | List of Lambda Layer Version ARNs (maximum of 4) to attach to the Lambda Function. | `list(string)` | `[]` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | CloudWatch log group retention in days. Defaults to 120. | `number` | `120` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Amount of memory in MB your Lambda Function can use at runtime. Valid value between 128 MB to 10,240 MB (10 GB), in 64 MB increments. | `number` | `128` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for your lambda function | `string` | `""` | no |
| <a name="input_package_type"></a> [package\_type](#input\_package\_type) | The Lambda deployment package type. Valid values are Zip and Image. | `string` | `"Zip"` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of subnet IDs for the fargate service. | `list(string)` | `[]` | no |
| <a name="input_role_permissions_boundary_arn"></a> [role\_permissions\_boundary\_arn](#input\_role\_permissions\_boundary\_arn) | ARN of the IAM Role permissions boundary to place on each IAM role created. | `string` | `""` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | The runtime environment for your function. (e.g. python3.9) | `string` | `""` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | A map that defines secrets for the Lambda Function. | `map(string)` | `{}` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | List of extra security group IDs to attach to the function | `list(string)` | `[]` | no |
| <a name="input_source_code_hash"></a> [source\_code\_hash](#input\_source\_code\_hash) | The path to your deployment package. Used to detect changes requiring re-provisioning | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of AWS Tags to attach to each resource created | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | The amount of time your Lambda Function has to run in seconds. | `number` | `30` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | `""` | no |

## Outputs
| Name | Description |
|------|-------------|
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | The ARN of the Lambda Function |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | The name of the Lambda Function |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the IAM role created for the Lambda Function |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the IAM role created for the Lambda Function |


