output "lambda_function_arn" {
  description = "The ARN of the Lambda Function"
  value       = aws_lambda_function.lambda.arn
}

output "lambda_function_name" {
  description = "The name of the Lambda Function"
  value       = aws_lambda_function.lambda.function_name
}


output "lambda_role_arn" {
  description = "The ARN of the IAM role created for the Lambda Function"
  value       = aws_iam_role.lambda.arn
}

output "lambda_role_name" {
  description = "The name of the IAM role created for the Lambda Function"
  value       = aws_iam_role.lambda.name
}

