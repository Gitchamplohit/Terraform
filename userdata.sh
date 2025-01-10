#!/bin/bash
sudo apt-get update
sudo apt install nginx -y
echo "<h1> this is test</h1>" | sudo tee -a /var/www/html/nginx.debian.html
sudo systemctl start nginx
#helo
#heloo
