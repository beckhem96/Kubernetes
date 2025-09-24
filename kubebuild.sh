./gradlew clean build

#docker build -t myapp:latest .
# Deployment 생성
#kubectl apply -f k8s/deployment.yaml

# Service 생성
#kubectl apply -f k8s/service.yaml
# 배포 상태 확인
#kubectl get deployments
#kubectl get pods
#kubectl get services

eval $(minikube docker-env)
docker build -t myapp:latest .

# Deployment와 Service 배포
#kubectl apply -f k8s/deployment.yaml
#kubectl apply -f k8s/service.yaml

kubectl rollout restart deployment myapp-deployment

# 배포 상태 확인
kubectl get all