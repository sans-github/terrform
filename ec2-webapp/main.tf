terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

# Generate an SSH key locally
resource "tls_private_key" "tf_ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Register the public key with AWS
resource "aws_key_pair" "tf_ec2_key_pair" {
  key_name   = "tf_ec2_key"
  public_key = tls_private_key.tf_ec2_key.public_key_openssh
}

# Output private key for local use
output "private_key_pem" {
  value     = tls_private_key.tf_ec2_key.private_key_pem
  sensitive = true
}

resource "local_file" "tf_ec2_key_file" {
  content         = tls_private_key.tf_ec2_key.private_key_pem
  filename        = "${pathexpand("~/.ssh/tf_ec2_key.pem")}"
  file_permission = "0400"
}

resource "aws_security_group" "sg_webapp_only_8080" {
  name = "sg_webapp_only_8080"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Exposes publicly; restrict for private use
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"] # Exposes publicly over IPv6; restrict for private use
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Exposes publicly; restrict for private use
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "webapp" {
  instance_type = "t3.micro"
  # https://aws.amazon.com/ec2/pricing/on-demand/?icmpid=docs_console_unmapped
  ami                    = "ami-0c1a6eb95aba250b6"
  vpc_security_group_ids = [aws_security_group.sg_webapp_only_8080.id]
  key_name               = aws_key_pair.tf_ec2_key_pair.key_name
  user_data = file("setup-app.sh")
}