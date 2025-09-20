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
    echo "⏳ Waiting for RDS to be available..."

    for i in {1..30}; do
        # Try a simple connection to check if DB is up
        if mysql -h "${db_host}" -u "${db_user}" -p"${db_password}" -e "SELECT 1;" 2>/dev/null; then
            echo "✅ Database connection successful!"

            # Ensure the database exists
            # echo "📂 Ensuring database ${db_name} exists..."
            # mysql -h "${db_host}" -u "${db_user}" -p"${db_password}" -e "CREATE DATABASE IF NOT EXISTS \`${db_name}\`;"

            # Import schema safely
            echo "📦 Importing schema into ${db_name}..."
            if mysql -h "${db_host}" -u "${db_user}" -p"${db_password}"  < /tmp/appdb.sql; then
                echo "🎉 Database initialization complete!"
                return 0
            else
                echo "❌ Failed to import schema!"
                return 1
            fi
        fi

        echo "📡 Database not ready yet (attempt $i/30), retrying in 10 seconds..."
        sleep 10
    done

    echo "❌ Timeout waiting for database connection!"
    return 1
}


initialize_database

echo "========== Installing Node.js app dependencies =========="
cd $APP_DIR/app_files
npm install

echo "========== Installing PM2 globally =========="
npm install -g pm2

echo "========== Starting app with PM2 =========="
pm2 start index.js --name "${project_name}-app"

echo "========== Saving PM2 process list & enabling startup =========="
pm2 save
pm2 startup systemd -u ec2-user --hp /home/ec2-user

echo "🎉 App tier setup completed successfully!"
echo "🌐 Server: $(hostname)"
echo "📊 Environment: ${environment}"
echo "🏷️ Project: ${project_name}"
echo "🔗 Connected DB: ${db_name} @ ${db_host}"
