#!/bin/bash

set -e

BAMBOO_IMG_VERSION=2.2
ANT_17_VERSION=1.7.1
ANT_18_VERSION=1.8.2
MAVEN_3_VERSION=3.0.4

function log {
    echo "`date` $@"
}

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


########################################
# Update Ubuntu image
########################################

log "Update APT Repository"
apt-get update

log "Perform dist-upgrade"
apt-get dist-upgrade -V


########################################
# Install JDKs
########################################

log "Fetch OAB Script"
wget https://github.com/flexiondotorg/oab-java6/raw/0.2.5/oab-java.sh -O oab-java.sh
chmod +x oab-java.sh

log "Build JDK6 Packages"
./oab-java.sh

log "Build JDK7 Packages"
./oab-java.sh -7

log "Install JDK6 & JDK7"
apt-get install sun-java6-jdk oracle-java7-jdk


########################################
# Install APT managed packages
########################################

log "Install APT managed packages"
apt-get install ec2-api-tools ec2-ami-tools apache2 subversion libsvn-java cronolog tree unzip git-core


########################################
# Install build tools
########################################

function downloadAndExtract {
    log "Install $2"

    wget $1 -O /opt/$2
    tar xzC /opt -f /opt/$2
    rm /opt/$2
}

downloadAndExtract "http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_17_VERSION}-bin.tar.gz" apache-ant-${ANT_17_VERSION}-bin.tar.gz
downloadAndExtract "http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_18_VERSION}-bin.tar.gz" apache-ant-${ANT_18_VERSION}-bin.tar.gz
downloadAndExtract "http://archive.apache.org/dist/maven/binaries/apache-maven-${MAVEN_3_VERSION}-bin.tar.gz" apache-maven-${MAVEN_3_VERSION}-bin.tar.gz


########################################
# Configure Apache Modules
########################################

log "Configure Apache Modules"
a2enmod ssl proxy_ajp rewrite


########################################
# Install ELB Utilities
########################################

log "Configure ELB Utilities"
sudo wget "http://ec2-downloads.s3.amazonaws.com/ElasticLoadBalancing.zip" -O /opt/ElasticLoadBalancing.zip
sudo unzip /opt/ElasticLoadBalancing.zip -d /opt/
sudo ln -s /opt/ElasticLoadBalancing-* /opt/ElasticLoadBalancing
rm /opt/ElasticLoadBalancing.zip


########################################
# Setup the Bamboo Agent
########################################

log "Setup Bamboo Agent $BAMBOO_IMG_VERSION"
useradd -m bamboo
wget https://maven.atlassian.com/content/repositories/atlassian-public/com/atlassian/bamboo/atlassian-bamboo-elastic-image/${BAMBOO_IMG_VERSION}/atlassian-bamboo-elastic-image-${BAMBOO_IMG_VERSION}.zip
rm -Rf /opt/bamboo-elastic-agent
mkdir -p /opt/bamboo-elastic-agent
unzip -o atlassian-bamboo-elastic-image-${BAMBOO_IMG_VERSION}.zip -d /opt/bamboo-elastic-agent
chown -R bamboo /opt/bamboo-elastic-agent
chmod -R u+r+w /opt/bamboo-elastic-agent
rm atlassian-bamboo-elastic-image-${BAMBOO_IMG_VERSION}.zip


chown -R bamboo:bamboo /home/bamboo/

# Setup bamboo profile.sh
echo "export JAVA_HOME=/usr/lib/jvm/java-6-sun
export M2_HOME=/opt/apache-maven-${MAVEN_3_VERSION}
export ANT_HOME=/opt/apache-ant-${ANT_18_VERSION}
export AWS_ELB_HOME=/opt/ElasticLoadBalancing
" > /etc/profile.d/bamboo.sh
echo '
export PATH=$AWS_ELB_HOME/bin:/opt/bamboo-elastic-agent/bin:$JAVA_HOME/bin:$M2_HOME/bin:$ANT_HOME/bin:$PATH
' >> /etc/profile.d/bamboo.sh

chmod +x /etc/profile.d/bamboo.sh

cp /opt/bamboo-elastic-agent/etc/rc.local /etc/rc.local

log "##############################################"
log "# EDIT /etc/rc.local to remove auto shutdown #"
log "##############################################"



########################################
# Setup the Apache Auto-Conf Script
########################################

log "Setup Apache Auto-Conf Script"
echo '#!/bin/bash
svn export https://source.jasig.org/infrastructure/live-build-config /mnt/live-build-config
/mnt/live-build-config/configure-instance.sh
rm -Rf /mnt/live-build-config' > /opt/customize-instance.sh

chmod +x /opt/customize-instance.sh

echo '
/opt/customize-instance.sh >> /tmp/jasigCustomizeInstance.log 2>&1
' >> /etc/rc.local
