#!/bin/bash
source $1

#url=192.168.56.10:8080
#war="mnt-lab.war"
#username="admin"
#password="admin"


if [ -z "$url" ] || [ -z "$war" ] || [ -z "$username" ] || [ -z "$password" ] ; then
    echo "Missed parameter... exit..."
    exit 0
fi
if [ ! -f $war ]; then
    echo "deploy file is missing... exit..."
    exit 0
fi
filename=$(basename "$war")
url_end="${filename%.*}"
d_time=$(date)
out=$(curl -u $username:$password --upload-file $war "$url/manager/text/deploy?path=/$url_end&update=true")

echo $out | grep huiisiiia > /dev/null
if [ $? == 0 ]; then
    status="ok"
    changed="true"
else
    status="failed"
    changed="false"
    printf '{"changed": "%s", "status": "%s", "date": "%s", "username": "%s", "app": "%s"}' "$changed" "$status" "$d_time" "$username" "$url_end"

    exit 0
fi


printf '{"changed": "%s", "status": "%s", "date": "%s", "username": "%s", "app": "%s"}' "$changed" "$status" "$d_time" "$username" "$url_end"


#curl -u admin:admin --upload-file mnt-lab.war "htpp://192.168.56.10:8080/manager/text/deploy?path=/mnt-lab"
