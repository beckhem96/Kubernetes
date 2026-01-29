# Kubernetes 배포 트러블슈팅 기록

**날짜**: 2026-01-27
**프로젝트**: Kubernetes (Spring Boot + Kafka + ELK + Redis on Minikube)

---

## 주요 내용

### 1. 초기 문제: Minikube 연결 실패
```
error validating data: dial tcp 192.168.49.2:8443: i/o timeout
```
**원인**: minikube가 실행 중이 아님
**해결**: `minikube start`

---

### 2. Pod 접속 문제
`localhost:8080`으로 접속 불가

**원인**: Kubernetes는 Docker Compose와 다르게 직접 포트 노출 안됨
**해결 방법**:
- Port-forward: `kubectl port-forward svc/dev-myapp-service 8080:80 -n myapp-dev`
- 또는 Ingress 설정 후 `/etc/hosts`에 도메인 추가

---

### 3. Kafka CrashLoopBackOff
```
UnknownHostException: zookeeper
```
**원인**: `namePrefix: dev-` 때문에 서비스명이 `dev-zookeeper`로 변경됨
**해결**: `k8s/overlays/dev/patches/kafka-patch.yaml` 추가
```yaml
env:
  - name: KAFKA_ZOOKEEPER_CONNECT
    value: "dev-zookeeper:2181"
  - name: KAFKA_ADVERTISED_LISTENERS
    value: "PLAINTEXT://dev-kafka:9092,INTERNAL://dev-kafka:9093"
```

---

### 4. myapp ErrImageNeverPull
**원인**: `imagePullPolicy: Never` 설정인데 minikube Docker에 이미지 없음
**해결**:
```bash
eval $(minikube docker-env)
docker build -t myapp:latest .
```

---

### 5. myapp 503 SERVICE_UNAVAILABLE (Health Check 실패)
**원인 1**: ConfigMap에서 서비스명이 `redis`, `kafka`, `elasticsearch`로 되어있음
**해결**: `configmap-patch.yaml`에 서비스명 패치 추가
```yaml
SPRING_KAFKA_BOOTSTRAP_SERVERS: "dev-kafka:9092"
SPRING_ELASTICSEARCH_URIS: "http://dev-elasticsearch:9200"
SPRING_DATA_REDIS_HOST: "dev-redis"
```

**원인 2**: Elasticsearch Health Indicator 실패
```
Missing required property 'HealthResponse.unassignedPrimaryShards'
```
**해결**: ES health check 비활성화
```yaml
MANAGEMENT_HEALTH_ELASTICSEARCH_ENABLED: "false"
```

---

## 수정된 파일

| 파일 | 변경 내용 |
|-----|----------|
| `k8s/overlays/dev/patches/kafka-patch.yaml` | 신규 생성 - Kafka 서비스명 패치 |
| `k8s/overlays/dev/patches/configmap-patch.yaml` | 서비스명 + ES health check 비활성화 추가 |
| `k8s/overlays/dev/kustomization.yaml` | kafka-patch.yaml 참조 추가 |

---

## 핵심 교훈

> **Kustomize의 `namePrefix`를 사용하면 모든 내부 서비스 참조(환경변수, 설정)도 함께 패치해야 한다.**

---

## 다음 할 일

- [ ] 재배포 후 myapp 정상 동작 확인
  ```bash
  ./deploy.sh dev apply
  kubectl rollout restart deployment dev-myapp -n myapp-dev
  kubectl get pods -n myapp-dev -w
  ```
- [ ] `localhost:8080` 접속 테스트
  ```bash
  kubectl port-forward svc/dev-myapp-service 8080:80 -n myapp-dev
  ```
- [ ] prod overlay에도 동일한 서비스명 패치 적용 검토
- [ ] Elasticsearch 클라이언트 버전 호환성 확인 (health check 재활성화 가능 여부)