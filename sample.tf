provider "aws" {
    region= "ap-south-1"
    access_key = ""
    secret_key = ""
  
}
resource "aws_instance" "name1" {
  ami = "ami-01216e7612243e0ef"
  instance_type = "t2.micro"
}
