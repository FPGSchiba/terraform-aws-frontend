output "amplify_app_id" {
  value = aws_amplify_app.this.id
}

output "default_domain" {
  description = "Amplify’s default domain for the app"
  value       = aws_amplify_app.this.default_domain
}

output "branch_url" {
  value = aws_amplify_branch.this.branch_url
}
