pipeline {
    agent any // 어떤 Jenkins 에이전트에서든 실행

    stages {
        stage('Prepare'){
            steps {
                // 이 단계에서는 빌드에 필요한 도구 설치나 환경 설정 등을 수행합니다.
                // 예: sh 'npm install'
                echo 'Preparation stage (Code is already checked out)'
            }
        }
        stage('Test') {
            steps {
                // 예: sh './gradlew test'
                echo 'Test stage'
            }
        }
        stage('Build') {
            steps {
                // 예: sh './gradlew build'
                echo 'Build stage'
            }
        }
        // ... 이하 Docker 빌드 등 다른 단계들
    }
}
