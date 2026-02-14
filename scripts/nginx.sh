#!/bin/bash

set -ex

sudo apt update
sudo apt install nginx -y
sudo systemctl start nginx 


sudo mv /tmp/motd /etc/motd