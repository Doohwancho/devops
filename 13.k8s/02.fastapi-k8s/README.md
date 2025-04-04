# what 

ML-Ops practice (fastapi + mongodb + ELK on k8s)

1. k8s에서 간단한 webapp + ELK for logging run
2. terminal에서 send http GET create user, get user request
3. mongo-express에서 데이터 잘 들어왔는지 확인 
4. logstash, elastic cache에 log가 쌓였는지 확인 
5. kibana dashboard에서 로그 visualize

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

# 이제 localhost:80번 포트로 fastapi 에 GET 요청 보낼 수 있다. 
curl http://localhost:80


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

### 8-1. fastapi로 POST create_user 해놓고, get_users 해보자
```bash
# 유저 생성
curl -X POST http://localhost:80/create_user/ \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "doohwan",
    "Age": 20,
    "Occupation": "developer",
    "Learning": "k8s"
  }'

# 생성된 유저 확인
curl -X GET http://localhost:80/get_users/doohwan
```

그러면 mongo-express web page에 "my_db" 데이터베이스가 추가되면서,

collection을 보면 추가된걸 확인할 수 있다. 



## step9. fastapi에서 log가 잘 작동해서 elk에서 저장됬는지 확인
POST create user, GET user 했을 때, 적은 로그를 키바나로 보자.

먼저 로그가 찍혔는지 확인해보자. 


또한, fastapi 내부에 로그를 보면, create user, get user시 로그도 확인할 수 있다. 
```bash
kubectl get pod
kubectl logs fastapi-deployment-956cb4b4b-9746n

INFO:     Started server process [1]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
DB Connection successful
INFO:     10.244.0.1:41490 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:41570 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:41720 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:41784 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:41930 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:41992 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:42212 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:42276 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:42422 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:42484 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:42632 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:42694 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:42854 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:42922 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:43078 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:43140 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:5793 - "GET / HTTP/1.1" 200 OK
INFO:     10.244.0.1:5793 - "GET /favicon.ico HTTP/1.1" 404 Not Found
INFO:     10.244.0.1:43364 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:43438 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:43604 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:43666 - "GET /health HTTP/1.1" 200 OK
{"asctime": "2025-04-04 08:35:25", "levelname": "INFO", "name": "app", "message": "Creating user: doohwan", "hostname": "fastapi-deployment-956cb4b4b-9746n"}
{"asctime": "2025-04-04 08:35:25", "levelname": "INFO", "name": "app", "message": "User created successfully: doohwan", "hostname": "fastapi-deployment-956cb4b4b-9746n"}
INFO:     10.244.0.1:14398 - "POST /create_user/ HTTP/1.1" 200 OK
INFO:     10.244.0.1:43824 - "GET /health HTTP/1.1" 200 OK
{"asctime": "2025-04-04 08:35:30", "levelname": "INFO", "name": "app", "message": "Fetching user: doohwan", "hostname": "fastapi-deployment-956cb4b4b-9746n"}
{"asctime": "2025-04-04 08:35:30", "levelname": "INFO", "name": "app", "message": "User found: doohwan", "hostname": "fastapi-deployment-956cb4b4b-9746n"}
INFO:     10.244.0.1:9563 - "GET /get_users/doohwan HTTP/1.1" 200 OK
INFO:     10.244.0.1:43890 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:44036 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:44100 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:44256 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:44330 - "GET /health HTTP/1.1" 200 OK
INFO:     10.244.0.1:44492 - "GET /health HTTP/1.1" 200 OK
``` 



먼저 logstash에 user create & get 로그가 있는지 확인해보자 
```bash 
kubectl logs deployment/logstash-deployment

...
{
       "@version" => "1",
           "tags" => [
        [0] "fastapi",
        [1] "_jsonparsefailure"
    ],
           "type" => "python-logstash",
     "@timestamp" => 2025-04-04T08:55:35.224Z,
    "logger_name" => "app",
           "host" => "fastapi-deployment-956cb4b4b-rh2c6",
       "hostname" => "fastapi-deployment-956cb4b4b-rh2c6",
          "level" => "INFO",
        "message" => "User created successfully: doohwan",
           "path" => "/code/main.py",
           "port" => 45084
}
{
       "@version" => "1",
           "tags" => [
        [0] "fastapi",
        [1] "_jsonparsefailure"
    ],
           "type" => "python-logstash",
     "@timestamp" => 2025-04-04T08:55:38.478Z,
    "logger_name" => "app",
           "host" => "fastapi-deployment-956cb4b4b-rh2c6",
       "hostname" => "fastapi-deployment-956cb4b4b-rh2c6",
          "level" => "INFO",
        "message" => "Fetching user: doohwan",
           "path" => "/code/main.py",
           "port" => 45084
}
...
```
logstash log에 적혀있다. 


elastic에 인덱스가 있는지 확인하자 (fastapi-logs-2025.04.04)
```bash
curl http://localhost:9200/_cat/indices\?v

health status index                           uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases                TsxaVGWOROaniSqesEFslA   1   0         39            0     36.7mb         36.7mb
green  open   .apm-custom-link                FpMhkTpITN-ERkqUOvD_gg   1   0          0            0       208b           208b
green  open   .kibana-event-log-7.15.2-000001 5HPzWTDrRlCeqIiLP8p_Rw   1   0          1            0      5.9kb          5.9kb
green  open   .apm-agent-configuration        9zMcFyMFTRuVWjqMfC7h8g   1   0          0            0       208b           208b
yellow open   fastapi-logs-2025.04.04         j3jHuKrdQ8WiWqmJhylyWw   1   1          4            0     11.2kb         11.2kb
green  open   .kibana_7.15.2_001              ZSzssGiiRXiPj4T5ywXa5g   1   0         11            0      2.3mb          2.3mb
green  open   .kibana_task_manager_7.15.2_001 mDr98G5pQtyXH8jibApHWQ   1   0         15          237      123kb          123kb
```

`fastapi-logs-2025.04.04`가 있는걸 확인!

```bash
# fastapi-logs 인덱스 확인
curl http://localhost:9200/fastapi-logs-*/_search?pretty
```
이러면 elastic cache에 로그 찍힌걸 볼 수 있다.






## step10. kibana test
로그 저장된걸 확인했으니까, kibana에서 로그 저장된걸 보자.

```bash
# Kibana 테스트 (로그 시각화)
minikube service kibana-service
```

1. Index Pattern 생성
```
1. 왼쪽 메뉴에서 "Stack Management" 클릭 (⚙️ 아이콘)
2. "Index Patterns" 클릭
3. "Create index pattern" 버튼 클릭
4. Index pattern name에 "fastapi-logs-*" 입력
5. "Next step" 클릭
6. Time field에서 "@timestamp" 선택
7. "Create index pattern" 클릭
```

2. Discover에서 로그 확인
```
1. 왼쪽 메뉴에서 "Discover" 클릭
2. 상단의 인덱스 패턴 선택기에서 "fastapi-logs-*" 선택
3. 시간 범위를 우측 상단에서 "Last 15 minutes" 또는 적절한 범위로 설정

4. 유용한 필드 선택 (왼쪽 Available Fields에서):
   - message
   - level
   - logger_name
   - hostname
   - @timestamp
```

3. 대시보드 생성
```
1. 왼쪽 메뉴에서 "Dashboard" 클릭
2. "Create new dashboard" 클릭
3. "Create visualization" 클릭
4. 다음과 같은 시각화 추가:

   a. 로그 레벨 분포 (파이 차트)
   - Metrics: Count of records
   - Buckets: Split slices -> Aggregation: Terms -> Field: level.keyword

   b. 시간별 로그 발생량 (라인 차트)
   - Metrics: Count of records
   - Buckets: X-axis -> Aggregation: Date Histogram -> Field: @timestamp

   c. 최근 로그 메시지 (Data Table)
   - Metrics: Count of records
   - Buckets: Split rows -> Aggregation: Terms -> Field: message.keyword
```

테스트 로그 더 생성 
```bash
# 여러 번 API 호출하여 로그 생성
curl -X POST http://localhost:80/create_user/ \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "user1",
    "Age": 25,
    "Occupation": "developer",
    "Learning": "elk"
  }'

curl -X GET http://localhost:80/get_users/user1
```


## step11. stop & delete 
```bash
# Stop minikube
minikube stop

# Delete minikube cluster
minikube delete
```
