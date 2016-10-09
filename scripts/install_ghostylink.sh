#!/bin/bash
(
    # Install composer and production dependencies
    cd  "$GHOSTYLINK_WEBROOT"
    curl -s https://getcomposer.org/installer | php
    sed -ie 's#\s*\/\/\(\s*.*PRODUCTION.*\)#\1#g' config/bootstrap.php
    cp  "$GHOSTYLINK_WEBROOT/config/prod/app_prod_template.php" \
        "$GHOSTYLINK_WEBROOT/config/prod/app_prod.php"
    mkdir -p tmp 
    mkdir -p logs 
    php composer.phar install --no-dev
    ./bin/cake asset_compress.asset_compress build 
    chown -R www-data:www-data "$GHOSTYLINK_WEBROOT"
    chmod -R 775 "$GHOSTYLINK_WEBROOT"
    mv "$GHOSTYLINK_WEBROOT"/config/prod/app_prod_template.php "$GHOSTYLINK_WEBROOT"/config/

    # Some symlink for easier access    
    ln -s "$GHOSTYLINK_WEBROOT"/config/prod /conf 
    # Create a empty directory (otherwise it will be created at run and mounted
    # volume will not detect it
    mkdir /var/lib/mysql/
    ln -s /var/lib/mysql/ /data
    
    # Apache configuration
    cp "/image/apache-conf/default.conf" "/etc/apache2/sites-available/000-default.conf"
)