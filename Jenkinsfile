// Software Construction – Assignment 1. Jenkins: add credential
//   Kind: Username with password
//   ID: dockerhub-credentials
//   (Docker Hub user + access token)
pipeline {
    agent any

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }

    environment {
        // Docker image: <username>/assignment-1-app:BUILD_NUMBER
        IMAGE_BASENAME = 'assignment-1-app'
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Build ${env.BUILD_NUMBER} from SCM"
            }
        }

        stage('Install and test') {
            steps {
                sh """
                    set -e
                    python3 -m venv .venv
                    . .venv/bin/activate
                    pip install -r requirements.txt
                    python -m pytest -v --cov=app --cov-report=term-missing tests/
                """
            }
        }

        stage('Build and push image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'HUB_USER',
                    passwordVariable: 'HUB_TOKEN'
                )]) {
                    sh """
                        set -e
                        echo \${HUB_TOKEN} | docker login -u \${HUB_USER} --password-stdin
                        docker build -t \${HUB_USER}/\${IMAGE_BASENAME}:${env.BUILD_NUMBER} -t \${HUB_USER}/\${IMAGE_BASENAME}:latest .
                        docker push \${HUB_USER}/\${IMAGE_BASENAME}:${env.BUILD_NUMBER}
                        docker push \${HUB_USER}/\${IMAGE_BASENAME}:latest
                    """
                }
            }
        }
    }

    post {
        always {
            sh "docker logout || true"
            sh "rm -rf .venv || true"
        }
        success {
            echo "Pipeline success: see Docker Hub for the pushed tags."
        }
    }
}
