HOW TO USE it
# important: YOU MUST HAVE A DOCKER ENGINE IN YOUR ENVIRONMENT

1. Using Terminal/command prompt type:
<span>docker-compose up -d</span>
2. After Finished type in terminal:
<span>docker container start eprintsrepo</span>
<span>docker exec -it eprintsrepo /bin/bash</span>
3. in container bash following this instruction
 <code># apt-get install -y certbot python-certbot-apache ufw</code>
 <code># cd /var/ssl/</code>
 <code># openssl genrsa -des3 -out rootCA.key 4096 && openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem && openssl req -new -sha256 -nodes -out server.csr -newkey rsa:2048 -keyout server.key -config <( cat server.csr.cnf ) && openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 500 -sha256 -extfile v3.ext</code>
<u>in this step, please provide pashprhase</u>
4. still inside bash container, create eprints repository
<code># cd /usr/share/eprints</code>
<code># su eprints</code>
<code>$ ./bin/epadmin create pub</code>
<u>Following installation eprints instruction</u>
5. As a root user (type 'exit' after create eprints)
<code># a2ensite eprints</code>
<code># a2dissite 000-default</code>
<code># service apache2 reload</code>
6. Please Access your repository via curl command



<h3>USING HTTPS</h3>
if you're using https when configure eprints in first step, 
1. Command Instruction
<code># su eprints</code>
<code>$ cp /var/ssl/archiveid.conf /usr/share/eprints/cfg/apache_ssl/{YOUR_ID_ARCHIVE}.conf</code>
<code>$ exit</code>
2. as a root user modify /etc/apache2/sites-available/eprints
<code># nano /etc/apache2/sites-available/eprints</code>
3. add a line
    <i>Include /usr/share/eprints/cfg/apache_ssl.conf</i>
4. save with ctrl+x and 'Y'
5. and then
<code># service apache2 reload</code>


<h2>USING eprints from container to server host</h2>
<h3>following this configuration for apache</h3>
<pre>
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
</pre>
<p> If you're using https </p>
<pre>
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
</pre>
<h3>following this configuration for nginx</h3>
<pre>
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
</pre>
<p> If you're using https </p>
<pre>
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
</pre>