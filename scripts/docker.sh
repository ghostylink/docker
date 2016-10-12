#!/bin/bash

## Initialize specified directory to run docker-compose
## @param $1 Version to install
## @param $2 Domain the ghostylink instance should be installed on
## @param $3 [optional] Directory were data will be put in (db, logs, mail account)
## @param $4 [optional] subdomain ghostylink should be put on
## @return void
function docker_init_compose {
    local ghostylinkVersion="$1"
    local domain="$2"
    local port="$3"
    if [[ "$#" -lt 2 ]]; then
        echo "Command usage:"
        echo "docker_init_compose version domain [directory] [subdomain]"
        return 1
    fi

    if [[ "$port" == "" ]]; then
        port=9999
    fi
    local ghostylinkDir="$4"
    if [[ "$ghostylinkDir" == "" ]]; then
        ghostylinkDir="."
    fi
    
    # Configure image
    local url="http://$domain:$port"
    docker_init_image "$ghostylinkVersion" "$ghostylinkDir" "$url"
    
    # Configure other requirements for a standalone usage
    # docker_get_compose_file "$versionToInstall" "$ghostylinkVersion"
    mailerPassword=$(docker_generate_password)
    echo "mailer@$domain|$mailerPassword" > "$ghostylinkDir/postfix/accounts.cf"

    # Configure email sending with the smtp linked docker service
    docker_configure_email "smtp" "mailer@$domain" "$mailerPassword" "$ghostylinkDir"
    sed -ie "s#__HOST#$domain#g" "$ghostylinkDir/docker-compose.yml"
    sed -ie "s#__PORT#$port#g" "$ghostylinkDir/docker-compose.yml"

}

## Initialize configuration for the single ghostylink image
## @param $1 Version to install
## @param $2 ghostylink install directory
function docker_init_image {
    local ghostylinkVersion="$1"
    local ghostylinkDir="$2"
    local ghostylinkHost="$3"

    if [[ $ghostylinkDir == "" ]]; then
        ghostylinkDir='.'
    fi
    
    # docker_get_conf_template "$ghostylinkVersion" 
    docker_configure_host "$ghostylinkDir" "$ghostylinkHost"
    docker_configure_db "$ghostylinkDir"
    docker_configure_salt "$ghostylinkDir"
}

## Generate a password based on the current date
function docker_generate_password {
     echo $(docker_random_string |head -c 32)
}

## Generate a random string based on the current date
function docker_random_string {
    date +%s | sha256sum | base64|head -n 1;
}

## Configure database connection
## @param $1 [optional] installation directory. pwd if not provided
function docker_configure_db {
    local ghostylinkDir="$1"
    if [[ $ghostylinkDir == "" ]]; then
        ghostylinkDir="."
    fi

    ## Do not generate too long username and dbname. 
    ## Before Mysql 5.7.8 limit is 16 characters
    dbName="ghostylink$(docker_random_string | head -c 6)"
    userName="ghostylink$(docker_random_string | tail -c 6)"
    password=$(docker_generate_password)
    sed -ie "s#__DB_USERNAME#$userName#g" "$ghostylinkDir/conf/app_prod.php"
    sed -ie "s#__DB_PASSWORD#$password#g" "$ghostylinkDir/conf/app_prod.php"
    sed -ie "s#__DB_DATABASE#$dbName#g" "$ghostylinkDir/conf/app_prod.php"
}

## Configure mail transport connection
## @param $1 host of smtp error
## @param $2 username for smtp connection 
## @param $3 password for smtp connection
## @param $4 [optional] installation direcroy. pwd if not provided
function docker_configure_email {
    local host="$1"
    local user="$2"
    local password="$3"
    local ghostylinkDir="$4"
    if [[ $ghostylinkDir == "" ]]; then
        ghostylinkDir="."
    fi
    sed -ie "s#__EMAIL_HOST#$host#g" "$ghostylinkDir/conf/app_prod.php"
    sed -ie "s#__EMAIL_USERNAME#$user#g" "$ghostylinkDir/conf/app_prod.php"
    sed -ie "s#__EMAIL_PASSWORD#$password#g" "$ghostylinkDir/conf/app_prod.php"
}

## Configure salt for password hashing.
## @param $1 ghostylink install directory. Pwd if not provided.
function docker_configure_salt {
    local ghostylinkDir="$1"
    if [[ $ghostylinkDir == "" ]]; then
        ghostylinkDir="."
    fi
    securitySalt="$(docker_random_string)"
    sed -ie "s#__SECURITY_SALT#$securitySalt#g" "$ghostylinkDir/conf/app_prod.php"
}

## Configure full base url to create link in shell task (eg for mail)
function docker_configure_host {
    local ghostylinkDir="$1"
    local ghostylinkHost="$2"

    if [[ $ghostylinkDir == "" ]]; then
        ghostylinkDir="."
    fi
    securitySalt="$(docker_random_string)"
    sed -ie "s#__FULL_URL#$ghostylinkHost#g" "$ghostylinkDir/conf/app_prod.php"
}