pipeline {
   parameters {
        choice(name: 'action', choices: 'create\ndestroy', description: 'Create/update or destroy the k8s cluster.')
        string(name: 'cluster', defaultValue : 'jm-ta-eks', description: "cluster name.")
        string(name: 'credential', defaultValue : 'aws2', description: "Jenkins credential that provides the AWS access key and secret.")

   }

  options {
    disableConcurrentBuilds()
    timeout(time: 1, unit: 'HOURS')
  }

  agent any

  environment {
    PATH = "${env.WORKSPACE}/bin:${env.PATH}"
  }

  tools {
    terraform 'tf'
  }

  stages {

        stage('tf init plan') {
            when {
                expression { params.action == 'create' }
            }
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: params.credential, 
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',  
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                        sh """
                            terraform init
                            terraform plan -no-color -out ${plan}

                        """
                    }
                }
            }
        }
 
        stage('terraform Apply') {
            when {
                expression { params.action == 'create' }
            }
 
            steps {
                script {
                    // def tfHome = tool name: 'terraform'
                    // env.PATH = "${tfHome}:${env.PATH}"
                    input "Create/update Terraform stack ${params.cluster} in aws?" 

                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: params.credential, 
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',  
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    sh """
                        terraform apply -no-color -input=false -auto-approve ${plan}
                       """
                    }
                }
            }
            
        }

        stage('terraform Destroy') {
            when {
                expression { params.action == 'destroy' }
            }
 
            steps {
                script {
                    // def tfHome = tool name: 'terraform'
                    // env.PATH = "${tfHome}:${env.PATH}"
                    input "Destroy Terraform stack ${params.cluster} in aws?" 

                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: params.credential, 
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',  
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    sh """
                        terraform destroy -no-color -input=false -auto-approve
                       """
                    }
                }
            }
            
        }
      
    }
}