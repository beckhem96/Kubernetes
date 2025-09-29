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
        stage('Build and Run Docker Container') {
            steps {
                echo "Building Docker image..."
                // Dockerfile이 있는 프로젝트 폴더로 이동할 필요 없이,
                // Jenkins가 git clone한 경로에서 바로 빌드
                // docker.build()는 현재 작업 공간의 Dockerfile을 사용
                script {
                    def customImage = docker.build("myapp:latest")

                    echo "Stopping and removing old container..."
                    // sh 스텝을 사용하여 docker 명령을 로컬 셸에서 직접 실행
                    // || true : 컨테이너가 없어서 실패해도 파이프라인이 멈추지 않음
                    sh "docker stop myapp || true"
                    sh "docker rm myapp || true"

                    echo "Running new container..."
                    // 빌드된 이미지를 사용하여 새 컨테이너를 실행
                    customImage.run("-d --name myapp -p 8080:8080")
                }
            }
        }
    }
    post {
        always {
            echo "Pipeline finished. good 포트추가해서 다시, docker pipeline 설치해서 다시"
        }
    }
}
