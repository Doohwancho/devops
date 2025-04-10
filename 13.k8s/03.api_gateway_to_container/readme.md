# what 
k8s환경에서 api-gateway와 컨테이너와 통신하는 간단한 실험 

계속 안되길래 최소화 해서 한번 해봄. 

# how to test?
```bash
minikube delete

minikube start 

minikube addons enable ingress

./deploy.sh

kubectl get pod

minikube tunnel

# nginx까지 요청은 가지만 404에러뜨고 실패함. fastapi까지 가지 않음.
curl -v http://localhost:80/ 

# 성공함. 호스트를 적어줘야 ingress controller(nginx)가 이걸 기반으로 /etc/hosts 에서 읽고 redirect 해준다.
curl -v -H "Host: fastapi.local" http://localhost:80/
```