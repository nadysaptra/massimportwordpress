#!/bin/bash
# sudo chmod +x wordpress.sh
# NGIRIM file zip ke scp lalu menjalankan script di server setelah kirim 1 file termasuk sampai create db dan bikin subdomain

echo "START:"
DBHOST_OLD=OLDDBHOST
DBHOST_NEW=NEWDBHOST
DBUSER_OLD=OLDDBUSER
DBUSER_NEW=NEWDBUSER
DBPASS_OLD=OLDDBPASSWORD
DBPASS_NEW=NEWDBPASSWORD
domain=YOURTARGETDOMAIN
while IFS= read -r line; do 
    array=(`echo $line | sed 's/|/\n/g'`)
    location=${array[0]}
    dbName=${array[1]}
    domainName=${array[2]}
    echo "${dbName} start rename"
    sed -i "s%$DBHOST_OLD%$DBHOST_NEW%g" ${location}/wp-config.php
    sed -i "s%$DBPASS_OLD%$DBPASS_NEW%g" ${location}/wp-config.php
    sed -i "s%$DBUSER_OLD%$DBUSER_NEW%g" ${location}/wp-config.php
    echo "${dbName} end rename"

    echo "${dbName} start sql"
    sqlFile=`find ${location} -maxdepth 1 -name "*.sql"`
    echo "DROP DATABASE IF EXISTS ${dbName};" | mysql -h "${DBHOST_NEW}" -u "${DBUSER_NEW}" "-p${DBPASS_NEW}"
    echo "CREATE DATABASE ${dbName}" | mysql -h "${DBHOST_NEW}" -u "${DBUSER_NEW}" "-p${DBPASS_NEW}"
    if [ -f "$sqlFile" ]
    then 
        echo $sqlFile
        echo `mysql -h "${DBHOST_NEW}" -u "${DBUSER_NEW}" "${dbName}" "-p${DBPASS_NEW}" < "$sqlFile"`
        echo "UPDATE ${dbName}.wp_options SET option_value = REPLACE(option_value, 'http://${dbName}.com', 'http://${domainName}.${domain}') WHERE option_name = 'home' OR option_name = 'siteurl';" | mysql -h "${DBHOST_NEW}" -u "${DBUSER_NEW}" "-p${DBPASS_NEW}"
        echo "UPDATE ${dbName}.wp_posts SET guid = REPLACE(guid, 'http://${dbName}.com','http://${domainName}.${domain}');" | mysql -h "${DBHOST_NEW}" -u "${DBUSER_NEW}" "-p${DBPASS_NEW}"
        echo "UPDATE ${dbName}.wp_posts SET post_content = REPLACE(post_content, 'http://${dbName}.com', 'http://${domainName}.${domain}');" | mysql -h "${DBHOST_NEW}" -u "${DBUSER_NEW}" "-p${DBPASS_NEW}"
        echo "UPDATE ${dbName}.wp_postmeta SET meta_value = REPLACE(meta_value,'http://${dbName}.com','http://${domainName}.${domain}');" | mysql -h "${DBHOST_NEW}" -u "${DBUSER_NEW}" "-p${DBPASS_NEW}"
    fi
    echo "${dbName} end sql"

done < migratedb.txt
