variable "name" {
  type = string
}

variable "filename" {
  type        = string
  description = "The path to the function's deployment package within the local filesystem. If defined, The s3_-prefixed options and image_uri cannot be used."
  default     = null
}

variable "handler" {
  type        = string
  description = "The function entrypoint in your code."
  default     = null
}

variable "package_type" {
  type        = string
  description = "The Lambda deployment package type. Valid values are Zip and Image."
  default     = "Zip"
}

variable "description" {
  description = "Description of your Lambda Function (or Layer)"
  type        = string
  default     = ""
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime. Valid value between 128 MB to 10,240 MB (10 GB), in 64 MB increments."
  type        = number
  default     = 128
}

variable "layers" {
  type        = list(string)
  description = "List of Lambda Layer Version ARNs (maximum of 3) to attach to the Lambda Function."
  default     = []
}

variable "runtime" {
  type    = string
  default = null
}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds."
  type        = number
  default     = 30
}
variable "security_groups" {
  type        = list(string)
  description = "List of extra security group IDs to attach to the fargate task."
  default     = []
}
variable "vpc_id" {
  type        = string
  description = "VPC ID to deploy ECS fargate service."
  default     = ""
}

variable "role_permissions_boundary_arn" {
  type        = string
  description = "ARN of the IAM Role permissions boundary to place on each IAM role created."
}

variable "image_uri" {
  type        = string
  description = "The ECR image URI containing the function's deployment package."
  default     = null
}
variable "private_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the fargate service."
}

variable "log_retention_in_days" {
  type        = number
  description = "CloudWatch log group retention in days. Defaults to 120."
  default     = 120
}
variable "tags" {
  type        = map(string)
  description = "A map of AWS Tags to attach to each resource created"
  default     = {}
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "interval" {
  type    = string
  default = "10 minutes"

  description = "the time between invocations"
}

variable "environment_variables" {
  description = "A map that defines environment variables for the Lambda Function."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "A map that defines secrets for the Lambda Function."
  type        = map(string)
  default     = {}
}

variable "source_code_hash" {
  type    = string
  default = null
}
