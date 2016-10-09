#!/bin/bash
apt-get update && \
apt-get -y install curl php5-intl && \
service apache2 restart