#!/bin/bash
set -e

# Update and install dependencies
dnf update -y
dnf install -y git 

https://github.com/harishnshetty/3-tier-aws-terraform-packer-statelock-project.git

# Install official MySQL client
wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
dnf install -y mysql80-community-release-el9-1.noarch.rpm
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
dnf install -y mysql-community-client

# Clone the repo

# Deploy backend PHP app directly to /var/www/html
cd ~
git clone https://github.com/harishnshetty/3-tier-aws-terraform-packer-statelock-project.git
cd ~


# Copy SQL file for database initialization
cp /tmp/3-tier-aws-terraform-packer-statelock-project/application_code/webappdb.sql /tmp/webappdb.sql

# Database initialization function (RUNS IN FOREGROUND)
initialize_database() {
    echo "🔄 Initializing database..."
    
    # Database connection parameters (from Terraform template)
    DB_HOST="${db_host}"
    DB_NAME="${db_name}"
    DB_USER="${db_user}"
    DB_PASSWORD="${db_password}"
    
    # Wait for RDS to be ready (with timeout)
    echo "⏳ Waiting for RDS to be available..."
    for i in {1..30}; do
        if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" 2>/dev/null; then
            echo "✅ Database connection successful!"
            
            # Import the SQL schema
            echo "📦 Importing database schema..."
            if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" < /tmp/webappdb.sql; then
                echo "🎉 Database initialization complete!"
                return 0
            else
                echo "❌ Failed to import database schema!"
                return 1
            fi
        fi
        echo "📡 Database not ready yet (attempt $i/30), retrying in 10 seconds..."
        sleep 10
    done
    
    echo "❌ Timeout waiting for database connection!"
    return 1
}


# Make script executable and run it
chmod +x app.sh
sudo ./app.sh

cd /home/ec2-user/app_files

# Update the meta tag in HTML with the actual ALB DNS from Terraform

sed -i "s|rds-address|${db_host}|g" DbConfig.js
sed -i "s|db-user|${db_user}|g" DbConfig.js
sed -i "s|db-password|${db_password}|g" DbConfig.js

pm2 reload index.js

echo "🎉 Backend setup completed successfully!"
echo "🌐 Server: $(hostname)"
echo "📊 Environment: ${environment}"
echo "🏷️ Project: ${project_name}"