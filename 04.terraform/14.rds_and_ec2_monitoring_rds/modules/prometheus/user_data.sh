#!/bin/bash

# step1) private_ip_address를 export한다.
# Only export PRIVATE_IP_ADDRESS if it's provided
if [ ! -z "${private_ip_address}" ]; then
  export PRIVATE_IP_ADDRESS=${private_ip_address}
fi

# step2) install docker
# case1) prometheus_server가 amd64 인 경우(ex. t2.micro인 경우). 주의! arm64 아키텍처는 다른 명령어로 도커를 설치해야 한다. 
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce -y
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
yum install git -y

# step3) prometheus, grafana를 docker로 띄운다. 
# sudo mkdir /home/prometheus
# cd /home/prometheus
# git clone --depth 1 https://github.com/Doohwancho/ecommerce.git
# cd ecommerce/prometheus
# sudo chown -R ubuntu:ubuntu .
# sudo -u ubuntu sed -i "s/ECOMMERCE_APP_IP/${PRIVATE_IP_ADDRESS}/g" ./prometheus.yml
# cd /home/prometheus/ecommerce
# sudo docker-compose -f docker-compose-monitoring-prod.yml up -d --build