#!/bin/bash
sudo perl -pi -e 's/^#?Port 22$/Port 4545/' /etc/ssh/sshd_config;
sudo service sshd restart || service ssh restart;