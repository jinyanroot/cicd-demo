#!/bin/bash

sed -i "s/^PermitRootLogin.*/PermitRootLogin yes/" /etc/ssh/sshd_config && /etc/init.d/ssh restart
echo root:root@123 | chpasswd
