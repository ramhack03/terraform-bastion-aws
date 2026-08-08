# Terraform AWS Bastion Host Architecture

## 📌 Project Overview

This project demonstrates how to provision a secure AWS network architecture using **Terraform**.

The infrastructure consists of a public Bastion Host and a private EC2 instance. The Bastion Host provides controlled SSH access to the private instance, while a NAT Gateway allows the private EC2 instance to access the internet for outbound communication and package installation.

Nginx is automatically installed and configured on both EC2 instances using Terraform `user_data` and cloud-init.

---

## 🏗️ Architecture

```text
                         Internet
                            │
                            ▼
                  ┌──────────────────┐
                  │ Internet Gateway │
                  └────────┬─────────┘
                           │
              ┌────────────┴────────────┐
              │         VPC             │
              │      10.0.0.0/16        │
              │                         │
              │  ┌──────────────────┐   │
              │  │  Public Subnet   │   │
              │  │   10.0.1.0/24    │   │
              │  │                  │   │
              │  │   Bastion EC2    │   │
              │  │   Nginx Server   │   │
              │  └────────┬─────────┘   │
              │           │ SSH         │
              │           ▼             │
              │  ┌──────────────────┐   │
              │  │ Private Subnet   │   │
              │  │   10.0.2.0/24    │   │
              │  │                  │   │
              │  │   Private EC2    │   │
              │  │   Nginx Server   │   │
              │  └────────┬─────────┘   │
              │           │             │
              │           ▼             │
              │     ┌────────────┐      │
              │     │ NAT Gateway│      │
              │     └─────┬──────┘      │
              │           │             │
              └───────────┼─────────────┘
                          │
                          ▼
                       Internet
```

---

## ☁️ AWS Services Used

* Amazon VPC
* Public and Private Subnets
* Internet Gateway
* NAT Gateway
* Elastic IP
* Route Tables
* Security Groups
* Amazon EC2
* Ubuntu 24.04
* AWS IAM
* Terraform
* Cloud-init / EC2 User Data
* Nginx

---

## 📁 Project Structure

```text
terraform-bastion-aws/
│
├── provider.tf
├── variables.tf
├── vpc.tf
├── subnet.tf
├── nat.tf
├── security_groups.tf
├── ec2.tf
├── outputs.tf
├── userdata.sh
├── .gitignore
├── .terraform.lock.hcl
└── README.md
```

### File Description

| File                 | Purpose                                                                   |
| -------------------- | ------------------------------------------------------------------------- |
| `provider.tf`        | Configures the AWS provider                                               |
| `variables.tf`       | Defines Terraform input variables                                         |
| `vpc.tf`             | Creates the VPC and Internet Gateway                                      |
| `subnet.tf`          | Creates public/private subnets and routing                                |
| `nat.tf`             | Creates Elastic IP and NAT Gateway                                        |
| `security_groups.tf` | Defines Bastion and private EC2 security rules                            |
| `ec2.tf`             | Creates Bastion and private EC2 instances                                 |
| `outputs.tf`         | Displays important infrastructure information                             |
| `userdata.sh`        | Installs and configures Nginx                                             |
| `.gitignore`         | Prevents state files, keys and other sensitive files from being committed |

---

## 🔐 Network Design

### VPC

```text
CIDR: 10.0.0.0/16
```

### Public Subnet

```text
CIDR: 10.0.1.0/24
```

The public subnet is associated with a route table containing:

```text
0.0.0.0/0 → Internet Gateway
```

The Bastion Host is deployed in this subnet.

### Private Subnet

```text
CIDR: 10.0.2.0/24
```

The private subnet does not have a direct route to the Internet Gateway.

Instead:

```text
Private EC2
     ↓
Private Route Table
     ↓
NAT Gateway
     ↓
Internet Gateway
     ↓
Internet
```

This allows the private instance to initiate outbound internet connections without exposing it directly to the internet.

---

## 🔑 Bastion Host Design

The Bastion Host is deployed in the public subnet.

SSH access to the Bastion is restricted to the administrator's public IP address.

Example:

```text
Internet
   │
   │ SSH :22
   │
   ▼
Bastion EC2
```

The private EC2 does not allow SSH directly from the internet.

Instead:

```text
Administrator
      │
      │ SSH
      ▼
Bastion Host
      │
      │ SSH
      ▼
Private EC2
```

This provides a controlled entry point into the private network.

---

## 🔒 Security Groups

### Bastion Security Group

Allows:

```text
TCP 22
Source: Administrator public IP /32
```

The `/32` restricts SSH access to a single public IP address.

### Private EC2 Security Group

Allows:

```text
TCP 22
Source: Bastion Security Group
```

This means the private EC2 does not need to expose SSH to the entire internet.

---

## 🖥️ EC2 Instances

Two Ubuntu EC2 instances are created.

### Bastion EC2

```text
Subnet: Public
Purpose: SSH jump host
Internet access: Direct through Internet Gateway
Nginx: Installed automatically
```

### Private EC2

```text
Subnet: Private
Purpose: Private application server
Internet access: Outbound through NAT Gateway
Nginx: Installed automatically
```

---

## 🚀 Nginx Automation

The `userdata.sh` script is executed during EC2 first boot.

It performs:

```text
1. Update package repositories
2. Install Nginx
3. Enable Nginx
4. Start Nginx
5. Create a custom index.html
```

Example:

```bash
#!/bin/bash

apt-get update -y

apt-get install -y nginx

systemctl enable nginx
systemctl start nginx

echo "Nginx Server configured by Terraform" > /var/www/html/index.html
```

Terraform is configured to replace the EC2 instance when user-data changes so that the updated provisioning script executes during the new instance's first boot.

---

## ⚙️ Terraform Deployment

Initialize Terraform:

```bash
terraform init
```

Format the configuration:

```bash
terraform fmt
```

Validate the configuration:

```bash
terraform validate
```

Create an execution plan:

```bash
terraform plan
```

For a saved plan:

```bash
terraform plan -out=tfplan
```

Apply the saved plan:

```bash
terraform apply tfplan
```

View outputs:

```bash
terraform output
```

---

## 🔍 Verify Infrastructure

List Terraform-managed resources:

```bash
terraform state list
```

Check AWS instances:

```bash
aws ec2 describe-instances \
  --region us-east-1 \
  --query 'Reservations[].Instances[].[InstanceId,State.Name,PrivateIpAddress,PublicIpAddress]' \
  --output table
```

Check VPC:

```bash
aws ec2 describe-vpcs \
  --region us-east-1 \
  --query 'Vpcs[].VpcId' \
  --output table
```

---

## 🔑 SSH Access

### Connect to Bastion

```bash
chmod 400 test-key.pem

ssh -i test-key.pem ubuntu@<BASTION_PUBLIC_IP>
```

### Connect from Bastion to Private EC2

```bash
ssh -i test-key.pem ubuntu@<PRIVATE_IP>
```

The private EC2 is accessed through the Bastion Host rather than directly from the internet.

---

## 🧪 Nginx Verification

On either EC2 instance:

```bash
sudo systemctl status nginx
```

Test locally:

```bash
curl localhost
```

Expected output:

```text
Nginx Server configured by Terraform
```

---

## 🛠️ Troubleshooting Experience

During development, several real-world Terraform and AWS issues were encountered and resolved.

### Terraform route configuration

Incorrect arguments such as:

```text
route_table
Destination
Gateway
```

were replaced with the correct AWS provider arguments:

```hcl
route_table_id
destination_cidr_block
gateway_id
```

### Route table association

The correct attribute is:

```hcl
subnet_id
```

rather than:

```hcl
subnet
```

### Security Group ingress

Terraform requires `ingress` as a block rather than a map.

Correct structure:

```hcl
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["<ADMIN_IP>/32"]
}
```

### EC2 Security Group IDs

`vpc_security_group_ids` expects a collection, so the security group ID is provided as:

```hcl
vpc_security_group_ids = [aws_security_group.bastion.id]
```

### AWS Key Pair

Terraform failed when the configured key pair did not exist in the AWS environment.

The key pair was subsequently created/configured and used by the EC2 instances.

### Dynamic Public IP

The Bastion public IP changed when the instance was recreated.

The current address should always be obtained using:

```bash
terraform output bastion_public_ip
```

### Cloud-init / User Data

The private EC2 initially failed to configure Nginx because the user-data script returned an error.

The script was simplified and the unnecessary:

```bash
systemctl status nginx
```

command was removed.

Terraform was then configured to replace EC2 instances when user-data changes.

---

## 💰 Cost Considerations

This project uses AWS resources that may incur charges depending on the AWS account/environment.

Important resources to monitor include:

* NAT Gateway
* Elastic IP
* EC2 instances
* EBS volumes
* Data transfer

For temporary environments, destroy the infrastructure when finished:

```bash
terraform destroy
```

---

## 🧹 Cleanup

To remove all Terraform-managed infrastructure:

```bash
terraform destroy
```

Review the plan and confirm before proceeding.

---

## 🎯 Skills Demonstrated

This project demonstrates practical experience with:

* Terraform Infrastructure as Code
* AWS VPC architecture
* Public/private subnet design
* Internet Gateway
* NAT Gateway
* Route tables
* Security Groups
* EC2 provisioning
* Bastion/Jumphost architecture
* Linux administration
* SSH
* Cloud-init
* EC2 User Data
* Nginx automation
* Terraform state
* Terraform variables
* Terraform outputs
* Git
* GitHub

---

## 🚀 Future Enhancements

Planned improvements:

* Application Load Balancer
* Auto Scaling Group
* Multiple Availability Zones
* HTTPS with ACM
* Route 53
* CloudWatch monitoring
* Terraform modules
* Remote Terraform state using S3
* DynamoDB state locking where applicable
* GitHub Actions CI/CD
* Terraform security scanning
* Infrastructure testing
* Dev/Staging/Production environments

---

## 👨‍💻 Author

**Ramkumar S**

DevOps / Cloud Engineering Portfolio Project

Technologies:

```text
AWS | Terraform | Linux | Git | GitHub | Nginx
```

