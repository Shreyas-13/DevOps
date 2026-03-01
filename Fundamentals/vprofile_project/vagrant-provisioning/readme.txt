## This is a VProfile Project which is a java based social media platform. There are following components in the projects:

- NGNIX -> Web Server
- Tomcat -> Application Server
- RabbitMQ -> Message Queuing Agent (Dummy Service)
- Memcache -> DB Caching
- MySQL -> DB

## The automation stacks comprises of the following:

- Vagrant -> VM Automation
- VirtualBox -> Hypervisor
- Bash -> Scripting

## Plugins

- Vagrant-hostmanager -> Simplifies multi machine vagrant setups by automatically managing the /etc/hosts file on guest VMs. Every VM on the private network knows about every other VM on the network with their designated private IPs. 
 
 Enable the following settings:

  - config.hostmanager.enabled = true : enables the host manager for a VM stack
  - config.hostmanager.manage_host = true : Updates the /etc/hosts and C:\Windows\System32\drivers\etc\hosts file on host     and guest

## Setting up MySQL DB

  - vagrant ssh db01
  - dnf update -y
  - dnf install epel-release git mariadb-server -y
  - systemctl start mariadb
  - systenctl enable mariadb

  - mysql_secure_installation - Answer the questions asked, set up the password (admin123) for the root user. Allow remote access
  - mysql -u root -p
  - create database accounts;
  - grant all privileges on accounts.* TO 'admin'@'localhost' identified by 'admin123'; - Grant all access to admin user on the same server
  - grant all privileges on accounts.* TO 'admin'@'%' identified by 'admin123'; - Grant all access to admin user from any remote server
  - FLUSH PRIVILEGES;
  - exit

  - cd /tmp/
  - git clone -b local 'https://github.com/hkhcoder/vprofile-project/'
  - cd vprofile-project
  - mysql -u root -padmin123 < src/main/resources/db_backup.sql - Load the SQL DB from the repo to the local database
  - mysql -u root -p
  - show tables; - To verify everything was loaded
  - exit

  ## Setting up Memcached

  Memcached is a DB caching service and once a user is trying to login to our portal, the credentials will first be checked in the memcached if it's not there then a system call will be made to the DB.

  - dnf update -y
  - dnf install epel-release memcached -y
  - systemctl start memcached 
  - systemctl enable memcached
  - sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached : This changes the listening IP from 127.0.0.1 to 0.0.0.0 so that the service can be accessed remotely from other servers as well/ 127.0.0.1 refers to any request from the same server but 0.0.0.0 opens the listening to any IPv4 address
  - systemctl restart memcached
  - memcached -p 11211 -U 11111 -u memcached -d : Run memcached as a daemon (-d) on ports 11211 (-p) and 11111 for UDP (-U) for user named memcached (-u)

## Setting up RabbitMQ

RabbitMQ is amessage queuing service, we won't be utilizing rabbitmq in our project but it is there to increase the complexity of the project.

- dnf update -y
- dnf install epel-release wget -y
- dnf install centos-release-rabbitmq-38 -y: Installs the repo used to download rabbitmq
- dnf --enablerepo=centos-rabbitmq-38 install rabbitmq-server: Enables the downloaded repo and installs rabbitmq
- systemctl start rabbit-mq-server
- systemctl enable rabbit-mq-server

- sudo sh -c 'echo"[{rabbitmq, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config': Creates a new bourne shell and changes the config of the rabbitmq-server
- rabbitmqctl add_user test test: Creates a user test with password as test
- rabbitmqctl set_user_tags test administrator: Add a tag of admin to the test user
- rabbitmqctl set_permissions -p / test ".*" ".*" ".*"
- systemctl restart rabbit-mqserver

## Setting up Tomcat
- dnf update -y
- dnf install java-17-openjdk -y
- useradd --home-dir /opt/tomcat --shell /sbin/nologin
- wget tomcat10_link
- tar -xvf downloaded_file
- cp -r unzipped_file/* /opt/tomcat/
- chown -R tomcat:tomcat /opt/tomcat
- vim /etc/systemd/system/tomcat.service: Define the unit file using outside_svc branch
- systemctl daemon-reload
- systemctl start tomcat
- systemctl enable tomcat

## Setting up Maven

Maven is an open-source build automation tool for Java projects. Streamlines the build process by enforcing a standard project structure.

- vagrant shh app01
- wget 'maven3.9.9'
- unzip downloaded_file
- cp -r downloaded_file/* /opt/maven3.9
- export MAVEN_OPTS="-Xmx512m"
- git clone -b local project link
- cd vprofile-project
- vim src/main/resources/applicaion.properties : Make sure all the setingsof you VMs and svcs matches with what is defined in the file.
- /opt/maven/bin/mvn install
- systemctl stop tomcat
- rm -rf /opt/tomcat/webapps/ROOT* : Remove all the default tomcat webpage
- cp target/vprofile-v2.war /opt/tomcat/webapps/ROOT.war
- unzip /opt/tomcat/webapps/ROOT.war -d /opt/tomcat/webapps/ROOT
- chown tomcat:tomcat /opt/tomcat/webapps/ -R
- systemctl restart tomcat


## Nginx Setup

Nginx is an open source web server software that can act as a web server, reverse proxy, load balancer content cache and proxy for TCP/UDP or email protocols

- vagrant ssh web01
- sudo -i
- apt update && apt upgrade
- apt install nginx -y
- vi /etc/nginx/sites-available/vrpoapp: Define the content in the file
 upstream vproapp {
 	server app01: 80;
}
server {
	listen: 80;
	location / {
		proxy_pass: http://vproapp
		}
	}
 
 - rm -rf /etc/nginx/sites-enabled/default : Delee he default nginx file
 - ln -s /etc/nginx/sites-available/vrpoapp /etc/nginx/sites-enabled/vproapp : Create a soft link in sites-enabled for our created config
 - systemctl resart nginx

This is the whole configuration for all our services. Now vagrant up all the VMs and in your web browser search for the IP of nginx server. Login using 'admin_vp' 'admin_vp' and verify if all the other services created are working or not.
