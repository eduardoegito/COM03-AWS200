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

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
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
