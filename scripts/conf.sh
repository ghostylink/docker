#!/bin/bash -e
function conf_is_present {
    if [[ -f "$GHOSTYLINK_WEBROOT/config/prod/app_prod.php" ]]; then
        return 0
    fi
    return 1
}

function conf_get_from_template {
    cp "$GHOSTYLINK_WEBROOT/config/prod/app_prod_template.php" "$GHOSTYLINK_WEBROOT/config/prod/app_prod.php"
}

function conf_get_unconfigured_keys {
    local missing_keys=$(grep  "__" "$GHOSTYLINK_WEBROOT/config/prod/app_prod.php")
    ret=$?
    echo "$missing_keys"
    return $ret
}