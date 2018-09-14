#!/bin/bash
# sudo chmod +x wordpress.sh
# NGIRIM file zip ke scp lalu menjalankan script di server setelah kirim 1 file termasuk sampai create db dan bikin subdomain

echo "START:"
IP='127.0.0.1'
domain=YOURDOMAIN
targetDirectory='/var/www'
targetNginx='/etc/nginx'
DBHOST=YOURDBHOST
DBUSER=YOURDBUSER
DBPASS=YOURDBPASS
while IFS= read -r line; do 
    array=(`echo $line | sed 's/|/\n/g'`)
    file=${array[0]}
    dbName=${array[1]}
    domainName=${array[2]}
    location="${targetDirectory}/${domainName}.${domain}"
    # unzip file to target
    echo "${file} START:------- unzipping"
    tar -zxf ${file} --overwrite
    cp -R ${dbName}.com ${targetDirectory}/${domainName}.${domain}
    rm -rf ${targetDirectory}/${dbName}.com
    mv ${targetDirectory}/${domainName}.${domain}/.user.ini ${targetDirectory}/${domainName}.${domain}/.user.ini.backup
    rm -rf ${dbName}.com
    echo "${file} DONE:-------- unzipping"
    echo "${file} START:------- copy wp-config.php -> wp-config.php.backup"
    `echo cp ${location}/wp-config.php ${location}/wp-config.php.backup`
    echo "${file} DONE:-------- copy wp-config.php -> wp-config.php.backup"

    # set config file
    echo "${file} START:------- copy to target path and replace wp-config parameter"
    `echo cp -rf wp-config.php.master ${location}/wp-config.php`
    `echo sed -i "s/{DB_HOST}/$DBHOST/g" ${location}/wp-config.php`
    `echo sed -i "s/{DB_USER}/$DBUSER/g" ${location}/wp-config.php`
    `echo sed -i "s/{DB_PASSWORD}/$DBPASS/g" ${location}/wp-config.php`
    `echo sed -i "s/{DB_NAME}/$dbName/g" ${location}/wp-config.php`
    echo "${file} DONE:-------- copy to target path and replace wp-config parameter"

    # insert to database
    echo "${file} START:------- search sql file and execute"
    sqlFile=`find ${location} -maxdepth 1 -name "*.sql"`
    echo "DROP DATABASE IF EXISTS ${dbName};" | mysql -h "${DBHOST}" -u "${DBUSER}" "-p${DBPASS}"
    echo "CREATE DATABASE ${dbName}" | mysql -h "${DBHOST}" -u "${DBUSER}" "-p${DBPASS}"
    if [ -f "$sqlFile" ]
    then 
        echo $sqlFile
        echo `mysql -h "${DBHOST}" -u "${DBUSER}" "${dbName}" "-p${DBPASS}" < "$sqlFile"`
        echo "UPDATE ${dbName}.wp_options SET option_value = REPLACE(option_value, 'http://${dbName}.com', 'http://${domainName}.${domain}') WHERE option_name = 'home' OR option_name = 'siteurl';" | mysql -h "${DBHOST}" -u "${DBUSER}" "-p${DBPASS}"
        echo "UPDATE ${dbName}.wp_posts SET guid = REPLACE(guid, 'http://${dbName}.com','http://${domainName}.${domain}');" | mysql -h "${DBHOST}" -u "${DBUSER}" "-p${DBPASS}"
        echo "UPDATE ${dbName}.wp_posts SET post_content = REPLACE(post_content, 'http://${dbName}.com', 'http://${domainName}.${domain}');" | mysql -h "${DBHOST}" -u "${DBUSER}" "-p${DBPASS}"
        echo "UPDATE ${dbName}.wp_postmeta SET meta_value = REPLACE(meta_value,'http://${dbName}.com','http://${domainName}.${domain}');" | mysql -h "${DBHOST}" -u "${DBUSER}" "-p${DBPASS}"
    fi
    echo "${file} DONE:-------- search sql file and execute"

    # set up nginx sites
    echo "${file} START:------- setup nginx "
    `echo sudo cp -rf sites-available ${targetNginx}/sites-available/${domainName}.${domain}`
    `echo sudo sed -i "s/{TARGET_PATH}/${domainName}.${domain}/g" ${targetNginx}/sites-available/${domainName}.${domain}`
    `echo sudo sed -i "s/{DOMAIN}/${domainName}.${domain}/g" ${targetNginx}/sites-available/${domainName}.${domain}`
    `echo sudo ln -sf ${targetNginx}/sites-available/${domainName}.${domain} ${targetNginx}/sites-enabled/`
    echo "${file} DONE:------- setup nginx "

    echo "${file} START:------- insert to /etc/hosts "
    if grep -Fxq "${IP}     ${domainName}.${domain}" /etc/hosts
    then
        echo "${file} /etc/hosts:------- found -> NOT INSERTING AGAIN"
    else
        echo `sudo -- sh -c -e "echo '${IP}     ${domainName}.${domain}' >> /etc/hosts"`;
    fi
    echo "${file} DONE:------- insert to /etc/hosts "

done < lamtim.txt
