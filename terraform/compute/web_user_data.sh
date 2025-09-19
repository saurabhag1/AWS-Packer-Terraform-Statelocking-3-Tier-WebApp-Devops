#!/bin/bash
set -e

# Update and install dependencies
dnf update -y
dnf install -y nginx git

# Enable and start Apache
systemctl enable httpd
systemctl start httpd


# Deploy backend PHP app directly to /var/www/html
cd ~
git clone https://github.com/harishnshetty/3-tier-aws-terraform-packer-statelock-project.git
cd ~
cp -r 3-tier-aws-terraform-packer-statelock-project/application_code/web_files .




# Ensure ownership
sudo chown -R ec2-user:ec2-user /home/ec2-user
sudo chmod -R 755 /home/ec2-user

# Run build as ec2-user
su - ec2-user <<'EOF'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Sync latest code
rsync -av --delete ~/application-code/web-tier/ ~/web-tier/

cd ~/web-tier
npm install
npm run build
EOF

cd ~
cd 3-tier-aws-terraform-packer-statelock-project/application_code

# Update the meta tag in HTML with the actual ALB DNS from Terraform

sed -i "s|[REPLACE-WITH-INTERNAL-LB-DNS]|${app_alb_dns}|g" nginx.conf

# Replace nginx config
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx-backup.conf || true
sudo cp -f /home/ec2-user/3-tier-aws-terraform-packer-statelock-project/application_code/nginx.conf /etc/nginx/nginx.conf

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