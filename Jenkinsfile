pipeline {
  agent any

  stages {

    stage('Checkout') {
      steps {
        git 'https://github.com/ayushmahajan267/devsecops-test-repo.git'
      }
    }

    stage('Unit Test') {
      steps {
        sh 'python app.py'
      }
    }

    stage('SonarQube SAST') {
      steps {
        withSonarQubeEnv('SonarQube') {
          sh '''
          sonar-scanner \
            -Dsonar.projectKey=devsecops-test \
            -Dsonar.sources=.
          '''
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
          --exit-code 0 \
          devsecops-test:latest
        '''
      }
    }
  }
}
