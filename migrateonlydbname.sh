#!/bin/bash

echo "START:"
DBHOST=
DBUSER=
DBPASS=
while IFS= read -r line; do
    array=(`echo $line | sed 's/|/\n/g'`)
    dbName=${array[0]}
     echo "${dbName} start rename"
    domainPrev=${array[1]}
    domainNext=${array[2]}
    echo "${domainPrev} - ${domainNext}"
    echo "UPDATE ${dbName}.wp_options SET option_value = REPLACE(option_value, '${domainPrev}', '${domainNext}') WHERE option_name = 'home' OR option_name = 'siteurl';" | mysql -h "${DBHOST}" -u "${DBUSER}" "-p${DBPASS}"
    echo "UPDATE ${dbName}.wp_posts SET guid = REPLACE(guid, '${domainPrev}','${domainNext}');" | mysql -h "${DBHOST}" -u "${DBUSER}" "-p${DBPASS}"
    echo "UPDATE ${dbName}.wp_posts SET post_content = REPLACE(post_content, '${domainPrev}', '${domainNext}');" | mysql -h "${DBHOST}" -u "${DBUSER}" "-p${DBPASS}"
    echo "UPDATE ${dbName}.wp_postmeta SET meta_value = REPLACE(meta_value,'${domainPrev}','${domainNext}');" | mysql -h "${DBHOST}" -u "${DBUSER}" "-p${DBPASS}"
done < migratedbonlydomain.txt


echo "END:"