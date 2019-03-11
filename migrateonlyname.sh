#!/bin/bash

echo "START:"
while IFS= read -r line; do
    array=(`echo $line | sed 's/|/\n/g'`)
     echo "${dbName} start rename"
    domainPrev=${array[0]}
    domainNext=${array[1]}
    echo "${domainPrev} - ${domainNext}"
    sudo sed -i "s/${domainPrev}/${domainNext}/g" /etc/nginx/sites-available/$domainPrev
    sudo mv /var/www/$domainPrev /var/www/$domainNext
done < migrateonlydomain.txt


echo "END:"

# mysql -h lamtim-node6-db.cirrh4gmmfvl.ap-southeast-1.rds.amazonaws.com -u thAAr8j2fDTz3XqL -pn3Rtj4vcyUbbvUzy