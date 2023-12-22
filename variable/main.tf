terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}
provider "aws" {
  region  = var.vpc["region"]
  profile = "default"
}

#Ec-2 instance creation in public subnet
resource "aws_instance" "myserver" {
  ami                    = var.vpc["ami_id"]
  instance_type          = var.vpc["instance-type"]
  vpc_security_group_ids = [var.vpc["sg"]]
  key_name               = var.vpc["key"]
  tags = {
    Name = var.vpc["tag"]
  }
}