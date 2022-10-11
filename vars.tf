terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


provider "aws" {
  region = "us-west-1"  

}

resource "aws_instance" "myserver" {
    ami = "ami-09208e69ff3feb1db" 
    instance_type = var.instance-type
    key_name = "hello"
    tags = {
       Name = "app1.ank.dev.aps1"
    }

} 

variable "instance_type" {
    description = "please enter the instance-type"
    type = string
  
}
