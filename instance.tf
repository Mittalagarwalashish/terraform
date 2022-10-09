resource "aws_instance" "vm-public" {
  ami           = "ami-09208e69ff3feb1db" # us-west-2
  instance_type = "t2.micro"
  subnet_id = aws_subnet.Public.id
  key_name = "terraformwest"
  vpc_security_group_ids = [aws_security_group.public-allow.id]
  depends_on = [aws_vpc.vpc1.id]
  tags = {
    Name = "public-vm"
  } 
}

resource "aws_instance" "vm-private" {
  ami           = "ami-09208e69ff3feb1db" # us-west-2
  instance_type = "t2.micro"
  subnet_id = aws_subnet.Private.id
  key_name = "terraformwest"
  vpc_security_group_ids = [aws_security_group.private-allow.id]
  depends_on = [aws_vpc.vpc1.id]
  tags = {
    Name = "private-vm"
  } 
}
