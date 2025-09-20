#!/bin/bash
set -e   # exit on error

# Download app-tier code


cd /home/ec2-user

sudo chown -R ec2-user:ec2-user /home/ec2-user
sudo chmod -R 755 /home/ec2-user

sudo rm -rf 3-tier-aws-terraform-packer-statelock-project
git clone https://github.com/harishnshetty/3-tier-aws-terraform-packer-statelock-project.git

cp -rf 3-tier-aws-terraform-packer-statelock-project/application_code/web_files .

cd /home/ec2-user/web_files

# # Ensure correct ownership/permissions
sudo chown -R ec2-user:ec2-user /home/ec2-user
sudo chmod -R 755 /home/ec2-user/web_files



# Run build as ec2-user
su - ec2-user <<'EOF'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Sync latest code
rsync -av --delete ~/3-tier-aws-terraform-packer-statelock-project/application-code/web_files/ ~/web_files/

cd ~/web_files
npm install
npm run build
EOF