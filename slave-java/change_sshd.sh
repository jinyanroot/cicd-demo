#!/bin/bash

echo root:root@123 | chpasswd
sed -i "s/^PermitRootLogin.*/PermitRootLogin yes/" /etc/ssh/sshd_config && /etc/init.d/ssh restart
