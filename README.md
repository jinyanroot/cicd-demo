# 介绍
##### 这是一个持续集成和持续发布的Demo，它可以在Windows、Linux环境使用。
##### windows-use(localdev).bat：本地开发环境，它会编译代码，打包并使用docker启动
##### linux-use(cicd).sh：CICD环境，它会部署Jenkins，并内置了一个pipeline Job

# 1.本地开发环境
## 1.1 要求
##### a.Windows 10，理论上能兼容其它Windows版本。
##### b.安装Docker。
##### c.安装Winrar。
##### d.安装Maven。
##### e.默认使用E:\demo\company-news作为代码路径，可修改。

## 1.2 使用方法
##### 修改完代码后，双击直接运行windows-use(localdev).bat即可。
##### 如没有报错，会自动打开网址：http://127.0.0.1:8080/company-news/

# 2.CICD环境
## 2.1 要求
##### a. 运行机器为Centos 7，其它Linux发行版本和Windows版本暂未测试，理论上都是可以运行的。
##### b. 安装Docker 17.06.2-ce
##### c. 配置Docker的启动命令：将/usr/lib/systemd/system/docker.service中的ExecStart行改为如下：
```Bash
ExecStart=/usr/bin/dockerd -H tcp://HOST_IP:2375 -H unix:///var/run/docker.sock
```
##### d. 配置Docker的阿里云的加速器：
```Bash
# cat /etc/docker/daemon.json
{
    "registry-mirrors": ["https://tgw7pqgq.mirror.aliyuncs.com"]
}
```
    
## 2.2 准备
##### a. 在机器上执行prepare.sh
##### b. 等待30秒后，在浏览器中访问http://HOST_IP:8081
##### c. 依次点击Jenkins的系统管理-管理节点-新建节点，相关配置如下：
```Bash
Name:slave-java
# of executors:2
远程工作目录:/home/jenkins
标签:slave-java
用法:尽可能的使用这个节点
启动方法：Launch slave agents via SSH
Host:slave-java
Credentials:帐号root，密码root@123（即slave-java/change_sshd.sh中设置的）
```
  
## 2.3 使用
##### a. 开发人员在本地提交代码。示例Demo：https://github.com/jinyanroot/company-news.git
##### b. 根据实际环境，修改相关配置：
```Bash
ansible/host：配置HOST_IP
slave/change_sshd.sh：配置服务器密码
Jenkinsfile：
line 3：配置代码路径
line 28/29/30：配置各环境的IP
```
##### c. 在Jenkins中执行job:company-news-cd，选择需要发布的环境

# 3.待改进
因时间关系，还有不少可以改进的地方，如下：
1. 兼容其它Linux发行版本和Windows版本。
2. 动态的生成Jenkins slave，用完即销毁。
3. 定制Docker的Jenkins image和Jenkins slave image，以减少脚本优化或避免手动设置。
4. 启动sonar server，让stage 'test'可以做代码静态质量检查等。
5. 完善deploy阶段的test和prod。
6. deploy staging阶段使用jenkins pipeline ansible plugin，以替换shell。
7. 对deploy至test、staging、prod做准入。
8. 完善安全相关配置，例如非root启动程序、不明文存放密码等。

# 特别说明
1. 考虑到效率问题，Jenkins选择了master-slave架构。

