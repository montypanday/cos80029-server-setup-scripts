siteurl="wordpress2.com"
sitename="WordPress 2"
wpuser="admin"
wppass="admin1234"
wpemail="admin@test.com"

sudo apt update
sudo apt install apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip
sudo mkdir -p /srv/www
sudo chown www-data: /srv/www
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www

echo '<VirtualHost *:80>
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>' | sudo tee -a /etc/apache2/sites-available/wordpress.conf >/dev/null

sudo a2ensite wordpress
sudo a2enmod rewrite
sudo a2dissite 000-default
sudo service apache2 reload

sudo mysql -u root <<MY_QUERY
CREATE DATABASE wordpress;
CREATE USER wordpress@localhost IDENTIFIED BY 'mysecretpassword';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON wordpress.* TO wordpress@localhost;
FLUSH PRIVILEGES;
MY_QUERY

sudo service mysql start

sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php

sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/password_here/mysecretpassword/' /srv/www/wordpress/wp-config.php

# sudo -u www-data nano /srv/www/wordpress/wp-config.php

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

cd /srv/www/wordpress

echo '<IfModule mod_rewrite.c>
RewriteEngine On
RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
' | sudo tee -a .htaccess > /dev/null

wp core install --url="$siteurl" --title="$sitename" --admin_user="$wpuser" --admin_password="$wppass" --admin_email="$wpemail"

sudo -u www-data wp config shuffle-salts
sudo -u www-data wp plugin install miniorange-saml-20-single-sign-on
sudo -u www-data wp plugin activate miniorange-saml-20-single-sign-on

sudo -u www-data wp plugin install jwt-auth

jwtsecret=$(echo $RANDOM | md5sum | head -c 20);

sudo -u www-data wp config set JWT_AUTH_SECRET_KEY $jwtsecret
sudo -u www-data wp config set JWT_AUTH_CORS_ENABLE true --raw

sudo -u www-data wp plugin activate jwt-auth
