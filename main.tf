
provider "aws" {
   region = "us-west-2"
}
resource "aws_instance" "sci37web" {
  ami           = "ami-0686851c4e7b1a8e1"
  instance_type = "t2.micro"
  user_data     = <<-EOF
                  #!/bin/bash
                  sudo su
                  yum -y install httpd
                  echo "<p>Science 37 Webserver Interview</p>" >> /var/www/html/index.html
                  sudo systemctl enable httpd
                  sudo systemctl start httpd
                  EOF
}

output "DNS" {
  value = aws_instance.sci37web.public_dns
}

resource "aws_vpc" "sci37vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "sci37webvpc"
  }
}

resource "aws_security_group" "sci37sg" {
  name        = "sci31_web"
  description = "Science 37 HTTP allows"
  vpc_id      = aws_vpc.sci37vpc.id

  ingress {
    description      = "http to webserver"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
  }

  ingress {
    description      = "https to webserver"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
