pipeline {
    agent any
     environment {
        ACCESSTOKEN = 'vveeo'
        DOCKER_IMAGE = "ddrench/k8"
        DOCKER_TAG_FRONT_END = "frontend_v2" // or use a variable like "${env.BUILD_NUMBER}" for unique tagging
        DOCKER_TAG_BACK_END = "backend_v2" // or use a variable like "${env.BUILD_NUMBER}" for unique tagging
        DOCKER_REGISTRY = "registry.hub.docker.com"
        DOCKER_CREDENTIALS_ID = "dockerHub"
        FRONT_END_IMAGE_NAME = "frontend"
        BACK_END_IMAGE_NAME = "backend"
        MS_HOST = 'http://3.6.145.178:8000/'
    }

    stages {
        stage('front end docker build') {
            steps {
            dir('/var/jenkins_home/workspace/k8-cluster-setup/frontend/') {
                
                 sh 'pwd'
                 sh 'ls'
                 sh 'docker build --build-arg ACCESSTOKEN=${ACCESSTOKEN} --build-arg MS_HOST=${MS_HOST} -t ${DOCKER_IMAGE}:${DOCKER_TAG_FRONT_END} .'
            }
                
            }
        }
        stage('Back end docker build') {
            steps {
            dir('/var/jenkins_home/workspace/k8-cluster-setup/backend/') {
                
                 sh 'pwd'
                 sh 'ls'
                 sh 'docker build --build-arg ACCESSTOKEN=${ACCESSTOKEN} -t ${DOCKER_IMAGE}:${DOCKER_TAG_BACK_END} .'
            }
                
            }
        }
        stage('Push Docker front end Image') {
            steps {
                script {
                    // Log in to the Docker registry
                    docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                       
                        // Push the Docker image
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG_FRONT_END}").push()
                    }
                }
            }
        }
        stage('Push Docker Back end Image') {
            steps {
                script {
                    // Log in to the Docker registry
                    docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                        // Push the Docker image
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG_BACK_END}").push()
                    }
                }
            }
        }
    }
}


