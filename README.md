# 3-Tier AWS Terraform Project + Packer with StateID Lock in S3 Bucket

## For more projects, check out  
[https://harishnshetty.github.io/projects.html](https://harishnshetty.github.io/projects.html)

[![Video Tutorial](https://github.com/harishnshetty/image-data-project/blob/9abf8f00d35d9f50dc95893102fcf3f374319383/3tieraws-project-statelock-terraform-packer.jpg)](https://www.youtube.com/@devopsHarishShetty)

[![Channel Link](https://github.com/harishnshetty/image-data-project/blob/9abf8f00d35d9f50dc95893102fcf3f374319383/3tieraws-project-statelock-terraform-packer%20-structure.jpg)](https://www.youtube.com/@devopsHarishShetty)

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
- Source_ami: `"ami-0533167fcff018a86"` (it's in the packer .json files)  
  *(not necessary to replace, but if this AMI is not available in the future then you have to update)*
- Amazon Linux 2023 kernel-6.12 AMI  
  *(not necessary to replace, but if this AMI is not available in the future then you have to update)*
- Create S3 Bucket: for statelock it creates the DynamoDB and S3 bucket - make sure you give a unique bucket name
- Path: `backend-bootstrap` – `terraform init` – `terraform plan` – `terraform apply -auto-approve`
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

- Packer

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