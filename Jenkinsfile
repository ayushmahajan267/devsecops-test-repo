pipeline {
  agent any

  environment {
    SONAR_LOG = 'sonar.log'
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
              -Dsonar.sources=. | tee ${SONAR_LOG}
            """
          }
        }
      }
    }

    stage('SonarQube Quality Gate (Observable)') {
      steps {
        script {
          echo "🔍 Waiting for SonarQube Quality Gate with visibility..."

          sh '''
            TASK_ID=$(grep -o "task?id=[A-Za-z0-9_-]*" sonar.log | cut -d= -f2 | tail -1)

            if [ -z "$TASK_ID" ]; then
              echo "❌ Could not find SonarQube task ID in logs"
              exit 1
            fi

            echo "✅ SonarQube Task ID: $TASK_ID"

            for i in {1..20}; do
              STATUS=$(curl -s -u $SONAR_AUTH_TOKEN: \
                "$SONAR_HOST_URL/api/ce/task?id=$TASK_ID" | jq -r '.task.status')

              echo "Attempt $i → Sonar task status: $STATUS"

              if [ "$STATUS" = "SUCCESS" ]; then
                echo "✅ SonarQube background processing completed"
                exit 0
              fi

              if [ "$STATUS" = "FAILED" ]; then
                echo "❌ SonarQube background task FAILED"
                exit 1
              fi

              sleep 30
            done

            echo "⏳ SonarQube task still running after polling — infra is slow"
            exit 1
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
            --ignore-unfixed \
            --exit-code 1 \
            devsecops-test:latest
        '''
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: '*.log', allowEmptyArchive: true
    }
  }
}
