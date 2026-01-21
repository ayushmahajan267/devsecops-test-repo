pipeline {
  agent any

  options {
    timestamps()
  }

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

    stage('SonarQube Quality Gate') {
      steps {
        echo "⏳ Waiting for SonarQube Quality Gate result..."
        timeout(time: 10, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('OWASP Dependency Check (SCA)') {
      steps {
        sh '''
          dependency-check \
            --project "devsecops-test" \
            --scan app.py \
            --format HTML \
            --out dependency-check-report \
            --noupdate
        '''
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

  post {
    always {
      archiveArtifacts artifacts: 'dependency-check-report/*.html', allowEmptyArchive: true
      echo "✅ Pipeline execution completed."
    }
  }
}
