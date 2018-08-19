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
		def staging_war_ip = "192.168.62.188"
		def staging_statics_ip = "192.168.62.188"
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
			
		// according to the jobs' parameters,we can deploy test/staging/prod flexibly
		if (DEPLOY_EVE == 'test') {
			echo 'test'
		} else if (DEPLOY_EVE == 'staging') {
			// set up login without password
			sh "ansible-playbook ansible/rsync_key.yml \
			    -i ansible/host -e hosts=${staging_war_ip}"
			sh "ansible-playbook ansible/rsync_key.yml \
			    -i ansible/host -e hosts=${staging_statics_ip}"
			
			// deploy war
			sh "ansible-playbook ./ansible/webapps-deploy.yml \
			    -i ./ansible/host -e hosts=${staging_war_ip} \
			    -e war_path=${war_path}/company-news.war"
			
			// deploy statics
			sh "ansible-playbook ./ansible/statics-deploy.yml \
			    -i ./ansible/host -e hosts=${staging_statics_ip} \
			    -e statics_path=${statics_path}/company-news.zip"
		} else if (DEPLOY_EVE == 'prod') {
			echo 'prod'
		} else {
			echo 'error'
		}
	}