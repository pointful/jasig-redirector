#!/bin/bash

# Append the hosts config
echo "Appending customizations to /etc/hosts"
cat $CONFIG_DIR/hosts_addition >> /etc/hosts
