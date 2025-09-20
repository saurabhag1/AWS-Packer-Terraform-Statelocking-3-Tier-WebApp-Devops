#!/bin/bash
set -e

echo "========== Updating system & installing dependencies =========="
dnf update -y
dnf install -y git mysql -y   # MySQL client for RDS
dnf install -y nodejs npm

echo "========== Cloning application repository =========="
cd /home/ec2-user
git clone https://github.com/harishnshetty/3-tier-aws-terraform-packer-statelock-project.git || true

APP_DIR=/home/ec2-user/3-tier-aws-terraform-packer-statelock-project/application_code

echo "========== Configuring DbConfig.js =========="
# Replace placeholders with Terraform-provided values
sed -i "s|REPLACE-WITH-RDS-ENDPOINT|${db_host}|g" $APP_DIR/app_files/DbConfig.js
sed -i "s|REPLACE-WITH-DB-USER|${db_user}|g" $APP_DIR/app_files/DbConfig.js
sed -i "s|REPLACE-WITH-DB-PASSWORD|${db_password}|g" $APP_DIR/app_files/DbConfig.js
sed -i "s|REPLACE-WITH-DB-NAME|${db_name}|g" $APP_DIR/app_files/DbConfig.js

echo "========== Preparing SQL schema =========="
cp $APP_DIR/appdb.sql /tmp/appdb.sql

echo "========== Initializing database =========="

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
            if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" < /tmp/appdb.sql; then
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

# Run database initialization (in foreground)
initialize_database




echo "========== Installing Node.js app dependencies =========="
cp -rf /home/ec2-user/3-tier-aws-terraform-packer-statelock-project/application_code/app_files  /home/ec2-user
cp -rf /home/ec2-user/3-tier-aws-terraform-packer-statelock-project/application_code/app.sh  /home/ec2-user
chmod +x /home/ec2-user/app.sh


echo "========== Running web.sh =========="
/home/ec2-user/app.sh

cd /home/ec2-user/app_files


echo "🎉 App tier setup completed successfully!"
echo "🌐 Server: $(hostname)"
echo "📊 Environment: ${environment}"
echo "🏷️ Project: ${project_name}"
echo "🔗 Connected DB: ${db_name} @ ${db_host}"
