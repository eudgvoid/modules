#!/bin/bash

COMPUTE_MACHINE_UUID=$(cat /sys/devices/virtual/dmi/id/product_uuid | tr '[:upper:]' '[:lower:]')
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s)
COMPUTE_INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: ${TOKEN}" http://169.254.169.254/latest/meta-data/instance-id -s)

DOCROOT="/var/www/html"
mkdir -p $DOCROOT

cat <<EOT > ${DOCROOT}/index.html
This message was generated on instance ${COMPUTE_INSTANCE_ID} with the following UUID ${COMPUTE_MACHINE_UUID}
EOT

if command -v yum &>/dev/null; then
  yum install -y httpd && {
    systemctl start httpd
    systemctl enable httpd
    exit 0
  }
fi

nohup python -m SimpleHTTPServer 80 &
