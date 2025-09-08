resource "aws_cognito_user_pool" "this" {
  name                 = "${var.project_name}-${var.env}-up-${var.suffix}"
  deletion_protection  = "INACTIVE"
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = "${var.project_short}-${var.env}-${var.suffix}"
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_user_pool_client" "this" {
  name           = "${var.project_name}-${var.env}-client-${var.suffix}"
  user_pool_id   = aws_cognito_user_pool.this.id
  generate_secret = false
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]
}
