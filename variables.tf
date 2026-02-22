variable "github_token" {
  type      = string
  sensitive = true
  default   = ""
}

variable "discord_webhook_url" {
  type      = string
  sensitive = true
  default   = ""
}

variable "deploy_public_key" {
  type    = string
  default = ""
}