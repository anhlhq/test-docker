pipeline{
	agent any
	environment {
		DOCKERHUB_CREDENTIALS=credentials('docker_hub')
		BRANCH_NAME="${GIT_BRANCH.split('/')[1]}"
		DOCKER_COMPOSE_FOLDER="${BRANCH_NAME == "production" ? "/home/agenttool/docker/agenttool" : "/home/ta/docker/demo"}"
        SSH_HOST="s.teeaitech.com"
		SSH_USER="ta"
	}
	stages {
		stage('Build') {
			steps {
				echo "${BRANCH_NAME}"
				sh 'docker build -f Dockerfile.${BRANCH_NAME} --build-arg BE_URI=${BE_URI} -t lehuyquanganh/teeaitech:${BRANCH_NAME} .'
			}
		}

		stage('Login') {
			steps {
				sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
			}
		}

		stage('Push') {
			steps {
				sh 'docker push lehuyquanganh/teeaitech:${BRANCH_NAME}'
			}
		}

		stage('Deploy') {
			steps {
				sshagent(credentials: ['sshkey']) {
            sh '''
                [ -d ~/.ssh ] || mkdir ~/.ssh && chmod 0700 ~/.ssh
                ssh-keyscan -t rsa,dsa ${SSH_HOST} >> ~/.ssh/known_hosts
				whoami
                ssh -t ${SSH_USER}@${SSH_HOST} "cd ${DOCKER_COMPOSE_FOLDER} && docker compose pull && docker compose up -d --build"
            '''
				}
			}
		}
	}

	post {
		always {
			sh 'docker logout'
		}
	}

}