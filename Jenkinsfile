pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "us-east-1"
        REPOSITORY_URI = "426353511441.dkr.ecr.us-east-1.amazonaws.com/node-repo"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    tools {
        nodejs 'node18'
        jdk 'jdk17'
    }

    stages {
        stage ('Checkout Code'){
            steps {
                checkout scm
            }
        }
        stage ('SonarCloud Scan') {
            steps {
                withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 
                'SONAR_TOKEN')]) {
                    sh '''
                    docker run --rm \
                    -e SONAR_TOKEN=$SONAR_TOKEN \
                    -v $(pwd):/usr/src \
                    sonarsource/sonar-scanner-cli \
                    -Dsonar.projecKey=Jefferson-org_node_project \
                    -Dsonar.organization=Jefferson-org \
                    -Dsonar.sources=. \
                    -Dsonar.host.url=https://sonarcloud.io
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Sonarcloud analysis successful'
            echo 'Build and Docker image push sucessful'
            echo "Pushed Image: $REPOSITORY_URI:$IMAGE_TAG"
        failure {
            echo 'Build failed. Check logs above'
        }
        }
    }
}