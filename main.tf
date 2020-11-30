#Create VPC
resource "aws_vpc" "Project1" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "Project1_VPC"
  }
}

#Create Public Subnet for Web Server
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.Project1.id
  cidr_block        = var.public_cidr
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Web Server"
  }
}

#Create Private Subnet for App Server
resource "aws_subnet" "private1_subnet" {
  vpc_id            = aws_vpc.Project1.id
  cidr_block        = var.private1_cidr
  availability_zone = "ap-south-1a"

  tags = {
    Name = "App Server"
  }
}
#Create Private Subnet for DB Server
resource "aws_subnet" "private2_subnet" {
  vpc_id            = aws_vpc.Project1.id
  cidr_block        = var.private2_cidr
  availability_zone = "ap-south-1a"

  tags = {
    Name = "DB Server"
  }
}
#Create Internet Gateway for Public Subnet
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.Project1.id

  tags = {
    Name = "VPC IGW"
  }
}
#Route Table for Public Subnet
resource "aws_route_table" "web-public-rt" {
  vpc_id = aws_vpc.Project1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "PublicSubnet-RT"
  }
}
#Assign Public route Table to Public Subnet
resource "aws_route_table_association" "web-public-rt" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.web-public-rt.id
}

#Define Security group for Public Subnet
resource "aws_security_group" "sgweb" {
  name        = "vpc_web_server_sg"
  description = "Allow Incoming HTTP/HTTPS & SSH access from Internet"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

  vpc_id = aws_vpc.Project1.id
  tags = {
    Name = "Web Server SG"
  }
}

#Define Security groups for Private Subnet - application Server
resource "aws_security_group" "sg-app" {
  name        = "vpc_app_server_sg"
  description = "Allow Incoming HTTP/HTTPS & SSH access from Web Server"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.public_cidr]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.public_cidr]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.public_cidr]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.Project1.id
  tags = {
    Name = "App Server SG"
  }
}

#Define Security groups for Private Subnet - DB Server
resource "aws_security_group" "sg-DB" {
  name        = "vpc_db_server_sg"
  description = "Allow Incoming MYSQL port & SSH access from Application Server"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.private1_cidr]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.private1_cidr]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.Project1.id
  tags = {
    Name = "DB Server SG"
  }
}

## SSH Key Pair
resource "aws_key_pair" "default" {
  key_name   = "Terraform_Project1"
  public_key = "<Public Key>

#Create Web server inide Public Subnet
resource "aws_instance" "web" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.default.id
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.sgweb.id]
  associate_public_ip_address = "true"
  source_dest_check           = false
  user_data                   = file("install.sh")

  tags = {
    Name = "Web Server"
  }
}
