#!/bin/bash

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
chmod 755 `pwd`/slave-java/change_sshd.sh
docker cp `pwd`/slave-java/change_sshd.sh slave-java:/root
docker exec slave-java "/root/change_sshd.sh"

# Copy jenkins files
rm -rf /var/jenkins_home && cp -r jenkins_home/ /var/

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
       -v /var/jenkins_home:/var/jenkins_home \
       registry.aliyuncs.com/acs-sample/jenkins:2.19.2
