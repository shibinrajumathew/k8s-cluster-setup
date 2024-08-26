pipeline {
    agent any
    
    stages {
        stage('Stop and Clean Containers') {
            steps {
                script {
                    sh 'docker stop frontend backend'
                    sh 'docker container prune -a -f'
                    sh 'docker image prune -a -f'
                    sh 'docker network prune -a -f'
                }
            }
        }
        
        stage('Create Network') {
            steps {
                script {
                    sh 'docker network create k8-docker-network'
                }
            }
        }
        
        stage('Pull Docker Images') {
            steps {
                script {
                    sh 'docker pull ddrench/k8:backend_v2'
                    sh 'docker pull ddrench/k8:frontend_v2'
                }
            }
        }
        
        stage('Run Docker Containers') {
            steps {
                script {
                    sh 'docker run -d -p 80:3000 --name frontend --network k8-docker-network ddrench/k8:frontend_v2'
                    sh 'docker run -d -p 8000:8000 --network k8-docker-network --name backend ddrench/k8:backend_v2'
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
