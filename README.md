# Purpose
This is the [ghostylink](https://github.com/ghostylink/ghostylink) docker image.
You can use it if you want to host the project on your own
It contains:
* A MySQL server
* An Apache server
* The ghostylink project

# Usage
## First start
### Standalone image
You will need to configure some necessary informations:

* Database access
* A security salt for password hashing

*Optional*

* Google recatpcha keys (disable it by setting ``reCaptcheKeys.public` to `null`)
 - Used for recaptcha component activation
* Smtp access (disable it by setting `EmailTransport.default.username` to `null`)
 - Used for ghostyfication alerts
 - Used for user's email verification


| Configuration key       | Description           | Required  |
| ------------- |:-------------|:-----:|
|'fullBaseUrl'      | ghostylink installed url | **Yes** |
|'Security.salt' | a salt for password hashing      |    **Yes** |
|'Datasources.default.username' | database username      |    **Yes** |
|'Datasources.default.password' | database password      |    **Yes** |
|'Datasources.default.database' | database name      |    **Yes** |
|'EmailTransport.default.host'      | smtp host      |   No |
|'EmailTransport.default.username'      | smtp username      |   No |
|'EmailTransport.default.password' | smtp password      |    No |
|'reCaptcheKeys.public'      | google recaptcha public key      |   No |
|'reCaptcheKeys.private'      | google recaptcha private key      |   No |


To configure easily those keys, you can use our `docker.sh` bash script.
Create a `<conf>` dir and put the template configuration for your version
in it. Create a `<data>` and a `<log>` directory.
```bash
cd <ghostylink_dir> && mkdir conf data log
wget -P conf https://raw.github.com/ghostylink/ghostylink/<version>/config/prod/app_prod_template.php \
     -O conf/app_prod.php
wget https://raw.github.com/ghostylink/docker/<version>/scripts/docker.sh\
     -O docker.sh
source docker.sh

docker_init_image <ghostylink_version> <ghostylink_dir> <ghostylink_host>
```

Run then command:
```bash
docker run -v <conf>:/conf \
           -v <data>:/var/lib/mysql \
           -v <log>:/log \
           -p <port>:80 ghostylink/ghostylink
```
### Using docker-compose
We provide a docker-compose.yml file for additional services required by 
ghostylink.
It includes:
* A smtp server
* The ghostylink project

To use it:
```bash
cd <ghostylink_dir> && mkdir conf data log postfix
version=<version>
wget -P conf https://raw.github.com/ghostylink/ghostylink/$version/config/prod/app_prod_template.php \
     -O conf/app_prod.php
wget https://raw.github.com/ghostylink/docker/$version/scripts/docker.sh\
     -O docker.sh
wget https://raw.github.com/ghostylink/docker/$version/docker-compose.yml\
     -O docker-compose.yml
source docker.sh

# Configure google recaptcha manually or replace by null if not wanted
vi conf/app_prod.php

docker_init_compose version domain port <ghostylink_dir>
docker-compose up
```

## Using existing data
Run the command bellow with your existing `conf` , `data` and `log` directories

```bash
docker run -v <conf>:/conf \
           -v <data>:/var/lib/mysql\
           -v <log>:/log \
           -p <port>:80 ghostylink/ghostylink
```

### Upgrade
When your `data` directory contains data from an older version, ghostylink migrations
are applied automatically at start up.

### Downgrade
In a similar way, you can downgrade to an older version of the ghostylink project.
Note that you will lose irredeemably data.

# Building

## From a given commit
```bash
git clone https://github.com/ghostylink/docker/
docker build -t local/ghostylink  --build-arg commit=<commit-id> .
```

## From a given branch
```bash
git clone https://github.com/ghostylink/docker/
docker build -t local/ghostylink  --build-arg branch=<branch-name> .
```

## From a given tag
```bash
git clone https://github.com/ghostylink/docker/
docker build -t local/ghostylink  --build-arg tag=<tag-name> .
```
