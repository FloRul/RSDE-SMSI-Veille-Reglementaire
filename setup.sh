#!/bin/bash

# Install Python and dependencies
sudo yum install python3.11
sudo yum install python3-pip
pip3 install changedetection.io

# Create a directory for the datastore
mkdir datastore

# Install poppler-utils used by changedetection to read PDFs
sudo yum install poppler-utils

# Create a service file for ChangeDetection
cat <<EOL | sudo tee /etc/systemd/system/changedetection.service
[Unit]
Description=ChangeDetection Service
After=network.target

[Service]
ExecStart=/home/ec2-user/.local/bin/changedetection.io -d /home/ec2-user/datastore -p 8080
User=ec2-user
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Start and enable the ChangeDetection service
sudo systemctl start changedetection
sudo systemctl enable changedetection
