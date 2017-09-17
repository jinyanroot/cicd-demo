# 介绍
这是一个持续集成和持续发布的Demo。

# 要求
###### 1. 运行机器为Centos 7，其它Linux发行版本和Windows版本暂未测试，理论上都是可以运行的。<br>
###### 2. 安装Docker 17.06.2-ce，有以下两个地方需要特别配置：<br>
a. 将/usr/lib/systemd/system/docker.service中的ExecStart行改为如下：<br>
```Bash
ExecStart=/usr/bin/dockerd -H tcp://HOST_IP:2375 -H unix:///var/run/docker.sock<br>
```
b. 配置阿里云的加速器：
```Bash
# cat /etc/docker/daemon.json
{
    "registry-mirrors": ["https://tgw7pqgq.mirror.aliyuncs.com"]
}
```
    
# 准备
1. 在机器上执行prepare.sh<br>
2. 等待30秒后，在浏览器中访问http://HOST_IP:8081<br>
3. 依次点击Jenkins的系统管理-管理节点-新建节点，相关配置如下：<br>
   Name:slave-java<br>
   of executors:2<br>
   远程工作目录:/home/jenkins<br>
   标签:slave-java<br>
   用法:尽可能的使用这个节点<br>
   启动方法：Launch slave agents via SSH<br>
       Host:slave-java<br>
       Credentials:帐号root，密码root@123（即slave-java/change_sshd.sh中设置的）<br>
  
# 使用
1. 提交代码，本demo以https://github.com/jinyanroot/company-news.git为例<br>
2. 在Jenkins中执行job:company-news-cd，选择需要发布的环境<br>
