resource "aws_cognito_user_pool" "this" {
  name = "${var.project_name}-user-pool"
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "${var.project_name}-client"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = false
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = "${var.project_name}-domain"
  user_pool_id = aws_cognito_user_pool.this.id
}

output "user_pool_arn"     { value = aws_cognito_user_pool.this.arn }
output "user_pool_id"      { value = aws_cognito_user_pool.this.id }
output "user_pool_client_id" { value = aws_cognito_user_pool_client.this.id }
output "user_pool_domain"  { value = aws_cognito_user_pool_domain.this.domain }
