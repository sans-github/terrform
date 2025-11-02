#!/bin/bash
set -e

# Set to pacfic timezone
sudo timedatectl set-timezone America/Los_Angeles

# Update system packages
sudo dnf update -y

# Install dependencies
sudo dnf install -y git gcc-c++ make tar xz

# Install Node.js via NodeSource
# ---------------------------
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo dnf install -y nodejs

# Verify installation
node -v
npm -v

# Clone app
APP_DIR="/home/ec2-user/my-app"
if [ ! -d "$APP_DIR" ]; then
  git clone https://github.com/sans-github/hello-node.git "$APP_DIR"
fi
cd "$APP_DIR"

# Install app dependencies
npm install

# Genreate Logs: /etc/.pm2/logs/hello-node-out.log, /etc/.pm2/logs/hello-node-error.log
# pm2 logs -> For real time logs like tail -f
# pm2 logs hello-node -> For app specific log
# pm2 logs --lines 100
# pm2 logs --err
# pm2 logs --out

# Start the app with PM2
sudo npm install -g pm2
pm2 start index.js --name hello-node
pm2 save
# Enable PM2 startup on boot
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u ec2-user --hp /home/ec2-user

echo "Node app setup complete! App is running under PM2."