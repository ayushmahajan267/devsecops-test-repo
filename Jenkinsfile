pipeline {
  agent any

  stages {

    stage('Unit Tests') {
      steps {
        sh 'python3 app.py'
      }
    }

    stage('SonarQube SAST') {
      steps {
        withSonarQubeEnv('SonarQube') {
          script {
            def scannerHome = tool 'SonarScanner'
            sh """
            ${scannerHome}/bin/sonar-scanner \
            -Dsonar.projectKey=devsecops-test \
            -Dsonar.sources=.
            """
          }
        }
      }
    }


    stage('Docker Build') {
      steps {
        sh 'docker build -t devsecops-test .'
      }
    }

    stage('Trivy Image Scan') {
      steps {
        sh 'trivy image devsecops-test'
      }
    }
  }
}
