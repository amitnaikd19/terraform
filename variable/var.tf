variable "vpc" {
  type = map(any)
  default = {
    "region"        = "us-east-2"
    "az"            = "us-east-2a"
    "tag"           = "my-server"
    "ami_id"        = "ami-0f599bbc07afc299a"
    "instance-type" = "t2.micro"
    "subnet_id"     = "subnet-0ede06be910cdf63c"
    "sg"            = "default"
    "key"           = "terraform-key"
  }
}