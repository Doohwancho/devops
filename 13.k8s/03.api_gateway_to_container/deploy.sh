#!/bin/bash

# 이미지 빌드
docker build -t my-fastapi-app .

# Minikube에 이미지 로드 (Minikube 사용 시)
minikube image load my-fastapi-app:latest

# K8s 리소스 적용
kubectl apply -f k8s-fastapi.yaml
kubectl apply -f k8s-ingress.yaml

# Ingress 적용 확인
echo "Waiting for Ingress to be ready..."
sleep 5
kubectl get ingress

# 호스트 파일 설정 안내
echo "Add the following line to your /etc/hosts file:"
echo "$(minikube ip) fastapi.local"

# Minikube Tunnel 실행 안내
echo "Run 'minikube tunnel' in a separate terminal to enable Ingress access"