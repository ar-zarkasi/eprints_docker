HOW TO USE it
# important: YOU MUST HAVE A DOCKER ENGINE IN YOUR ENVIRONMENT

1. Using Terminal/command prompt type:
<span>docker-compose up -d</span>
2. After Finished type in terminal:
<span>docker container start eprintsrepo</span>
<span>docker exec -it eprintsrepo /bin/bash</span>
3. in container bash following this instruction
 # apt-get install -y certbot python-certbot-apache ufw
 # cd /var/ssl/
 # openssl genrsa -des3 -out rootCA.key 4096 && openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem && openssl req -new -sha256 -nodes -out server.csr -newkey rsa:2048 -keyout server.key -config <( cat server.csr.cnf ) && openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 500 -sha256 -extfile v3.ext
<u>in this step, please provide pashprhase</u>
4. still inside bash container, create eprints repository
 # cd /usr/share/eprints
 # su eprints
 $ ./bin/epadmin create pub
 <u>Following installation instruction</u>
5. As a root user (type 'exit' after create eprints)
 # a2ensite eprints
 # a2dissite 000-default
 # service apache2 reload
6. Please Access your repository via curl command



<h1>USING HTTPS</h1>
if you're using https when configure eprints in first step, 
1. Command Instruction
# su eprints
$ cp /var/ssl/archiveid.conf /usr/share/eprints/cfg/apache_ssl/{YOUR_ID_ARCHIVE}.conf
$ exit
2. as a root user modify /etc/apache2/sites-available/eprints
# nano /etc/apache2/sites-available/eprints
3. add a line
    Include /usr/share/eprints/cfg/apache_ssl.conf
4. save with ctrl+x and 'Y'
5. and then
# service apache2 reload


<h1>USING eprints from container to server host</h1>
<h3>following this configuration for apache</h3>
<code>
    <VirtualHost *:80> 
        DocumentRoot "YOUR-DOCUMENT-ROOT"
        ServerName YOUR-SITE-DOMAIN
        ServerAlias *.YOUR-SITE-DOMAIN
        <Directory "YOUR-DOCUMENT-ROOT">
            AllowOverride All
            Require all granted
        </Directory>
        ProxyPreserveHost On
        ProxyPass / http://127.0.0.1:8081/
        ProxyPassReverse / http://127.0.0.1:8081/
    </VirtualHost>
</code>
<p> If you're using https </p>
<code>
    <VirtualHost *:443>
        DocumentRoot "YOUR-DOCUMENT-ROOT"
        ServerName YOUR-SITE-DOMAIN
        ServerAlias *.YOUR-SITE-DOMAIN
        <Directory "YOUR-DOCUMENT-ROOT">
            AllowOverride All
            Require all granted
        </Directory>
        ProxyPreserveHost On
        SSLProxyEngine On
        SSLProxyVerify none
        SSLProxyCheckPeerCN off
        SSLProxyCheckPeerName off
        SSLProxyCheckPeerExpire off
        ProxyPass / https://127.0.0.1:8084/
        ProxyPassReverse / https://127.0.0.1:8084/
        SSLEngine on
        SSLCertificateFile      LOCATION-SSL-FILE
        SSLCertificateKeyFile   LOCATION-SSL-KEY-FILE
        SSLProtocol all -SSLv2 -SSLv3
        SSLProxyProtocol all -SSLv2 -SSLv3 -TLSv1 
    </VirtualHost>
</code>
<h3>following this configuration for nginx</h3>
<code>
    server {
        listen 8080;
        server_name YOUR-SITE-DOMAIN *.YOUR-SITE-DOMAIN;
        root "YOUR-DOCUMENT-ROOT";
        
        index index.html index.htm index.php;
    
        location / {
            try_files $uri $uri/ /index.php$is_args$args;
            autoindex on;
            proxy_pass http://127.0.0.1:8081;
        }
        
        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass php_upstream;		
        }
        charset utf-8;
        location = /favicon.ico { access_log off; log_not_found off; }
        location = /robots.txt  { access_log off; log_not_found off; }
        location ~ /\.ht {
            deny all;
        }
    }
</code>
<p> If you're using https </p>
<code>
    server {
        listen 8080;
        listen 8443 ssl;
        server_name YOUR-SITE-DOMAIN *.YOUR-SITE-DOMAIN;
        root "YOUR-DOCUMENT-ROOT";
        
        index index.html index.htm index.php;
    
        location / {
            try_files $uri $uri/ /index.php$is_args$args;
            autoindex on;
            proxy_set_header X-Real-IP  $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto https;
            proxy_set_header X-Forwarded-Port 443;
            proxy_pass https://127.0.0.1:8084;
        }
        
        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass php_upstream;
        }

        # Enable SSL
        ssl_certificate "LOCATION-SSL-FILE";
        ssl_certificate_key "LOCATION-SSL-KEY-FILE";
        ssl_session_timeout 5m;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
        ssl_prefer_server_ciphers on;
        
        
        charset utf-8; 
        location = /favicon.ico { access_log off; log_not_found off; }
        location = /robots.txt  { access_log off; log_not_found off; }
        location ~ /\.ht {
            deny all;
        }
    }
</code>