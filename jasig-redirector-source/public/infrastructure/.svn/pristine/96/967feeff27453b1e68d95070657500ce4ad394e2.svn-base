#!/bin/bash

# Stop apache
echo "Restart Apache"
/etc/init.d/apache2 stop

# Copy the config data into the Apache config dir
echo "Copying Apache config"
cp -r $CONFIG_DIR/apache2/* $APACHE_CONFIG_DIR/

# Enable all sites
echo "Enable all vhosted sites"
/usr/sbin/a2ensite '*'

# Enable log viewer
rm -Rf /var/log/apache2
mkdir -p /var/log/apache2
chmod 755 /var/log/apache2
mkdir /var/log/apache2/tomcat/
chown bamboo /var/log/apache2/tomcat/

# Start apache to reload the config
echo "Restart Apache"
/etc/init.d/apache2 start
