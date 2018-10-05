#!/bin/bash

export CONFIG_DIR=`dirname $0`

# Load shell configuration
. /etc/profile.d/bamboo.sh
. $CONFIG_DIR/ec2-configuration

# Call the hosts configuration script
$CONFIG_DIR/configure-hosts.sh

## DISABLED DUE TO BAMBOO ISSUE http://jira.atlassian.com/browse/BAM-7694
# Call the EIP Association Script
#$CONFIG_DIR/associate-eip.sh

# Add the instance to the elastic load balancer
$CONFIG_DIR/register-with-elb.sh

# Configure the Apache instance
$CONFIG_DIR/configure-apache.sh

# Configure the Maven Settings
$CONFIG_DIR/configure-maven.sh
