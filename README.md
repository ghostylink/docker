# Disclaimer
This is only pre-release information. Docker image will be soon available :)

# Purpose
This is the [ghostylink](https://github.com/ghostylink/ghostylink) docker image.
You can use it if you want to host the project on your own
It contains:
* A MySQL server
* An Apache server
* The ghostylink project

# Usage
## First start
You will need to configure some necessary informations:
* Database access
* A security salt for password hashing
* Google recatpcha keys
* Smtp access

```
'fullBaseUrl' => '__FULL_URL'
'host' => '__EMAIL_HOST',
'username' => '__EMAIL_USERNAME',
'password' => '__EMAIL_PASSWORD',
'username' => '__DB_USERNAME',
'password' => '__DB_PASSWORD',
'database' => '__DB_DATABASE',
'private' => '__CAPTCHA_PRIVATE',
'public' => '__CAPTCHA_PUBLIC'
'salt' => '__SECURITY_SALT',
```

Create a `<conf>` dir and put the template configuration for your version
in it. Create a `<data>` and a `<log>` directory.
```
cd <ghostylink_dir> && mkdir conf data log
wget -P conf https://raw.github.com/ghostylink/ghostylink/<version>/config/prod/app_prod_template.php -O conf/app_prod.php
wget https://raw.github.com/ghostylink/docker/<version>/scripts/docker -O docker.sh
source docker.sh

docker_init_image <ghostylink_version> <ghostylink_dir> <ghostylink_host>
```

Run then command:
```bash
docker run -v <conf>:/conf -v <data>:/var/lib/mysql -p <port>:80 ghostylink/ghostylink
```

## Using existing data
Run the command bellow with your existing `conf` , `data` and `log` directories

```bash
docker run -v <conf>:/conf -v <data>:/var/lib/mysql -p <port>:80 ghostylink/ghostylink
```

### Migrations
When your `data` directory contains data from an older version, ghostylink migrations
are applied automatically
In a similar way, you can downgrade to an older version of the ghostylink project

# Building

```bash
git clone https://github.com/ghostylink/docker/
docker build -t local/ghostylink  --build-arg commit=<commit-id> .
```