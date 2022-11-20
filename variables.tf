variable "name" {
  type        = string
  description = "Name for your lambda function"
  default     = ""
}

variable "filename" {
  type        = string
  description = "The path to the function's deployment package within the local filesystem. If defined, The s3_-prefixed options and image_uri cannot be used."
  default     = ""
}

variable "handler" {
  type        = string
  description = "The function entrypoint in your code."
  default     = ""
}

variable "package_type" {
  type        = string
  description = "The Lambda deployment package type. Valid values are Zip and Image."
  default     = "Zip"
}

variable "description" {
  type        = string
  description = "Description of your Lambda Function (or Layer)"
  default     = ""
}

variable "memory_size" {
  type        = number
  description = "Amount of memory in MB your Lambda Function can use at runtime. Valid value between 128 MB to 10,240 MB (10 GB), in 64 MB increments."
  default     = 128
}

variable "layers" {
  type        = list(string)
  description = "List of Lambda Layer Version ARNs (maximum of 4) to attach to the Lambda Function."
  default     = []
}

variable "runtime" {
  type        = string
  description = "The runtime environment for your function. (e.g. python3.9)"
  default     = ""
}

variable "timeout" {
  type        = number
  description = "The amount of time your Lambda Function has to run in seconds."
  default     = 30
}

variable "security_groups" {
  type        = list(string)
  description = "List of extra security group IDs to attach to the function"
  default     = []
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
  default     = ""
}

variable "role_permissions_boundary_arn" {
  type        = string
  description = "ARN of the IAM Role permissions boundary to place on each IAM role created."
  default     = ""
}

variable "image_uri" {
  type        = string
  description = "The ECR image URI containing the function's deployment package."
  default     = ""
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the fargate service."
  default     = []
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

variable "environment_variables" {
  type        = map(string)
  description = "A map that defines environment variables for the Lambda Function."
  default     = {}
}

variable "secrets" {
  type        = map(string)
  description = "A map that defines secrets for the Lambda Function."
  default     = {}
}

variable "source_code_hash" {
  type        = string
  description = "The path to your deployment package. Used to detect changes requiring re-provisioning"
  default     = null
}
