#!/bin/bash
source $1

if [ -z "$path" ]; then
    echo "Path to vagrantfile is missed"
    exit 0
fi


if [ ! -f $path/Vagrantfile ]; then
          if [ ! -f $path ] || [ $(echo $path | rev | cut -d'/' -f-1 | rev) != Vagrantfile  ]; then
            echo "File not found!" && exit 0
          else
             path=$(echo $path | sed 's/Vagrantfile.*//g')
          fi
else
      cd $path
fi

if [ ${state:+1} ]; then
            if  [ $state != "started" ] && [ $state != "stopped" ] && [ $state != "destroyed" ]; then
                echo "Not a valid state" && exit 0
            fi
else
   echo "State is missed" && exit 0
fi
status=$(vagrant status | awk 'NR == 3 {print $2;}')

case $status
 in
running)
          if [ $state = stopped ]; then
              vagrant halt
              changed="true"
              printf '{"changed": "%s", "state": "%s"}' $changed $status
              exit 0
            else
              if [ $state = destroyed ]; then
                vagrant destroy -f
                changed="true"
                printf '{"changed": "%s", "state": "%s"}' $changed $status
                exit 0
              else
                changed="false"
              fi
          fi
;;
poweroff)
           if [ $state == started ]; then
               vagrant up
               changed="true"
           else
             if [ $state = destroyed ]; then
               vagrant destroy -f
               changed="true"
               printf '{"changed": "%s", "state": "%s"}' $changed $status
               exit 0
             else
               changed="false"
               printf '{"changed": "%s", "state": "%s"}' $changed $status
               exit 0
             fi
           fi
;;
not)

           if [ $state = started ]; then
               vagrant up
               changed="true"
           else
             if [ $state = stopped ]; then
               changed="false"
               printf '{"changed": "%s", "state": "%s"}' $changed $status
               exit 0
             else
                changed="false"
                status="not created"
                printf '{"changed": "%s", "state": "%s"}' $changed $status
                exit 0
             fi
           fi

esac
$vagrant_cmd


ipaddress=$(vagrant ssh-config | awk 'NR == 2 {print $2;}')
port=$(vagrant ssh-config | awk 'NR == 4 {print $2;}')
ssh_path=$(vagrant ssh-config | awk 'NR == 8 {print $2;}')
user=$(vagrant ssh-config | awk 'NR == 3 {print $2;}')
os_name=$(vagrant ssh -c 'cat /etc/*-release' | awk 'NR == 1 {print $1,$2,$3,$4;}')
ram_size=$(vagrant ssh -c 'free -m' | awk 'NR == 2 {print $2;}')


printf '{"check": "%s", "changed": "%s", "state": "%s", "ipaddress": "%s", "port": "%s", "ssh_path": "%s", "user": "%s", "os_name": "%s", "ram_size": "%s"}' $state $changed $status "$ipaddress" $port $ssh_path $user "$os_name" $ram_size
