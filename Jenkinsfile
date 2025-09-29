pipeline {
    agent any // 어떤 Jenkins 에이전트에서든 실행

    stages {
        stage('Prepare'){
            steps {
                // 이 단계에서는 빌드에 필요한 도구 설치나 환경 설정 등을 수행합니다.
                // 예: sh 'npm install'
                echo 'Preparation stage (Code is already checked out)'
                cleanWs()
            }
        }
        stage('Build and Deploy with Docker Compose') {
            steps {
                echo "Building and deploying the entire stack with Docker Compose..."
                // 이전 Docker Compose 스택을 깔끔하게 정리하고 중지합니다. (권장)
                sh 'docker-compose down'

                // docker-compose.yml을 사용하여 전체 스택을 실행합니다.
                // --build : myapp 서비스의 소스코드가 변경되었으면 이미지를 다시 빌드합니다.
                // -d : 백그라운드에서 실행합니다.
                sh 'docker-compose up --build -d'
            }
        }
    }
    post {
        always {
            // 실행 중인 서비스 목록을 로그에 출력하여 확인
            sh 'docker-compose ps'
            echo "Pipeline finished. Deployed stack with Docker Compose! 🚀"
        }
    }
}
