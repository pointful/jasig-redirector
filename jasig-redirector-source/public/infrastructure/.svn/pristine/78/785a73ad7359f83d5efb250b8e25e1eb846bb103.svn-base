#!/bin/bash

EIP_TMP_DIR=/mnt/eip

# Create and move into temp dir
mkdir $EIP_TMP_DIR
pushd $EIP_TMP_DIR

# Grab the pk & cert from the user data
/opt/bamboo-elastic-agent/bin/getCustomData.sh aws.accountPrivateKey $EIP_TMP_DIR/pk.pem
/opt/bamboo-elastic-agent/bin/getCustomData.sh aws.accountCert $EIP_TMP_DIR/cert.pem

# Associate the EIP with the instance
EC2_INSTANCE_ID=`ec2metadata --instance-id`
echo "Associating $ELASTIC_IP with instance $EC2_INSTANCE_ID"
ec2-associate-address -K $EIP_TMP_DIR/pk.pem -C $EIP_TMP_DIR/cert.pem -i $EC2_INSTANCE_ID $ELASTIC_IP

PUBLIC_IP=`ec2metadata --public-ipv4`
while [ "$ELASTIC_IP" != "$PUBLIC_IP" ]; do
    echo "Waiting for Elastic IP $ELASTIC_IP to associate, current public IP is $PUBLIC_IP"
    sleep 5
    PUBLIC_IP=`ec2metadata --public-ipv4`
done;

PUBLIC_IP=`ec2metadata --public-ipv4`
echo "Elastic IP $ELASTIC_IP to associated, current public IP is $PUBLIC_IP"

# Pop out of the temp dir
popd

# Remove the temp dir
rm -Rf $EIP_TMP_DIR
