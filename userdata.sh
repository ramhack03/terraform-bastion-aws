#!/bin/bash
#If the APT package has been failed need to clean before installing the Nginx Package

set -euxo pipefail

apt-get clean
rm -rf /var/lib/apt/lists/*

#Update the existing files
sudo apt-get update

#Installing the Nginx Server
sudo apt-get install -y nginx

#Enable the Nginx Server
systemctl enable nginx

#Start the Nginx Server
systemctl start nginx

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Bastion Architecture</title>
</head>
<body>
    <h1>Hello from Private EC2</h1>
    <p>Hostname: $(hostname)</p>
    <p>Private IP: $(hostname -I)</p>
    <p>Nginx is running successfully.</p>
</body>
</html>
EOF

#Store the welcome page to the location
echo "Nginx Server configured by Terraform" > /var/www/html/index.html