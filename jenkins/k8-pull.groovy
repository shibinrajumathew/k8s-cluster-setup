pipeline {
    agent any

    stages {
        stage('Pull new code') {
            steps {
               checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[ url: 'https://github.com/shibinrajumathew/k8s-cluster-setup.git']])
            }
        }
    }
}
