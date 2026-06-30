// Assignment 1 — Jenkins + GitHub + Docker Hub
// Jenkins credential ID: dockerhub-credentials (Username with password = Docker Hub token)
pipeline {
    agent any

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }

    environment {
        IMAGE_BASENAME = 'assignment-1-app'
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
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'HUB_USER',
                    passwordVariable: 'HUB_TOKEN'
                )]) {
                    script {
                        if (isUnix()) {
                            sh """
                                set -e
                                echo \${HUB_TOKEN} | docker login -u \${HUB_USER} --password-stdin
                                docker build -t \${HUB_USER}/\${IMAGE_BASENAME}:${env.BUILD_NUMBER} -t \${HUB_USER}/\${IMAGE_BASENAME}:latest .
                                docker push \${HUB_USER}/\${IMAGE_BASENAME}:${env.BUILD_NUMBER}
                                docker push \${HUB_USER}/\${IMAGE_BASENAME}:latest
                            """
                        } else {
                            bat """
                                echo %HUB_TOKEN%| docker login -u %HUB_USER% --password-stdin
                                docker build -t %HUB_USER%/%IMAGE_BASENAME%:${env.BUILD_NUMBER} -t %HUB_USER%/%IMAGE_BASENAME%:latest .
                                docker push %HUB_USER%/%IMAGE_BASENAME%:${env.BUILD_NUMBER}
                                docker push %HUB_USER%/%IMAGE_BASENAME%:latest
                            """
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
