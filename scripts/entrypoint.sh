#!/bin/bash
scripts_dir="$(dirname "$0")"
source "$scripts_dir/db.sh"
source "$scripts_dir/conf.sh"

echo  "######################################################################"
echo  "#################     Retrieve configuration               ###########"
echo  "######################################################################"
if ! conf_is_present; then
    echo "[INFO] Retrieving template configuration"
    cp "$GHOSTYLINK_WEBROOT"/config/app_prod_template.php /conf/app_prod.php    
else
    echo "[INFO] Retrieving existing configuration file"
fi

keys=$(conf_get_unconfigured_keys)
if [[ "$keys" != "" ]]; then
    echo -e "[ERROR] Some configuration keys are not set\n$keys" 1>&2 
    exit 1
fi
sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
        -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini

ghostylinkDir="$GHOSTYLINK_WEBROOT"

echo  "######################################################################"
echo  "##############     Ghostylink database initialization    #############"
echo  "######################################################################"
if ! db_volume_exist; then
    echo -e "\t=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME\n"
    echo -e "\t=> Installing MySQL ...\n"
    mysql_install_db > /dev/null 2>&1
    echo -e "\t=> Done!\n"    
    db_start
    db_create  "$ghostylinkDir"
    db_upgrade "$ghostylinkDir"
else
    chown -R mysql:mysql /data/
    db_start
    echo -e "\t=> Using an existing volume of MySQL"
    expectedVersion=$(db_get_expected_version "$ghostylinkDir")
    currentVersion=$(db_get_version "$ghostylinkDir")
    
    if db_version_is_before "$currentVersion" "$expectedVersion"; then
        echo -e "\t\t=> Upgrading from migration $currentVersion to $expectedVersion"
        db_upgrade "$ghostylinkDir"
    elif db_version_is_after "$currentVersion" "$expectedVersion"; then
        # TODO : ask confirmation before downgrading
        echo -e "\t\t=> Downgrading from migration $currentVersion to $expectedVersion"
        db_downgrade "$ghostylinkDir"
    fi
fi

mysqladmin -uroot shutdown

echo  "######################################################################"
echo  "##############   Ghostylink cron jobs initialization     #############"
echo  "######################################################################"
/image/scripts/init_crons.sh

exec supervisord -n
