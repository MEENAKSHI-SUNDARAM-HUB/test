provider "aws" {
  region=var.region
  access_key=var.access
  secret_key=var.secret
}

resource "aws_vpc" "vpc1" {
  instance_tenancy = "default"
  cidr_block = var.cidr
  tags = {
    Name="test"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.vpc1.id
  cidr_block = var.cidr-sub
  tags = {
    Name="test"
  }
}

#resource "aws_subnet" "subnet2" {
#  vpc_id = aws_vpc.vpc1.id
#  cidr_block = "173.100.1.0/24"
#  availability_zone = "ap-south-1c"
#  tags = {
#    Name="test2"
#  }
#}

resource "aws_internet_gateway" "gw1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name="testgw"
  }
}

resource "aws_route_table" "route1" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw1.id
  }
  tags = {
    Name="testroute"
  }
}

resource "aws_route_table_association" "assc1" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route1.id
}

resource "aws_security_group" "sg1" {
  name = "allow_ssh_http"
  vpc_id = aws_vpc.vpc1.id

  ingress {
    description      = "ssh from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  ingress {
    description      = "http from VPC"
    from_port        = 80
    to_port          = 80
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
    Name = "allow_ssh_http"
  }
}

resource "aws_instance" "vm1" {
  ami ="ami-0a0f1259dd1c90938"
  instance_type="t2.micro"
  subnet_id=aws_subnet.subnet1.id
  vpc_security_group_ids=[aws_security_group.sg1.id]
  key_name="ssh-key"
  associate_public_ip_address = true
  root_block_device {
    volume_type="gp2"
  }
  tags = {
    Name="vm1"
  }
}

resource "aws_instance" "vm2" {
  ami="ami-03f4878755434977f"
  instance_type="t2.micro"
  subnet_id=aws_subnet.subnet1.id
  vpc_security_group_ids=[aws_security_group.sg1.id]
  key_name="ssh-key"
  associate_public_ip_address = true
  root_block_device {
    volume_type="gp2"
  }
  tags = {
    Name="webvm1"
  }
  user_data = <<-EOF
  #!/bin/bash
  sudo apt update
  sudo apt install apache2 -y
  cat /var/www/html/index.html > /code.txt
  echo "Hello from Pavan" > /var/www/html/index.html
  sudo systemctl restart apache2
  sudo systemctl enable apache2
  EOF
}
