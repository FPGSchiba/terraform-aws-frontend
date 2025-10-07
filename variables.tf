variable "app_name" {
  description = "Amplify app name"
  type        = string
}

variable "github_repository_url" {
  description = "GitHub repo URL, e.g., https://github.com/org/repo"
  type        = string
}

variable "github_token" {
  description = "GitHub token with repo access (or use GitHub App token)"
  type        = string
  sensitive   = true
  default     = null
}

variable "branch_name" {
  description = "Branch to build/deploy"
  type        = string
}

variable "output_directory" {
  description = "Directory with built assets (e.g., dist or build)"
  type        = string
}

variable "build_command" {
  description = "Build command to run"
  type        = string
}

variable "pre_build_commands" {
  description = "Optional list of preBuild commands"
  type        = list(string)
  default     = []
}

variable "environment_variables" {
  description = "Env vars passed to build and runtime"
  type        = map(string)
  default     = {}
}

variable "app_root" {
  description = "Subfolder of the repo containing the app, if monorepo"
  type        = string
  default     = "."
}

variable "framework" {
  description = "Optional framework hint for Amplify UI"
  type        = string
  default     = null
}

variable "stage" {
  description = "Amplify stage label"
  type        = string
  default     = "PRODUCTION"
}

variable "enable_pr_previews" {
  description = "Enable PR preview builds"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Optional custom domain to map to the app"
  type        = string
  default     = null
}

variable "domain_prefix" {
  description = "Subdomain prefix, e.g., www"
  type        = string
  default     = "www"
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}
