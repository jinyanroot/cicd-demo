stage 'build'
	node('slave-java') {
		git 'https://github.com/jinyanroot/company-news.git'
		sh "mvn -e -B -U clean package -Dmaven.test.skip=true"
		step([$class: 'ArtifactArchiver', artifacts: '**/target/*.war, \
		     **/target/*.zip', fingerprint: true])
		stash excludes: 'target/', includes: '**', name: 'source'
	}

stage 'test'
	parallel 'integration': { 
		node('slave-java') {
			unstash 'source'
			sh "mvn -e -B -U clean verify"
		}
	}, 'quality': {
		node('slave-java') {
			unstash 'source'
			// You can prepare a sonar server,and run '''sh "mvn sonar:sonar"'''
			// For the time,I only use the below for test
			sh "mvn -e -B -U clean test -Dmaven.test.failure.ignore"
		}
	}
	
stage name:'deploy', concurrency: 1
	node('master') {
		// define variable
		def dev_docker_ip = "192.168.62.188"
		def test_docker_ip = "192.168.62.188"
		def war_image = docker.image('tomcat:7')
		def statics_image = docker.image('nginx')
		def cur_build_path = JENKINS_HOME + "/jobs/" + JOB_NAME + \
							 "/builds/" + BUILD_NUMBER + "/archive/target"
		def war_path = JENKINS_HOME + "/jobs/" + JOB_NAME + \
							 "/builds/" + BUILD_NUMBER + "/code/war"
		def statics_path = JENKINS_HOME + "/jobs/" + JOB_NAME + \
							 "/builds/" + BUILD_NUMBER + "/code/statics"
							 
		// create war and statics directory and unzip stagics files
		sh "mkdir -p ${war_path} ${statics_path} \
		    && cp ${cur_build_path}/*.war ${war_path} \
			&& cp ${cur_build_path}/*.zip ${statics_path} \
			&& unzip -q ${statics_path}/*.zip -d ${statics_path}"
			
		// according to the jobs' parameters,we can deploy dev/test/staging/prod flexibly
		if (DEPLOY_EVE == 'dev') {
			// connect to dev server
			withDockerServer([uri: 'tcp://' + dev_docker_ip + ':22375']) {
				// clean the last container
				try {
					sh "docker rm -f dev-war-jinyanroot dev-statics-jinyanroot"
					echo "rm container:dev-war-jinyanroot,dev-statics-jinyanroot"
				} catch(e) {
					echo "container:dev-war-jinyanroot or \
					      dev-statics-jinyanroot isn't exist"
				}
				
				// run the containers of war and statics
				def war_container = war_image.run("--name dev-war-jinyanroot \
				                          -p 8080:8080 -v " + war_path + \
										  ":/usr/local/tomcat/webapps")
				def statics_container = statics_image.run("--name dev-statics-jinyanroot \
				                          -p 80:80 -v " + statics_path + \
										  ":/usr/share/nginx/html")
			
				echo "Your dev env is:http://" + dev_docker_ip + \
				     ":8080/company-news-0.0.1-SNAPSHOT"
			}
		} else if (DEPLOY_EVE == 'test') {
			echo 'test'
		} else if (DEPLOY_EVE == 'staging') {
			echo 'staging'
		} else if (DEPLOY_EVE == 'prod') {
			echo 'prod'
		} else {
			echo 'error'
		}
	}