#!/bin/bash

#Update the existing files
sudo apt-get update

#Installing the Nginx Server
sudo apt-get install -y nginx

#Enable the Nginx Server
systemctl enable nginx

#Start the Nginx Server
systemctl start nginx

#Store the welcome page to the location
echo "Nginx Server configured by Terraform" > /var/www/html/index.html