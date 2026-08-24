#Creating the CIDR variable

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

}

#Creating the Public Subnet
variable "public_subnet_cidr" {
  description = "Public subnet block for the VPC"
  type        = string
  default     = "10.0.1.0/24"
}

#Creating the Private Subnet
variable "private_subnet_cidr" {
  description = "Private subnet block for the VPC"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the subnets"
  type        = string
  default     = "us-east-1a"
}

variable "key_name" {
  description = "EC2 key pair"
  type        = string
  default     = "test-key"
}

variable "instance_type" {
  description = "EC2 for the instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "EC2 for the AMI ID"
  type        = string
  default     = "ami-052355af2a014bd2c"
}

variable "public_subnet_2_cidr" {
  description = "Second public subnet CIDR"
  type        = string
  default     = "10.0.3.0/24"
}

variable "availability_zone_2" {
  description = "Second availability zone"
  type        = string
  default     = "us-east-1b"
}

variable "private_subnet_2_cidr" {
  description = "Second private subnet CIDR"
  type        = string
  default     = "10.0.4.0/24"
}

variable "db_name" {
  description = "RDS database name"
  type        = string
}

variable "db_username" {
  description = "RDS master username"
  type        = string
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}