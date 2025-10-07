terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  normalized_output_dir = trim(var.output_directory, "/")
}

resource "aws_amplify_app" "this" {
  name       = var.app_name
  repository = var.github_repository_url # e.g. https://github.com/org/repo

  # Connect Amplify to GitHub via token
  oauth_token = var.github_token

  # Optional env vars available during build (NODE_OPTIONS, VITE_*, etc.)
  environment_variables = merge(
    {
      _LIVE_UPDATES = jsonencode([{
        name  = "amplify-cli"
        pkg   = "@aws-amplify/cli@latest"
        type  = "npm"
      }])
    },
    var.environment_variables
  )

  # Buildspec controls install/build/artifacts phases
  build_spec = <<-EOT
    version: 1
    applications:
      - appRoot: ${var.app_root}
        frontend:
          phases:
            preBuild:
              commands:
                - ${length(var.pre_build_commands) > 0 ? join("\n                - ", var.pre_build_commands) : "npm ci || npm install"}
            build:
              commands:
                - ${var.build_command}
          artifacts:
            baseDirectory: ${local.normalized_output_dir}
            files:
              - '**/*'
          cache:
            paths:
              - node_modules/**/*
        # Global redirects (SPA fallback)
        customHeaders:
          - pattern: '**/*'
            headers:
              - key: 'Cache-Control'
                value: 'public, max-age=0, must-revalidate'
        redirects:
          - source: </^[^.]+$|\\.(?!(css|gif|ico|jpg|jpeg|js|png|svg|txt|ttf|woff|woff2|map)$)([^.]+$)/>
            target: /index.html
            status: 200
            condition: ''
  EOT

  auto_branch_creation_config {
    enable_pull_request_preview = var.enable_pr_previews
    environment_variables       = var.environment_variables
    # pattern defaults in aws to create branches; we’ll disable auto-branch creation to be explicit
  }

  enable_auto_branch_creation = false

  tags = var.tags
}

resource "aws_amplify_branch" "this" {
  app_id            = aws_amplify_app.this.id
  branch_name       = var.branch_name
  enable_auto_build = true

  framework = var.framework # optional hint for UI, e.g., "React", "Next.js"

  stage = var.stage # e.g., "PRODUCTION" | "DEVELOPMENT"

  environment_variables = var.environment_variables

  tags = var.tags
}

# Optional: custom domain
resource "aws_amplify_domain_association" "this" {
  count  = var.domain_name == null ? 0 : 1
  app_id = aws_amplify_app.this.id
  domain_name = var.domain_name

  sub_domain {
    branch_name = aws_amplify_branch.this.branch_name
    prefix      = var.domain_prefix # e.g., "www" or "" for apex
  }
}
