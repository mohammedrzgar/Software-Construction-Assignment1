// Assignment 1 — Jenkins + GitHub + Docker Hub
// Jenkins credential ID: dockerhub-credentials (Username with password = Docker Hub token)
// Fallback: JENKINS_HOME/secrets/dockerhub-token.txt (local Jenkins only, not in git)

def dockerBuildAndPush(String hubUser, String hubToken) {
    if (isUnix()) {
        sh """
            set -e
            echo ${hubToken} | docker login -u ${hubUser} --password-stdin
            docker build -t ${hubUser}/${env.IMAGE_BASENAME}:${env.BUILD_NUMBER} -t ${hubUser}/${env.IMAGE_BASENAME}:latest .
            docker push ${hubUser}/${env.IMAGE_BASENAME}:${env.BUILD_NUMBER}
            docker push ${hubUser}/${env.IMAGE_BASENAME}:latest
        """
    } else {
        bat """
            echo ${hubToken}| docker login -u ${hubUser} --password-stdin
            docker build -t ${hubUser}/${env.IMAGE_BASENAME}:${env.BUILD_NUMBER} -t ${hubUser}/${env.IMAGE_BASENAME}:latest .
            docker push ${hubUser}/${env.IMAGE_BASENAME}:${env.BUILD_NUMBER}
            docker push ${hubUser}/${env.IMAGE_BASENAME}:latest
        """
    }
}

pipeline {    agent any

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }

    environment {
        IMAGE_BASENAME = 'assignment-1-app'
        // Jenkins Windows service does not inherit your user PATH — add Python + Docker explicitly
        PATH = "C:\\Users\\mohammed\\AppData\\Local\\Programs\\Python\\Python312;C:\\Users\\mohammed\\AppData\\Local\\Programs\\Python\\Python312\\Scripts;C:\\Program Files\\Docker\\Docker\\resources\\bin;${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Build #${env.BUILD_NUMBER} — ${env.JOB_NAME}"
                checkout scm
            }
        }

        stage('Install and test') {
            steps {
                script {
                    if (isUnix()) {
                        sh '''
                            set -e
                            python3 -m venv .venv
                            . .venv/bin/activate
                            pip install -r requirements.txt
                            python -m pytest -v --cov=app --cov-report=term-missing tests/
                        '''
                    } else {
                        bat '''
                            python -m venv .venv
                            call .venv\\Scripts\\activate.bat
                            pip install -r requirements.txt
                            python -m pytest -v --cov=app --cov-report=term-missing tests/
                        '''
                    }
                }
            }
        }

        stage('Build and push image') {
            steps {
                script {
                    def tokenFile = "${env.JENKINS_HOME}/secrets/dockerhub-token.txt"
                    if (fileExists(tokenFile)) {
                        def hubUser = 'kakahama'
                        def hubToken = readFile(tokenFile).trim()
                        dockerBuildAndPush(hubUser, hubToken)
                    } else {
                        withCredentials([usernamePassword(
                            credentialsId: 'dockerhub-credentials',
                            usernameVariable: 'HUB_USER',
                            passwordVariable: 'HUB_TOKEN'
                        )]) {
                            dockerBuildAndPush(env.HUB_USER, env.HUB_TOKEN)
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                if (isUnix()) {
                    sh 'docker logout || true'
                    sh 'rm -rf .venv || true'
                } else {
                    bat 'docker logout 2>nul || exit /b 0'
                    bat 'if exist .venv rmdir /s /q .venv'
                }
            }
        }
        success {
            echo 'Pipeline finished. Image tags: BUILD_NUMBER and latest on Docker Hub.'
        }
    }
}
