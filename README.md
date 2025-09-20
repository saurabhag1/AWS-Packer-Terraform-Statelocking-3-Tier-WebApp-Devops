# 3-Tier Kubernetes Project with GitOps, Dynamic PVC, and Route-53 Integration

## For more projects, check out  
## [https://harishnshetty.github.io/projects.html](https://harishnshetty.github.io/projects.html)

[![Video Tutorial]( https://github.com/harishnshetty/image-data-project/blob/9abf8f00d35d9f50dc95893102fcf3f374319383/3tieraws-project-statelock-terraform-packer.jpg)](https://www.youtube.com/@devopsHarishNShetty)

[![Channel Link](https://github.com/harishnshetty/image-data-project/blob/9abf8f00d35d9f50dc95893102fcf3f374319383/3tieraws-project-statelock-terraform-packer%20-structure.jpg)](https://www.youtube.com/@devopsHarishNShetty)

take one of the ec2 instance in ubuntu
t2.micro

create this key-pair name only / replace with own keypair name in the iaac Project

```bash
new-keypair
```


install all the application packages

terraform
packer
aws
jq

Refer: [Terrafrom](https://developer.hashicorp.com/terraform/install)

## terraform and Packer installtion
```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform packer
```

## AWS CLI Installation

Refer: [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

```bash
sudo apt install -y unzip jp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```


## 5. AWS CLI Configuration

```bash
aws configure
```

## What are the Things I need to Replace if i do it myself

- Github Repo   : https://github.com/harishnshetty/3-tier-aws-terraform-packer-statelock-project.git  [beacuse for you changed the bucket-name in the terraform Project]
- Source_ami    : "ami-0533167fcff018a86" (its int he packer .json files) this is the a [not necessary to Replace if future if this Ami is not AVabile then you have to update]
- Amazon Linux 2023 kernel-6.12 AMI (not necessary to Replace if future if this Ami is not AVabile then you have to update)

- Create S3 Bucket : for statelock it creartes the dynamodb and s3 bucket - make source you given unqiune bucket name
- Path : backend-bootstrap - terraform init - terraform plan - terraform apply -auto-approve
- S3 Bucket Name : three-tier-terrafrom-s3-8745 [replace your new Bucket name in all the terraform files] - use the visual search lens for replacment i shown in the Video


 ## what are the thing we are learing here

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
- Backend s3 bucket

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

