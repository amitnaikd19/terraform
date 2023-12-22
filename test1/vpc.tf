terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}
provider "aws" {
  region = "us-east-2"
}

#create VPc

resource "aws_vpc" "my-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"
  tags = {
    Name = "my-vpc"
  }
}

#create subnet

resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-2a"
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"
  tags = {
    Name = "private-subnet"
  }
}

#create internet gateway

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "my-igw"
  }
}

# create route table

resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  tags = {
    Name = "public-route"
  }
}

resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  tags = {
    Name = " private-route"
  }
}

#route assosiation

resource "aws_route_table_association" "Public-route-attatch" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-route.id
}

resource "aws_route_table_association" "private-route-attatch" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-route.id
}

#security group

resource "aws_security_group" "my-sg" {
  name   = "default_ssh"
  vpc_id = aws_vpc.my-vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = " allow ssh"
  }
}



#copy public-key to remote host.

resource "aws_key_pair" "ansible_host-key" {
  key_name   = "ansible_host-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0B3CHHNZc5F3oLmM6eAF4dMNGIUjx6ONvqzgpW1xXvRRmzEgkQnLnj91l1PO/rGnMVc0qYIzRGStto0dDmcH+5y+X0NsJP1lhx+dh5DxHFe9f2zs2flCInAJLGmbRNNbemTjZ4i2VEB9LCHC6hIVtylE43p+6Xx/m7H0kVtOl+255JJDUoO3T+WBg+VEE7kJniOcqpBm4W5FFwTqpJkN9ALzNRBoGnQnCJNhrubm2RHoPyU3ZW168KvJiqbhwwYWK+1le9yR52ZlMUFsK2vnqO3Kzq6DkfyXHAM+iZd3VHDSNtbEk+79OwwusIzgutGuJ6fVHeK/UivsO7kotl1I/ root@ansible"
}

#Ec-2 instance creation in public subnet
resource "aws_instance" "my-server-1" {
  ami                    = "ami-0f599bbc07afc299a"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  key_name               = aws_key_pair.ansible_host-key.id
  tags = {
    Name = "my-server-public"
  }
}

resource "aws_instance" "my-server-2" {
  ami                    = "ami-0f599bbc07afc299a"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  key_name               = aws_key_pair.ansible_host-key.id
  tags = {
    Name = "my-server-private"
  }
}