#!/bin/bash
set -e  # Exit immediately on any error

echo "=== [install.sh] Updating system packages ===" >> /tmp/deploy.log
sudo yum update -y

echo "=== [install.sh] Installing HTTPD (Apache) ===" >> /tmp/deploy.log
sudo yum install -y httpd

echo "=== [install.sh] Installing Java (required for Tomcat) ===" >> /tmp/deploy.log
sudo amazon-linux-extras enable java-openjdk11
sudo yum install -y java-11-openjdk

echo "=== [install.sh] Creating Tomcat user and directory ===" >> /tmp/deploy.log
sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat || true
cd /tmp

echo "=== [install.sh] Downloading and installing Apache Tomcat ===" >> /tmp/deploy.log
TOMCAT_VERSION=9.0.85
wget https://downloads.apache.org/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

sudo mkdir -p /opt/tomcat
sudo tar -xvzf apache-tomcat-$TOMCAT_VERSION.tar.gz -C /opt/tomcat --strip-components=1
sudo chown -R tomcat: /opt/tomcat
sudo chmod +x /opt/tomcat/bin/*.sh

echo "=== [install.sh] Creating Tomcat systemd service ===" >> /tmp/deploy.log
sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOF
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "=== [install.sh] Reloading systemd and enabling services ===" >> /tmp/deploy.log
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl enable httpd

echo "=== [install.sh] Tomcat and HTTPD installation complete ===" >> /tmp/deploy.log
exit 0
