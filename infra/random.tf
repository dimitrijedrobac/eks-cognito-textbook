resource "random_string" "short" {
  length  = 5
  upper   = false
  lower   = true
  numeric  = true
  special = false
}
