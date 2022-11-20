output "function_arn" {
  description = "The ARN of the Lambda Function"
  value       = aws_lambda_function.lambda.arn
}

output "function_name" {
  description = "The name of the Lambda Function"
  value       = aws_lambda_function.lambda.function_name
}

output "role_arn" {
  description = "The ARN of the IAM role created for the Lambda Function"
  value       = aws_iam_role.lambda.arn
}

output "role_name" {
  description = "The name of the IAM role created for the Lambda Function"
  value       = aws_iam_role.lambda.name
}

