provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc-lk" {

  tags = {
    Name = "vpc-lk"
  }
}

resource "aws_subnet" "subnet-lk" {
  vpc_id            = aws_vpc.vpc-lk.id
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "subnet-lk"
  }
}

resource "aws_security_group" "ec2-security-group-lk" {
  name        = "ec2 security group"
  description = "allow access on ports 8080 and 22"
  vpc_id      = aws_vpc.vpc-lk.id

  ingress {
    description      = "http access"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0]
  }

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["ip_adress"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0]
  }

  tags   = {
    Name = "ec2-security-group-lk"
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "jenkins-ec2-instance" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.subnet-lk.id
  vpc_security_group_ids = [aws_security_group.ec2-security-group-lk.id]
  key_name               = "lk-aws"
  user_data              = file("jenkins-installation.sh)

  tags = {
    Name = "jenkins-ec2-instance"
  }
}

output "public_ipv4_address" {
  value = aws_instance.jenkins-ec2-instance.public_ip
}