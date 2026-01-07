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
                    -Dsonar.projectKey=mr-jefferson-orgs_node_project \
                    -Dsonar.organization=mr-jefferson-orgs \
                    -Dsonar.sources=. \
                    -Dsonar.host.url=https://sonarcloud.io
                    '''
                }
            }
        }

        stage ('Login to ECR'){
            steps {
                withCredentials([aws(credentialsId: 'AWS-ECR-CRED', accessKeyVariable: 
                'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        aws ecr get-login-password --region $AWS_DEFAULT_REGION \
                        | docker login --username AWS --password-stdin $REPOSITORY_URI
                    '''
                }
            }
        }

        stage ('Build Docker Image') {
            steps{
                sh '''
                    docker build -t my-app:$IMAGE_TAG App/
                    docker tag my-app:$IMAGE_TAG $REPOSITORY_URI:$IMAGE_TAG
                '''
            }
        }

        stage ('PUSH to ECR'){
            steps {
                sh '''
                docker push $REPOSITORY_URI:$IMAGE_TAG
                '''
            }
        }

        stage ('Deploy to kubernetes'){
            steps {
                withCredentials([file(credentialsId: 'KUBECONFIG_DEVOPS', 
                variable: 'KUBECONFIG'), aws(credentialsId: 'AWS-ECR-CRED',
                accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                      export KUBECONFIG=$KUBECONFIG
                      export AWS_DEFAULT_REGION=us-east-1

                      echo "installing prometheus monitor ..."
                      helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
                      helm repo update
                      helm upgrade --install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

                      echo "updating image tag in deployment.yaml ..."
                      sed -i "s|ECR_URI:latest|${REPOSITORY_URI}:${IMAGE_TAG}|g" K8s/deployment.yaml

                      echo "Applying kubernetes manifests ..."
                      kubectl apply -f K8s/

                      echo "verifying rollout ..."
                      kubectl rollout status deployment/node-app
                    '''
                }
            }
        }
   
    }

    post {
        success {
            echo 'Sonarcloud analysis successful'
            echo 'Build and Docker Image push successful'
            echo "Push Image: $REPOSITORY_URI:$IMAGE_TAG"
            echo "Kubernetes Deployment Successful"
        }
        failure {
            echo 'Build failed. Check logs above'
        }
    }
}