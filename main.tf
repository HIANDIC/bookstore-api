terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  # If you are not using AWS CLI configuration, you need to enter your credentials or create an appropriate a role in order to create resources
  region = "us-east-1"
}

# Configure the GitHub Provider
provider "github" {
  # please enter your token here
  token = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

resource "github_repository" "myrepo" {
  name       = "bookstore-repo"
  auto_init  = true
  visibility = "private"
}

resource "github_branch_default" "main" {
  branch     = "main"
  repository = github_repository.myrepo.name
}

variable "files" {
  default = ["bookstore-api.py", "Dockerfile", "docker-compose.yml", "requirements.txt"]
}

resource "github_repository_file" "myfiles" {
  for_each            = toset(var.files)
  content             = file(each.value)
  file                = each.value
  repository          = github_repository.myrepo.name
  branch              = "main"
  commit_message      = "Managed by Terraform"
  overwrite_on_create = true
}

resource "aws_instance" "tf-docker-ec2" {
  ami             = "ami-0f9fc25dd2506cf6d"
  instance_type   = "t2.micro"
  key_name        = "First_Key"
  security_groups = ["pugat-docker-sec-gr"]
  tags = {
    "Name" = "Web Server of Bookstore"
  }

  # in userdata you need to enter your valid token
  user_data = <<-EOF
        #! /bin/bash
          yum update -y
          amazon-linux-extras install docker -y
          systemctl start docker
          systemctl enable docker
          usermod -a -G docker ec2-user
          curl -L "https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-$(uname -s)-$(uname -m)" \
          -o /usr/local/bin/docker-compose
          chmod +x /usr/local/bin/docker-compose  
          mkdir -p /home/ec2-user/bookstore-api
          cd /home/ec2-user/bookstore-api          
          TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
          FOLDER="https://$TOKEN@raw.githubusercontent.com/HIANDIC/bookstore-repo/main/"
          curl -s -o bookstore-api.py -L "$FOLDER"bookstore-api.py 
          curl -s -o Dockerfile -L "$FOLDER"Dockerfile 
          curl -s -o docker-compose.yml -L "$FOLDER"docker-compose.yml 
          curl -s -o requirements.txt -L "$FOLDER"requirements.txt 
          docker build -t bookstore-api:latest .
          docker-compose up -d
        EOF
depends_on = [
  github_repository.myrepo, github_repository_file.myfiles
]
}

resource "aws_security_group" "tf-docker-ec2-sec-gr" {
    name = "pugat-docker-sec-gr"
    tags = {
      "Name" = "docker-sec-gr"
    }

    ingress {
        from_port = 80
        protocol = "tcp"
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        protocol = "tcp"
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        protocol = "-1"
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }  
}

output "website" {
    value = "http://${aws_instance.tf-docker-ec2.public_dns}"
  
}
