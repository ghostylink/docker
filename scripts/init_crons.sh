#!/bin/bash
echo "=> Reading configuration from '$GHOSTYLINK_WEBROOT/config/'"
mail_alert_frequency=$(php -r "\$conf = require '$GHOSTYLINK_WEBROOT/config/prod/app_prod.php'; \
                                print_r(\$conf['Docker']['crons']['ghostification']['mail']);")
life_checker_frequency=$(php -r "\$conf = require '$GHOSTYLINK_WEBROOT/config/prod/app_prod.php'; \
                                print_r(\$conf['Docker']['crons']['life_checker']);")
#### Current crontab entries
echo "=> Retrieving existing crontab entries"
crontab -l > mycron

##### Mailer alert
echo "=> Setting cron for mail to $mail_alert_frequency"
if [[ $(grep "mailer alerts" mycron) == "" ]]; then
  printf "\tAdding a new crontab entry\n"
  echo "$mail_alert_frequency $GHOSTYLINK_WEBROOT/bin/cake mailer alerts" >> mycron
  # Cron requires an empty line  
else
  printf "\tReplacing existing crontab entry\n"
  sed -i "s#\(.*\)\($GHOSTYLINK_WEBROOT/bin/cake mailer alerts\)#$mail_alert_frequency \2#g" mycron
fi

#### Life check cron
echo "=> Setting cron for life checker to $life_checker_frequency"
if [[ $(grep "lifechecker delete-dead" mycron) == "" ]]; then
  printf "\tAdding a new crontab entry\n"
  echo "$life_checker_frequency $GHOSTYLINK_WEBROOT/bin/cake lifechecker delete-dead" >> mycron  
else
  printf "\tReplacing existing crontab entry\n"
  sed -i "s#\(.*\)\($GHOSTYLINK_WEBROOT/bin/cake lifechecker delete-dead\)#$life_checker_frequency \2#g" mycron
fi

# Making crontab effective
echo "=> Applying new crontab"
# Cron requires an empty line
echo "" >> mycron 
crontab mycron && cron
