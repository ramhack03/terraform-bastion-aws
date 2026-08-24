resource "aws_db_subnet_group" "main" {
  name = "bastion-app-db-subnet-group"

  subnet_ids = [
    aws_subnet.private.id,
    aws_subnet.private2.id
  ]

  tags = {
    Name        = "Bastion-App-DB-Subnet-Group"
    Environment = "Dev"
    Project     = "Bastion-Architecture"
  }
}

resource "aws_db_instance" "main" {
  identifier = "bastion-app-db"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false

  multi_az = false

  backup_retention_period = 7

  skip_final_snapshot = true

  deletion_protection = false

  tags = {
    Name        = "Bastion-App-RDS"
    Environment = "Dev"
    Project     = "Bastion-Architecture"
  }
}