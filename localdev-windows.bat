@echo Off
echo ###### README                                                                    ######
echo ###### 1. Please install docker.You can find it as below:                        ######
echo ######    https://store.docker.com/editions/community/docker-ce-desktop-windows  ######
echo ###### 2. (Default)It use WINRAR to unzip file.                                  ######
echo ###### 3. (Default)It use MAVEN as compile tool.                                 ######
echo ###### 4. (Default)It use E:\demo\company-news as the code path.                 ######

:: Set vars
set sourcePath=E:\demo\company-news
set volPath=/e/demo/company-news/target

:: Compile and package
echo RUN mvn command
E:
cd %sourcePath%
Call mvn clean package -U >nul
If errorlevel 1 (
	pause & exit
)

:: Unzip
echo UNZIP .zip file
winrar x "%sourcePath%\target\company-news.zip" "%sourcePath%\target\"
If errorlevel 1 (
	pause & exit
)

:: Clean all dockers
echo RM all dockers
FOR /f "tokens=*" %%i IN ('docker ps -aq') DO docker rm -f %%i >nul
If errorlevel 1 (
	pause & exit
)

:: Start docker:tomcat
echo START Tomcat
docker run -d -p 8080:8080 --name=tomcat7 -v %volPath%:/usr/local/tomcat/webapps tomcat:7 >nul
If errorlevel 1 (
	pause & exit
)

:: Start docker:nginx
echo START Nginx
docker run -d -p 80:80 --name=nginx -v %volPath%:/usr/share/nginx/html nginx >nul
If errorlevel 1 (
	pause & exit
)
ping -n 15 127.0.0.1>nul

If errorlevel 1 (
	pause & exit
) else (
    start http://127.0.0.1:8080/company-news/
)