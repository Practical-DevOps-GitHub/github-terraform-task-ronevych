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
}

resource "github_repository" "repo" {
  name        = "terraform-lab-github"
  visibility  = "public"
  auto_init   = true # Створює початковий коміт і гілку main
}

resource "github_repository_collaborator" "collab" {
  repository = github_repository.repo.name
  username   = "softservedata"
  permission = "push"
}

resource "github_branch" "develop" {
  repository = github_repository.repo.name
  branch     = "develop"
}

resource "github_branch_default" "default" {
  repository = github_repository.repo.name
  branch     = github_branch.develop.branch
}

resource "github_repository_file" "pr_template" {
  repository          = github_repository.repo.name
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
  repository          = github_repository.repo.name
  branch              = "main"
  file                = ".github/CODEOWNERS"
  content             = "* @softservedata"
  overwrite_on_create = true
  depends_on          = [github_branch.develop]
}

resource "github_branch_protection" "develop_protection" {
  repository_id = github_repository.repo.node_id
  pattern       = "develop"

  required_pull_request_reviews {
    required_approving_review_count = 2
  }
}

resource "github_branch_protection" "main_protection" {
  repository_id = github_repository.repo.node_id
  pattern       = "main"

  required_pull_request_reviews {
    required_approving_review_count = 0
    require_code_owner_reviews      = true
  }
}

resource "github_actions_secret" "pat" {
  repository      = github_repository.repo.name
  secret_name     = "PAT"
  plaintext_value = var.github_token
}

resource "github_actions_secret" "terraform_code" {
  repository      = github_repository.repo.name
  secret_name     = "TERRAFORM"
  plaintext_value = file("main.tf")
}

resource "github_repository_deploy_key" "deploy_key" {
  repository = github_repository.repo.name
  title      = "DEPLOY_KEY"
  key        = var.deploy_public_key
  read_only  = true
}