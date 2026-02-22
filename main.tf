terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = "Practical-DevOps-GitHub"
}

resource "github_repository_collaborator" "collab" {
  repository = "github-terraform-task-ronevych"
  username   = "softservedata"
  permission = "push"
}

resource "github_branch" "develop" {
  repository    = "github-terraform-task-ronevych"
  branch        = "develop"
  source_branch = "main"
}

resource "github_branch_default" "default" {
  repository = "github-terraform-task-ronevych"
  branch     = github_branch.develop.branch
}

resource "github_repository_file" "pr_template" {
  repository          = "github-terraform-task-ronevych"
  branch              = "main"
  file                = ".github/pull_request_template.md"
  depends_on          = [github_branch.develop]
  content             = <<EOT
Describe your changes
Issue ticket number and link
Checklist before requesting a review
- [ ] I have performed a self-review of my code
- [ ] If it is a core feature, I have added thorough tests
- [ ] Do we need to implement analytics?
- [ ] Will this be part of a product update? If yes, please write one phrase about this update
EOT
  overwrite_on_create = true
}

resource "github_repository_file" "codeowners" {
  repository          = "github-terraform-task-ronevych"
  branch              = "main"
  file                = ".github/CODEOWNERS"
  content             = "* @softservedata"
  overwrite_on_create = true
  depends_on          = [github_branch.develop]
}

resource "github_branch_protection" "develop_protection" {
  repository_id = "github-terraform-task-ronevych"
  pattern       = "develop"

  required_pull_request_reviews {
    required_approving_review_count = 2
  }
}

resource "github_branch_protection" "main_protection" {
  repository_id = "github-terraform-task-ronevych"
  pattern       = "main"

  required_pull_request_reviews {
    required_approving_review_count = 0
    require_code_owner_reviews      = true
  }

  depends_on = [
    github_repository_file.codeowners,
    github_repository_file.pr_template,
  ]
}

resource "github_actions_secret" "pat" {
  repository      = "github-terraform-task-ronevych"
  secret_name     = "PAT"
  plaintext_value = var.github_token
}

resource "github_actions_secret" "terraform_code" {
  repository      = "github-terraform-task-ronevych"
  secret_name     = "TERRAFORM"
  plaintext_value = file("main.tf")
}

resource "github_repository_deploy_key" "deploy_key" {
  repository = "github-terraform-task-ronevych"
  title      = "DEPLOY_KEY"
  key        = var.deploy_public_key
  read_only  = true
}