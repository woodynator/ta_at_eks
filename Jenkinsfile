pipeline {
   parameters {
        choice(name: 'action', choices: 'create\ndestroy', description: 'Create/update or destroy the k8s cluster.')
        string(name: 'cluster', defaultValue : 'jm-ta-eks', description: "cluster name.")
        string(name: 'credential', defaultValue : 'aws2', description: "Jenkins credential that provides the AWS access key and secret.")

   }

  options {
    disableConcurrentBuilds()
    timeout(time: 1, unit: 'HOURS')
    withAWS(credentials: params.credential,)

  }

  agent any

  environment { 
    PATH = "${env.WORKSPACE}/bin:${env.PATH}"
    KUBECONFIG = "${env.WORKSPACE}/.kube/config"
  }

  tools {
    terraform 'tf'
  }

  stages {

    stage('Setup') {
      steps {
        script {
        //   currentBuild.displayName = "#" + env.BUILD_NUMBER + " " + params.action + " " + params.cluster
          plan = params.cluster + '.plan'

           println "Downloading the kubectl and helm binaries..."
          //  (major, minor) = params.k8s_version.split(/\./)
          //  sh """
          //    [ ! -d bin ] && mkdir bin
          //    ( cd bin
          //    curl --silent -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl
          //    curl -fsSL -o - https://get.helm.sh/helm-v3.8.0-linux-amd64.tar.gz | tar -xzf - linux-amd64/helm
          //    mv linux-amd64/helm .
          //    rm -rf linux-amd64
          //    chmod u+x kubectl helm
          //    ls -l kubectl helm )
          //  """
        }
      }
    }

 
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
                    input "Create or Update EKS cluster ${params.cluster} in AWS?" 

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
                    input "Destroy EKS cluster ${params.cluster} in AWS?" 

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