resource "aws_security_group" "rds_sg" {
  name        = "sg_rds_instance"
  description = "sg_rds_instance allow all"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# module "db" {
#   source  = "terraform-aws-modules/rds/aws"
#   version = "~> 2.0"
#   identifier = "notes-app"
#   engine            = "mysql"
#   engine_version    = "5.7.19"
#   instance_class    = "db.t3.micro"
#   allocated_storage = 1
#   name     = "notes_app"
#   username = "root"
#   password = "callicoder"
#   port     = "3306"
#   iam_database_authentication_enabled = true
#   vpc_security_group_ids = [aws_security_group.rds_sg.id]
#   tags = {
#     Owner       = "user"
#     Environment = "dev"
#   }
#   subnet_ids = [module.vpc.private_subnets[2],module.vpc.private_subnets[3]]
#   family = "mysql5.7"
#   major_engine_version = "5.7"
#   final_snapshot_identifier = "demodb"
#   maintenance_window = "Mon:00:00-Mon:03:00"
#   backup_window      = "03:00-06:00"
#   parameter_group_name = "default.mysql5.7"
# }

data "template_file" "mysql_userinit" {
  template = "${file("${path.module}/userdata.tpl")}"
}


module "ec2_cluster" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"
  name                   = "db"
  instance_count         = 1
  ami                    = var.ami_image
  instance_type          = "t3.micro"
  key_name               = "${aws_key_pair.generated_key.key_name}"
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  subnet_id              = module.vpc.private_subnets[2]
  user_data              = data.template_file.mysql_userinit.rendered

  tags = {
    Terraform   = "true"
    Environment = "dev"
    service = "mysql"
  }
}

resource "aws_route53_zone" "main" {
  name = "java-app.net"
  vpc {
    vpc_id = module.vpc.vpc_id
  }
  tags = {
    Environment = "dev"
  }
}

resource "aws_route53_record" "mysql-A" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "db.java-app.net"
  type    = "A"
  ttl     = "30"
  records = [module.ec2_cluster.private_ip[0]]
}