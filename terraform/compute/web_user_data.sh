#!/bin/bash
set -e

echo "========== Updating system & installing dependencies =========="
dnf update -y
dnf install -y nginx git

echo "========== Cloning application repository =========="
cd /home/ec2-user
git clone https://github.com/harishnshetty/3-tier-aws-terraform-packer-statelock-project.git || true

echo "========== Copying web.sh =========="
cp -f /home/ec2-user/3-tier-aws-terraform-packer-statelock-project/application_code/web.sh /home/ec2-user/web.sh
chmod +x /home/ec2-user/web.sh

echo "========== Preparing nginx.conf =========="
# Replace placeholder BEFORE moving nginx.conf into /etc
sed -i "s|REPLACE-WITH-INTERNAL-LB-DNS|${app_alb_dns}|g" \
    /home/ec2-user/3-tier-aws-terraform-packer-statelock-project/application_code/nginx.conf

# Backup old config & apply new one
mv /etc/nginx/nginx.conf /etc/nginx/nginx-backup.conf || true
cp -f /home/ec2-user/3-tier-aws-terraform-packer-statelock-project/application_code/nginx.conf /etc/nginx/nginx.conf

echo "========== Running web.sh =========="
/home/ec2-user/web.sh

echo "========== Validating nginx configuration =========="
nginx -t

echo "========== Restarting & enabling nginx =========="
systemctl restart nginx
systemctl enable nginx

echo "🎉 Frontend setup completed successfully!"
echo "🌐 Server: $(hostname)"
echo "📊 Environment: ${environment}"
echo "🏷️ Project: ${project_name}"
echo "🔗 Backend API: http://${app_alb_dns}/api"
