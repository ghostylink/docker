#!/bin/bash
rm -rf /var/www/html/*
git clone https://github.com/ghostylink/ghostylink "$GHOSTYLINK_WEBROOT"
(
    cd "$GHOSTYLINK_WEBROOT"
    
    if [[ "$branch" != "" ]]; then
        git checkout "$branch"
    if [[ "$version" != "" ]]; then
        git checkout "tags/$version"
    elif [[ "$commit" != "" ]]; then
        git checkout "$commit"
    fi
)
