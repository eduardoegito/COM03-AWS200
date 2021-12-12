terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_vpc" "default" {

  default = true
}

data "aws_security_group" "default" {
    name = "default"
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_http_ssh.name]
  key_name = aws_key_pair.name
  user_data = <<EOF
  #!/bin/bash

apt-get install -y  nginx php70-fpm
echo "<header>Hello World</header><p> It is working, dude!</p>" > /usr/share/nginx/html/index.php
for i in php-fpm nginx; do service $i start; done

EOF

  tags = {
    Name = "COM03-AWS100"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKsmf3/tJGZKJTzY2PLiqFQmp8g4UNFyvUrVFXztXWxvFl/kNsp4+7wO64hSzp/RGPyOHNi+7LkRS8SLQxnuvmh8EKKqHuqApb9RAdCGJOChXJON4J9N/Y+2ufAWDwYIj6DPdhe2Zz8caluqCGlB6zvLjouQx3etJhpSwn6f0gxE8UuhJuezEl+K+hW6BrMBpueJYibgEgRi17WftDRbOaLJ99zKvIz5q89MIaE/ckdC5Z26DCoNM7GYzMe1Vnnk/MoRGJE3oH11lYvzCzT4VEtYbo/funxk1Y7a2UV/KolTgUX4sRSTi8kTGaizIHHoLcRkek0Ea66YZs1gk5OFKF eduardoegito@re437505"
}

resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "HTTP from Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH from Internet"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}