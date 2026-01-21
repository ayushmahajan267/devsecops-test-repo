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
          sh '''
            sonar-scanner \
              -Dsonar.projectKey=devsecops-test \
              -Dsonar.sources=. \
              -Dsonar.host.url=http://localhost:9000
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
        sh 'trivy image devsecops-test:latest'
      }
    }
  }
}
