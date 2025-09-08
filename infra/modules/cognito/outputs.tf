output "user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.arn
}

output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_client_id" {
  description = "ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.this.id
}

output "user_pool_domain" {
  description = "Hosted UI domain prefix (not full URL)"
  value       = aws_cognito_user_pool_domain.this.domain
}

output "user_pool_domain_prefix" {
  value = aws_cognito_user_pool_domain.this.domain
}