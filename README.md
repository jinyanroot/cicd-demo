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
```Bash
Name:slave-java<br>
# of executors:2<br>
远程工作目录:/home/jenkins<br>
标签:slave-java<br>
用法:尽可能的使用这个节点<br>
启动方法：Launch slave agents via SSH<br>
Host:slave-java<br>
Credentials:帐号root，密码root@123（即slave-java/change_sshd.sh中设置的）<br>
```
  
# 使用
1. 开发人员在本地提交代码。示例Demo：https://github.com/jinyanroot/company-news.git<br>
2. 根据实际环境，修改相关配置：
```Bash
ansible/host：配置HOST_IP
slave/change_sshd.sh：配置服务器密码
Jenkinsfile：
line 3：配置代码路径
line 28/29/30：配置各环境的IP
```
3. 在Jenkins中执行job:company-news-cd，选择需要发布的环境<br>

# 待改进
因时间关系，还有不少可以改进的地方，如下：<br>
1. 兼容其它Linux发行版本和Windows版本。<br>
2. 动态的生成Jenkins slave，用完即销毁。<br>
3. 定制Docker的Jenkins image和Jenkins slave image，以减少脚本优化或避免手动设置。<br>
4. 启动sonar server，让stage 'test'可以做代码静态质量检查等。<br>
5. 完善deploy阶段的test和prod。<br>
6. deploy staging阶段使用jenkins pipeline ansible plugin，以替换shell。<br>
7. 对deploy至test、staging、prod做准入。<br>
8. 完善安全相关配置，例如非root启动程序、不明文存放密码等。<br>

# 特别说明
1. 考虑到效率问题，Jenkins选择了master-slave架构。<br>

