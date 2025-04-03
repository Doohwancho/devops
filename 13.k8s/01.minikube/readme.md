# B. how
## B.1. install
```
# Homebrew로 설치
brew install minikube

# 또는 바이너리 직접 다운로드
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/

# kubectl 설치
brew install kubectl
```

## B.2. run
```
# Docker 드라이버로 시작
minikube start --driver=docker

# 또는 VirtualBox 드라이버로 시작 (설치되어 있는 경우)
minikube start --driver=virtualbox

# 리소스 할당 지정
minikube start --memory=4096 --cpus=2
```

## B.3. 상태확인
```
# Minikube 상태 확인
minikube status

# 노드 확인
kubectl get nodes

# 클러스터 정보 확인
kubectl cluster-info
```
## B.4. 간단 실습
### B.4.1. 간단한 앱 배포
```
# Nginx 배포
kubectl create deployment nginx --image=nginx

# 배포 확인
kubectl get deployments
kubectl get pods

# 서비스 노출
kubectl expose deployment nginx --port=80 --type=NodePort

# 서비스 확인
kubectl get services
```

### B.4.2. 서비스 접속
```
# 서비스 URL 얻기
minikube service nginx --url

# 브라우저에서 서비스 열기
minikube service nginx
```


### B.4.3. 대시보드 활성화 및 접속
```
# 대시보드 애드온 활성화
minikube addons enable dashboard

# metric 활성화
minikube addons enable metrics-server

# 대시보드 실행
minikube dashboard
```

### B.4.4. 인그레스 컨트롤러 설정
```
# 인그레스 애드온 활성화
minikube addons enable ingress

# 간단한 인그레스 규칙 생성
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  rules:
  - host: nginx.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF

# 인그레스 확인
kubectl get ingress
```

### B.4.5. 로그 확인 및 디버깅
```
# 파드 로그 확인
kubectl logs $(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}")

# 파드 내부 접속
kubectl exec -it $(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}") -- /bin/bash
```

### B.4.6. minikube 정리하기
```
# Minikube 중지
minikube stop

# Minikube 삭제 (모든 리소스 제거)
minikube delete --all --purge
```

