#!/bin/bash

ELB_TMP_DIR=/mnt/elb

# Create and move into temp dir
mkdir $ELB_TMP_DIR
pushd $ELB_TMP_DIR

# Grab the pk & cert from the user data
/opt/bamboo-elastic-agent/bin/getCustomData.sh aws.accountPrivateKey $ELB_TMP_DIR/pk.pem
/opt/bamboo-elastic-agent/bin/getCustomData.sh aws.accountCert $ELB_TMP_DIR/cert.pem

# Associate the EIP with the instance
EC2_INSTANCE_ID=`ec2metadata --instance-id`
echo "Registering instance $EC2_INSTANCE_ID with ELB $ELASTIC_LOAD_BALANCER"
elb-register-instances-with-lb -K $ELB_TMP_DIR/pk.pem -C $ELB_TMP_DIR/cert.pem -lb $ELASTIC_LOAD_BALANCER --instances $EC2_INSTANCE_ID

# Pop out of the temp dir
popd

# Remove the temp dir
rm -Rf $ELB_TMP_DIR
