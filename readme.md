● Kubernetes 샘플 코드가 완성되었습니다.

생성된 구조

k8s/                                                                                                                                                                                                                              
├── base/                           # 공통 리소스                                                                                                                                                                                 
│   ├── kustomization.yaml                                                                                                                                                                                                        
│   ├── namespace.yaml                                                                                                                                                                                                            
│   ├── app/                                                                                                                                                                                                                      
│   │   ├── deployment.yaml         # 애플리케이션 배포                                                                                                                                                                           
│   │   ├── service.yaml            # 서비스                                                                                                                                                                                      
│   │   ├── configmap.yaml          # 환경 설정                                                                                                                                                                                   
│   │   └── hpa.yaml                # 오토스케일링                                                                                                                                                                                
│   ├── kafka/                                                                                                                                                                                                                    
│   │   ├── zookeeper.yaml          # Zookeeper StatefulSet                                                                                                                                                                       
│   │   └── kafka.yaml              # Kafka StatefulSet                                                                                                                                                                           
│   ├── elk/                                                                                                                                                                                                                      
│   │   ├── elasticsearch.yaml      # Elasticsearch StatefulSet                                                                                                                                                                   
│   │   ├── logstash.yaml           # Logstash (Kafka→ES 파이프라인)                                                                                                                                                              
│   │   └── kibana.yaml             # Kibana 대시보드                                                                                                                                                                             
│   └── redis/                                                                                                                                                                                                                    
│       └── redis.yaml              # Redis StatefulSet                                                                                                                                                                           
├── overlays/                                                                                                                                                                                                                     
│   ├── dev/                        # 개발 환경                                                                                                                                                                                   
│   │   ├── kustomization.yaml                                                                                                                                                                                                    
│   │   ├── namespace.yaml          # myapp-dev 네임스페이스                                                                                                                                                                      
│   │   ├── ingress.yaml            # dev.myapp.local                                                                                                                                                                             
│   │   └── patches/                # 리소스 축소, DEBUG 로깅                                                                                                                                                                     
│   └── prod/                       # 상용 환경                                                                                                                                                                                   
│       ├── kustomization.yaml                                                                                                                                                                                                    
│       ├── namespace.yaml          # myapp-prod 네임스페이스                                                                                                                                                                     
│       ├── ingress.yaml            # TLS, myapp.example.com                                                                                                                                                                      
│       ├── pdb.yaml                # Pod Disruption Budget                                                                                                                                                                       
│       └── patches/                # 리소스 확대, 레플리카 증가

사용 방법

## 개발 환경 배포
./deploy.sh dev apply

## 상용 환경 배포
./deploy.sh prod apply

## 미리보기 (dry-run)
./deploy.sh dev dry-run

## 삭제
./deploy.sh dev delete

또는 kubectl 직접 사용:                                                                                                                                                                                                           
kubectl apply -k k8s/overlays/dev   # 개발 환경                                                                                                                                                                                   
kubectl apply -k k8s/overlays/prod  # 상용 환경

환경별 차이점                                                                                                                                                                                                                     
┌────────────────┬───────────┬─────────────┐                                                                                                                                                                                      
│      항목      │    Dev    │    Prod     │                                                                                                                                                                                      
├────────────────┼───────────┼─────────────┤                                                                                                                                                                                      
│ 네임스페이스   │ myapp-dev │ myapp-prod  │                                                                                                                                                                                      
├────────────────┼───────────┼─────────────┤                                                                                                                                                                                      
│ App 레플리카   │ 1         │ 3           │                                                                                                                                                                                      
├────────────────┼───────────┼─────────────┤                                                                                                                                                                                      
│ Kafka 레플리카 │ 1         │ 3           │                                                                                                                                                                                      
├────────────────┼───────────┼─────────────┤                                                                                                                                                                                      
│ 로깅 레벨      │ DEBUG     │ WARN        │                                                                                                                                                                                      
├────────────────┼───────────┼─────────────┤                                                                                                                                                                                      
│ 리소스         │ 최소화    │ 충분히 할당 │                                                                                                                                                                                      
├────────────────┼───────────┼─────────────┤                                                                                                                                                                                      
│ TLS            │ 없음      │ 있음        │                                                                                                                                                                                      
├────────────────┼───────────┼─────────────┤                                                                                                                                                                                      
│ PDB            │ 없음      │ 있음        │                                                                                                                                                                                      
└────────────────┴───────────┴─────────────┘                                                                                                                                                                                      
추가된 의존성 (build.gradle)

- Spring Kafka
- Spring Data Elasticsearch
- Spring Data Redis
- Spring Actuator (health check


1. 네임스페이스 충돌 해결

문제: base/namespace.yaml과 overlays/dev/namespace.yaml 모두 myapp-dev 네임스페이스를 생성하려고 해서 충돌 발생

해결:
- k8s/overlays/dev/kustomization.yaml - namespace.yaml 리소스 제거
- k8s/overlays/prod/kustomization.yaml - namespace.yaml 리소스 제거

base의 네임스페이스가 overlay의 namespace: myapp-dev 지시문에 의해 자동으로 변환되므로 별도의 namespace.yaml이 필요 없음

2. commonLabels 지원 중단 경고 해결

문제: commonLabels가 deprecated 됨

해결: 3개 파일에서 commonLabels를 새로운 labels 문법으로 변경                                                                                                                                                                     
┌──────────────────────────────────┬────────────────────────────────────────┬───────────────────────────────────────────┐                                                                                                         
│               파일               │                변경 전                 │                  변경 후                  │                                                                                                         
├──────────────────────────────────┼────────────────────────────────────────┼───────────────────────────────────────────┤                                                                                                         
│ base/kustomization.yaml          │ commonLabels: project: myapp           │ labels: - pairs: project: myapp           │                                                                                                         
├──────────────────────────────────┼────────────────────────────────────────┼───────────────────────────────────────────┤                                                                                                         
│ overlays/dev/kustomization.yaml  │ commonLabels: environment: development │ labels: - pairs: environment: development │                                                                                                         
├──────────────────────────────────┼────────────────────────────────────────┼───────────────────────────────────────────┤                                                                                                         
│ overlays/prod/kustomization.yaml │ commonLabels: environment: production  │ labels: - pairs: environment: production  │                                                                                                         
└──────────────────────────────────┴────────────────────────────────────────┴───────────────────────────────────────────┘  

# deploy.sh 후 
● deploy.sh는 Kubernetes(minikube)에 배포하는 스크립트입니다. Docker Compose와는 다릅니다.

동작 방식

./deploy.sh dev apply                                                                                                                                                                                                             
↓                                                                                                                                                                                                                            
kubectl apply -k k8s/overlays/dev                                                                                                                                                                                                 
↓                                                                                                                                                                                                                            
Kustomize가 base + dev overlay 병합                                                                                                                                                                                               
↓                                                                                                                                                                                                                            
minikube 클러스터에 Pod들 생성

배포되는 리소스                                                                                                                                                                                                                   
┌───────────┬─────────────────────────────────────────────────────┐                                                                                                                                                               
│ 구성 요소 │                        설명                         │                                                                                                                                                               
├───────────┼─────────────────────────────────────────────────────┤                                                                                                                                                               
│ App       │ Spring Boot 애플리케이션 (Deployment, Service, HPA) │                                                                                                                                                               
├───────────┼─────────────────────────────────────────────────────┤                                                                                                                                                               
│ Kafka     │ Zookeeper + Kafka 메시지 브로커                     │                                                                                                                                                               
├───────────┼─────────────────────────────────────────────────────┤                                                                                                                                                               
│ ELK       │ Elasticsearch, Logstash, Kibana                     │                                                                                                                                                               
├───────────┼─────────────────────────────────────────────────────┤                                                                                                                                                               
│ Redis     │ 캐시/세션 저장소                                    │                                                                                                                                                               
└───────────┴─────────────────────────────────────────────────────┘                                                                                                                                                               
Docker Compose vs Kubernetes

- Docker Compose (docker-compose.yml) → 로컬 Docker 컨테이너로 직접 실행
- Kubernetes (deploy.sh) → minikube 클러스터 안에 Pod로 실행

Docker에서 kafka, elk가 안 뜨는 이유는 이 스크립트가 Kubernetes 배포용이기 때문입니다. minikube가 실행 중이어야 하고, 배포 후에는 kubectl get pods -n myapp-dev로 확인해야 합니다.

기존 docker-compose.yml로 kafka, elk를 실행하려면:                                                                                                                                                                                
docker-compose up -d

# minikube로 띄우고 접속 방법
● minikube에서는 localhost:8080으로 바로 접속이 안 됩니다. 서비스 설정을 확인해볼게요.                                                                                                    03:48 PM  claude-opus-4-5-20251101

● Bash(kubectl get svc -n myapp-dev)                                                                                                                                                                                                
⎿  NAME                         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE                                                                                                                       
dev-elasticsearch            ClusterIP   10.105.137.138   <none>        9200/TCP,9300/TCP            5m5s                                                                                                                      
dev-elasticsearch-headless   ClusterIP   None             <none>        9200/TCP,9300/TCP            5m5s                                                                                                                      
dev-kafka                    ClusterIP   10.108.169.18    <none>        9092/TCP                     5m5s                                                                                                                      
dev-kafka-headless           ClusterIP   None             <none>        9092/TCP,9093/TCP            5m5s                                                                                                                      
dev-kibana                   ClusterIP   10.98.142.38     <none>        5601/TCP                     5m5s                                                                                                                      
dev-logstash                 ClusterIP   10.100.119.140   <none>        5044/TCP,9600/TCP            5m5s                                                                                                                      
dev-myapp-service            ClusterIP   10.109.130.199   <none>        80/TCP                       5m5s                                                                                                                      
dev-redis                    ClusterIP   10.107.121.36    <none>        6379/TCP                     5m5s                                                                                                                      
dev-redis-headless           ClusterIP   None             <none>        6379/TCP                     5m5s                                                                                                                      
dev-zookeeper                ClusterIP   10.104.10.3      <none>        2181/TCP                     5m5s                                                                                                                      
dev-zookeeper-headless       ClusterIP   None             <none>        2181/TCP,2888/TCP,3888/TCP   5m5s

● Read(k8s/overlays/dev/ingress.yaml)                                                                                                                                                                                               
⎿  Read 53 lines                                                                                                                                                                                                                  
⎿  PostToolUse:Callback hook succeeded: Success

∴ Thinking…

The services are all ClusterIP type, which means they're only accessible inside the cluster. To access them from outside, there are a few options:

1. Port-forward (simplest, no setup required)
2. Ingress (set up with host names like dev.myapp.local)
3. minikube service command

Let me explain the options to the user.

● 서비스가 모두 ClusterIP 타입이라 클러스터 외부에서 직접 접근이 안 됩니다.                                                                                                               03:48 PM  claude-opus-4-5-20251101

접속 방법 3가지

1. Port-forward (가장 간단)

kubectl port-forward svc/dev-myapp-service 8080:80 -n myapp-dev                                                                                                                                                                   
그 후 localhost:8080으로 접속 가능

2. Ingress 사용 (이미 설정됨)

## Ingress addon 활성화
minikube addons enable ingress

## /etc/hosts에 추가
echo "$(minikube ip) dev.myapp.local dev.kibana.local" | sudo tee -a /etc/hosts                                                                                                                                                   
그 후 http://dev.myapp.local로 접속

3. minikube tunnel

minikube tunnel                                                                                                                                                                                                                   
별도 터미널에서 실행 후 ClusterIP로 직접 접근 가능
                                                                                                                                                                                                                                    
---                                                                                                                                                                                                                               
빠르게 테스트하려면 1번 port-forward 추천:                                                                                                                                                                                        
kubectl port-forward svc/dev-myapp-service 8080:80 -n myapp-dev     

# myapp이랑 kafka 죽어 있었음 -> 해결

● 문제 원인

1. myapp - ErrImageNeverPull

- imagePullPolicy: Never 설정인데 minikube 안에 myapp:latest 이미지가 없음
- minikube Docker에 이미지를 빌드해야 함

2. kafka - CrashLoopBackOff

- Kafka가 zookeeper:2181로 연결 시도
- 하지만 실제 서비스 이름은 dev-zookeeper (namePrefix 때문)

● Read 1 file (ctrl+o to expand)

● 확인됐습니다. Kafka가 zookeeper:2181를 하드코딩하고 있는데, namePrefix: dev- 때문에 실제 서비스명은 dev-zookeeper입니다.

해결 방법

1. Kafka - Zookeeper 연결 수정

dev overlay에 patch 추가가 필요합니다:

● Write(k8s/overlays/dev/patches/kafka-patch.yaml)
Kafka 서비스 이름 패치 (namePrefix 반영)                                                                                                                                                                              
+  - path: patches/kafka-patch.yaml

● 2. myapp - 이미지 빌드 필요

● Searched for 1 pattern (ctrl+o to expand)

● 이미지 빌드와 재배포 명령:

## 1. minikube Docker 환경으로 전환
eval $(minikube docker-env)

## 2. 이미지 빌드
docker build -t myapp:latest .

## 3. 재배포 (Kafka 패치 적용 + myapp 재시작)
./deploy.sh dev apply

## 4. Pod 재시작 (이미지 다시 로드)
kubectl rollout restart deployment dev-myapp -n myapp-dev                                                                                                                                                                         
kubectl rollout restart statefulset dev-kafka -n myapp-dev

또는 한번에:                                                                                                                                                                                                                      
eval $(minikube docker-env) && docker build -t myapp:latest . && ./deploy.sh dev apply && kubectl rollout restart deployment dev-myapp -n myapp-dev && kubectl rollout restart statefulset dev-kafka -n myapp-dev 

# 위 설정 후 localhost:8080과 ingress 접속 방식이 에러남
● 원인 분석
● Bash(kubectl get pods -n myapp-dev | grep myapp)                                                                                                                                                                                  


● Bash(kubectl get endpoints dev-myapp-service -n myapp-dev)                                                                                                                                                                        
⎿  NAME                ENDPOINTS   AGE                                                                                                                                                                                            
dev-myapp-service               25m                                                                                                                                                                                            
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice

● Bash(kubectl describe svc dev-myapp-service -n myapp-dev)                                                                                                                                                                         
⎿  Name:                     dev-myapp-service                                                                                                                                                                                    
Namespace:                myapp-dev                                                                                                                                                                                            
Labels:                   app=myapp                                                                                                                                                                                            
… +16 lines (ctrl+o to expand)

● Bash(kubectl logs dev-myapp-67d8578d84-2j9wl -n myapp-dev --tail=50)                                                                                                                                                              
⎿     at io.netty.channel.AbstractChannel$AbstractUnsafe.access$200(AbstractChannel.java:428) ~[netty-transport-4.1.127.Final.jar!/:4.1.127.Final]                                                                                
at io.netty.channel.AbstractChannel$AbstractUnsafe$1.run(AbstractChannel.java:485) ~[netty-transport-4.1.127.Final.jar!/:4.1.127.Final]                                                                                     
at io.netty.util.concurrent.AbstractEventExecutor.runTask(AbstractEventExecutor.java:173) ~[netty-common-4.1.127.Final.jar!/:4.1.127.Final]  
로그를 보면:
1. Redis 연결 실패: [channel=... (inactive)] - lettuce Redis 클라이언트가 연결 안됨
2. Health Check 503: Redis 연결 실패로 /actuator/health → 503 반환
3. Pod 재시작: Kubernetes가 unhealthy pod를 계속 재시작

근본 원인: ConfigMap에서 서비스명이 redis, kafka, elasticsearch인데, namePrefix: dev- 때문에 실제 서비스명은 dev-redis, dev-kafka, dev-elasticsearch

해결 방법
- dev 환경의 configmap-patch.yaml에 서비스명 추가:   
-     26 +  # ----- 서비스명 패치 (namePrefix: dev- 반영) ----- k8s/overlays/dev/patches/configmap-patch.yaml                                                                                                                                                                     
      27 +  SPRING_KAFKA_BOOTSTRAP_SERVERS: "dev-kafka:9092"                                                                                                                                                                        
      28 +  SPRING_ELASTICSEARCH_URIS: "http://dev-elasticsearch:9200"                                                                                                                                                              
      29 +  SPRING_DATA_REDIS_HOST: "dev-redis"        
● 이제 재배포:

## 재배포
./deploy.sh dev apply

## Pod 재시작 (ConfigMap 변경 반영)
kubectl rollout restart deployment dev-myapp -n myapp-dev                                                                                                                                                                         
kubectl rollout restart statefulset dev-kafka -n myapp-dev

## 상태 확인 (30초 정도 기다린 후)
kubectl get pods -n myapp-dev

요약                                                                                                                                                                                                                              
┌─────────────────┬──────────────────────────┬───────────────────────────────────────┐                                                                                                                                            
│      문제       │           원인           │                 해결                  │                                                                                                                                            
├─────────────────┼──────────────────────────┼───────────────────────────────────────┤                                                                                                                                            
│ myapp 503       │ Redis/Kafka/ES 연결 실패 │ ConfigMap에 dev- prefix 추가          │                                                                                                                                            
├─────────────────┼──────────────────────────┼───────────────────────────────────────┤                                                                                                                                            
│ Kafka CrashLoop │ Zookeeper 못찾음         │ kafka-patch.yaml로 dev-zookeeper 지정 │                                                                                                                                            
└─────────────────┴──────────────────────────┴───────────────────────────────────────┘                                                                                                                                            
namePrefix를 사용하면 모든 내부 서비스 참조도 함께 패치해야 합니다.  


# myapp ready가 0/1인 현상 
● 문제를 찾았습니다!

원인:
- 앱 시작에 46초 소요
- Liveness probe: delay=30s, timeout=1s, failure=3
- 30초 후 체크 시작하는데, 앱이 아직 시작 중이라 실패 → 컨테이너 재시작

로그에서 Graceful shutdown complete가 보이는 건 Kubernetes가 liveness 실패로 컨테이너를 죽이는 것입니다.

해결책: Liveness probe의 initialDelaySeconds를 늘리거나 startupProbe를 추가해야 합니다. 

-- deployment에서 수정 필요
livenessProbe:                                                                                                                                                                                                                    
initialDelaySeconds: 60  # 30 → 60으로 변경

--또는 startupProbe 추가 (권장)
startupProbe:                                                                                                                                                                                                                     
httpGet:                                                                                                                                                                                                                        
path: /actuator/health                                                                                                                                                                                                        
port: 8080                                                                                                                                                                                                                    
failureThreshold: 30                                                                                                                                                                                                            
periodSeconds: 10                                                                                                                                                                                                               
● Update(k8s/overlays/dev/patches/deployment-patch.yaml)                                                                                                                                                                            
⎿  Added 40 lines       

```
30            env:                                                                                                                                                                                                            
31              - name: SPRING_PROFILES_ACTIVE                                                                                                                                                                                
32                value: "dev"                                                                                                                                                                                                
33 +                                                                                                                                                                                                                          
34 +          # ----- 개발 환경 리소스 (낮은 사양으로 시작 느림) -----                                                                                                                                                        
35 +          resources:                                                                                                                                                                                                      
36 +            requests:                                                                                                                                                                                                     
37 +              memory: "128Mi"                                                                                                                                                                                             
38 +              cpu: "100m"                                                                                                                                                                                                 
39 +            limits:                                                                                                                                                                                                       
40 +              memory: "256Mi"                                                                                                                                                                                             
41 +              cpu: "250m"                                                                                                                                                                                                 
42 +                                                                                                                                                                                                                          
43 +          # ----- Startup Probe -----                                                                                                                                                                                     
44 +          # 앱 시작 완료까지 liveness/readiness 체크 보류                                                                                                                                                                 
45 +          # 최대 300초(5분) 대기 (failureThreshold * periodSeconds)                                                                                                                                                       
46 +          startupProbe:                                                                                                                                                                                                   
47 +            httpGet:                                                                                                                                                                                                      
48 +              path: /actuator/health                                                                                                                                                                                      
49 +              port: 8080                                                                                                                                                                                                  
50 +            failureThreshold: 30                                                                                                                                                                                          
51 +            periodSeconds: 10                                                                                                                                                                                             
52 +                                                                                                                                                                                                                          
53 +          # ----- Liveness Probe (오버라이드) -----                                                                                                                                                                       
54 +          # startupProbe 성공 후에만 동작                                                                                                                                                                                 
55 +          livenessProbe:                                                                                                                                                                                                  
56 +            httpGet:                                                                                                                                                                                                      
57 +              path: /actuator/health                                                                                                                                                                                      
58 +              port: 8080                                                                                                                                                                                                  
59 +            initialDelaySeconds: 0                                                                                                                                                                                        
60 +            periodSeconds: 10                                                                                                                                                                                             
61 +            timeoutSeconds: 5                                                                                                                                                                                             
62 +            failureThreshold: 3                                                                                                                                                                                           
63 +                                                                                                                                                                                                                          
64 +          # ----- Readiness Probe (오버라이드) -----                                                                                                                                                                      
65 +          readinessProbe:                                                                                                                                                                                                 
66 +            httpGet:                                                                                                                                                                                                      
67 +              path: /actuator/health                                                                                                                                                                                      
68 +              port: 8080                                                                                                                                                                                                  
69 +            initialDelaySeconds: 0                                                                                                                                                                                        
70 +            periodSeconds: 5                                                                                                                                                                                              
71 +            timeoutSeconds: 5                                                                                                                                                                                             
72 +            failureThreshold: 3
```
● 이제 적용하겠습니다.

● Bash(kubectl apply -k /home/lwt/dev/personal/Kubernetes/k8s/overlays/dev)                                                                                                                                                         
⎿  namespace/myapp-dev unchanged         

● myapp 해결됐습니다!

- dev-myapp-5c6c94cd8b-rjtsq: 1/1 Running, 재시작 0회

변경 내용:
- startupProbe 추가: 최대 5분 동안 앱 시작 대기
- liveness/readiness probe의 initialDelaySeconds를 0으로 변경 (startupProbe가 대신 처리)
- timeoutSeconds를 1초 → 5초로 늘림                   

# kibana도 ready 0/1
● 문제를 찾았습니다!

원인: Kibana가 Elasticsearch 연결 설정을 기다리고 있습니다.

로그에서:                                                                                                                                                                                                                         
Kibana has not been configured.                                                                                                                                                                                                   
Go to http://0.0.0.0:5601/?code=713678 to get started.

그리고 환경변수가 ELASTICSEARCH_HOSTS: http://elasticsearch:9200인데, 실제 서비스 이름을 확인해봅시다.   

● Bash(kubectl get svc -n myapp-dev | grep elastic)                                                                                                                                                                                 
⎿  dev-elasticsearch            ClusterIP   10.105.137.138   <none>        9200/TCP,9300/TCP            19h                                                                                                                       
dev-elasticsearch-headless   ClusterIP   None             <none>        9200/TCP,9300/TCP            19h

● 서비스 이름이 dev-elasticsearch인데 Kibana는 elasticsearch:9200으로 연결 시도 중입니다.

Kibana 설정 파일을 확인하고 수정하겠습니다.

● Searched for 1 pattern, read 2 files (ctrl+o to expand)

● namePrefix: dev-가 서비스 이름에 붙어서 dev-elasticsearch가 된 건데, Kibana 환경변수는 그대로 elasticsearch를 참조하고 있습니다.

Kibana 패치 파일을 만들겠습니다.

● Write(k8s/overlays/dev/patches/kibana-patch.yaml)                                                                                                                                                                                 
⎿  Wrote 18 lines to k8s/overlays/dev/patches/kibana-patch.yaml      
```
1  # =============================================================================                                                                                                                                           
2 # Kibana Patch - Dev Environment                                                                                                                                                                                           
3 # =============================================================================                                                                                                                                            
4 # 목적: namePrefix로 인해 변경된 서비스 이름 반영                                                                                                                                                                          
5 # =============================================================================                                                                                                                                            
6 apiVersion: apps/v1                                                                                                                                                                                                        
7 kind: Deployment                                                                                                                                                                                                           
8 metadata:                                                                                                                                                                                                                  
9   name: kibana                                                                                                                                                                                                             
10 spec:                                                                                                                                                                                                                      
… +8 lines (ctrl+o to expand)
```
● Update(k8s/overlays/dev/kustomization.yaml)                                                                                                                                                                                       
⎿  Added 2 lines                       
````
45    - path: patches/resource-patch.yaml                                                                                                                                                                                     
46    # Kafka 서비스 이름 패치 (namePrefix 반영)                                                                                                                                                                              
47    - path: patches/kafka-patch.yaml                                                                                                                                                                                        
48 +  # Kibana Elasticsearch 연결 주소 패치 (namePrefix 반영)                                                                                                                                                                 
49 +  - path: patches/kibana-patch.yaml                      
````
┌────────────┬────────┬────────────────────────────────────────────────┐                                                                                                                                                          
│    Pod     │ Status │                   해결 내용                      │                                                                                                                                                          
├────────────┼────────┼────────────────────────────────────────────────┤                                                                                                                                                          
│ dev-myapp  │ 1/1 ✓  │ startupProbe 추가로 시작 시간 확보                 │                                                                                                                                                          
├────────────┼────────┼────────────────────────────────────────────────┤                                                                                                                                                          
│ dev-kibana │ 1/1 ✓  │ ELASTICSEARCH_HOSTS를 dev-elasticsearch로 수정   │                                                                                                                                                          
└────────────┴────────┴────────────────────────────────────────────────┘                                                                                                                                                          
요약:
- k8s/overlays/dev/patches/deployment-patch.yaml - myapp startupProbe 추가
- k8s/overlays/dev/patches/kibana-patch.yaml - 새로 생성, ES 주소 패치
- k8s/overlays/dev/kustomization.yaml - kibana 패치 등록                                                                                                                                                                          
                                                               

# 접속 방법

1. Port Forward (가장 간단)                                                                                                                                                                                                       
   kubectl port-forward -n myapp-dev svc/dev-myapp-service 8080:80                                                                                                                                                                   
   그 후 http://localhost:8080 접속

2. Ingress 사용                                                                                                                                                                                                                   
   hosts 파일에 추가 필요:                                                                                                                                                                                                           
   echo "192.168.49.2 dev.myapp.local dev.kibana.local" | sudo tee -a /etc/hosts                                                                                                                                                     
   그 후 http://dev.myapp.local 접속

3. minikube service (minikube 전용)                                                                                                                                                                                               
   minikube service dev-myapp-service -n myapp-dev                                                                                                                                                                                   
                                                 