#Creating the bastion host instance

resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = file("${path.module}/userdata.sh")
  tags = {
    Name        = "Bastion-Host"
    Environment = "Dev"
    Project     = "Bastion-Architecture"
  }
  user_data_replace_on_change = true
}

#Creating the private EC2 instance

resource "aws_instance" "private" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private.id]
  key_name               = var.key_name

  user_data = file("${path.module}/userdata.sh")
  tags = {
    Name        = "Private-EC2"
    Environment = "Dev"
    Project     = "Bastion-Architecture"
  }
  user_data_replace_on_change = true
}