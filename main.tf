# Configuring providers and backend
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "100daysofcloud-eduardoegito"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

# Configuring the AWS Provider
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

resource "aws_autoscaling_group" "asg" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 3
  max_size           = 5
  min_size           = 3

  launch_template {
    id = aws_launch_template.web.id
    #    version = "$Latest"
  }
}

data "template_file" "user_data_web" {
  template = <<EOF
#!/bin/bash -xe

sudo apt-get update
sudo apt-get install -y nginx
sudo echo "<header>Hello World</header><p> It is working, dude!</p><p>CaduEgito finished the COM03-AWS100 Project!" > /var/www/html/index.nginx-debian.html
sudo systemctl start nginx
sudo systemctl enable nginx
EOF
}

resource "aws_launch_template" "web" {

  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_http_ssh.id]
  key_name               = aws_key_pair.deployer.key_name
  user_data              = "${base64encode(data.template_file.user_data_web.rendered)}"

  tags = {
    Name = "COM03-AWS200"
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
    Name = "allow_http_ssh"
  }
}