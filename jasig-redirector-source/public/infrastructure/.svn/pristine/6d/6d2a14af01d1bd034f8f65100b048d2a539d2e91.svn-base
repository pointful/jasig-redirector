#!/bin/bash

# Copy the m2 settings
echo "Copying Maven Settings"
mkdir -p $BAMBOO_M2_DIR
cp -r $CONFIG_DIR/m2-settings.xml $BAMBOO_M2_DIR/settings.xml
chown -R bamboo:bamboo $BAMBOO_M2_DIR
