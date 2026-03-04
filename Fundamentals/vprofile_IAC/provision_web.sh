# adding repository and installing nginx		
dnf install epel-release -y
dnf install nginx -y

# Allow nginx to connect to upstream servers (SELinux)
setsebool -P httpd_can_network_connect on

firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

cat <<EOT > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /var/run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    upstream vproapp {
        server app01:8080;
    }

    server {
        listen       80;
        listen       [::]:80;
        server_name  _;

        location / {
            proxy_pass http://vproapp;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }

    include /etc/nginx/conf.d/*.conf;
}
EOT


#starting nginx service and firewall
systemctl start nginx
systemctl enable nginx
systemctl restart nginx