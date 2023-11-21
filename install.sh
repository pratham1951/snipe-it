#!/bin/bash
DB_USER="admin"
DB_PASS="root"
DB_NAME="strapi-db" 

sudo apt update

curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install nodejs -y

sudo apt update

sudo apt install postgresql postgresql-contrib -y
sudo systemctl start postgresql.service

sudo apt install nginx -y
sudo ufw allow 'Nginx HTTP'
sudo systemctl start nginx


url=$(curl -s ifconfig.me)

sudo tee /etc/nginx/sites-available/$url <<EOL
server {
    listen 80;
    listen [::]:80;

    server_name $url www.$url;

    location / {
        proxy_pass http://localhost:1337;
        include proxy_params;
    }
}
EOL

sudo ln -s /etc/nginx/sites-available/$url /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx



sudo -i -u postgres createdb $DB_NAME
sudo -i -u postgres createuser $DB_USER
sudo -i -u postgres psql -c "ALTER USER $DB_USER PASSWORD '$DB_PASS';"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE \"$DB_NAME\" TO $DB_USER ;"



yes | npx create-strapi-app@latest my-project \
  --dbclient=postgres \
  --dbhost=127.0.0.1 \
  --dbname=strapi-db \
  --dbusername=$DB_USER \
  --dbpassword=$DB_PASS \
  --dbport=5432

# cd my-project
# NODE_ENV=production npm run build
# #nohup /usr/bin/node /home/adminuser/my-project/node_modules/.bin/strapi start > /home/adminuser/strapi.log 2>&1 &
# node /home/adminuser/my-project/node_modules/.bin/strapi start


# PM2
cd /home/ubuntu/my-project
sudo npm install pm2@latest -g

sudo tee server.js <<EOL
const strapi = require('@strapi/strapi');
strapi().start();
EOL

pm2 start --name strapi server.js


echo "Strapi is Running"