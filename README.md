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
You can retrieve the template for the version you chose to install with:
```
wget https://raw.githubusercontent.com/ghostylink/ghostylink/<version>/config/prod/app_prod_template.php
```

Run then command:
```
docker run -v <conf>:/conf -v <data>:/var/lib/mysql -p <port>:80 ghostylink/docker
```

## Using existing data

# Building
