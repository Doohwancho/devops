# what 

ML-Ops practice (fastapi + mongodb + elk on k8s)

[resource](https://github.com/deshwalmahesh/fastapi-kubernetes/tree/main)

# how 

## step1. install 
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Docker Desktop for Mac (M1)
brew install --cask docker

# Install kubectl
brew install kubectl

# Install minikube
brew install minikube
```

## step2. 로컬 이미지 빌드 
```bash
# 로컬 이미지 빌드
docker build -t fastapi-image-test-k8 ./fastapi_code/.

# 도커허브용으로 태그 달기
docker tag fastapi-image-test-k8 doohwancho/fastapi-image-test-k8

# 도커허브에 푸시 (먼저 docker login 해야됨)
docker login
docker push doohwancho/fastapi-image-test-k8
```

docker login을 github 연동으로 한 경우, 
1. account settings
2. personal access token
3. read & write 권한으로 하나 발급받아서
4. docker login으로 로그인 (password는 발급받은 토큰으로 입력)
5. `docker push doohwancho/fastapi-image-test-k8`
6. dockerhub -> myhub -> doohwancho/fastapi-image-test-k8 확인


## step3. set docker setting 

로컬에 k8s로 fastapi + mongodb + express + elk 빌드할 때 필요 리소스가 많다.

avg load core수는 10개,\
메모리도 넉넉하게 잡아줘야 한다.

따라서, docker -> preference -> 

1. cpu : 7core
2. memory : 12gib
3. swap: 3gib
4. disk image size: 40gib

보니까 ram / swap / disk 메모리는 좀 적어도 되는 듯 하는데, cpu는 4로 하면 터짐.


## step4. start minikube
```bash
# Start minikube with docker driver
# 내 컴퓨터 기준 돌아가는 스펙 
minikube start --cpus=7 --memory=11500 --disk-size=40g

# Enable ingress addon for routing
minikube addons enable ingress
```


## step5. run `./deploy.sh`
```bash
./deploy.sh
```

주의!\
만약 doohwancho가 아닌 본인 이름의 docker image를 만들었을 경우,\
deploy.sh에 doohwancho -> 본인 이름으로 전부 수정해주기 


## step6. 상태확인 
```bash
minikube ip

kubectl get pods
kubectl get services
minikube dashboard &  # k8s 대시보드 열림

# Check logs if needed
kubectl logs <pod-name>
```

## step7. fastAPI test 
```bash
# 새 터미널 열고 (ingress routing 설정 했나?)
# LoadBalancer 타입 서비스들한테 external IP 할당해주는 역할
# 맥에서 docker driver 쓸 때는 tunnel이 좀 까다로움
# 실제 운영환경(AWS, GCP 같은데)에서는 잘 됨
sudo minikube tunnel

# 다른 터미널에서 load balancer로 접근하기 (실패)
curl http://localhost:30000/


# 포트포워딩으로 접근하는법 
# 터미널1에서
kubectl port-forward service/fastapi-app-service 8000:80

# 터미널2에서
curl http://localhost:8000/
curl http://localhost:8000/health
```

```bash
# 제일 쉬운 서비스로 접근하기
# FastAPI 테스트
minikube service fastapi-app-service
```

## step8. mongo-express test 
Q. what is mongo-express?\
A. 몽고DB 관리용 웹 인터페이스. 데이터베이스 구조를 빠르게 확인하거나 테스트할 때 유용함.

```bash
# Mongo Express 테스트 (DB 관리 GUI)
minikube service mongo-express-service

id: admin
password: pass
```

## step9. kibana test 
```bash
# Kibana 테스트 (로그 시각화)
minikube service kibana-service
```


## step10. elastic search test 
```bash
# Elasticsearch 테스트
minikube service elasticsearch-service
```


## step11. stop & delete 
```bash
# Stop minikube
minikube stop

# Delete minikube cluster
minikube delete
```
