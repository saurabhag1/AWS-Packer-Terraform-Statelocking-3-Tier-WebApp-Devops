# 3-Tier AWS Terraform Project + Packer with StateID Lock in S3 Bucket

## For more projects, check out  
[https://harishnshetty.github.io/projects.html](https://harishnshetty.github.io/projects.html)

[![Video Tutorial](https://github.com/harishnshetty/image-data-project/blob/9abf8f00d35d9f50dc95893102fcf3f374319383/3tieraws-project-statelock-terraform-packer.jpg)](https://youtu.be/M6BxKpSvWa4)

[![Channel Link](https://github.com/harishnshetty/image-data-project/blob/9abf8f00d35d9f50dc95893102fcf3f374319383/3tieraws-project-statelock-terraform-packer%20-structure.jpg)](https://youtu.be/M6BxKpSvWa4)


---

## Create a Security Group

| SG name      | inbound        | Access         | Description                                  |
|--------------|----------------|---------------|----------------------------------------------|
| Jump Server  | 22             | MY-ip         | access from my laptop                        |
| 1. web-frontend-alb     | 80,         | 0.0.0.0/24    | all access from internet                     |
| 2. Web-srv-sg      | 80,  22    | 1. web-frontend-alb       | only front-alb and jump server access        |
|              |                | jump-server   |                                              |
| 3. app-Internal-alb-sg     |  80,  | 2. Web-srv-sg      | only web-srv                                 |
| 4. app-Srv-sg      | 4000,  22 | 3. app-Internal-alb-sg | only 3. app-Internal-alb-sg and jump server access          |
|              |                | jump-server   |                                              |
| 5. DB-srv       | 3306, 22       | 4. app-Srv-sg       | only app-srv and jump server access          |
|              |      3306          | jump-server   |                                              |

---

## Create a VPC

| #  | Component         | Name                  | CIDR / Details                                |
|----|-------------------|-----------------------|-----------------------------------------------|
| 1  | VPC              | 3-tier-vpc            | 10.75.0.0/16                                  |
| 12 | Subnets          | Public-Subnet-1a      | 10.75.1.0/24                                  |
|    |                  | Public-Subnet-1b      | 10.75.2.0/24                                  |
|    |                  | Public-Subnet-1c      | 10.75.3.0/24                                  |
|    |                  | Web-Private-Subnet-1a | 10.75.4.0/24                                  |
|    |                  | Web-Private-Subnet-1b | 10.75.5.0/24                                  |
|    |                  | Web-Private-Subnet-1c | 10.75.6.0/24                                  |
|    |                  | App-Private-Subnet-1a | 10.75.7.0/24                                  |
|    |                  | App-Private-Subnet-1b | 10.75.8.0/24                                  |
|    |                  | App-Private-Subnet-1c | 10.75.9.0/24                                  |
|    |                  | DB-Private-Subnet-1a  | 10.75.10.0/24                                 |
|    |                  | DB-Private-Subnet-1b  | 10.75.11.0/24                                 |
|    |                  | DB-Private-Subnet-1c  | 10.75.12.0/24                                 |

| #   | Component         | Name/Route Table                | CIDR/Details      | NAT Gateway | Notes                                         |
|-----|-------------------|---------------------------------|-------------------|-------------|-----------------------------------------------|
| 1   | Internet Gateway  | 3-tier-igw                      |                   |             |                                               |
| 3   | Nat gateway       | 3-tier-1a                       |                   |             |                                               |
|     |                   | 3-tier-1b                       |                   |             |                                               |
|     |                   | 3-tier-1c                       |                   |             |                                               |
| 10  | Route-Table       | 3-tier-Public-rt                |                   |             |                                               |
|     |                   | 3-tier-web-Private-rt-1a        | 10.75.4.0/24      | nat-1a      |                                               |
|     |                   | 3-tier-web-Private-rt-1b        | 10.75.5.0/24      | nat-1b      |                                               |
|     |                   | 3-tier-web-Private-rt-1c        | 10.75.6.0/24      | nat-1c      |                                               |
|     |                   | 3-tier-app-Private-rt-1a        | 10.75.7.0/24      | nat-1a      |                                               |
|     |                   | 3-tier-app-Private-rt-1b        | 10.75.8.0/24      | nat-1b      |                                               |
|     |                   | 3-tier-app-Private-rt-1c        | 10.75.9.0/24      | nat-1c      |                                               |
|     |                   | 3-tier-db-Private-rt-1a         | 10.75.10.0/24     | nat-1a      |                                               |
|     |                   | 3-tier-db-Private-rt-1b         | 10.75.11.0/24     | nat-1b      |                                               |
|     |                   | 3-tier-db-Private-rt-1c         | 10.75.12.0/24     | nat-1c      |                                               |
 

---

## Steps

- Take one of the EC2 instances in Ubuntu (t2.micro)
- Create this key-pair name only / replace with own keypair name in the Iaac Project

```bash
new-keypair
```

- Install all the application packages:

  - terraform
  - packer
  - aws
  - jq
  - git

Refer: [Terraform](https://developer.hashicorp.com/terraform/install)

## Terraform and Packer Installation

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs)" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform packer git 
```

## AWS CLI Installation

Refer: [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

```bash
sudo apt install -y unzip jq
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

## AWS CLI Configuration

```bash
aws configure
```

---

## What are the Things I need to Replace if I do it myself

- Github Repo: https://github.com/harishnshetty/3-tier-aws-terraform-packer-statelock-project.git  
  *(because you've changed the bucket-name in the Terraform Project)*

- Source_ami: `"ami-0533167fcff018a86"`   Amazon Linux 2023 kernel-6.12 AMI    (it's in the packer .json files)  
  *(not necessary to replace, but if this AMI is not available in the future then you have to update)*

- Create S3 Bucket: for statelock it creates the DynamoDB and S3 bucket - make sure you give a unique bucket name

- Path: `backend-bootstrap` | `terraform init` | `terraform plan` | `terraform apply -auto-approve`

- S3 Bucket Name: `three-tier-terrafrom-s3-8745`  
  *(replace with your new bucket name in all the Terraform files – use the visual search lens for replacement as shown in the video)*

---

## What are the things we are learning here

- Clone the Project

```bash
git clone https://github.com/harishnshetty/3-tier-aws-terraform-packer-statelock-project.git
```

```bash
cd 3-tier-aws-terraform-packer-project-main/terraform/compute
```

```bash
du -sh * .
```

- Packer [for testing]

```bash
PACKER_LOG=1 packer build packer/backend/backend.json
```

```bash
PACKER_LOG=1 packer build packer/frontend/frontend.json
```

- Backend S3 bucket

- Script file

```bash
./apply.sh
```

```bash
cd 3-tier-aws-terraform-packer-project-main/terraform/compute
```

```bash
du -sh * .
```
 
# SORRY FOR NOT SHOWING TO DESTROYING THE INFRA IN Video

```bash
./destroy.sh
```

# "Important: Delete the snapshots along with the EBS volume, otherwise I may be charged."


---

# Manually Delete the S3 Bucket and dynamodb table / run the command in the [ backend-bootstrap ] folder
```bash
terraform destroy -auto-approve
``` 
[![Video Tutorial](https://github.com/harishnshetty/image-data-project/blob/c757fcf45b14c2ab0a65b0d01633685c191d88ec/Screenshot%20from%202025-09-20%2017-12-11.png)](https://www.youtube.com/@devopsHarishShetty)