

variable "aws_region" {
  type    = "string"
  default = "us-east-1"
}

variable "stack_name" {
  description = "This name will be used for resources created on AWS"
}
 

variable "github_repo_url" {
  description = "url for repo with static web, e.g. https://github.com/user/repo"
}
