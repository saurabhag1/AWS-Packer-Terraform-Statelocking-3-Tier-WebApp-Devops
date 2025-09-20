#!/bin/bash
set -e

# Update and install dependencies
dnf update -y
dnf install -y nginx git


# Deploy backend PHP app directly to /var/www/html
cd /home/ec2-user
git clone https://github.com/harishnshetty/3-tier-aws-terraform-packer-statelock-project.git
cp -rf /home/ec2-user/3-tier-aws-terraform-packer-statelock-project/application_code/web.sh /home/ec2-user/


cd /home/ec2-user/3-tier-aws-terraform-packer-statelock-project/application_code

# Update the meta tag in HTML with the actual ALB DNS from Terraform

sed -i "s|[REPLACE-WITH-INTERNAL-LB-DNS]|${app_alb_dns}|g" nginx.conf

# Replace nginx config
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx-backup.conf || true
sudo cp -f /home/ec2-user/3-tier-aws-terraform-packer-statelock-project/application_code/nginx.conf /etc/nginx/nginx.conf

cd /home/ec2-user/

chmod +x web.sh
sudo ./web.sh

# Validate config before reload
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx
sudo systemctl enable nginx


echo "🎉 Frontend setup completed successfully!"
echo "🌐 Server: $(hostname)"
echo "📊 Environment: ${environment}"
echo "🏷️ Project: ${project_name}"
echo "🔗 Backend API: http://${app_alb_dns}/api"