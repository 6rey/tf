pipeline {
    agent any
    tools {
        terraform 'terraform'
    }

    stages {
        stage('Git Checkout terraform') {
            agent { 
                label 'master' 
            }
            steps {
                    
                    git branch: 'main', credentialsId: 'jenkins-token', url: 'https://github.com/6rey/tf.git'
            }
        }
        stage('Terraform Init Env, Build and Test instance') {
            agent { 
                label 'master' 
            }
            steps {
                sh 'terraform init'
            }
            
        }
        stage('Terraform Plan Env, Build and Test instance') {
            agent { 
                label 'master' 
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-ec2', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) 
                {
                sh 'terraform plan'
                }
            }
        }
        stage('Terraform Apply Env, Build and Test instance') {
            agent { 
                label 'master' 
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-ec2', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) 
                {
                sh 'terraform apply --auto-approve'
                }
            }
        }
        
        stage('Git Checkout java project') {
            agent { 
                label 'agent-jar' 
            }
                steps {
                    git branch: 'master', credentialsId: 'jenkins-token', url: 'https://github.com/6rey/java-simple-app.git'
                }
        }
        stage('Build app') {
            agent { 
                label 'agent-jar' 
            }
                steps {
                    sh './build.sh'
                }
        }
        stage('Run app') {
            agent { 
                label 'agent-jar' 
            }
                steps {
                    sh './run.sh'
                }
        }
        stage ("wait_for_start_app"){
            agent { 
                label 'agent-jar' 
            }
            
            steps {    
                echo 'Waiting 15 seconds for start application'
                sh 'sleep 15'
            }
        }    
        stage('Test runing app') {
            agent { 
                label 'agent-jar' 
            }
                steps {
                    script{

                        cmd = """
                            curl -s -o /dev/null -w "%{http_code}\n" 'http://localhost/SampleServlet/' 
                            """

                        status_code = sh(script: cmd, returnStdout: true).trim()
                        // must call trim() to remove the default trailing newline
                  
                        echo "HTTP response status code: ${status_code}"
                        echo "Everything is ok"

                        if (status_code != "200") {
                        error('URL status different of 200. Exiting script.')
                    } 
                }
            }
        }
        stage('Push docker image to DockerHub') {
            agent { 
                label 'agent-jar' 
            }
            steps{
                withDockerRegistry(credentialsId: 'dockerhub-cred-6rey', url: 'https://index.docker.io/v1/') {
                    sh '''
                        docker push 6rey/java_app:ver01
                    '''
                }
            }
        }
        stage ("Wait befor destroy Build instance"){
            agent { 
                label 'master' 
            }
            
            steps {    
                echo 'Waiting 10 seconds befor_destory instance'
                sh 'sleep 10'
            }
        }
        stage('Terraform Destroy Build instance') {
            agent { 
                label 'master' 
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-ec2', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) 
                    {
                        sh 'terraform destroy --auto-approve'
                    }
            }
        }
        stage('Terraform Init Production instance') {
            agent { 
                label 'master' 
            }
            steps {
                dir('prod'){
                  sh 'terraform init'
                }  
            }
            
        }
        stage('Terraform Plan Production instance') {
            agent { 
                label 'master' 
            }
            steps {
                dir('prod'){
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-ec2', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) 
                    {
                        sh 'terraform plan'
                    }
                }    
            }
        }
        stage('Terraform Apply Production instance') {
            agent { 
                label 'master' 
            }
            steps {
                dir('prod'){
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-ec2', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) 
                    {
                        sh 'terraform apply --auto-approve'
                    }
                }    
            }
        }
        
        stage('Pull docker image to DockerHub') {
            agent { 
                label 'prodsrv' 
            }
            steps{
                withDockerRegistry(credentialsId: 'dockerhub-cred-6rey', url: 'https://index.docker.io/v1/') {
                    sh '''
                        docker image pull 6rey/java_app:ver01
                        docker run -p 80:8080 -td 6rey/java_app:ver01
                    '''
                }
            }
        }
        stage ("Waiting befor instance destroy"){
            agent { 
                label 'master' 
            }
            
            steps {    
                echo 'Waiting 60 seconds befor_destory instance'
                sh 'sleep 60'
            }
        }
        stage('Terraform Destroy') {
            agent { 
                label 'master' 
            }
            steps {
                dir('prod'){
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-ec2', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) 
                    {
                        sh 'terraform destroy --auto-approve'
                    }
                }    
            }
        }
    }    
}
