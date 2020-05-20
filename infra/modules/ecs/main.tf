#data "aws_region" "current" {}

data "aws_caller_identity" "current" {}



resource "aws_iam_role" "iamEcsRole" {
  name = "iamEcsRole"
  permissions_boundary = ""
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ecsInstanceRole" {
  name = "ecsInstanceRole"
  role = "${aws_iam_role.iamEcsRole.name}"
}

resource "aws_iam_role_policy_attachment" "containerServiceAttach" {
    role       = "${aws_iam_role.iamEcsRole.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    depends_on = ["aws_iam_role.iamEcsRole"]
}


# resource "aws_launch_configuration" "ecs_lc" {
#   image_id             = "${var.ami_image}"
#   instance_type        = "${var.instance_type}"
#   security_groups      = ["${aws_security_group.ecs_sg_instance.id}"]
#   user_data            = "${data.template_file.user_data.rendered}"
#   iam_instance_profile = "${aws_iam_instance_profile.ecsInstanceRole.id}"
#   key_name             = "${var.ecs_key}"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# data "template_file" "user_data" {
#   template =  "${file("${path.module}/user_data.sh")}"

#   vars = {
#     cluster_name      = "${aws_ecs_cluster.ecs_cluster_name.name}"
#   }
# }


# resource "aws_autoscaling_group" "ecs_asg" {
#   max_size             = "1"
#   min_size             = "1"
#   desired_capacity     = "1"
#   force_delete         = true
#   launch_configuration = "${aws_launch_configuration.ecs_lc.id}"
#   vpc_zone_identifier  = var.private_subnet_ids
#   health_check_type    = "EC2"
#   default_cooldown     = 60
# }



resource "aws_ecr_repository" "ecr_java_app" {
  name = "java_app"
}

resource "aws_ecs_cluster" "ecs_cluster_name" {
  name = "java-app"
}


resource "aws_iam_role" "iam_codepipeline_role" {
  name = "iam_codepipeline"
  permissions_boundary = ""
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}
resource "aws_iam_role_policy" "iam_codepipeline_policy" {
  name = "iam_codepipeline_policy"
  role = "${aws_iam_role.iam_codepipeline_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:StartBuild",
                "codebuild:BatchGetBuilds"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

# ECS Service Role
resource "aws_iam_role" "iam_ecs_service_role" {
  name = "ecsServiceRole"
  path = "/"
  permissions_boundary = ""
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecsServiceRolePolicy" {
  name = "ecsServiceRolePolicy"
  role = "${aws_iam_role.iam_ecs_service_role.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:Describe*",
            "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
            "elasticloadbalancing:DeregisterTargets",
            "elasticloadbalancing:Describe*",
            "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
            "elasticloadbalancing:RegisterTargets"
        ],
        "Resource": "*"
    }
  ]
}
POLICY
}
# #Allow all
# resource "aws_security_group" "elb_sg" {
#   name        = "allow_all"
#   description = "Allow all inbound and outbound traffic"
#   vpc_id      = "${var.vpc_id}"
#   ingress {
#     from_port   = 0
#     to_port     = 65535
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#     egress {
#     from_port   = 0
#     to_port     = 65535
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "allow_all"
#   }
# }
# Create a new load balancer
# resource "aws_elb" "java-app-elb" {
#   name               = "java-app"
#   subnets = "${var.public_subnet_ids}"
#   listener {
#     instance_port     = 5000
#     instance_protocol = "http"
#     lb_port           = 80
#     lb_protocol       = "http"
#   }

#   health_check {
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     timeout             = 3
#     target              = "HTTP:5000/"
#     interval            = 30
#   }

#   cross_zone_load_balancing   = true
#   idle_timeout                = 400
#   connection_draining         = true
#   connection_draining_timeout = 400
#   security_groups = ["${aws_security_group.elb_sg.id}"]
#   tags = {
#     Name = "java-app"
#   }
# }
resource "aws_iam_role" "iam_code_build_role" {
  name = "iam_code_build_role"
  permissions_boundary = ""
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iam_code_build_policy" {
  name = "iam_code_build_policy"
  role = "${aws_iam_role.iam_code_build_role.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning"
      ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": "AccessCodePipelineArtifacts"
    },
    {
      "Action": [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs",
          "ec2:*",
          "iam:PassRole"
       ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": "AccessECR"
    },
    {
      "Action": [
          "ecr:GetAuthorizationToken"
      ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": "ecrAuthorization"
    },
    {
      "Action": [
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeServices",
          "ecs:CreateService",
          "ecs:ListServices",
          "ecs:UpdateService"
      ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": "ecsAccess"
    },
    {
         "Sid":"logStream",
         "Effect":"Allow",
         "Action":[
            "logs:PutLogEvents",
            "logs:CreateLogGroup",
            "logs:CreateLogStream"
         ],
         "Resource":"arn:aws:logs:${var.region}:*:*"
    },
    {
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:PassRole"
            ],
            "Resource": "${aws_iam_role.iam_ecs_service_role.arn}"
    }
  ]
}
POLICY
}

resource "random_id" "random" {
 byte_length = 5
}

resource "aws_s3_bucket" "default" {
  bucket = "${random_id.random.dec}-ecs"
  acl    = "private"

  tags = {
    Name        = "Demo"
    Environment = "Demo"
  }
}

resource "aws_codepipeline" "codepipeline" {
  name     = "demo"
  role_arn = "${aws_iam_role.iam_codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.default.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]

      configuration = {
        OAuthToken           = "${var.github_oauth_token}"
        Owner                = "${var.repo_owner}"
        Repo                 = "${var.repo_name}"
        Branch               = "${var.branch}"
        PollForSourceChanges = "${var.poll_source_changes}"
      }
    }
  }

  stage {
    name = "BuildDocker"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["code"]
      output_artifacts = ["jar_file"]
      version         = "1"
      configuration = {
        ProjectName = "${aws_codebuild_project.codebuild_docker_image.name}"
      }
    }
  }
  stage {
  name = "Approve"

  action {
    name     = "Approval"
    category = "Approval"
    owner    = "AWS"
    provider = "Manual"
    version  = "1"
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["code"]
      version         = "1"
      configuration = {
        ProjectName = "${aws_codebuild_project.codebuild_deploy_on_ecs.name}"
      }
    }
  }
lifecycle {
    ignore_changes = [
      "stage[0].action[0].configuration",
    ]
}

}

resource "aws_codebuild_project" "codebuild_docker_image" {
  name         = "codebuild_docker_image"
  description  = "build docker images"
  build_timeout      = "300"
  service_role = "${aws_iam_role.iam_code_build_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    type         = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "${var.region}"
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "${data.aws_caller_identity.current.account_id}"
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "${aws_ecr_repository.ecr_java_app.name}"
    }
  }

  vpc_config {
    vpc_id = var.vpc_id
    subnets = var.private_subnet_ids
    security_group_ids = [
      var.ecs_sg,
    ]
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "java-app/buildspec.yml"
  }

}

resource "aws_codebuild_project" "codebuild_deploy_on_ecs" {
  name         = "codebuild_deploy_on_ecs"
  description  = "Code Build Deploy ECS"
  build_timeout      = "300"
  service_role = "${aws_iam_role.iam_code_build_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    type         = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "AWS_REGION"
      value = "${var.region}"
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "${data.aws_caller_identity.current.account_id}"
    }
    environment_variable {
      name  = "ECS_CLUSTER"
      value = "${aws_ecs_cluster.ecs_cluster_name.name}"
    }
    environment_variable {
      name  = "IMAGE_NAME"
      value = "java_app"
    }
    #subnet_ids
    environment_variable {
      name  = "SUBNET_IDS"
      value = "${var.private_subnet_ids[0]},${var.private_subnet_ids[1]}"
    }
    #sg_ids
    environment_variable {
      name  = "SG_IDS"
      value = var.ecs_sg
    }
    environment_variable {
      name = "ECS_TASKEXEC_ARN"
      value = "${aws_iam_role.ecs_tasks_execution_role.arn}"
    }
    environment_variable {
      name = "TG_ARN"
      value = var.tg_arn
    }
  }

  source {
    type            = "CODEPIPELINE"
    buildspec = <<EOF
version: 0.2
phases:
  install:
    commands:
      - yum install jq -y
  build:
    commands:
      - cd java-app
      - echo "Create/update on the ECS cluster."
      - bash deploy.sh
EOF
  }

}