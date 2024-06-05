#!/bin/bash

# Print the RDS endpoint to a text file
echo "RDS Endpoint: ${rds_endpoint}" > /home/ubuntu/rds_endpoint.txt

# Update system packages
sudo apt update

# Install Apache2
sudo apt install -y apache2

# Ensure Apache is running and enabled to start on boot
sudo systemctl start apache2
sudo systemctl enable apache2

# (Optional) Customize Apache landing page as a test
echo "<html><body><h1>Hello from $(hostname -f)</h1></body></html>" | sudo tee /var/www/html/index.html

