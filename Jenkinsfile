pipeline {
  agent any

  stages {

    stage('Checkout') {
      steps {
        git branch: 'main',
        url: 'https://github.com/ayushmahajan267/devsecops-test-repo.git'
      }
    }

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
        sh 'docker build -t devsecops-test:latest .'
      }
    }

    stage('Trivy Image Scan') {
      steps {
        sh '''
          trivy image \
            --severity HIGH,CRITICAL \
            --ignore-unfixed \
            --exit-code 1 \
            devsecops-test:latest
        '''
      }
    }
    
  }
}
