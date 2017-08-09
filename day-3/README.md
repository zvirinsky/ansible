
###### MTN.NIX Automated Environment Configuration Management  
## Ansible. 3 
##### Student: Zakhar Virinsky


##### Lab Work Task. Web Server Provisioning
##### Review:  
Developing custom modules and filters. Learning by doing.
##### Task
On Host Node (Control Machine):
  *  Create folder ~/cm/ansible/day-3. All working files are supposed to be placed right there.
  *  Develop custom filter to select an url to download mongodb depends on OS name and S/W version from https://www.mongodb.org/dl/linux/  
  Requirements:
   - Write a playbook (name: mongodb.yml) to prove that this module works
   - At least 9 versions of MongoDB for 3 different Linux distributives (list with links)
   - Filter should process a list of urls and takes 3 options: os_family (discovered by ansible, variable, produced by setup module), os release number and mongodb_version (set in play vars)  


   *  Develop custom module to manage VirtualBox:
    - Arguments:
       - path to vagrantfile
       - state: started, stopped, destroyed
    - Return values:
       - state: running, stopped, not created
       - ip address, port
       - path to ssh key file
       - username to connect to VM
       - os_name
       - RAM size
    - Errors:
       - file doesn’t exists
       - failed on creation
       - etc  
   * Create a playbook (name: stack.yml) to provision Tomcat stack (nginx + tomcat) on VirtualBox VM
    - Requirements:
        - 2 Plays: provision VM, roll out Tomcat stack (using roles from previous lab work)
        - 2nd play should work with dynamically composed Inventory (connection settings to VM), http://docs.ansible.com/ansible/add_host_module.html
    -  Verification Procedure: playbook will be checked by instructor’s CI system as follows:
       - 5.1 Connect to student’s host by ssh (username “student”) with own ssh key.
       - 5.2 Go into the folder mentioned in point 1
       - 5.3 Destroy: vagrant destroy
       - 5.4 Execute VM provisioning: ansible-playbook stack.yml -i localhost, -c local -vv
       - 5.5 If previous steps are done successfully, instructor will check report (pdf-file)
   * Feedback: report issues/problems you had during the development of playbook and time spent for development.



## Report notes

##### filter_plugins/filter_plugins.py:
```python
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible import errors

def get_mongo_src(arg, a, b, c):
    result = "is not available for current conditions"
    d = a + b
    for i in range(len(arg)):
        arg[i] = arg[i].split('-')
        if d in arg[i][3]:
            if c in arg[i][4]:
                result = '-'.join(arg[i])
    return result

class FilterModule(object):
    def filters(self):
        return {
            'get_mongo_src': get_mongo_src
        }

```
##### mongodb.yml:
```yaml
- name: get link for mongodb
  hosts: localhost
  connection: local

  vars:
    os_fam: "{{ ansible_os_family }}"
    os_distr: "{{ ansible_distribution_major_version }}"
    mongo_ver: "3.4"
    mongo_src:
      - http://downloads.mongodb.org/linux/mongodb-linux-x86_64-rhel62-3.4.1.tgz?_ga=2.199605801.607463346.1501744015-1811212876.1501744015
      - http://downloads.mongodb.org/linux/mongodb-linux-x86_64-rhel70-3.4.1.tgz?_ga=2.199605801.607463346.1501744015-1811212876.1501744015
      - http://downloads.mongodb.org/linux/mongodb-linux-x86_64-rhel55-3.2.11.tgz?_ga=2.200896809.607463346.1501744015-1811212876.1501744015
      - http://downloads.mongodb.org/linux/mongodb-linux-x86_64-debian81-3.4.7-rc0.tgz?_ga=2.91077021.607463346.1501744015-1811212876.1501744015
      - http://downloads.mongodb.org/linux/mongodb-linux-x86_64-ubuntu1604-3.2.16-rc0.tgz?_ga=2.155628988.607463346.1501744015-1811212876.1501744015
      - http://downloads.mongodb.org/linux/mongodb-linux-x86_64-rhel55-3.0.14.tgz?_ga=2.195608107.607463346.1501744015-1811212876.1501744015
      - http://downloads.mongodb.org/linux/mongodb-linux-x86_64-rhel70-3.5.10.tgz?_ga=2.155628988.607463346.1501744015-1811212876.1501744015
      - http://downloads.mongodb.org/linux/mongodb-linux-x86_64-rhel70-3.0.14.tgz?_ga=2.157782333.607463346.1501744015-1811212876.1501744015
      - http://downloads.mongodb.org/linux/mongodb-linux-x86_64-ubuntu1604-3.4.7-rc0.tgz?_ga=2.157782333.607463346.1501744015-1811212876.1501744015

  tasks:

    - name: override RedHat with rhel
      set_fact:
        os_fam: "rhel"
      when: ansible_os_family=="RedHat"

    - debug: msg=" download link {{ mongo_src | get_mongo_src(os_fam,os_distr,mongo_ver)}}"
```    
##### library/pro_varg.sh:
```bash
#!/bin/bash
source $1
#path=$1
#state=$2

if [ ! -f $path/Vagrantfile ]; then
    echo "File not found!" && exit 0
else
      cd $path
fi

if [ $state != "started"   ] && [ $state != "stopped" ] && [ $state != "destroyed" ]; then
    echo "Not a valid state" && exit 0
fi

status=$(vagrant status | awk 'NR == 3 {print $2;}')

case $status
 in
 running)
          if [ $state = stopped ]; then
              vagrant_cmd="vagrant halt"
              changed=true
              printf '{"changed": "%s", "state": "%s"}' $changed $status
              exit 0
            else
              if [ $state = destroyed ]; then
                vagrant_cmd="vagrant destroy -f"
                changed=true
                printf '{"changed": "%s", "state": "%s"}' $changed $status
                exit 0
              else
                changed=false
              fi
          fi
;;
 poweroff)
           if [ $state = started ]; then
               vagrant_cmd="vagrant up"
               changed=true
           else
             if [ $state = destroyed ]; then
               vagrant_cmd="vagrant destroy -f"
               changed=true
               printf '{"changed": "%s", "state": "%s"}' $changed $status
               exit 0
             else
               changed=false
               printf '{"changed": "%s", "state": "%s"}' $changed $status
               exit 0
             fi
           fi
;;
 not)

           if [ $state = started ]; then
               vagrant_cmd="vagrant up"
               changed=true
           else
             if [ $state = stopped ]; then
               changed=false
               printf '{"changed": "%s", "state": "%s"}' $changed $status
               exit 0
             else
                changed=false
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

printf '{"changed": "%s", "state": "%s", "ipaddress": "%s", "port": "%s", "ssh_path": "%s", "user": "%s", "os_name": "%s", "ram_size": "%s"}' $changed $status "$ipaddress" $port $ssh_path $user "$os_name" $ram_size

```
##### stack.yml:
```yaml
- name: build new host
  hosts: localhost

  tasks:
  - name: execute script
    pro_vagr:
      path: /home/student/cm/ansible/day-3
      state: started
    register: output

  - add_host:
      name: ad-hoc-host
      groups: just_created
      ansible_host: "{{output.ipaddress}}"
      ansible_port: "{{output.port}}"
      ansible_user: "{{output.user}}"
      ansible_ssh_private_key_file: "{{output.ssh_path}}"
      insecure_private_key: yes
    when: output.state ==  "running"

- name: installation
  hosts: ad-hoc-host
  become: true
  become_method: sudo

  roles:
  - role: tomcat
  - role: nginx
  - role: java_test
  - role: nginx_test
  - role: tomcat_test
```
