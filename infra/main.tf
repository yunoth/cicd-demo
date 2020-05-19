provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# resource "aws_ecr_repository" "ecr_repo" {
#   name                 = "casestudy"
#   image_tag_mutability = "MUTABLE"
#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }


resource "tls_private_key" "example" {
  algorithm = "RSA"
}

resource "aws_key_pair" "generated_key" {
  key_name   = "pemkey"
  public_key = "${tls_private_key.example.public_key_openssh}"
}

resource "local_file" "public_key_openssh" {
  content  = tls_private_key.example.private_key_pem
  filename = "/tmp/pemkey_ecs.pem"
  file_permission = "0400"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "myvpc"
  cidr = "${var.vpc_cidr}" #"10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24","10.0.3.0/24", "10.0.4.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
  enable_dns_hostnames = true
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_codecommit_repository" "backend-repository" {
  repository_name = "${var.repository_name}"
  description     = "${var.repository_name}"
  lifecycle {
    prevent_destroy = false
  }
}


module "ecs" {
  source = "./modules/ecs"
  repo_owner = "${var.repo_owner}"
  repo_name = "${var.repo_name}"
  github_oauth_token = var.github_oauth_token
  #vpc_cidr = "${var.vpc_cidr}"
  ami_image = var.ami_image
  ecs_key = "${aws_key_pair.generated_key.key_name}"
  instance_type = var.instance_type
  private_subnet_ids =  [module.vpc.private_subnets[0],module.vpc.private_subnets[1]]
  public_subnet_ids =  [module.vpc.public_subnets[0],module.vpc.public_subnets[1]]
  vpc_id = module.vpc.vpc_id
  region = var.region
  tg_arn = module.alb.target_group_arns[0]
}

