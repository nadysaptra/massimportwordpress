#!/bin/bash

echo "START:"
DBHOST=
DBUSER=
DBPASS=
while IFS= read -r line; do
    array=(`echo $line | sed 's/|/\n/g'`)
    domain=${array[0]}
    dbName=${array[1]}
    newTheme=${array[2]}
    echo "${domain} start rename"
    echo "${domain}"
    echo "UPDATE ${dbName}.wp_options SET option_value = '${newTheme}' WHERE option_name = 'template' OR option_name = 'stylesheet';" | mysql -h "${DBHOST}" -u "${DBUSER}" "-p${DBPASS}"
    sudo tar -zxvf $newTheme.tar.gz -C /var/www/$domain/wp-content/themes/
done < migratenewtheme.txt


echo "END:"