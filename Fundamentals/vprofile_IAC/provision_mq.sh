#!/bin/bash
sudo yum install epel-release -y
sudo yum update -y
sudo yum install wget -y
cd /tmp/
dnf -y install centos-release-rabbitmq-38
dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server
systemctl enable --now rabbitmq-server

# Configure firewall to allow RabbitMQ
firewall-cmd --permanent --add-port=5672/tcp
firewall-cmd --permanent --add-port=15672/tcp
firewall-cmd --reload

sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server
sudo systemctl status rabbitmq-server

# Allow RabbitMQ to be accessible from other hosts
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}, {tcp_listeners, [5672]}]}]." > /etc/rabbitmq/rabbitmq.config'

sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
rabbitmqctl set_permissions -p / test ".*" ".*" ".*"

sudo systemctl restart rabbitmq-server