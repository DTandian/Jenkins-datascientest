pipeline {
    environment {
        DOCKER_ID = "tandiand"
        DOCKER_IMAGE = "datascientestapi"
        DOCKER_TAG = "v.${BUILD_ID}.0"
    }
    agent any
    stages {
        stage('Docker Build') {
            steps {
                script {
                    // Build Docker image
                    sh '''
                    docker rm -f jenkins
                    docker build -t $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG .
                    sleep 6
                    '''
                }
            }
        }
        stage('Docker run') {
            steps {
                script {
                    // Run Docker container
                    sh '''
                    docker run -d -p 80:80 --name jenkins $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG
                    sleep 10
                    '''
                }
            }
        }
        stage('Test Acceptance') {
            steps {
                script {
                    // Test the deployed application
                    sh '''
                    curl localhost
                    '''
                }
            }
        }
        stage('Docker Push') {
            environment {
                DOCKER_PASS = credentials("DOCKER_HUB_PASS")
            }
            steps {
                script {
                    // Push Docker image to Docker Hub
                    sh '''
                    docker login -u $DOCKER_ID -p $DOCKER_PASS
                    docker push $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG
                    '''
                }
            }
        }
        stage('Deploiement en dev') {
            steps {
                script {
                    // Create a temporary directory within the Jenkins workspace
                    def tempDir = pwd()
                    dir(tempDir) {
                        // Copy the Kubernetes configuration file from Jenkins credentials
                        sh "cp ${credentials("config_kub")} kubeconfig"

                        // Modify values.yaml file with Docker tag
                        sh "cp fastapi/values.yaml values.yml"
                        sh "sed -i \"s+tag.*+tag: ${DOCKER_TAG}+g\" values.yml"

                        // Set KUBECONFIG environment variable to the temporary directory path
                        env.KUBECONFIG = "${tempDir}/kubeconfig"

                        // Upgrade Helm chart in the dev namespace
                        sh "helm upgrade --install app fastapi --values=values.yml --namespace dev"
                    }
                }
            }
        }
        stage('Deploiement en staging') {
            steps {
                script {
                    // Create a temporary directory within the Jenkins workspace
                    def tempDir = pwd()
                    dir(tempDir) {
                        // Copy the Kubernetes configuration file from Jenkins credentials
                        sh "cp ${credentials("config_kub")} kubeconfig"

                        // Modify values.yaml file with Docker tag
                        sh "cp fastapi/values.yaml values.yml"
                        sh "sed -i \"s+tag.*+tag: ${DOCKER_TAG}+g\" values.yml"

                        // Set KUBECONFIG environment variable to the temporary directory path
                        env.KUBECONFIG = "${tempDir}/kubeconfig"

                        // Upgrade Helm chart in the staging namespace
                        sh "helm upgrade --install app fastapi --values=values.yml --namespace staging"
                    }
                }
            }
        }
        stage('Deploiement en prod') {
            steps {
                script {
                    timeout(time: 15, unit: "MINUTES") {
                        input message: 'Do you want to deploy in production ?', ok: 'Yes'
                    }

                    // Create a temporary directory within the Jenkins workspace
                    def tempDir = pwd()
                    dir(tempDir) {
                        // Copy the Kubernetes configuration file from Jenkins credentials
                        sh "cp ${credentials("config_kub")} kubeconfig"

                        // Modify values.yaml file with Docker tag
                        sh "cp fastapi/values.yaml values.yml"
                        sh "sed -i \"s+tag.*+tag: ${DOCKER_TAG}+g\" values.yml"

                        // Set KUBECONFIG environment variable to the temporary directory path
                        env.KUBECONFIG = "${tempDir}/kubeconfig"

                        // Upgrade Helm chart in the prod namespace
                        sh "helm upgrade --install app fastapi --values=values.yml --namespace prod"
                    }
                }
            }
        }
    }
}
