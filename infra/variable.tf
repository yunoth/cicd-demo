variable "environment" {
  type = "string"
  description = "environment"
  default = "staging"
}
variable "region" { default = "us-east-1"}
variable "service_name" {}
variable "repository_name" {}
variable "repo_owner" {}
variable "repo_name" {}
variable "github_oauth_token" {}
variable "vpc_cidr"  {}
variable "ami_image" {default = "ami-09568291a9d6c804c"}
variable "ecs_key" { default = "demo" }
variable "instance_type" {}
variable "access_key" {}
variable "secret_key" {}
