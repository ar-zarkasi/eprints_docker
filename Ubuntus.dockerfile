FROM ubuntu:bionic
RUN apt-get update && apt-get install -y sudo wget nano
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
RUN apt-get update
RUN apt-get install -y gnupg inetutils-ping iproute2
RUN touch /etc/apt/sources.list.d/eprints.list
RUN sudo echo "deb http://deb.eprints.org/3.4/stable/ ./" > /etc/apt/sources.list.d/eprints.list
RUN wget -O - http://deb.eprints.org/keyFile | apt-key add -
RUN apt-get update
RUN cd /tmp
RUN wget http://security.ubuntu.com/ubuntu/pool/main/p/poppler/libpoppler73_0.62.0-2ubuntu2.12_amd64.deb
RUN wget http://archive.ubuntu.com/ubuntu/pool/universe/x/xpdf/xpdf_3.04-7_amd64.deb
RUN apt-get install -y ./libpoppler73_0.62.0-2ubuntu2.12_amd64.deb
RUN apt-get install -y ./xpdf_3.04-7_amd64.deb
RUN apt-cache show eprints && apt-get install -y eprints=3.4.3
RUN apt-get install -y software-properties-common
RUN add-apt-repository universe
RUN apt-get update
#RUN apt-get install -y certbot python-certbot-apache ufw
RUN wget https://files.eprints.org/2500/8/eprints-3.4.2-flavours.tar.gz
RUN tar -xzvf eprints-3.4.2-flavours.tar.gz
RUN mv -v eprints-3.4.2/flavours /usr/share/eprints/
RUN ls -al /usr/share/eprints && chmod -R g+w /usr/share/eprints/flavours/pub_lib
RUN chown -R eprints:eprints /usr/share/eprints/flavours/pub_lib
RUN cd /usr/share/eprints
RUN su eprints
ADD mysql.pm /usr/share/eprints/perl_lib/EPrints/Database/mysql.pm
RUN chown eprints:www-data /usr/share/eprints/perl_lib/EPrints/Database/mysql.pm
RUN chmod 644 /usr/share/eprints/perl_lib/EPrints/Database/mysql.pm
RUN exit
RUN a2enmod ssl
RUN a2enmod headers
RUN cd /
RUN mkdir /var/ssl
ADD server.csr.cnf /var/ssl/server.csr.cnf
ADD v3.ext /var/ssl/v3.ext
ADD securevhost.conf /var/ssl/securevhost.conf
ADD archiveid.conf /var/ssl/archiveid.conf
RUN chown eprints:eprints /var/ssl/archiveid.conf
RUN chmod 664 /var/ssl/archiveid.conf
RUN cd /var/ssl
RUN apt-get install -y curl
RUN cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.bak
RUN echo "ServerName localhost" > /etc/apache2/apache2.conf
#RUN openssl genrsa -des3 -out rootCA.key 4096
#RUN openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem
#RUN openssl req -new -sha256 -nodes -out server.csr -newkey rsa:2048 -keyout server.key -config <( cat server.csr.cnf )
#RUN openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 500 -sha256 -extfile v3.ext
#RUN cd /usr/share/eprints
#RUN su eprints
#RUN ./bin/epadmin create pub
CMD ["apachectl", "-D", "FOREGROUND"]