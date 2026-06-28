#!/bin/bash
set -euxo pipefail
exec > >(tee /var/log/user-data.log) 2>&1

date

COMPUTE_MACHINE_UUID=$(cat /sys/devices/virtual/dmi/id/product_uuid | tr '[:upper:]' '[:lower:]')
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
COMPUTE_INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: ${TOKEN}" http://169.254.169.254/latest/meta-data/instance-id)

DOCROOT="/var/www/html"
mkdir -p "$DOCROOT"

cat <<EOT > "${DOCROOT}/index.html"
This message was generated on instance ${COMPUTE_INSTANCE_ID} with the following UUID ${COMPUTE_MACHINE_UUID}
EOT

date

if yum install -y httpd; then
  systemctl enable httpd
  systemctl restart httpd
  exit 0
fi

date

if command -v python3 &>/dev/null; then
  nohup python3 -m http.server 80 --directory "$DOCROOT" >/var/log/http-server.log 2>&1 &
elif command -v python &>/dev/null; then
  cd "$DOCROOT" && nohup python -m SimpleHTTPServer 80 >/var/log/http-server.log 2>&1 &
fi

date
