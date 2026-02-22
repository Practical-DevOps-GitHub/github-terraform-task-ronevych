variable "github_token" {
  type      = string
  sensitive = true
}

variable "discord_webhook_url" {
  type      = string
  sensitive = true
}

variable "deploy_public_key" {
  type = string
}