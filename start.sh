#!/bin/bash
# -----------------------------------------------------------------------------
# Filename:      start.sh
# Encoding:      UTF-8
# Date:          2017/9/15
# Author:        jinyanroot
# Email:         jinyanroot@gmail.com
# Function:      
# Usage:         Just run it
# Version:       1.0
# -----------------------------------------------------------------------------

# Start Jenkins Slave
docker run -d \
       --name slave-java \
       --privileged=true \
       --restart=always \
       -v /var/run/docker.sock:/var/run/docker.sock \
       registry.aliyuncs.com/acs-sample/jenkins-slave-dind-java
if [[ $? -ne 0 ]];then echo 'Start Slave Faild'; exit 1; fi
sleep 3

# Permit root login slave-java
docker cp `pwd`/slave-java/change_sshd.sh slave-java:/root
docker exec slave-java "/root/change_sshd.sh"

# Start Jenkins
docker run -d -u root \
       --name jenkins \
       --privileged=true \
       --restart=always \
       --link=slave-java \
       -p 8081:8080 \
       -p 50000:50000 \
       -v /var/run/docker.sock:/var/run/docker.sock \
       -v $(which docker):/bin/docker \
       -v `pwd`/jenkins_home:/var/jenkins_home \
       registry.aliyuncs.com/acs-sample/jenkins:2.19.2
